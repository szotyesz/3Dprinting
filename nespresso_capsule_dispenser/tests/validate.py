#!/usr/bin/env python3
"""Real OpenSCAD renders and mesh/input checks; no third-party Python packages.

Run: python3 tests/validate.py [--output /tmp/nespresso-validation]
Outputs meshes/logs/report outside the source tree by default. No physical
feeding, slicer, structural or stability certification is implied.
"""
import argparse
from collections import Counter, defaultdict
from concurrent.futures import ThreadPoolExecutor
import json
import math
from pathlib import Path
import re
import subprocess
import tempfile

SOURCE = Path(__file__).resolve().parents[1] / "nespresso_capsule_dispenser.scad"


def render(root, name, settings, extension="stl", source=SOURCE):
    output = root / f"{name}.{extension}"
    output.unlink(missing_ok=True)  # Never mistake a stale mesh for success.
    command = ["openscad", "--hardwarnings", "-o", str(output)]
    if extension == "stl":
        command += ["--export-format", "asciistl"]
    for key, value in settings.items():
        command += ["-D", f"{key}={value}"]
    result = subprocess.run(command + [str(source)], capture_output=True, text=True, timeout=300)
    log = result.stdout + result.stderr
    (root / f"{name}.log").write_text(log)
    return output, log, result.returncode


def mesh_info(path):
    vertices = [tuple(map(float, line.split()[1:])) for line in path.read_text().splitlines()
                if line.strip().startswith("vertex ")]
    assert vertices and len(vertices) % 3 == 0, f"{path.name}: empty/malformed STL"
    triangles = [vertices[i:i+3] for i in range(0, len(vertices), 3)]
    edges = Counter()
    directed = Counter()
    neighbors = defaultdict(set)
    signed_volume = 0
    for a, b, c in triangles:
        cross = (b[1]*c[2]-b[2]*c[1], b[2]*c[0]-b[0]*c[2], b[0]*c[1]-b[1]*c[0])
        signed_volume += sum(a[i]*cross[i] for i in range(3)) / 6
        assert len({a, b, c}) == 3, f"{path.name}: degenerate triangle"
        for u, v in ((a,b), (b,c), (c,a)):
            edges[tuple(sorted((u,v)))] += 1
            directed[(u,v)] += 1
            neighbors[u].add(v)
            neighbors[v].add(u)
    assert all(count == 2 for count in edges.values()), f"{path.name}: non-manifold/open edges"
    assert all(directed[(v,u)] == count for (u,v), count in directed.items()), f"{path.name}: inconsistent winding"
    assert signed_volume > 0, f"{path.name}: nonpositive volume"
    remaining = set(neighbors)
    components = 0
    while remaining:
        todo = [remaining.pop()]
        components += 1
        while todo:
            for neighbor in neighbors[todo.pop()]:
                if neighbor in remaining:
                    remaining.remove(neighbor)
                    todo.append(neighbor)
    low = [min(v[i] for v in vertices) for i in range(3)]
    high = [max(v[i] for v in vertices) for i in range(3)]
    return dict(bounds_min=low, bounds_max=high, dimensions=[high[i]-low[i] for i in range(3)],
                components=components, volume_mm3=round(signed_volume, 3), triangles=len(triangles))


def canonical_mesh(path):
    # CGAL may reorder STL facets across processes, even for identical solids.
    vertices = [tuple(map(float, line.split()[1:])) for line in path.read_text().splitlines()
                if line.strip().startswith("vertex ")]
    return sorted(tuple(sorted(vertices[i:i+3])) for i in range(0, len(vertices), 3))


def check_intersections(root):
    # Use actual parametric parts, rather than approximate bounding boxes.
    prefix = SOURCE.read_text().rsplit("\nvalidate() {", 1)[0]
    intersections = {
        "lower_upper": "intersection(){ lower_element(); translate([0,lower_path,0]) upper_element(); }",
        "upper_upper": "intersection(){ upper_element(); translate([0,upper_path,0]) upper_element(); }",
        "base_lower": "intersection(){ translate([0,0,pad_height]) base(); installed() lower_element(); }",
        "cover_base": "intersection(){ base(); translate([8,8,base_thickness-3]) ballast_cover(); }",
        "brace_lower": "intersection(){ installed() lower_element(); translate([(base_width-overall_width)/2-2,panel_y,base_mount_height+support_y(lower_module_length)-12]) brace(); }",
    }

    def check(case):
        name, body = case
        source = root / f"intersection_{name}.scad"
        source.write_text(prefix + "\n" + body)
        path, log, _ = render(root, f"intersection_{name}", {}, source=source)
        assert "ERROR:" not in log, f"Intersection evaluation error: {name}"
        if "top level object is empty" not in log.lower():
            # CGAL can preserve an intentional coplanar bearing/contact face
            # and warn that this zero-thickness intersection is not a solid.
            # Accept ONLY a planar contact; any positive thickness still fails.
            vertices = [tuple(map(float, line.split()[1:])) for line in path.read_text().splitlines()
                        if line.strip().startswith("vertex ")]
            assert vertices, f"Unexplained intersection result: {name}"
            dimensions = [max(v[i] for v in vertices)-min(v[i] for v in vertices) for i in range(3)]
            assert min(dimensions) < 1e-5, f"Solid interference at {name}: {dimensions}"
            warnings = [line for line in log.splitlines() if "WARNING:" in line]
            assert all("may not be a valid 2-manifold" in line for line in warnings), log
        else:
            assert "WARNING:" not in log, f"Intersection evaluation warning: {name}"
        print(f"PASS no solid interference {name}", flush=True)
        return f"no solid intersection: {name}"

    with ThreadPoolExecutor(max_workers=3) as pool:
        return list(pool.map(check, intersections.items()))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    root = args.output or Path(tempfile.mkdtemp(prefix="nespresso-validation-"))
    root.mkdir(parents=True, exist_ok=True)
    print(f"Validation artifacts: {root}", flush=True)
    report = {"openscad": subprocess.check_output(["openscad", "--version"], stderr=subprocess.STDOUT, text=True).strip(),
              "parts": {}, "rejections": [], "checks": []}

    valid = [(f"{part}_{n}", {"part": json.dumps(part), "number_of_lines": str(n)})
             for n in range(1,6) for part in ("lower", "upper", "base", "ballast_cover")]
    valid += [(part, {"part": json.dumps(part)}) for part in
              ("brace", "fit_coupon", "joint_coupon", "outlet_prototype")]

    def check_valid(case):
        name, settings = case
        path, log, code = render(root, name, settings)
        assert code == 0 and not re.search(r"WARNING:|ERROR:", log), f"{name}: see {name}.log"
        info = mesh_info(path)
        assert info["components"] == (2 if name == "joint_coupon" else 1), f"{name}: disconnected geometry"
        assert abs(info["bounds_min"][2]) < 1e-5, f"{name}: not on bed"
        assert all(lo >= -1e-5 for lo in info["bounds_min"]), f"{name}: outside positive octant"
        assert all(d <= limit + 1e-4 for d, limit in zip(info["dimensions"], (225,225,235))), f"{name}: oversize mesh"
        bounds = re.search(r"part_bounds_mm = (\[[^\n]+\])", log)
        expected = json.loads(bounds[1])
        assert all(actual <= declared+1e-4 for actual, declared in zip(info["bounds_max"], expected)), f"{name}: underreported bounds"
        if name.startswith(("lower_", "upper_")):
            n = int(settings["number_of_lines"])
            assert math.isclose(info["dimensions"][0], 20+n*37.8+(n-1)*3, abs_tol=1e-4)
            assert math.isclose(info["dimensions"][1], 220-(0.1 if name.startswith("upper") else 0), abs_tol=1e-4)
        print(f"PASS render/mesh {name}", flush=True)
        return name, info

    with ThreadPoolExecutor(max_workers=3) as pool:
        for name, info in pool.map(check_valid, valid):
            report["parts"][name] = info

    invalid = []
    for parameter, values in {
        "number_of_lines": ["0", "-1", "6", "1.5", '"3"', "true", "undef"],
        "number_of_upper_elements": ["-1", "1.5", '"1"', "false", "undef"],
        "part": ['"unknown"', '"assembly_preview"'],
        "installation_mode": ['"unknown"'],
        "lower_module_length": ["50", "230"],
        "upper_module_length": ["30", "230"],
        "joint_overlap": ["5", "220"],
        "lip_overlap": ["0.2", "5"],
        "backplate_thickness": ["0", "-1", '"thick"'],
        "rim_thickness_max": ["0.1"], "seam_gap": ["0.5"],
        "capsule_depth_max": ["1"], "rim_diameter_min": ["35"],
        "connector_revision": ["2"], "joint_clearance": ["0.3"],
        "base_depth": ["150"], "bed_x": ['"wide"'],
        "divider_width": ["0"], "ballast_mass": ["-1"],
    }.items():
        for value in values:
            settings = {parameter: value}
            if parameter == "upper_module_length":
                settings["part"] = '"upper"'
            invalid.append(settings)
    invalid += [dict(number_of_lines="5", divider_width="8"),
                dict(number_of_lines="5", brim_reserve="10"),
                dict(number_of_lines="5", rim_diameter_max="40"),
                dict(bed_x="50"), dict(part='"brace"', bed_z="40")]
    for i, settings in enumerate(invalid):
        path, log, _ = render(root, f"reject_{i}", settings)
        assert "ERROR: Assertion" in log and "WARNING:" not in log, f"Missing useful rejection: {settings}"
        assert not path.exists() or "vertex " not in path.read_text(), f"Rejected case exported usable mesh: {settings}"
        report["rejections"].append(settings)
    print(f"PASS {len(invalid)} invalid parameter cases", flush=True)

    # Advanced dimensions must recalculate the lane limit, without silently
    # resizing a capsule path or truncating the requested number of lanes.
    for name, settings in {
        "larger_rim": dict(number_of_lines="4", rim_diameter_min="37.6", rim_diameter_max="38"),
        "wider_divider": dict(number_of_lines="4", divider_width="5"),
        "larger_brim": dict(number_of_lines="4", brim_reserve="10", lower_module_length="210", upper_module_length="210"),
    }.items():
        _, log, code = render(root, name, settings, "csg")
        assert code == 0 and not re.search(r"WARNING:|ERROR:", log)
        assert "max_lines = 4" in log
        report["checks"].append(f"recalculated lane limit: {name}")

    # Repeated upper mesh must be independent of the selected stack size and
    # diagnostic capsules. Full assembly is deliberately not STL exportable.
    baseline = canonical_mesh(root / "upper_3.stl")
    for uppers in (0,2,12):
        path, log, code = render(root, f"upper_count_{uppers}",
            dict(part='"upper"', number_of_upper_elements=str(uppers), show_capsules="true"))
        assert code == 0 and "ERROR:" not in log and "WARNING:" not in log
        assert canonical_mesh(path) == baseline, "Upper geometry depends on stack count or preview capsules"
    report["checks"].append("upper STL invariant for upper counts 0, 1, 2, 12 and show_capsules=true")
    for uppers in (0,1,2,12):
        _, log, code = render(root, f"assembly_{uppers}",
            dict(part='"assembly_preview"', number_of_upper_elements=str(uppers), **{"$preview":"true"}), "csg")
        assert code == 0 and not re.search(r"WARNING:|ERROR:", log)
        assert "support required for ALL configurations" in log
    report["checks"].append("assembly previews 0, 1, 2, 12 uppers; explicit support required")

    report["checks"].extend(check_intersections(root))
    (root / "report.json").write_text(json.dumps(report, indent=2)+"\n")
    print(f"PASS all checks; report: {root / 'report.json'}", flush=True)


if __name__ == "__main__":
    main()

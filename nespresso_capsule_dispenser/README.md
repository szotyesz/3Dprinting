# Modular Nespresso capsule dispenser

Open [`nespresso_capsule_dispenser.scad`](nespresso_capsule_dispenser.scad) in
OpenSCAD 2021.01 or later. This is a **digitally checked prototype**, assuming
Nespresso Original capsules. Capsule measurements, brand compatibility, actual
nozzle, PETG brand, slicer profile, installation constraints and physical test
results have not been supplied. The defaults are examples, not measured fits.

The [original implementation plan](nespresso_capsule_dispenser.md) remains the
physical acceptance procedure. Its instructions restricting changes to Markdown
describe the earlier planning task; the implementation is now in the SCAD file.

## Select and export parts

Use `part` in the Customizer, F6 to render, then export STL. Each part is already
oriented for printing at **100% scale**. The source has no external dependencies.
From this directory, for example:

```bash
openscad -o /tmp/lower.stl -D 'part="lower"' nespresso_capsule_dispenser.scad
openscad -o /tmp/upper.stl -D 'part="upper"' nespresso_capsule_dispenser.scad
openscad -o /tmp/base.stl -D 'part="base"' nespresso_capsule_dispenser.scad
openscad -o /tmp/cover.stl -D 'part="ballast_cover"' nespresso_capsule_dispenser.scad
openscad -o /tmp/brace.stl -D 'part="brace"' nespresso_capsule_dispenser.scad
```

| Selection | Quantity | Purpose / print orientation |
| --- | --- | --- |
| `lower` | 1 | Seats and lift-out outlets; backplate down |
| `upper` | `number_of_upper_elements` | Identical open-ended extensions; backplate down |
| `base` | 1 | Gusseted receiver and enclosed ballast cavity; foot down |
| `ballast_cover` | 1 | Bolted, flush cover; broad face down |
| `brace` | 2 per element for the proposed supported installation | Bolted frame support and lateral restraint; foot down |
| `fit_coupon` | At least 1 per fit trial | One short lane with the actual rail profile |
| `joint_coupon` | 1 pair per joint fit trial | Two separate mating pieces on one plate |
| `outlet_prototype` | 1 per outlet trial | Short lower with room for three capsules |
| `assembly_preview` | Display only | F5 assembled view; F6/STL export deliberately rejected |

Coupons always use one lane. For a base-to-outlet-prototype trial, export the base
with `number_of_lines=1` to match the prototype's mounting-hole spacing.

**Paint build-plate-only supports beneath the projecting top tongues** on lower,
upper and joint-coupon parts. Their 20 mm cantilevers start 6 mm above the bed;
they cannot print unsupported in this orientation. The exterior supports are
accessible for removal. Clean the underside bearing faces flat and prove the
support-interface settings on joint coupons before full parts. Block supports
inside capsule grooves and bottom sockets. The sloped capsule lips target
support-free printing, subject to the fit-coupon trial. This first revision uses
local tongue supports rather than achieving the plan's all-part support-free
aspiration.

`show_capsules` adds background mock capsules only to the assembly view. It never
adds geometry to a part export. Use F5 with zero, one and two uppers to inspect
the standalone lower and both types of joint. A CLI CSG preview can be generated
with `-D 'part="assembly_preview"' -D '$preview=true' -o /tmp/assembly.csg`.

## Dimensions and interfaces

`number_of_lines` means side-by-side lanes. The calculated default range is
**1–5**, with widths **57.8, 98.6, 139.4, 180.2 and 221.0 mm**. Compared with the
plan's illustrative width calculation, the outer edges are widened to 10 mm
to provide screw lands. Runtime assertions recalculate the maximum when advanced
parameters or printer reservations change; the Customizer slider is only a hint.

Lower and upper envelopes are 220 mm long and 12 mm thick. The final 20 mm is a
pair of structural tongues; the rail path ends at 200 mm. Upper sockets overlap
these tongues while their rails begin at the previous rail endpoint, leaving
only the deliberate 0.10 mm seam. The bottom socket has a bearing floor at 6 mm;
its unequal left/right widths key the joint. Two bolts prevent separation and
clamp the tongues against the floors. The large shoulder surfaces transfer
compression. Capsule rail clearance and connector clearance are independent.

Each upper adds **200 mm** without changing its own geometry. With 6 mm pads and
the 20 mm base, zero/one/two uppers produce heights **246/446/646 mm**, and planning
capacities **5/10/15 capsules per lane**. These are capacity estimates, not seat
load ratings. The example three-lane, one-upper assembly holds an estimated
30 capsules. Loading allowance includes the exposed structural tongues and the
top rail entry; it is applied once, not at every interface.

Rails support the rim on narrow rear ledges, leaving 0.6 mm nominal foil relief.
The lip underside slopes upward toward the channel, so the narrowest slot is
1.5 mm at its root. The default front opening is 33.4 mm. The outlet lip ends are
calculated from the circular rim's intersection with that opening. A 2 mm curb
retains the resting capsule; the proposed removal is a 3 mm lift then forward
pull. This mechanism must pass the three-capsule trial before printing full parts.

Compatibility marks are shallow notches on the outside top of each structural
edge: left count = lanes, right count = connector revision (currently one).
The projecting tongues point upward. Match lane count, all fit/rail parameters,
module interface dimensions and revision across a stack; notch marks do not
encode arbitrary advanced-parameter edits. Revision 1 is the only supported
revision. Do not mix old prints after changing interface dimensions.

Base dimensions are `max(180, lane width)` × 180 × 60 mm including receiver;
the default is 180 × 180 × 60 mm. The lid's nominal recess is `(base width−16)` ×
82 × 3 mm; the printed lid has 0.2 mm edge clearance. The cavity is
`(base width−40)` × 58 × 14 mm at defaults (113.7 cm³ for three lanes).
**The 1 kg ballast value is a target for calculation, not a promise that a
particular material fits.** Weigh the ballast that actually fits, use dense solid
pieces where needed, secure them against shifting, and update `ballast_mass`.
Loose fill without packing is unsuitable. Ballast is centered approximately at
X = base center, Y = 49 mm, Z = pad height + half the base thickness in the
estimate; replace the mass model if its actual placement differs substantially.

## Hardware and assembly

Hardware dimensions are provisional. Confirm clearances, washer size and bolt
length against the printed parts. Each M3 bolt needs two washers and one locknut.

| Connection | Hardware |
| --- | --- |
| Each lower/upper or upper/upper interface | 2 × M3×18 |
| Lower to base receiver | 4 × M3×30 |
| Ballast cover | 4 × M3×25 |
| Each pair of support brackets | 4 × M3×25, plus 4 substrate-appropriate M4-class anchors |
| Feet | 4 × 20 × 20 × 6 mm non-slip pads, each 5 mm from the nearest base edges |

The feet raise the base enough to clear the cover's underside locknuts and bolt
ends. The four additional base anchor holes are optional; pads are not anchors.

1. Print the fit, joint and outlet trials using the same PETG/profile as the final
   parts. Inspect toolpaths before printing; the full starting profile and tuning
   order are inline at the top of the SCAD source.
2. Fit the pads and immobilize the weighed ballast in the pocket. Secure the lid
   with its four bolts; check that neither hardware nor lid interferes with feet.
3. With all capsules removed, lower the lower element's outer spines into the base
   receiver. Its back faces the rear receiver walls; its body openings face the
   long front portion of the base. Install all four receiver bolts.
4. Place an upper's keyed bottom sockets over the existing top tongues. Fully seat
   shoulders without forcing the rails, then insert both joint bolts front to
   rear and fit washers/locknuts. Check the 0.10 mm seam and aligned sliding faces.
   Repeat with identical uppers as needed. Avoid tightening enough to distort PETG.
5. Install and verify the necessary structural supports before loading. Load foil
   toward the backplate, body toward the user. Test removal at each lane.
6. To extend or dismantle, unload completely, support the frame, remove the
   affected supports and joint locks, and lift off the upper. Reassemble, lock,
   inspect seams and reinstall supports before reloading.

## Stability and taller installations

**No configuration has a tested freestanding rating.** The default is `anchored`.
The source reports support required even if `installation_mode="freestanding"`;
that selection does not certify stability or prevent exporting reusable parts.

The default three-lane stack with one upper and the assumed masses fails the
proposed 1.5 restoring/overturning margin for a 5 N push at the top. In the empty
case its estimated worst margin is about **0.45**. Thus the proposed base/ballast
alone does not meet the handling target. Even improving the calculation cannot
replace force, sliding, incline and sustained-load tests.

The source echoes center of mass, four edge moment margins and tipping angles for
empty, full, outer-lane, alternating-lane, top-loading and high-jam cases. Component
masses are explicitly estimates in kilograms; coordinates are installed-world
millimetres, converted to metres for torque. A conservative 2 mm lean allowance
reduces restoring distances. The disturbance is 5 N at the full height; the
horizontal outlet target is `max(10, 2 × measured_extraction_force)` N. Actual
lift/pull forces, sliding/friction, brace strength, creep and compliance remain
physical checks. Bracket masses are not included in the freestanding estimate.

The proposed supported arrangement uses **two bolted brackets on every element**:
one behind each outer edge. Front holes are at local rail heights
`(module_length−joint_overlap)/2` and 18 mm above that, so defaults put brackets
every 200 mm vertically. Rear anchor holes share those heights; the anchor plane
is 50 mm behind the panel's rear face. The side webs and front bolts provide a
vertical frame-load path as well as lateral restraint. Install on a rigid wall,
cabinet or supporting frame with accessible bolt/anchor tools. Verify substrate,
fasteners and bracket shear/bending/creep experimentally; **200 mm is proposed
spacing, not a tested maximum unsupported span or anchor rating**.

Repeating this arrangement avoids making lower frame joints carry unlimited
structural weight. However every capsule still rests through the column on the
lowest capsule and dispensing seat. Additional frame supports do not increase
the tested capsule-column capacity. Every taller loaded installation needs a new
column-load and outlet-release check. There is no fixed CAD upper-count limit.

## Validation and outstanding physical work

Digital checks on 2026-09-19 with OpenSCAD 2021.01 passed: 24 fully rendered part
variants, 41 rejected invalid configurations, three recalculated lane-limit cases,
identical upper meshes across stack counts, four assembly previews and five
solid-interference probes. Intentional planar bearing contacts are allowed by
the interference checks. No slicer or physical print test has been performed.

Run the reproducible digital checks with Python's standard library and OpenSCAD:

```bash
python3 tests/validate.py --output /tmp/nespresso-validation
```

The harness fully renders lower, upper, base and cover for lanes 1–5 plus all
coupons and the brace, checks closed consistently wound meshes, connected parts,
positive volume and actual printer bounds, tests invalid inputs, compares upper
exports across stack counts, checks tall assembly previews, and renders solid
intersection probes at joints, base, cover and support. It stores STLs, logs and
JSON results in the specified temporary directory. Each rejection uses a fresh
output path. Mesh checks do not prove strength or capsule operation.

Remaining acceptance work from the plan:

- Measure at least ten representative capsules, mounting hardware and available
  installation footprint/height; record actual nozzle, filament and profile.
- Slice every advertised part/lane count in the actual Q1 Pro profile including
  brim, purge lines and exclusions; inspect lips, socket floors, bolt holes,
  receivers and bracket webs. Record time and material estimates.
- Tune rail clearances independently from joint fit. The baseline per-face joint
  clearance is 0.10 mm; greater values are rejected by the 0.2 mm lateral-step
  target. If that cannot print reliably, redesign the alignment before widening
  the accepted tolerance. Check fore/aft and angular play as well as lateral play.
- Complete 30 outlet removals, 20 joint assembly cycles, smallest/largest capsule
  seam passes, then 50 removals for the one-lane lower with zero/one/two uppers.
- Test full/empty/uneven loading and at least 20 removals per final lane, including
  adjacent finger access. Record capacity and peak extraction force.
- Measure masses/lean, repeat calculations, and test 5 N at the highest point,
  the defined outlet force and 5° incline in each direction; then 24-hour and
  seven-day sustained load checks. Test the actual support/anchor installation
  and complete capsule-column load separately.
- Publish only physically tested combinations of lane count, stack height,
  base/ballast/pads, material and support arrangement. All such ratings are pending.

Reference: the printer budget follows [QIDI's Q1 Pro specifications](https://us.qidi3d.com/products/q1-pro-3d-printer).
Assertions, type checks, preview guards and CLI-compatible source use
[OpenSCAD 2021.01 language features](https://openscad.org/cheatsheet/).

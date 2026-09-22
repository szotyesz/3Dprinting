/*
 Nespresso Original gravity dispenser -- prototype, connector revision 1.
 Units mm. PRINT: X across lanes, Y along lanes, Z out of backplate.
 INSTALL: +Y becomes up, +Z faces the user; foil faces the backplate.
 Capsule dimensions below are UNMEASURED examples. No physical fit, load,
 freestanding height or anchor arrangement has been validated. Print coupons
 first. Original only; Vertuo requires new measurements and geometry.

 QIDI Q1 Pro: nominal 245 x 245 x 240; reserve 5 mm edge + 5 mm brim
 on each XY side, 5 mm above. Check actual profile exclusions in the slicer.
 Lower/upper/coupons: backplate flat at Z=0. Base/brace: foot down.
 Ballast cover: broad flat face down. All exports at 100% scale.
 Proposed 0.4 mm nozzle PETG settings (NOT tested): 0.20 mm layers,
 0.42-0.45 mm extrusion, 4 walls, 5 top/bottom layers, 20-25% gyroid.
 Use local solid modifiers at joints, seats, receivers and brace roots.
 Start 245 C nozzle / 80 C bed ONLY if spool and plate permit; actual brand,
 drying instructions, profile version and calibrated flow remain unknown.
 First layer 20-25 mm/s; functional walls 35-45; inner/infill 50-70.
 Initial uncalibrated volumetric limit 8 mm^3/s. Main fan off 2-3 layers,
 then trial 30-50%; auxiliary fan and chamber heat initially off.
 Follow spool/QIDI guidance for drying and door/lid position. Record results.
 Rails target no supports: prove sloped lips and horizontal fastener holes
 on coupons. The projecting top lap tongues start 6 mm above the bed and
 REQUIRE locally painted, build-plate-only support under their exposed
 20 mm undersides (including joint coupons). These supports are accessible
 from outside. Remove completely and clean the bearing faces flat before
 fitting; verify support-interface settings and the resulting fit on coupons.
 Block automatic supports inside rim slots and bottom sockets.
 Tune elephant foot, flow, retraction and seam position on coupons; keep
 seams off sliding faces. Use <=5 mm brim if needed; cool before removal
 and follow the installed plate's PETG preparation instructions.
 STL does NOT contain these settings. Inspect every sliced toolpath.

 Assembly: one lower, N identical uppers, one base, one ballast_cover.
 Each joint: 2 M3x18 bolts, 4 washers and 2 locknuts, rear nuts accessible.
 Base receiver: 4 M3x30 bolts, 8 washers and 4 locknuts.
 Cover: 4 M3x25 bolts, 8 washers and 4 locknuts; pad height clears nuts.
 Secure solid ballast within the closed cavity (pack to prevent movement).
 Four 20 x 20 x 6 mm non-slip pads at the base corners, inset 5 mm.
 Anchored prototype: 2 braces PER element, 4 M3x25 bolts + washers/nuts
 per element, and 4 substrate-specific M4-class anchors per element.
 Brace front attaches to structural edge holes; rear attaches to wall.
 Bolted brackets carry frame weight AND restrain lateral motion. Their
 load rating/anchor substrate/spacing require tests. Seat/capsule column
 load still accumulates regardless of frame supports. Never load an
 untested tall stack merely because another upper can be attached.
 Empty before assembly/extension: seat keyed joints, fit both locks,
 inspect seams, fit base/ballast/pads and required supports, then load.
 At outlet lift the bottom capsule ~3 mm and pull forward, without forcing
 rails apart. Prove 30 removals on outlet prototype before a full print.
 See README.md and original plan for the remaining physical acceptance tests.
*/

/* [Main controls] */
number_of_lines = 3; // [1:1:5]
number_of_upper_elements = 1;
part = "lower"; // [lower,upper,base,ballast_cover,brace,fit_coupon,joint_coupon,outlet_prototype,assembly_preview]
installation_mode = "anchored"; // [freestanding,anchored]
show_capsules = false;

/* [Provisional capsule measurements -- replace from samples] */
rim_diameter_min = 36.6;
rim_diameter_max = 37;
rim_thickness_min = 0.8;
rim_thickness_max = 1.2;
body_diameter_max = 30;
capsule_depth_max = 30;
foil_relief = 0.6;
capsule_mass = 0.006; // kg, estimate
side_clearance = 0.4; // PER SIDE, independent of joint clearance
rim_slot_extra = 0.3; // TOTAL
body_clearance = 0.4;
minimum_rim_capture = 0.5;
lip_overlap = 2.2;

/* [Structure and independent connector fit] */
lower_module_length = 220; // complete envelope, including top tongues
upper_module_length = 220;
joint_overlap = 20;
joint_clearance = 0.10; // per lateral mating face; coupon before changing
seam_gap = 0.10; // rail/backplate gap, must remain below thinnest rim
connector_revision = 1; // only revision 1 is implemented
edge_width = 10; // screw lands included, not external to width calculation
divider_width = 3;
backplate_thickness = 3.2;
lip_thickness = 1.6;
spine_height = 12;
joint_floor = 6;
joint_root_length = 12;
seat_height = 3;
curb_height = 2;
removal_lift = 3;
entry_length = 2;
entry_flare = 0.3;
stack_allowance = 0.5; // planning allowance, NOT a physical air gap
nozzle_diameter = 0.4;
line_width = 0.45;
bolt_diameter = 3.4; // M3 clearance; verify actual hardware
washer_diameter = 7;
anchor_diameter = 4.5;

/* [Base and support -- no tested freestanding configuration] */
base_min_width = 180;
base_depth = 180;
base_thickness = 20;
base_receiver_height = 40;
receiver_clearance = 0.2;
receiver_wall = 4;
pad_height = 6;
pad_inset = 5;
pad_size = 20;
ballast_mass = 1.0; // kg TARGET, must actually fit and be secured
base_mass = 0.30; // kg estimate including cover/hardware, excluding ballast
lower_mass = 0.15;
upper_mass = 0.14;
measured_extraction_force = 0; // N, unknown; minimum 10 N target still used
estimated_top_lean = 2; // mm; replace with measured joint/rail deflection

/* [Printer reservations] */
bed_x = 245;
bed_y = 245;
bed_z = 240;
edge_margin = 5;
brim_reserve = 5;
z_margin = 5;

/* [Hidden] */
$fn = $preview ? 24 : 40;
eps = 0.01;

// Type validation is in functions used by all derived arithmetic. Thus a
// malformed input cannot generate undef geometry before the useful assertion.
function positive(v, name) = assert(is_num(v), str(name, " must be a number"))
    assert(v > 0, str(name, " must be positive")) v;
function nonnegative(v, name) = assert(is_num(v), str(name, " must be a number"))
    assert(v >= 0, str(name, " must be nonnegative")) v;
function count(v, name, lo) = assert(is_num(v), str(name, " must be an integer"))
    assert(v == floor(v) && v >= lo, str(name, " must be an integer >= ", lo)) v;
function p(v, name) = positive(v, name);
function nn(v, name) = nonnegative(v, name);
n = count(number_of_lines, "number_of_lines", 1);
uppers = count(number_of_upper_elements, "number_of_upper_elements", 0);
usable_x = p(bed_x,"bed_x") - 2*(nn(edge_margin,"edge_margin")+nn(brim_reserve,"brim_reserve"));
usable_y = p(bed_y,"bed_y") - 2*(edge_margin+brim_reserve);
usable_z = p(bed_z,"bed_z") - nn(z_margin,"z_margin");
channel_width = p(rim_diameter_max,"rim_diameter_max") + 2*p(side_clearance,"side_clearance");
lane_pitch = channel_width + p(divider_width,"divider_width");
function width(lanes) = 2*p(edge_width,"edge_width") + lanes*channel_width + (lanes-1)*divider_width;
max_lines = floor((usable_x - 2*p(edge_width,"edge_width") + divider_width)/lane_pitch);
overall_width = width(n);
front_opening = channel_width - 2*p(lip_overlap,"lip_overlap");
rim_rear = p(backplate_thickness,"backplate_thickness") + p(foil_relief,"foil_relief");
slot_height = p(rim_thickness_max,"rim_thickness_max") + p(rim_slot_extra,"rim_slot_extra");
lip_bottom = rim_rear + slot_height;
rail_height = lip_bottom + lip_overlap + p(lip_thickness,"lip_thickness");
part_height = max(rail_height, p(spine_height,"spine_height"));
lower_path = p(lower_module_length,"lower_module_length") - p(joint_overlap,"joint_overlap");
upper_path = p(upper_module_length,"upper_module_length") - joint_overlap;
dispenser_length = lower_module_length + uppers*upper_path;
base_width = max(p(base_min_width,"base_min_width"),overall_width);
base_mount_height = p(base_thickness,"base_thickness") + p(pad_height,"pad_height");
panel_y = p(base_depth,"base_depth")*0.73;
assembled_height = base_mount_height + dispenser_length;
loading_allowance = joint_overlap + p(entry_length,"entry_length");
outlet_allowance = p(seat_height,"seat_height");
usable_stack_length = dispenser_length - loading_allowance - outlet_allowance;
planning_capsule_pitch = rim_diameter_max + nn(stack_allowance,"stack_allowance");
capsules_per_line = 1 + floor((usable_stack_length-rim_diameter_max)/planning_capsule_pitch);
total_capacity = n*capsules_per_line;
// Circle/lip intersection at the inner lip edge determines release height.
release_height = seat_height + rim_diameter_max/2 +
    sqrt(max(0,pow(rim_diameter_max/2,2)-pow(front_opening/2,2))) +
    p(removal_lift,"removal_lift") + 0.8;
outlet_length = seat_height + 3*rim_diameter_max + 2*stack_allowance + entry_length;
coupon_length = 55;
joint_coupon_length = 2*joint_overlap + 35;
cover_width = base_width-16;
cover_depth = 82;
brace_width = edge_width+4;
brace_depth = max(50, base_depth-panel_y+1); // rear anchor plane clears the base
brace_height = 44;
function lane_x(i) = edge_width + i*lane_pitch;
function tongue_width(side) = side == 0 ? edge_width-4 : edge_width-5;
function tongue_x(side, w) = side == 0 ? 2 : w-edge_width+2.5;
function edge_x(side,w) = side == 0 ? 0 : w-edge_width;
function support_y(length) = (length-joint_overlap)/2;
function print_bounds(selection) =
    selection == "lower" ? [overall_width,lower_module_length,part_height] :
    selection == "upper" ? [overall_width,upper_module_length,part_height] :
    selection == "base" ? [base_width,base_depth,base_thickness+base_receiver_height] :
    selection == "ballast_cover" ? [cover_width,cover_depth,3] :
    selection == "brace" ? [brace_width,brace_depth,brace_height] :
    selection == "fit_coupon" ? [width(1),coupon_length,part_height] :
    selection == "joint_coupon" ? [2*width(1)+8,joint_coupon_length,part_height] :
    [width(1),outlet_length,part_height];

module validate() {
    assert(is_string(part) && len([for(candidate=["lower","upper","base","ballast_cover","brace","fit_coupon","joint_coupon","outlet_prototype","assembly_preview"]) if(part==candidate) 1]) == 1,
        "Unknown part; select a printable part or assembly_preview");
    assert(installation_mode == "freestanding" || installation_mode == "anchored", "Unknown installation_mode");
    assert(is_bool(show_capsules), "show_capsules must be Boolean");
    assert(connector_revision == 1, "Only connector_revision 1 is implemented; never mix revisions");
    assert(max_lines >= 1, "Even one lane cannot fit; reduce dimensions or printer reservations");
    assert(n <= max_lines, str("number_of_lines exceeds calculated max_lines=",max_lines));
    // Evaluate every editable structural input, including ones used only by
    // a different part, so no selected output can hide an invalid setting.
    for (item = [[rim_diameter_min,"rim_diameter_min"],[rim_thickness_min,"rim_thickness_min"],
        [body_diameter_max,"body_diameter_max"],[capsule_depth_max,"capsule_depth_max"],
        [body_clearance,"body_clearance"],[minimum_rim_capture,"minimum_rim_capture"],
        [joint_clearance,"joint_clearance"],[joint_floor,"joint_floor"],[joint_root_length,"joint_root_length"],
        [seam_gap,"seam_gap"],[curb_height,"curb_height"],[entry_flare,"entry_flare"],
        [nozzle_diameter,"nozzle_diameter"],[line_width,"line_width"],[bolt_diameter,"bolt_diameter"],
        [washer_diameter,"washer_diameter"],[anchor_diameter,"anchor_diameter"],
        [base_receiver_height,"base_receiver_height"],[receiver_clearance,"receiver_clearance"],
        [receiver_wall,"receiver_wall"],[pad_size,"pad_size"],[capsule_mass,"capsule_mass"],
        [base_mass,"base_mass"],[lower_mass,"lower_mass"],[upper_mass,"upper_mass"]])
        assert(p(item[0],item[1]) > 0);
    for (item = [[ballast_mass,"ballast_mass"],[measured_extraction_force,"measured_extraction_force"],
        [estimated_top_lean,"estimated_top_lean"],[pad_inset,"pad_inset"]]) assert(nn(item[0],item[1]) >= 0);
    assert(rim_diameter_min <= rim_diameter_max && rim_thickness_min <= rim_thickness_max, "Order measured rim minimum/maximum limits");
    assert(front_opening >= body_diameter_max + 2*body_clearance, "Body clearance error: widen front opening");
    assert(front_opening <= rim_diameter_min - 2*minimum_rim_capture, "Rim retention error: narrow front opening");
    assert(lip_overlap >= channel_width-rim_diameter_min+minimum_rim_capture,
        "Insufficient rim capture when the smallest capsule shifts to a side wall");
    assert(divider_width >= 4*line_width && backplate_thickness >= 4*line_width && lip_thickness >= 3*line_width,
        "Structural roots too thin for extrusion width");
    assert(line_width >= nozzle_diameter && line_width <= 1.5*nozzle_diameter, "Check nozzle and extrusion width");
    assert(spine_height >= rail_height && joint_floor >= backplate_thickness + 2*line_width && spine_height-joint_floor >= 4*line_width,
        "Joint floor/tongue wall or spine height is insufficient");
    assert(edge_width >= washer_diameter+3 && tongue_width(1) >= bolt_diameter+1.5,
        "Insufficient material/tool space around outer fasteners");
    assert(joint_clearance < 0.5 && 2*joint_clearance <= 0.2, "Joint lateral play exceeds 0.2 mm rail-step target; revise and test interface");
    assert(seam_gap < rim_thickness_min/2 && seam_gap <= 0.2, "Seam gap may catch the thinnest rim");
    assert(joint_overlap >= 2*washer_diameter+4 && joint_root_length >= washer_diameter+3, "Joint engagement/root too short");
    assert(lower_path > release_height + rim_diameter_max + joint_root_length && lower_path > 2*joint_overlap+40,
        "Lower module too short for outlet, capsule and joint structure");
    assert(upper_path > 2*joint_overlap+40, "Upper module too short for useful rails between connectors");
    assert(usable_stack_length >= rim_diameter_max, "Assembly has no usable capsule capacity");
    assert(removal_lift > curb_height && release_height < seat_height+rim_diameter_min,
        "Outlet lift/curb geometry would release the next capsule or trap the lowest");
    assert(capsule_depth_max > rim_thickness_max, "Capsule depth must exceed rim thickness");
    assert(entry_flare < lip_overlap-minimum_rim_capture && entry_length < rim_diameter_min/4, "Loading chamfer removes too much retention");
    assert(base_width >= overall_width && base_width >= 100 && base_depth >= 170 && base_thickness >= 20,
        "Base too small for receiver, secured ballast pocket and cover");
    assert(panel_y-spine_height-receiver_wall-20 > 90 && panel_y+receiver_wall+20 < base_depth,
        "Base receiver/gussets collide with ballast pocket or exceed footprint");
    assert(base_receiver_height >= 36 && receiver_wall >= 4*line_width && receiver_clearance < 0.5,
        "Base receiver wall, engagement or fit is invalid");
    assert(pad_inset+pad_size < min(base_width,base_depth)/2 && pad_height >= 6, "Pads must clear cover locknuts and remain inside footprint");
    assert(part != "assembly_preview" || $preview,
        "assembly_preview is display-only: use OpenSCAD F5, or CLI PNG/CSG with -D '$preview=true'; export parts separately");
    if (part != "assembly_preview") {
        bounds = print_bounds(part);
        assert(bounds[0] <= usable_x && bounds[1] <= usable_y && bounds[2] <= usable_z,
            str("Individual part exceeds reserved print envelope: ",part," ",bounds," vs ",[usable_x,usable_y,usable_z]));
    }
    children();
}

// Cross-section extrusion along print Y, with no imported libraries.
module along_y(points, y, length) {
    translate([0,y+length,0]) rotate([90,0,0]) linear_extrude(height=length) polygon(points);
}

module backplate(w, length) { cube([w,length,backplate_thickness]); }

module lip_at(x, direction, y, length) {
    translate([x,0,0]) scale([direction,1,1])
        along_y([[0,lip_bottom],[lip_overlap,lip_bottom+lip_overlap],
                 [lip_overlap,rail_height],[0,rail_height]],y,length);
}

// Shared walls are generated ONCE. Only the paired ledges/lips repeat.
module rails(lanes, y0, end, outlet=false) {
    w = width(lanes);
    for (s=[0,1]) translate([edge_x(s,w),y0,0]) cube([edge_width,end-y0,spine_height]);
    if (lanes > 1) for (i=[1:lanes-1])
        translate([lane_x(i)-divider_width,y0,0]) cube([divider_width,end-y0,rail_height]);
    for (i=[0:lanes-1]) {
        x = lane_x(i);
        for (s=[0,1]) {
            xx = s == 0 ? x : x+channel_width;
            d = s == 0 ? 1 : -1;
            // Rear ledge touches only the rim, leaving central foil relief.
            translate([s == 0 ? xx-eps : xx-lip_overlap,y0,backplate_thickness-eps])
                cube([lip_overlap+eps,end-y0,foil_relief+eps]);
            lip_at(xx,d,outlet ? release_height : y0,end-(outlet ? release_height : y0));
        }
    }
}

module loading_entry(lanes, end) {
    // Widen side walls and shorten lips over the last 2 mm of the rail.
    for (i=[0:lanes-1]) {
        x=lane_x(i);
        translate([0,0,backplate_thickness]) linear_extrude(height=part_height)
            polygon([[x+lip_overlap,end-entry_length],
                     [x+channel_width-lip_overlap,end-entry_length],
                     [x+channel_width+entry_flare,end+eps], [x-entry_flare,end+eps]]);
    }
}

module dispensing_pocket(lanes) {
    for(i=[0:lanes-1]) {
        x=lane_x(i);
        translate([x-eps,0,backplate_thickness-eps])
            cube([channel_width+2*eps,seat_height,lip_bottom+lip_overlap-backplate_thickness]);
        // Fixed shallow front curb, clear of the foil at its resting plane.
        translate([x-eps,0,rim_rear+rim_thickness_max+rim_slot_extra])
            cube([channel_width+2*eps,seat_height+curb_height,1.6]);
    }
}

module top_joint(w, end) {
    // Elevated lap tongues need exterior, build-plate-only slicer supports.
    // Do not infer support-free printability from a watertight mesh.
    for(s=[0,1]) translate([tongue_x(s,w),end-joint_root_length,joint_floor])
        cube([tongue_width(s),joint_root_length+joint_overlap,spine_height-joint_floor]);
}

module bottom_joint(w) {
    // Open-top keyed lap sockets need no trapped support; unequal tongue
    // widths prevent reversed mating. Bearing floors carry bending/clamp load.
    for(s=[0,1]) translate([tongue_x(s,w)-joint_clearance,-eps,joint_floor])
        cube([tongue_width(s)+2*joint_clearance,joint_overlap+joint_clearance+eps,spine_height]);
}

module z_bolt(x,y,diameter=bolt_diameter) {
    translate([x,y,-eps]) cylinder(d=diameter,h=part_height+2*eps);
}

module structural_holes(w,length,bottom=false,base_mount=false,top=true) {
    for(s=[0,1]) {
        x=edge_x(s,w)+edge_width/2;
        if(top) z_bolt(x,length-joint_overlap/2);
        if(bottom) z_bolt(x,joint_overlap/2);
        if(base_mount) for(y=[12,30]) z_bolt(x,y);
        for(y=[support_y(length),support_y(length)+18]) z_bolt(x,y);
    }
}

module compatibility_mark(w,y,lanes) {
    // Recessed binary notch count: lanes on left, revision on right.
    // Avoid font dependencies and keep marks outside every capsule path.
    for(i=[0:lanes-1]) translate([0,y+i*2.5,spine_height-0.6]) cube([1,1,1]);
    translate([w-1,y,spine_height-0.6]) cube([1,1,1]);
}

module element(lanes,length,bottom=false,outlet=false,top=true,base_mount=false) {
    w=width(lanes);
    end=top ? length-joint_overlap : length;
    start=bottom ? seam_gap : 0;
    difference() {
        union() {
            translate([0,start,0]) backplate(w,end-start);
            rails(lanes,start,end,outlet);
            if(outlet) dispensing_pocket(lanes);
            if(top) top_joint(w,end);
        }
        if(bottom) bottom_joint(w);
        loading_entry(lanes,end);
        structural_holes(w,length,bottom,base_mount,top);
        compatibility_mark(w,end-joint_root_length-16,lanes);
    }
}

module lower_element() { element(n,lower_module_length,outlet=true,base_mount=true); }
module upper_element() { element(n,upper_module_length,bottom=true); }
module fit_coupon() { element(1,coupon_length,top=false); }
module outlet_prototype() { element(1,outlet_length,outlet=true,top=false,base_mount=true); }
module joint_coupon() {
    // Two separate test pieces on ONE plate, same sockets/rails as full parts.
    element(1,joint_coupon_length);
    translate([width(1)+8,0,0]) element(1,joint_coupon_length,bottom=true);
}

module y_hole(x,y,z,d,length) {
    translate([x,y,z]) rotate([-90,0,0]) cylinder(d=d,h=length);
}

module receiver(w) {
    xoff=(base_width-w)/2;
    for(s=[0,1]) {
        x=xoff+edge_x(s,w);
        rear=panel_y+receiver_clearance;
        front=panel_y-spine_height-receiver_clearance-receiver_wall;
        difference() {
            union() {
                for(y=[front,rear]) translate([x,y,base_thickness-eps])
                    cube([edge_width,receiver_wall,base_receiver_height+eps]);
                // Triangular external gussets leave the insertion slot open.
                for(side=[0,1]) translate([x,side==0 ? front : rear+receiver_wall,base_thickness-eps])
                    rotate([0,0,side==0 ? 0 : 180])
                    translate([side==0 ? 0 : -edge_width,0,0])
                    rotate([90,0,90]) linear_extrude(height=edge_width)
                    polygon([[0,0],[-20,0],[0,base_receiver_height-4]]);
            }
            for(z=[12,30]) y_hole(x+edge_width/2,front-eps,base_thickness+z,bolt_diameter,
                rear+receiver_wall-front+2*eps);
        }
    }
}

module cover_holes(offset=[0,0],height=100) {
    for(x=[14,base_width-14],y=[14,84]) translate([x-offset[0],y-offset[1],-eps])
        cylinder(d=bolt_diameter,h=height+2*eps);
}

module base() {
    difference() {
        union() { cube([base_width,base_depth,base_thickness]); receiver(overall_width); }
        // Open cavity + flush bolted cover. 3 mm floor, broad surrounding rim.
        translate([20,20,3]) cube([base_width-40,58,base_thickness]);
        translate([8,8,base_thickness-3]) cube([cover_width,cover_depth,4]);
        cover_holes(height=base_thickness);
        for(x=[10,base_width-10],y=[105,base_depth-10])
            translate([x,y,-eps]) cylinder(d=anchor_diameter,h=base_thickness+2*eps);
    }
}

module ballast_cover() {
    difference() {
        translate([0.2,0.2,0]) cube([cover_width-0.4,cover_depth-0.4,3]);
        cover_holes([8,8],3);
    }
}

module brace() {
    // Front bolts to back of outer structural spine; rear to substrate.
    // Two diagonal side webs support frame weight via front bolt shear.
    difference() {
        union() {
            cube([brace_width,brace_depth,4]);
            for(y=[0,brace_depth-4]) translate([0,y,0]) cube([brace_width,4,brace_height]);
            for(x=[0,brace_width-2]) translate([x,0,0]) rotate([90,0,90])
                linear_extrude(height=2) polygon([[0,0],[brace_depth,0],[brace_depth,brace_height],[brace_depth-4,brace_height],[4,4],[0,4]]);
        }
        for(z=[12,30]) {
            y_hole(brace_width/2,-eps,z,bolt_diameter,4+2*eps);
            y_hole(brace_width/2,brace_depth-4-eps,z,anchor_diameter,4+2*eps);
        }
    }
}

// Installed preview uses world Z up and -Y toward the user. The base is
// raised by actual pad thickness; pads/hardware are background diagnostics.
module installed(y=0) {
    translate([(base_width-overall_width)/2,panel_y,base_mount_height+y]) rotate([90,0,0]) children();
}
module mock_capsule() {
    color("gold") {
        cylinder(d=rim_diameter_max,h=rim_thickness_max);
        translate([0,0,rim_thickness_max]) cylinder(d1=body_diameter_max,d2=23,h=capsule_depth_max-rim_thickness_max);
    }
}
module assembly_preview() {
    color("slategray") translate([0,0,pad_height]) base();
    color("gray") translate([8,8,pad_height+base_thickness-3]) ballast_cover();
    color("steelblue") installed() lower_element();
    if(uppers>0) for(i=[1:uppers]) color(i%2==0 ? "steelblue" : "lightsteelblue")
        installed(lower_path+(i-1)*upper_path) upper_element();
    if(installation_mode=="anchored") for(i=[0:uppers]) {
        offset=i==0 ? 0 : lower_path+(i-1)*upper_path;
        length=i==0 ? lower_module_length : upper_module_length;
        for(s=[0,1]) color("orange") translate([(base_width-overall_width)/2+edge_x(s,overall_width)-2,
            panel_y,base_mount_height+offset+support_y(length)-12]) brace();
    }
    if(show_capsules) for(i=[0:n-1],j=[0:capsules_per_line-1])
        %installed() translate([lane_x(i)+channel_width/2,seat_height+rim_diameter_max/2+j*planning_capsule_pitch,rim_rear]) mock_capsule();
    // Lock shafts shown as background only, never in printable geometry.
    if(uppers>0) for(i=[0:uppers-1],s=[0,1])
        %installed(lower_path+i*upper_path) translate([edge_x(s,overall_width)+edge_width/2,joint_overlap/2,-3]) cylinder(d=3,h=18);
    for(x=[pad_inset,base_width-pad_inset-pad_size],y=[pad_inset,base_depth-pad_inset-pad_size])
        %translate([x,y,0]) cube([pad_size,pad_size,pad_height]);
}

function sum(values,i=0) = i>=len(values) ? 0 : values[i]+sum(values,i+1);
// Mass records: [kg, world X, world Y, world Z], all lengths mm.
function frame_masses() = concat([
    [base_mass,base_width/2,base_depth/2,pad_height+base_thickness/2],
    [ballast_mass,base_width/2,49,pad_height+base_thickness/2],
    [lower_mass,base_width/2,panel_y-spine_height/2,base_mount_height+lower_module_length/2]],
    [for(i=[0:1:uppers-1]) [upper_mass,base_width/2,panel_y-spine_height/2,
        base_mount_height+lower_path+i*upper_path+upper_module_length/2]]);
function capsule_masses(mode) = [for(i=[0:n-1],j=[0:capsules_per_line-1])
    if(mode=="full" || mode=="high_jam" || (mode=="outer_lane" && i==0) || (mode=="alternating" && i%2==0))
    [capsule_mass,(base_width-overall_width)/2+lane_x(i)+channel_width/2,panel_y-rim_rear-capsule_depth_max/2,
        mode=="high_jam" ? assembled_height-loading_allowance-rim_diameter_max/2-j*planning_capsule_pitch :
        base_mount_height+seat_height+rim_diameter_max/2+j*planning_capsule_pitch]];
module stability_report() {
    for(mode=["empty","full","outer_lane","alternating","loading","high_jam"]) {
        masses=concat(frame_masses(),capsule_masses(mode),mode=="loading" ?
            [[capsule_mass,base_width/2,panel_y-capsule_depth_max/2,assembled_height]] : []);
        mass=sum([for(m=masses) m[0]]);
        com=[for(a=[1:3]) sum([for(m=masses) m[0]*m[a]])/mass];
        distances=[com[0]-pad_inset,base_width-pad_inset-com[0],com[1]-pad_inset,base_depth-pad_inset-com[1]];
        restoring=[for(d=distances) mass*9.81*(d-estimated_top_lean)/1000];
        top_margins=[for(r=restoring) r/(5*assembled_height/1000)];
        outlet_force=max(10,2*measured_extraction_force);
        outlet_margins=[for(r=restoring) r/(outlet_force*(base_mount_height+seat_height+rim_diameter_max/2)/1000)];
        echo(stability_case=mode,estimated_mass_kg=mass,COM_mm=com,
            edge_order="left/right/front/rear",top_5N_margins=top_margins,
            restoring_moments_Nm=restoring,estimated_tip_forces_at_top_N=[for(r=restoring) r/(assembled_height/1000)],
            outlet_horizontal_margins=outlet_margins,
            tip_angles_deg=[for(d=distances) atan((d-estimated_top_lean)/com[2])]);
    }
    echo("UNTESTED: support required for ALL configurations. No freestanding rating. Targets: margin >=1.5, 5 N at top, >=10 N outlet, 5 deg incline. Sliding, lift/pull, anchor strength and creep require physical tests.");
}

module report() {
    echo(connector_revision=connector_revision,lanes=n,max_lines=max_lines,upper_quantity=uppers,
        printable_part=part,part_bounds_mm=part=="assembly_preview" ? "display only" : print_bounds(part));
    echo(assembled_height_mm=assembled_height,capacity_estimate=total_capacity,capsules_per_line=capsules_per_line,
        base_footprint_mm=[base_width,base_depth],ballast_target_kg=ballast_mass);
    echo(added_length_per_upper_mm=upper_path,seat_load_per_lane_N=capsules_per_line*capsule_mass*9.81,
        proposed_brace_spacing_mm=upper_path,frame_and_seat_load_rating="UNTESTED");
    echo(BOM=str("1 lower, ",uppers," identical uppers, 1 base, 1 ballast_cover; joint M3x18 bolts=",2*uppers,
        "; receiver M3x30 bolts=4; cover M3x25 bolts=4; braces=",installation_mode=="anchored" ? 2*(uppers+1) : 0,
        "; brace M3x25 bolts=",installation_mode=="anchored" ? 4*(uppers+1) : 0,
        "; substrate anchors=",installation_mode=="anchored" ? 4*(uppers+1) : 0,
        "; 2 washers and 1 locknut per M3 bolt; 4 pads; secured ballast"));
    echo("Fit dimensions, masses, capsule column capacity and support loads are provisional. Confirm on physical samples.");
    stability_report();
}

validate() {
    report();
    if(part=="lower") lower_element();
    else if(part=="upper") upper_element();
    else if(part=="base") base();
    else if(part=="ballast_cover") ballast_cover();
    else if(part=="brace") brace();
    else if(part=="fit_coupon") fit_coupon();
    else if(part=="joint_coupon") joint_coupon();
    else if(part=="outlet_prototype") outlet_prototype();
    else assembly_preview();
}

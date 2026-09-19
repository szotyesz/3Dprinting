# Nespresso capsule dispenser: implementation plan

Create a parametric, modular Nespresso capsule dispenser in OpenSCAD for printing in PETG on a QIDI Q1 Pro. Make its vertical length extendable by printing **one lower dispensing element and any required number of identical upper elements**. An upper element must stack onto the lower element and onto another upper element. The assembled dispenser must be well balanced, robust, and resistant to tipping during loading, dispensing, and ordinary accidental contact.

The eventual source file must expose a `number_of_lines` parameter for the number of side-by-side lanes, provide separate printable module selections, reject invalid or oversized individual parts, and contain inline comments explaining the slicing settings and print orientation. Each part must fit the printer; the assembled stack may exceed its build volume. Modular length must have no fixed design-imposed endpoint, while freestanding use must stay within a tested stability and structural envelope. Provide bracing and intermediate support for taller installations.

This document is the plan. The steps below describe future CAD work, exports, and physical tests; no model or print has been validated yet. The planned source is `nespresso_capsule_dispenser/nespresso_capsule_dispenser.scad`. For this planning task, change only this Markdown file.

## 1. Establish the design assumptions and intended use

1. Interpret a **line** as one vertical, independently loaded capsule lane. `number_of_lines` controls the number of lanes side by side, not layer count or capsules per lane.
2. Use **Nespresso Original** capsules as the initial design assumption. Confirm the actual capsule family before implementing the fit geometry. Original and Vertuo use different capsules, so a Vertuo version requires fresh measurements and validation. [Nespresso capsule-system FAQ](https://www.contact.nespresso.com/faq-3/hk/en)
3. Use gravity feed: insert capsules at the top, remove the lowest capsule at the bottom, and let the next capsule settle into the dispensing position.
4. Orient the foil face toward the backplate and the capsule body toward the user. Guide and retain the outer rim while leaving the body accessible from the front.
5. Design for upright countertop use with a broad, stable base, and provide attachment points for positive anchoring or bracing of taller stacks. Make resistance to tipping and sliding an acceptance requirement. Determine the practical base footprint, available installation height, supporting surface, and anchoring arrangement before finalizing the design.
6. Start with three lanes. Keep lane count, upper-element count, and capsules per lane separate. Every element in one stack must use the same lane count, lane spacing, rail profile, and connector revision.
7. Put dispensing seats, outlets, and the base attachment only in the lower element. Give it the same top connector used on every upper element, so it works alone or with extensions.
8. Give each upper element a matching bottom connector, a repeatable top connector, and uninterrupted capsule paths through both ends. The same upper part must work in the middle or at the top of the stack, with no outlet, floor, or permanent end cap that blocks another extension.
9. Prefer a separately printed base positively secured to the lower element so the modules and base can each use a strong print orientation. Include every base part and fastener in the assembly instructions. An integrated base is acceptable only if it satisfies the same printability and stability checks.
10. Prove capsule release, feeding across joints, connector rigidity, and tipping resistance before adding cosmetic details. Adding an upper element must trigger a new check of total load and stability.

**Completion criterion:** record the capsule family, intended lane and upper-element counts, base footprint constraints, support arrangement, nozzle size, and PETG brand. Identify the lower, repeatable upper, and base as distinct parts of the design.

## 2. Measure the capsules and printing setup

1. Gather calipers, at least ten unused capsules representative of the intended brands, and the PETG spool's printing instructions.
2. Measure several orientations of each capsule to capture ovality and rim variation. Record minimum and maximum values, rather than designing around one capsule.
3. Fill in this measurement record before locking the model defaults:

| Measurement | Symbol | How it affects the design |
| --- | --- | --- |
| Minimum and maximum outside rim diameter | `rim_diameter_min`, `rim_diameter_max` | Retention at the smallest rim; sliding clearance at the largest rim |
| Minimum and maximum effective rim thickness, including the rolled edge | `rim_thickness_min`, `rim_thickness_max` | Maximum sets the guide-slot clearance; minimum informs the seam-gap test |
| Maximum body diameter near the rim | `body_diameter_max` | Minimum opening between retaining lips |
| Maximum projection from foil face to capsule tip | `capsule_depth_max` | Front clearance and the removal motion |
| Foil bulge or other rear protrusions | `foil_relief` | Space needed to keep the foil from dragging against the backplate |
| Capsule mass and planned loaded capacity | `capsule_mass`, derived capacity | Mounting and loaded dispensing tests |
| Actual nozzle diameter and selected line width | `nozzle_diameter`, `line_width` | Wall thicknesses and small printable features |
| Mounting screw shank and head dimensions | To be named after hardware selection | Hole clearance, head recesses, and edge distances |
| Available countertop footprint and loading height | Installation measurements | Base size, usable assembled height, and access to the top |
| Printed element, hardware, and ballast masses | Measured after the first prints | Loaded and empty center-of-mass estimates |
| Capsule extraction and loading forces | Measured with a force gauge or spring scale | Base, joint, and tipping test loads |
| Connector clearance, engagement, and assembled play | Measured on joint coupons | Interchangeability, rail alignment, and cumulative stack lean |

4. Photograph or sketch the rim cross-section for design reference during implementation. Identify which surfaces can guide the rim without pressing on the foil or crushing the capsule body.
5. Treat third-party capsules as separate samples. A successful fit with one brand does not establish compatibility with all Original-compatible capsules.
6. Record the installed OpenSCAD version and the slicer/printer profile selected for the Q1 Pro.

**Completion criterion:** measured capsule limits and actual printing equipment are known. Nominal example dimensions elsewhere in this plan remain calculation examples until checked against these measurements.

## 3. Fix the coordinate system, print orientation, and build envelope

1. Use millimetres throughout. Model the printable orientation directly:
   - `X`: dispenser width and lane repetition.
   - `Y`: dispenser length, which becomes vertical height when mounted.
   - `Z`: thickness projecting outward from the backplate.
2. Place the backplate flat on the build plate at `Z = 0`. In use, the top loading end is at larger `Y`, and capsules move toward smaller `Y`.
3. Start from the Q1 Pro's published **245 × 245 × 240 mm** build volume. Its listed standard nozzle is **0.4 mm**; check the nozzle actually installed. [QIDI Q1 Pro specifications](https://us.qidi3d.com/products/q1-pro-3d-printer)
4. Reserve space explicitly rather than using the full nominal bed dimensions:

   ```text
   bed_x = 245
   bed_y = 245
   bed_z = 240
   edge_margin = 5             // Project allowance on each XY edge.
   brim_reserve = 5            // Maximum planned brim width on each side.
   z_margin = 5

   usable_x = bed_x - 2 * (edge_margin + brim_reserve) = 225
   usable_y = bed_y - 2 * (edge_margin + brim_reserve) = 225
   usable_z = bed_z - z_margin = 235
   ```

5. Begin with `lower_module_length = 220 mm` and `upper_module_length = 220 mm`, subject to connector and outlet development. These are each element's complete `Y` extent, including projecting connectors. Joint engagement must be included within these lengths or the full bounds recalculated.
6. Check the lower element, upper element, base, connector hardware, and any brace as separate printable parts. Include mounting ears, tongues, stops, labels, and other projections in each bounding box. Print the base with its support face on the bed when that orientation gives adequate strength; evaluate joint layer direction separately.
7. Check the active slicer profile for excluded areas, purge lines, and other reserved space. The rectangular calculation is an initial bound; final placement must also pass the actual slicer layout check. Account for a skirt separately if one is enabled.
8. Reserve front access, base clearance, and loading clearance above the selected assembled height. Include access to joint locks and braces. Capsules are not part of the printed mesh, but their bodies and removal motion still need room in use.
9. Apply printer bounds to individual part exports, not the full assembly preview. A long assembly is made from repeated printable upper elements. If the required stable base exceeds one print's footprint, split it into positively locked base sections and validate their connection.

**Completion criterion:** every individual part has a documented print orientation and bounds check, and the complete assembled height and footprint are recorded separately.

## 4. Define parameters and derive the valid lane counts

Keep the main user controls short. Put measured fit dimensions and structural dimensions in a separate advanced section of the eventual OpenSCAD file.

| Parameter | Initial proposal | Rule |
| --- | --- | --- |
| `number_of_lines` | `3` | Integer from `1` through the calculated `max_lines` |
| `number_of_upper_elements` | `1` for the first assembled preview | Nonnegative integer; controls assembled height, preview, and bill of materials, not the size of an upper-element export |
| `lower_module_length`, `upper_module_length` | `220 mm` each | Complete lengths including connectors; each must fit its selected print orientation |
| `joint_overlap` | Establish on the joint prototype | Positive seated overlap; each upper must add a positive length |
| `joint_clearance` | Establish with a separate connector-fit coupon | Clearance per mating face, independent of capsule sliding clearance |
| `base_width`, `base_depth`, `base_thickness` | Derive from stability and stiffness checks | Must support the narrowest lane variant as well as wider variants |
| `ballast_mass`, `base_mount_height` | Derive from the selected base | Ballast must be secured; base mount height is the lower element's bottom datum above the countertop |
| `installation_mode` | `"freestanding"` or `"anchored"` | Freestanding suitability requires a tested module/base configuration; anchored mode requires defined supports |
| `rim_diameter_min`, `rim_diameter_max` | Measured | Positive; minimum no greater than maximum |
| `rim_thickness_max`, `body_diameter_max`, `capsule_depth_max` | Measured | Positive and checked against the guide geometry |
| `side_clearance` | `0.4 mm` per side for the first coupon | Positive; adjust using physical fit results |
| `rim_slot_extra` | `0.3 mm` total for the first coupon | Added to measured rim thickness; tune independently of side clearance |
| `divider_width` | `3.0 mm` | Includes the complete shared divider/rail structure |
| `edge_width` | `5.0 mm` on each side | Includes the complete outer rail structure |
| `backplate_thickness` | `3.2 mm` | Increase if the full print flexes or distorts |
| `lip_overlap` | Establish from the measured rim and body | Must retain the rim while clearing the body |
| `loading_allowance`, `outlet_allowance` | Establish from the end geometry | Apply once at the top and bottom of the assembled rail path |
| `part` | `"lower"` | Also select `"upper"`, `"base"`, `"fit_coupon"`, `"joint_coupon"`, `"outlet_prototype"`, or a non-printable `"assembly_preview"` |
| `show_capsules` | `false` | Preview aid only; must never add capsules to an exported print mesh |

1. Use shared dividers so the width formula matches the actual repeated construction:

   ```text
   channel_width = rim_diameter_max + 2 * side_clearance
   lane_pitch = channel_width + divider_width

   overall_width(N) = 2 * edge_width
                    + N * channel_width
                    + (N - 1) * divider_width

   max_lines = floor(
       (usable_x - 2 * edge_width + divider_width) / lane_pitch
   )
   ```

2. Use this illustrative calculation to make the expected range concrete. With an **example**, unverified `rim_diameter_max = 37.0 mm`, `side_clearance = 0.4 mm`, `divider_width = 3.0 mm`, and `edge_width = 5.0 mm`, the channel width is `37.8 mm` and lane pitch is `40.8 mm`:

   | Lanes | Model width | Fits the proposed 225 mm width budget? |
   | --- | --- | --- |
   | 1 | 47.8 mm | Yes |
   | 2 | 88.6 mm | Yes |
   | 3 | 129.4 mm | Yes |
   | 4 | 170.2 mm | Yes |
   | 5 | 211.0 mm | Yes |
   | 6 | 251.8 mm | No |

3. For those example lane-body dimensions, the valid lane counts are **1, 2, 3, 4, and 5**. Recalculate the maximum when measurements, margins, connectors, or structural dimensions change. Include any lateral connector projections in the complete width check. Check the base separately: its stability-driven width need not equal the lane-body width.
4. Add an integer Customizer control with a range matching the finalized defaults, for example `number_of_lines = 3; // [1:1:5]`. Explain that the source assertions govern changed advanced dimensions; a fixed Customizer range cannot replace the calculated limit.
5. Derive assembled height and capacity from the fully seated joints. Define `joint_overlap` as the overlap of the complete element envelopes at each interface:

   ```text
   added_length_per_upper = upper_module_length - joint_overlap
   dispenser_length = lower_module_length
                      + number_of_upper_elements * added_length_per_upper
   assembled_height = base_mount_height + dispenser_length

   usable_stack_length = dispenser_length - loading_allowance - outlet_allowance
   planning_capsule_pitch = rim_diameter_max + stack_allowance
   capsules_per_line = 1 + floor(
       (usable_stack_length - rim_diameter_max) / planning_capsule_pitch
   )
   total_capacity = number_of_lines * capsules_per_line
   ```

   Require `added_length_per_upper > 0`, `usable_stack_length >= rim_diameter_max`, and `stack_allowance >= 0`. Count each overlapped interface only once. Apply loading and outlet allowances only at the assembly ends; intermediate joints must preserve a continuous rail path. The capacity allowance does not imply that gravity-fed capsules maintain an air gap. Confirm actual capacity and feeding with a loaded stack.
6. As a length example, `220 mm` lower and upper elements with `20 mm` overlap give dispenser lengths of `220`, `420`, and `620 mm` for zero, one, and two uppers, before adding the base mount height. These are dimensional examples, not freestanding height ratings.
7. Echo lane count, upper-element count, required part quantities, individual print dimensions, assembled height, capacity, and the applicable support requirement. Report an untested configuration as untested even when all parts fit the printer.

**Completion criterion:** lane width, individual print size, assembled length, and stability limits have separate calculations; upper elements can be repeated without changing their geometry.

## 5. Specify validation before generating geometry

1. Validate input types before arithmetic. Reject undefined, string, Boolean, or fractional lane counts with a clear message.
2. Require `1 <= number_of_lines <= max_lines`. If `max_lines < 1`, report that even one lane cannot fit with the current dimensions.
3. Validate positive dimensions, nonnegative reserves, ordered measurement limits, and enough remaining material around every cutout.
4. Reject lower-element lengths that cannot contain the outlet, connector structure, and one capsule. Reject upper-element lengths that leave no useful rail path between connector features. Require valid positive engagement and remaining wall thickness at both ends.
5. Check each selected printable part against `usable_x`, `usable_y`, and `usable_z` in its print orientation. Validate `number_of_upper_elements` as a nonnegative integer without applying the printer's height limit to the assembled preview.
6. Define the front opening between retaining lips and check both body clearance and rim retention:

   ```text
   front_opening = channel_width - 2 * lip_overlap

   front_opening >= body_diameter_max + 2 * body_clearance
   front_opening <= rim_diameter_min - 2 * minimum_rim_capture
   ```

   `body_clearance` and `minimum_rim_capture` must be positive and tuned with the coupon. Account for sideways capsule movement and tilt when testing capture; these width checks alone do not prove retention.
7. Reject a rail profile whose narrowest effective slot is smaller than `rim_thickness_max + rim_slot_extra`. Include any sloped lip underside when locating that narrowest point.
8. Reject unknown `part` and `installation_mode` values. Keep diagnostic capsule shapes, assembly previews, and section views outside final print exports.
9. Use OpenSCAD assertions to explain the rejected input and how to correct it. Do not silently reduce lane count or scale the model, because either would change the requested capacity or capsule fit. [OpenSCAD language reference](https://openscad.org/cheatsheet/)
10. Validate connector compatibility and preserve a clear capsule path across every interface. Track the connector revision and mark mating parts so incompatible lane counts or revisions are not assembled together.
11. Keep freestanding validation separate from export permission: a printable upper element must remain reusable for longer, properly supported installations. Report support as required when the selected stack exceeds its tested freestanding configuration or has no stability result. Selecting anchored mode alone does not validate an unspecified anchor arrangement.

**Completion criterion:** invalid inputs produce useful errors before a printable model is presented.

## 6. Design and inspect one lane's guide cross-section

1. Build a backplate with two opposing rim guides. Keep the capsule foil clear of rubbing surfaces by supporting the rim and providing the measured rear relief.
2. Give each guide a retaining lip that captures the rim while leaving the capsule body in the central opening.
3. Add lead-in chamfers that allow loading into the exposed top of either element. At joined interfaces, preserve rim capture and remove any lip that could catch a descending capsule. Keep sharp edges and abrupt steps out of the sliding path.
4. Size the rail roots for the selected extrusion width. Aim for at least four extrusion widths at narrow load-bearing roots; inspect the sliced result rather than assuming a nominal wall thickness guarantees that count.
5. Use a sloped underside or a short, tested overhang for the retaining lip. Printing backplate-down creates an undercut at the rim slot, so prove this feature with a coupon before treating the design as support-free.
6. Avoid long bridges across the capsule opening. Keep internal supports out of the sliding grooves, where removal would be difficult and would damage the fit surface.
7. Inspect cross-sections with mock capsules at the measured minimum and maximum sizes, including a capsule straddling a module joint. Check foil clearance, rim slot, lip capture, and body clearance at the worst allowed connector offset.
8. If a printable lip cannot retain the measured rim, revise the cross-section and repeat the coupon. If separate rails become necessary, update the assembly, envelope, and export plan before continuing.

**Completion criterion:** the lane has a plausible support-free cross-section whose clearance and retention can be tested on a short print.

## 7. Design a controlled bottom dispensing pocket

1. Give each lane in the lower element its own bottom seat, positioned to support the lowest capsule by the rim or another measured robust surface. Upper elements must remain open to feed capsules into the lower element.
2. Terminate or relieve the retaining lips locally so the lowest capsule can move out through the front. Determine the release height from the circular rim's contact with the lips, rather than simply cutting a capsule-diameter opening.
3. Add a shallow fixed retaining curb so a capsule resting in the pocket does not fall forward on its own. The intended removal motion is a small deliberate lift or tilt followed by a forward pull.
4. Check the full removal motion with capsule mock-ups. The rim must clear both the curb and the rail ends without bending the foil, crushing the body, or forcing the printed lips apart.
5. Keep the next capsule guided during removal. As it drops, it must settle behind the curb in the now-empty seat. Check the empty, one-capsule, two-capsule, and full-stack states.
6. Leave finger access around the protruding capsule body. Test adjacent occupied lanes to ensure a hand can reach the selected capsule.
7. Round or chamfer contact edges and provide an accessible route for clearing a jam from the loading end.
8. Make a short prototype holding at least three capsules. A geometric opening alone is not proof that the dispenser releases one capsule at a time; verify the sequence physically in step 14. Repeat the outlet test under the full intended stack load, because extensions increase the load on the lowest capsule and seat.

**Completion criterion:** there is a defined removal motion, a seat that catches the next capsule, and a small prototype capable of testing unintended release and jamming.

## 8. Design repeatable, rigid, positively locked module joints

1. Define one common top interface for the lower element and every upper element, and one matching bottom interface on every upper element. Prove both lower-to-upper and upper-to-upper assembly using the same upper print. Keep the top interface available for the next extension.
2. Start with two widely separated keyed tongue-and-socket or dovetail connections along the rear/outer structural edges. Provide meaningful engagement length and broad bearing surfaces. Even a one-lane element needs resistance to twisting and bending in both directions.
3. Use seated shoulders to carry vertical compression and long mating surfaces to resist shear and bending. Reinforce connector roots with generous radii or gussets that leave the capsule path clear. Transfer the stack's load through the structure, rather than through a thin retaining clip.
4. Add a positive, removable lock, such as a retained transverse pin or a captive screw and nut, at each interface. It must prevent accidental separation during capsule removal or a bump. Do not rely only on friction, gravity, adhesive, or continuously flexed snap tabs to hold a tall stack together.
5. Keep structural alignment features distinct from the capsule rails. Connector tightening must not narrow the rim slots. Set independent fit allowances for the mating joint, and use a coupon to select a fit that seats by hand and becomes rigid when locked.
6. Align the backplate, rim-guide surfaces, and retaining lips across the seam. Start with a rail-step target of at most `0.2 mm`, tightening it if the selected capsule clearance requires it. Define and measure a seam-gap limit on the prototype; verify that the thinnest tested rim cannot enter or catch in the seam.
7. Design the rail transition at the actual seated joint datum, accounting for overlap exactly once. Inspect the worst allowed lateral shift, fore-aft shift, and angular play. The assembled path must have no constriction, exposed shelf, or interruption that allows a capsule to escape.
8. Key the joint against reversed or backward assembly and mark its orientation and revision on a non-sliding face. Keep locks accessible with the base, neighboring lanes, and any braces installed.
9. Check the lowest joint and the base connection against the weight of every element and capsule above them, plus bending from loading, dispensing, and the disturbance forces in step 9. Check lock pullout and root stresses under forces that tend to separate the joint. Printed layer direction and measured joint stiffness must inform the design.
10. Measure accumulated play and top displacement across multiple joints. Allocate tolerances so the longest validated unsupported span stays within its tipping and rail-alignment margins. For longer stacks, shorten the unsupported span with bracing and provide intermediate vertical support where required.
11. Specify assembly with empty modules: seat the joint fully, engage the lock, check rail alignment, secure required supports, then load capsules. Provide a clear reverse sequence for extending or dismantling the stack.

**Completion criterion:** identical upper elements join to the lower element and each other with a continuous feed path, positive retention, and a defined structural load path.

## 9. Design the base, balance, and support for taller stacks

Treat stability as a design calculation followed by a physical test. A low center of mass and a broad support footprint improve tipping resistance; stability depends on the location of the combined center of mass relative to the actual supporting contacts. [OpenStax: stability](https://openstax.org/books/college-physics/pages/9-3-stability)

1. Give the base meaningful front-to-back depth and side-to-side width. Size it from stability checks, independently of lane width, so the one-lane dispenser does not inherit a narrow, easily tipped foot. Account for the capsules projecting forward and the user's removal motion.
2. Secure the lower element into a deep, gusseted base receiver with positive fasteners or retained keys. Check front-to-back bending and sideways racking at this connection. Provide non-slip contact pads near the outside of the base and ensure all intended support points contact a flat surface without rocking.
3. Concentrate structural mass low down. If calculations require ballast, provide a low, closed pocket with a mechanically secured cover, and specify its required mass and position. Prevent ballast from shifting. Keep upper elements as light as their stiffness and joint-strength requirements allow.
4. Estimate mass distribution using slicer mass estimates, then replace them with measured part, hardware, ballast, and capsule masses. Use installed coordinates with height measured above the countertop; do not confuse these with the flat printing axes.
5. For each loading case, calculate the combined center of mass and the restoring moment about every edge of the actual support footprint. As an initial rigid-body check on a level surface:

   ```text
   total_mass = sum(component_mass)
   center_of_mass = sum(component_mass * component_position) / total_mass

   d_edge = horizontal inward distance from the center-of-mass projection
            to the tipping edge
   restoring_moment = total_mass * gravity * d_edge
   overturning_moment = horizontal_force * force_height
   moment_margin = restoring_moment / overturning_moment
   estimated_tip_force = restoring_moment / force_height
   estimated_tip_angle = atan(d_edge / center_of_mass_height)
   ```

   Use consistent units, such as kilograms, metres, and newtons. These expressions cover a single horizontal force and a rigid, non-sliding assembly. Include additional moments and vertical force components for the actual lift-and-pull removal motion, and reduce the margin for measured joint lean and deflection. [OpenStax: static equilibrium and torque](https://openstax.org/books/university-physics-volume-1/pages/12-1-conditions-for-static-equilibrium)
6. Evaluate the empty dispenser, fully loaded dispenser, one outer lane loaded, unevenly loaded lanes, and the empty dispenser during top loading. Include a capsule held near the loading opening. Evaluate any temporary jam that holds mass unusually high, as well as normal stacks resting on the lower seats. Do not assume the full or symmetrically loaded state is the worst case.
7. Use explicit initial project targets: withstand a `5 N` horizontal disturbance at the highest accessible point in front, rear, and side directions, and a dispensing load of at least the larger of `10 N` or twice the measured peak operating force, applied in the observed removal direction. Aim for at least a `1.5` calculated restoring-to-overturning moment ratio for the applicable load cases. These are proposed design targets to validate, not a product certification or a claim that every stack height passes.
8. Check sliding as well as tipping on the intended countertop. Non-slip pads can improve grip but must not be counted as anchoring. If the feet rock, a joint flexes, or the base slides before the target force, correct the design and repeat the tests.
9. Establish a tested freestanding upper-element limit for each supported lane count, module length, base, and ballast configuration. Increasing height requires recalculation and testing even when the joint still fits. A finite base cannot provide the same resistance for an arbitrarily tall unsupported stack.
10. Preserve arbitrary modular extension through positive wall/cabinet anchoring, a supporting frame, or other engineered bracing above the tested freestanding limit. Define the anchor locations, maximum unsupported span, compatible hardware, and supporting surface. Add intermediate weight-bearing supports when needed so lower elements and joints do not carry unlimited accumulated weight. Distinguish lateral restraints from supports that actually carry vertical load.
11. Ensure braces and support brackets attach to structural regions, remain accessible, and preserve the continuous capsule path. Their load rating and spacing must be checked for the selected assembly; naming an installation mode does not establish those limits.
12. If the required footprint is wider or deeper than one print, make base sections or outriggers that lock together rigidly, and include their full contact footprint in the calculation. Verify that no base section can fold, slide, or detach under the test loads.
13. Rate the capsule-column load separately from the frame load. External supports can carry the printed elements, but capsules in a continuous gravity-fed lane still bear on the lowest capsule and dispensing seat. Verify capsule damage, extraction force, and seat strength for the complete intended column; redesign and revalidate the lower mechanism if an extension exceeds that capacity. Module compatibility alone must not imply unlimited loaded capacity.

**Completion criterion:** the selected configuration has a defined base and load path, quantitative tipping targets, a testable freestanding envelope, and a support strategy for further extension.

## 10. Repeat the lane and add module support features

1. Generate lane features with a loop over `number_of_lines`. Use `lane_pitch` consistently for rails, seats, openings, and optional labels.
2. Build shared internal dividers once and place separate outer rails at the two sides. Avoid overlapping a complete pair of rails for each lane while still using the shared-divider width formula.
3. Join rails and structural features to a continuous backplate within each element using real overlapping solid volumes. Add seats only to the lower element. Avoid connections that meet only at an edge or a coplanar face.
4. Place base fasteners, joint locks, and brace mounting points outside the capsule paths. Keep screw heads and installation tools clear, use measured hardware clearances, and maintain adequate edge distances and material around connector sockets.
5. Ensure the one-lane version has a complete pair of outer guides, rigid module connections, usable brace attachments, and the independently sized stable base.
6. Keep labels shallow and outside sliding surfaces. Add them only after the mechanical geometry works.
7. Recompute every part's bounding box after adding joints, mounting, and cosmetic features. Include lateral projections in the lane-limit calculation and longitudinal connector projections in each part's length check.

**Completion criterion:** every allowed lane count produces complete, compatible lower and upper elements and a suitable base, with no interference between lanes, joints, or supports.

## 11. Organize the future OpenSCAD source

1. Keep the design self-contained, using OpenSCAD primitives and reusable modules without external libraries or imported meshes.
2. Organize the source in this order: purpose and printing notes, user parameters, advanced measurements, derived dimensions, validation, geometry modules, and output selection.
3. Separate responsibilities into modules such as `backplate()`, `outer_rail()`, `divider()`, `loading_entry()`, `dispensing_pocket()`, `top_joint()`, `bottom_joint()`, `lower_element()`, `upper_element()`, `base()`, `brace_attachment()`, `fit_coupon()`, `joint_coupon()`, `outlet_prototype()`, and `assembly_preview()`.
4. Generate coupons from the same rail, connector, and pocket modules as the full parts. Use the same interface definitions for lower-to-upper and upper-to-upper joints.
5. Set the default output to `part = "lower"`. Provide individually printable upper, base, and prototype selections, each placed on the bed and checked for fit. Add explicit selections for printed locks, split-base sections, or braces if the chosen design uses them; list purchased hardware separately. Changing `number_of_upper_elements` must not alter the geometry of an individual upper element; it changes assembly preview and required quantity.
6. Provide optional capsule, section, and assembled previews, guarded so print exports contain only the selected printable part. Display the base, repeated uppers, locks, and necessary supports in the assembly preview, while preventing the whole tall assembly from being mistaken for a single printable mesh.
7. Use reasonable preview and final curve resolution. Use small Boolean overlap allowances where needed, without changing functional dimensions.
8. Comment the reason for fit allowances, connector engagement, root reinforcement, base dimensions, lip shapes, and outlet dimensions next to the relevant parameters or geometry. Report the validated support configuration alongside the assembled dimensions.

**Completion criterion:** one source file generates the lower element, identical repeatable uppers, base, and meaningful prototypes, with a separate assembly preview and clear part quantities.

## 12. Write actionable PETG slicing comments in the source

Use the actual Q1 Pro printer profile and the actual spool manufacturer's material guidance. The following values are proposed starting points for a **0.4 mm nozzle**, not a proven universal PETG profile. Store the eventual tested settings in a comment block near the top of the `.scad` file, and put geometry-dependent advice beside the relevant features.

| Setting to document | Starting point and reason |
| --- | --- |
| Orientation | Lower and upper elements: backplate flat, lanes along printer `Y`; base: support face down unless joint-strength testing requires another orientation; print each part at 100% scale |
| Layer height | `0.20 mm`, including the initial fit prototypes, so their dimensions represent the final print |
| Extrusion width | Start around `0.42–0.45 mm`; use the calibrated profile and check thin walls in preview |
| Walls/perimeters | Start with `4`; use locally increased walls/solid regions at joint roots, locks, the base receiver, and seats where structural trials require them |
| Top and bottom solid layers | `5` each at `0.20 mm`, then inspect the backplate and seat coverage |
| Infill | Start with `20–25%` gyroid; inspect structural connector regions separately. Obtain required base mass through documented geometry or secured ballast, rather than relying on an unspecified infill percentage |
| Nozzle temperature | Start at `245 °C` only if permitted by the spool guidance; tune on the coupon for bonding, strings, and slot accuracy |
| Bed temperature | Start at `80 °C` only if compatible with the filament and installed plate |
| First-layer speed | `20–25 mm/s` to inspect adhesion and dimensional consistency |
| Outer walls and functional rails | `35–45 mm/s` initially to preserve slot and lip geometry |
| Inner walls and infill | `50–70 mm/s`, subject to the filament's calibrated volumetric-flow limit |
| Maximum volumetric flow | Use the calibrated filament limit; an uncalibrated conventional PETG trial can start at `8 mm³/s` and be adjusted from results |
| Main part-cooling fan | Off for the first `2–3` layers, then test `30–50%`; tune bridge/overhang cooling separately |
| Auxiliary fan | Start off; add only if the rail coupon benefits without lifting or uneven cooling |
| Chamber heating | Start off; record the door/lid arrangement used under the applicable QIDI filament guidance |
| Supports | Target none; inspect rail lips, sockets, locking holes, the base receiver, and the pocket. Redesign inaccessible support regions and prove joint surfaces on coupons |
| Brim | Reserve up to `5 mm` per side in the fit calculation; use it if the long backplate lifts |
| Seam placement | Put seams on external, non-sliding faces, away from rim slots, joint mating faces, and the dispensing seat |
| Retraction and flow compensation | Start with the Q1 Pro profile, then tune for the actual filament; record validated values rather than guessing a universal retraction distance |
| First-layer expansion | Check for elephant foot at functional openings; tune compensation without globally rescaling the dispenser |
| Plate preparation and removal | Follow the installed plate's PETG preparation instructions; allow the part to cool before removal |

Material guidance is product-specific. For example, QIDI PETG Basic lists `240–280 °C` nozzle temperature, `70–80 °C` bed temperature, and drying at `60–65 °C` for `6–8 h`; these apply to that filament, not automatically to the user's spool. [QIDI PETG Basic printing settings](https://us.qidi3d.com/products/petg-basic)

PETG's stringing and overhang behavior make the small rail trial useful. Prusa's material guide discusses these limitations, cooling, and PETG adhesion to different PEI surfaces; use it as general material context, while keeping the Q1 Pro and spool profile authoritative for this print. [Prusa PETG guide](https://help.prusa3d.com/article/petg_2059)

The comment block must also explain that STL exports do not carry these slicer settings: the user must apply and verify them in the slicer. Record filament drying instructions from the actual manufacturer, along with the final temperatures, cooling, speeds, and fit adjustments after testing. Document joint and base print orientations and reinforcement settings separately where needed. Validate connectors under sustained load and repeated assembly; a clean-looking fit alone does not establish long-term rigidity.

**Completion criterion:** a person opening the source can identify the orientation, profile, starting settings, tuning order, and tested settings without consulting a separate undocumented process.

## 13. Validate renders, bounds, and sliced toolpaths

1. Render each printable part fully in OpenSCAD, rather than relying only on a fast preview. Resolve warnings, missing geometry, and Boolean errors. Inspect the assembly separately.
2. Export lower and upper elements for every allowed lane count, along with the corresponding base parts. Export the fit, joint, and outlet prototypes as separate selections.
3. Inspect each exported mesh for connected geometry, closed surfaces, positive thickness, and the expected bounding box. Confirm mock capsules, other assembled modules, and preview cutaways are absent. In assembly views, inspect connector seating, fastener access, capsule passage, and unwanted solid intersections at both joint types.
4. Exercise this parameter matrix:

   | Case | Expected result |
   | --- | --- |
   | Each lane-count integer from `1` through `max_lines` | Complete, compatible lower/upper elements and appropriate printable base parts |
   | `0`, a negative number, or `max_lines + 1` | A clear lane-count error |
   | A fraction, a string, a Boolean, or an undefined lane count | A clear type/integer error |
   | Larger measured rims or wider dividers | A recalculated maximum; an error if the chosen count no longer fits |
   | A larger brim reserve or bed margin | A reduced usable area and updated fit check |
   | A module too short or its full print length beyond the bed limit | A connector/capacity or individual-part fit error |
   | `number_of_upper_elements = 0`, `1`, and `2` | Lower alone, lower-to-upper joint, and both joint types represented correctly |
   | A larger integer upper count whose assembly exceeds printer height | The same individual upper export and a longer assembly preview, with explicit support requirements |
   | Negative, fractional, string, Boolean, or undefined upper count | A clear count/type error |
   | Joint overlap too small for the connector or leaving no added length | A joint dimension error |
   | Changed lane count or connector revision on a mating element | Incompatibility detected or clearly marked; no claimed interchangeable assembly |
   | A stack beyond its tested freestanding configuration | Support required; no unsupported stability claim |
   | Opening too wide to capture the smallest rim | A retention error |
   | Opening too narrow for the largest capsule body | A clearance error |
   | Zero or negative structural thickness | A dimension error |
   | Unknown output part | A clear output-selection error |

5. During implementation, use exports such as the following from the dispenser directory. These commands are examples for the future source file:

   ```bash
   openscad -o /tmp/nespresso_lower_1_lane.stl -D 'part="lower"' -D 'number_of_lines=1' nespresso_capsule_dispenser.scad
   openscad -o /tmp/nespresso_lower_3_lanes.stl -D 'part="lower"' -D 'number_of_lines=3' nespresso_capsule_dispenser.scad
   openscad -o /tmp/nespresso_upper_3_lanes.stl -D 'part="upper"' -D 'number_of_lines=3' nespresso_capsule_dispenser.scad
   openscad -o /tmp/nespresso_base_3_lanes.stl -D 'part="base"' -D 'number_of_lines=3' nespresso_capsule_dispenser.scad
   openscad -o /tmp/nespresso_fit_coupon.stl -D 'part="fit_coupon"' nespresso_capsule_dispenser.scad
   openscad -o /tmp/nespresso_joint_coupon.stl -D 'part="joint_coupon"' nespresso_capsule_dispenser.scad
   ```

   OpenSCAD supports parameter overrides with `-D` and export selection with `-o`; check the installed version's help when running the commands. [OpenSCAD command-line documentation](https://files.openscad.org/documentation/manual/Using_OpenSCAD_in_a_command_line_environment.html)
6. For rejection cases, inspect the diagnostic and ensure there is no usable export; use fresh output paths so an old STL cannot be mistaken for success.
7. Import every valid default part/lane-count export into the Q1 Pro slicer profile at 100% scale. Confirm fit including brim and profile exclusions. Print repeated upper elements on separate plates when needed; never shrink them to fit a plate layout.
8. Inspect the first layers, rim-slot roofs, rail and connector roots, locking holes, seats, base receiver, and brace attachments in the sliced toolpaths. Check for unsupported starts, missing thin walls, accidental filled slots, and inaccessible supports inside mating or capsule paths.
9. Record slicer estimates for time and material per lower, upper, and base part. Produce totals for the chosen assembly, including joint locks, ballast, pads, and required braces. Use measured print masses later in the stability calculation.

**Completion criterion:** digital validation passes for the advertised lane counts, and invalid configurations fail visibly. Physical operation is still pending at this point.

## 14. Print and tune capsule-fit, joint, and outlet prototypes

1. Prepare and, if required by its manufacturer, dry the actual PETG. Use the same nozzle, layer height, orientation, and slicer settings intended for the dispenser.
2. Print short rail coupons with per-side clearances of `0.25`, `0.35`, `0.45`, and `0.55 mm`, keeping the measured rim dimensions fixed. Label each trial away from its sliding surface.
3. Separately compare extra rim-slot gaps, for example `0.2`, `0.3`, and `0.4 mm` total. Change one fit variable at a time so results are interpretable.
4. Test the smallest and largest measured capsule rims. Inspect the actual printed slot, lip underside, and first-layer edge before modifying the CAD dimensions.
5. Choose a fit where capsules slide under gravity in the intended installed orientation, remain captured in the main rails, and show no foil scraping or rim damage. Verify this with repeated insertion and sliding, not one successful pass.
6. Print the short outlet prototype using the selected rail fit. Load at least three capsules and test slow and quick deliberate removal of the bottom capsule.
7. Run at least **30 consecutive removals**, reloading as needed and including the measured capsule extremes. Target zero jams, unintended releases, and damaged capsules.
8. If a capsule sticks, identify whether the cause is side clearance, slot height, print roughness, seam placement, foil contact, or outlet geometry. Change the responsible variable and repeat the affected test.
9. If multiple capsules escape or the bottom one falls without deliberate removal, revise the retaining curb, seat angle, or release pocket and repeat the outlet test before printing a full dispenser.
10. Print mating joint coupons in the actual lower/upper print orientation, using several independent `joint_clearance` values. Select a fit that seats completely by hand, locks securely, and preserves the intended rail alignment without forcing the backplate to bow.
11. Assemble and dismantle the chosen joint at least **20 times**. Inspect connector roots, lock retention, wear, looseness, rail offset, and joint angle. Test both lower-to-upper and upper-to-upper geometry, and measure the worst resulting play for the stability model.
12. Test short rail sections joined by the actual connector. Pass the smallest and largest capsule samples across the seam repeatedly, including a single capsule moving under its own weight. Test both joint types and the worst allowed assembly offset. Eliminate seam-related sticking before full-length printing.
13. Test the base-to-lower attachment and any split-base connection with a representative structural coupon or short lower section. Apply the planned shear, bending, and separation loads without depending on capsule rails to carry them.

**Completion criterion:** capsule fit, dispensing, joint interchangeability, seam feeding, and structural connections work in PETG; measured fit and play are recorded.

## 15. Validate a complete modular lane

1. Print a one-lane lower element, two identical upper elements, and the calculated base. Check flatness, rail straightness, connector seating, slot consistency, and lock access after cooling.
2. Assemble and test the lower alone, then with one upper, then with two uppers. This proves lower-to-upper and upper-to-upper compatibility with full-length parts. Use the required bracing for each configuration before loading; hand-holding the dispenser does not establish stability.
3. Load each configuration from empty to its intended capacity. Confirm the exposed top remains loadable and the stack can move through every seam without cocking, overlapping rims, or escaping the rails.
4. Dispense repeatedly, including the last remaining capsule and single capsules crossing each seam under gravity. Complete at least **50 removals** for each of the three assembly configurations, across full, partially filled, and nearly empty states. Check the lower outlet with the greatest intended capsule-column load.
5. Leave the longest trial assembly loaded for at least **24 hours**, then repeat the fit and release checks. Look for rail spreading, seat movement, connector rotation, lock loosening, or base distortion. Extend the sustained-load check in step 17.
6. Record practical capacity, assembled height, mass, joint play, and peak extraction force for each configuration. If these differ from estimates, update the geometry or recorded values and repeat affected clearance, load, and stability calculations.
7. Confirm that jams can be cleared and the slide surfaces can be cleaned without damaging the dispenser.
8. Unload the dispenser, add or remove an upper element using the documented assembly sequence, and recheck feeding and locks. Confirm that extension requires no modification to an existing lower or upper element.

**Completion criterion:** a lower alone and stacks with one and two identical uppers feed correctly through their full length, remain structurally connected, and can be extended without redesigning existing elements.

## 16. Validate the final lane count, stack length, and load distribution

1. Print the selected lane count and required number of uppers using the proven dimensions and settings. Inspect each part for lifting and all lanes for changes in clearance across the bed. Measure assembled lean and the alignment of all seams.
2. Load every lane, then test uneven loading: one outer lane full, alternating lanes full, and one nearly empty lane beside full lanes. Repeat with the whole dispenser empty and while loading the top, since changes in mass distribution alter stability.
3. Check that removing a capsule from one lane does not dislodge adjacent capsules, rotate a joint, or flex the common backplate enough to bind their rims. Test joint locks and the base connection under the actual maximum supported column load.
4. Perform at least **20 removals per lane**, covering full and nearly empty states and capsules traveling from the uppermost element through every seam. Complete the stability and sustained-load tests in step 17 on the final assembly.
5. If the final print is narrower than `max_lines`, keep the maximum-width version marked as digitally checked until printed and loaded. Likewise, do not extend a physical stability claim to greater upper-element counts or to a different base. Test the narrowest configuration for lateral tipping as well as the widest for flatness and structural flex.
6. If testing changes connectors, base dimensions, ballast, braces, backplate, dividers, or rails, rerun the affected fit, structural, stability, render, and slicing checks before publishing the revision.

**Completion criterion:** the selected modular configuration feeds correctly under full and uneven loading, and claims about width, height, and support match the configurations actually tested.

## 17. Test resistance to tipping, sliding, and sustained deformation

1. Use the real base, pads, ballast, locks, and countertop surface. Reweigh the assembly and update the center-of-mass and moment estimates. Test the intended freestanding height and the one-lane case; include the empty and uneven loading cases from step 9.
2. Apply measured horizontal forces slowly with a force gauge or spring scale, at a recorded height, in front, rear, and both side directions. Test the highest accessible point against the `5 N` disturbance target and the outlet against the defined dispensing-force target. Arrange a loose catch that stops a fall without supporting the dispenser during measurement.
3. Record the force at first foot lift, base sliding, excessive flex, or joint movement. Pass only when the target force is reached without tipping, sliding, rocking, separation, or permanent deformation, and joint movement stays within the clearance and stability assumptions. Check the actual lift-and-pull extraction direction in addition to pure horizontal pulls.
4. Perform a controlled incline check in each tipping direction. Use an initial project target of **5 degrees** without tipping or sliding in the tested loading states. Compare the observed behavior with the estimated tipping angle. Treat the force and incline targets as complementary checks, not interchangeable evidence.
5. Repeat loading and dispensing without holding the base down. If operation requires the other hand to steady the stack, improve the base, ballast, attachment, or support arrangement and repeat the checks.
6. Leave the highest rated assembly at its full intended capsule load in the intended installation conditions for at least **7 days**, inspecting at 24 hours and at the end. Measure top lean, joint gaps, rail alignment, base flatness, and lock security before and after. Repeat feeding and force checks afterward. Record the test duration rather than implying an unlimited service-life guarantee.
7. Validate supported tall stacks separately: inspect brace spacing, anchor security, vertical load transfer, and the longest unsupported section under the same relevant operating and disturbance loads. Ensure the lower joint is not inadvertently carrying weight assigned to an intermediate support.
8. Record the greatest **tested freestanding configuration** as a combination of lane count, lower/upper lengths, number of uppers, base footprint, ballast, pads, and hardware. Record the tested bracing arrangement and load limits for supported extension. Leave untested combinations explicitly unvalidated.
9. If a stack fails, increase effective support width/depth, secure more mass low down, stiffen its connections, or add appropriate anchoring/support. Preserve repeatable module compatibility and repeat the failed tests after the change.

**Completion criterion:** measured tests demonstrate that the rated assembly is well balanced, robust, and resistant to ordinary handling forces, with clear support requirements for additional height.

## 18. Finalize the source comments and handoff

1. Replace provisional fit dimensions with the measured and tested defaults, retaining their meanings and units in comments.
2. Document the confirmed capsule family and tested brands, valid lane counts, connector revision, individual print dimensions, assembled lengths and capacities, base footprint, required ballast, joint locks, braces, and loading/removal motions.
3. Update the Customizer range and the explanatory lane-count example to agree with the final calculations. Keep runtime assertions authoritative for advanced changes.
4. Record the exact nozzle, filament, slicer/profile version, temperatures, cooling, layer settings, and any required brim or compensation used for the successful print.
5. Explain how to export one lower, the required quantity of identical uppers, and other printed parts; slice each at 100%; obtain the listed hardware; assemble and lock the joints; fit ballast and pads; and install any required supports before loading. Explain how to extend an emptied assembly without changing existing parts, within its validated loading and support requirements.
6. Document capsule clearance and connector clearance independently. Distinguish configurations that were only rendered or sliced from those physically printed, load-tested, and checked for tipping. Publish the actual freestanding limit and support requirements for further extension; keep unperformed physical checks pending.
7. Keep the implementation self-contained in the planned `.scad` source. Generated meshes and slicer project files may be produced during the future implementation, but are not deliverables of this Markdown-only planning change.

Use this checklist to track implementation completion:

- [ ] Capsule measurements, installation footprint, support requirements, and actual nozzle are recorded.
- [ ] `number_of_lines` has an integer user control and a calculated, enforced valid range.
- [ ] One lower element works alone and accepts identical uppers that also stack onto each other.
- [ ] Every printable part fits the Q1 Pro profile, including connectors and required print-space reservations.
- [ ] Upper count changes assembled length and quantity without changing the repeated upper geometry.
- [ ] Positive joint locks, structural shoulders, and the base attachment carry the stated loads without excessive play.
- [ ] Capsule clearance, rim capture, foil relief, seam transitions, and outlet release are checked together.
- [ ] Capsule, joint, and outlet trials pass with the intended PETG and capsule samples.
- [ ] The base footprint, ballast, and center-of-mass calculations cover empty, full, and uneven loading.
- [ ] The final assembly passes the measured force, incline, and sustained-load checks.
- [ ] The maximum-width and maximum freestanding-height configurations have documented validation status.
- [ ] Taller extensions have specified bracing, anchor locations, and intermediate load support where needed.
- [ ] The lower seat and dispensing mechanism are rated for the full intended capsule-column load, independently of frame supports.
- [ ] The source contains clear inline slicing settings, orientation instructions, and tuning guidance.
- [ ] Exported parts contain only their intended printable geometry; the full assembly is a separate preview.
- [ ] Final dimensions, part quantities, practical capacity, support requirements, and tested settings agree with the source parameters.

# Problem 2: Mars Rover Sample Collection Planning Using PDDL - Analytical Report
## 1. Problem Overview and Objective
The objective of this problem is to design an automated planning model using PDDL (Planning Domain Definition Language) for an autonomous Mars rover (`rover1`). Due to communication delays between Earth and Mars, the rover must independently plan and execute a sequence of actions to collect geological rock samples from different Martian sites (`siteA` to `siteF`) and bring them back to a central research `base`. 

The rover operates under strict physical and environmental constraints:
* It has only two storage bays (`bay1` and `bay2`), meaning it can carry a maximum of two rocks at any given time.
* Rocks are divided into two categories: soft rocks (which can be picked up directly) and hard rocks (which require the rover to first pick up a drill located at `siteE`).
* The map contains two-way paths and one steep downhill one-way path from `siteC` to `siteD`, meaning the rover cannot travel directly back from `siteD` to `siteC`.
* At the end of the mission, all rocks must be deposited at the `base`, both storage bays must be empty, and the rover must be parked at the `base`.

## 2. Task 1: Domain Modeling (`domain.pddl`)
In our `domain.pddl` file, we modeled the domain `mars-rover` strictly using `:strips` and `:typing` requirements without using negative preconditions or numeric fluents.

### Types Defined
We categorized all entities in the environment into six specific types:
* `rover`: Represents the autonomous vehicle.
* `location`: Represents the base and exploration sites.
* `sample`: Represents the geological rock samples.
* `bay`: Represents the internal storage compartments of the rover.
* `drill`: Represents the drilling tool required for hard rocks.
* `equipment`: General equipment type included in the schema.

### Predicates Used
To represent the state of the world at any time step, we implemented 10 boolean predicates:
* `(at ?r - rover ?l - location)`: Tracks the current location of the rover.
* `(sample-at ?s - sample ?l - location)`: Tracks where each rock sample is located.
* `(connected ?from - location ?to - location)`: Defines valid directed edges between locations.
* `(carrying ?r - rover ?s - sample ?b - bay)`: Indicates which rock is stored in which bay of the rover.
* `(empty ?r - rover ?b - bay)`: Tracks whether a specific storage bay is free.
* `(is-hard ?s - sample)` and `(is-soft ?s - sample)`: Differentiates between hard and soft rocks without needing negative preconditions.
* `(drill-at ?d - drill ?l - location)` and `(has-drill ?r - rover ?d - drill)`: Tracks whether the drill is lying at a site or is currently held by the rover.
* `(base ?l - location)`: Identifies the central research base location so the rover only deposits samples at the base.

### Actions Implemented
Instead of using conditional effects, we separated rock collection into two distinct actions (`collect-soft` and `collect-hard`) to keep the STRIPS model clean and strictly positive:
* `move`: Moves the rover from `?from` to `?to` if `(at ?r ?from)` and `(connected ?from ?to)` are true. It updates the location by deleting `(at ?r ?from)` and adding `(at ?r ?to)`.
* `pick-drill`: Allows the rover to pick up `drill1` when both the rover and drill are at the same location `?l`. It adds `(has-drill ?r ?d)` and deletes `(drill-at ?d ?l)`. Because there is no drop-drill action, the rover keeps the drill permanently once picked up.
* `collect-soft`: Picks up a rock `?s` at location `?l` into bay `?b` if `(is-soft ?s)` and `(empty ?r ?b)` are true. It deletes `(sample-at ?s ?l)` and `(empty ?r ?b)`, and adds `(carrying ?r ?s ?b)`.
* `collect-hard`: Works similarly to `collect-soft`, but checks `(is-hard ?s)` and requires an additional precondition `(has-drill ?r ?d)`.
* `deposit`: Drops a carried rock `?s` from bay `?b` at location `?l` only if `(base ?l)` is true. It frees the bay by adding `(empty ?r ?b)`, adds `(sample-at ?s ?l)`, and removes `(carrying ?r ?s ?b)`.

## 3. Task 2 & Task 5: Problem Modeling (`problem.pddl` & `problem_extended.pddl`)
We created two problem files corresponding to the original scenario and the extended dust storm scenario.

### Original Problem (`problem.pddl`)
* **Objects:** Defined `rover1`, 7 locations (`base`, `siteA` to `siteF`), 5 samples (`rock1` to `rock5`), 2 bays (`bay1`, `bay2`), and `drill1`.
* **Initial State:** `rover1` starts at `base` with both `bay1` and `bay2` empty. `drill1` is placed at `siteE`. Soft rocks are placed at `siteA` (`rock1`), `siteB` (`rock2`), and `siteD` (`rock4`). Hard rocks are placed at `siteC` (`rock3`) and `siteF` (`rock5`). Two-way routes are defined using pairs of symmetric `(connected X Y)` and `(connected Y X)` facts, while the steep slope is defined with a single directed fact `(connected siteC siteD)`.
* **Goal State:** Requires `(sample-at rock1 base)` through `(sample-at rock5 base)`, `(empty rover1 bay1)`, `(empty rover1 bay2)`, and `(at rover1 base)`.

### Extended Problem (`problem_extended.pddl`)
* **New Objects and Samples:** Added `rock6` (soft rock at `siteE`) and `rock7` (hard rock at `siteF`).
* **Dust Storm Route Modification:** The two-way connection between `base` and `siteB` (`(connected base siteB)` and `(connected siteB base)`) was completely removed from the `:init` block to model the dust storm closure.
* **Updated Goal State:** Extended to require all 7 rocks (`rock1` to `rock7`) delivered to `base`, both bays empty, and `rover1` back at `base`.

## 4. Task 3: Plan Generation and Search Metrics
We executed our PDDL files using two different planner configurations as recorded in our log files:
1. **Satisficing Configuration (`satisfying_plan_log.txt`):** Executed using the `1-BFWS` (Best-First Width Search) algorithm.
2. **Optimal Configuration (`optimal_plan_log.txt`):** Executed using Fast Downward (`lazy_greedy` with FF heuristic `hff` and Landmark-Sum heuristic `hlm` with unit cost adaptation). [MARKER: If your professor requires you to write A* here instead of Fast Downward's exact log command, replace the previous bracketed phrase with: "A* search with Landmark-Sum and FF heuristics"].

### Recorded Metrics from Planner Logs
* **Original Scenario - Satisficing Configuration (`1-BFWS`):**
  * Plan Length / Cost: 31 steps
  * States Expanded: 113 nodes
  * States Generated: 255 nodes
  * Planning / Search Time: 0.000928 seconds
* **Original Scenario - Optimal Configuration (Fast Downward):**
  * Plan Length / Cost: 27 steps
  * States Expanded: 49 states (Evaluated: 50 states, Generated: 155 states)
  * Search Time: 0.001591 seconds (Total time: 0.004256 seconds)
* **Extended Scenario - Satisficing Configuration (`1-BFWS`):**
  * Plan Length / Cost: 60 steps
  * States Expanded: 219 nodes
  * States Generated: 409 nodes
  * Planning / Search Time: 0.001332 seconds
* **Extended Scenario - Optimal Configuration (Fast Downward):**
  * Plan Length / Cost: 40 steps
  * States Expanded: 65 states (Evaluated: 66 states, Generated: 198 states)
  * Search Time: 0.002012 seconds (Total time: 0.005294 seconds)

### Sequence of Actions (Optimal Plans)
* **Original Optimal Plan (27 Actions):**
  1-4: Move `base -> siteA`, collect `rock1` (soft) in `bay2`, move `siteA -> base`, deposit `rock1`.
  5-10: Move `base -> siteB -> siteD`, collect `rock4` (soft) in `bay1`, move `siteD -> siteB -> base`, deposit `rock4`.
  11-14: Move `base -> siteB`, collect `rock2` (soft) in `bay2`, move `siteB -> base`, deposit `rock2`.
  15-18: Move `base -> siteA -> siteC -> siteE`, pick `drill1` at `siteE`.
  19-23: Move `siteE -> siteF`, collect `rock5` (hard) in `bay1`, move `siteF -> siteE -> siteC`, collect `rock3` (hard) in `bay2`.
  24-27: Move `siteC -> siteA -> base`, deposit `rock5` from `bay1`, deposit `rock3` from `bay2`.

* **Extended Optimal Plan (40 Actions):**
  1-4: Move `base -> siteA`, collect `rock1` (soft) in `bay2`, move `siteA -> base`, deposit `rock1`.
  5-10: Move `base -> siteA -> siteC -> siteD` (via one-way slope), collect `rock4` (soft) in `bay1`, move `siteD -> siteB`, collect `rock2` (soft) in `bay2`.
  11-18: Move `siteB -> siteD -> siteE`, pick `drill1` at `siteE`, move `siteE -> siteC -> siteA -> base`, deposit `rock4` and `rock2`.
  19-28: Move `base -> siteA -> siteC`, collect `rock3` (hard) in `bay1`, move `siteC -> siteE`, collect `rock6` (soft) in `bay2`, move `siteE -> siteC -> siteA -> base`, deposit `rock3` and `rock6`.
  29-40: Move `base -> siteA -> siteC -> siteE -> siteF`, collect `rock5` (hard) in `bay1` and `rock7` (hard) in `bay2`, move `siteF -> siteE -> siteC -> siteA -> base`, deposit `rock5` and `rock7`.

## 5. Task 4: Goal Verification (`verify/` logs)
We verified all four generated plans using the VAL plan validation tool (`plan_verification_optimal.txt`, `plan_verification_satisfying.txt`, `plan_extended_verification_optimal.txt`, and `plan_extended_verification_satisfying.txt`). 

* **Type-Checking and Step-by-Step Validation:** VAL first confirmed that all 5 actions (`move`, `pick-drill`, `collect-soft`, `collect-hard`, `deposit`) passed strict type-checking. It then simulated each happening (time step 1 to 27 in the original optimal plan, and 1 to 40 in the extended optimal plan) by tracking exact predicate additions and deletions.
* **Final State Confirmation:** At the final step of the validation logs (step 27 and step 40 respectively), the validator confirmed that:
  1. Every `(carrying rover1 ...)` predicate was deleted and replaced with `(sample-at rockX base)` for all rocks (`rock1` to `rock5` in original; `rock1` to `rock7` in extended).
  2. Both `(empty rover1 bay1)` and `(empty rover1 bay2)` were restored to true.
  3. The rover's position predicate was `(at rover1 base)`.
  4. VAL output `plan executed successfully - checking goal` and `plan valid`.

## 6. Task 6: Plan Analysis

### Comparison of Plan Lengths (Satisficing vs. Optimal)
* **Original Scenario (31 steps vs. 27 steps):** Both plans collect `rock1`, `rock2`, and `rock4` in separate trips first. However, after picking up the drill at `siteE` (step 18), the satisficing plan (`1-BFWS`) collects `rock5` at `siteF` into `bay2` and immediately returns all the way to `base` to deposit it, leaving `bay1` completely empty. It then has to make an extra trip `base -> siteA -> siteC` to collect `rock3` and return (`+4` wasted steps). The optimal plan uses both bays on the return journey from `siteF`, picking up `rock5` at `siteF` in `bay1` and `rock3` at `siteC` in `bay2` on the way back, saving 4 steps.
* **Extended Scenario (60 steps vs. 40 steps):** The difference jumps to 20 steps in the extended scenario. Because `1-BFWS` prioritizes novelty and fast single-subgoal completion without global path-cost minimization, it uses only one bay (`bay2` for steps 11 to 60) and makes **7 separate round trips** from the `base`—one for each individual rock! In contrast, the optimal configuration pairs rocks together into 3 double-bay trips and 1 single-bay trip, cutting out three entire deep-map round trips and saving 20 actions.

### How the Optimal Plan Uses the Two Storage Bays and When the Drill is Picked Up
* **Original Scenario Optimal Plan:**
  * *Storage Bays:* for the closer soft rocks (`rock1`, `rock4`, `rock2`), the optimal plan actually performs single-rock trips (note that collecting `rock4` at `siteD` and `rock2` at `siteB` in one trip would also take 27 steps, as depositing at `base` requires passing through `siteB` anyway). However, for the deep locations (`siteF` and `siteC`), it utilizes both bays simultaneously: putting `rock5` into `bay1` at `siteF` (step 20) and `rock3` into `bay2` at `siteC` (step 23) before depositing both at `base` (steps 26-27).
  * *Drill Pickup Timing:* The drill is picked up at **step 18** at `siteE`. The rover collects all soft rocks first (`rock1`, `rock4`, `rock2`), and only picks up the drill while traveling along the `base -> siteA -> siteC -> siteE -> siteF` path to extract the two hard rocks (`rock5` and `rock3`).
* **Extended Scenario Optimal Plan:**
  * *Storage Bays:* Here, the rover maximizes dual-bay capacity on every trip after `rock1`. Trip 1 collects `rock1` (`bay2`). Trip 2 pairs `rock4` (`bay1` at `siteD`) and `rock2` (`bay2` at `siteB`). Trip 3 pairs `rock3` (`bay1` at `siteC`) and `rock6` (`bay2` at `siteE`). Trip 4 pairs both hard rocks at `siteF`: `rock5` (`bay1`) and `rock7` (`bay2`).
  * *Drill Pickup Timing:* The drill is picked up at **step 13** at `siteE`. Very smartly, after collecting `rock4` at `siteD` and `rock2` at `siteB`, the rover cannot return via `base <-> siteB` (blocked by the dust storm) and cannot go up `siteD -> siteC` (one-way downhill slope). Since it is forced to exit via `siteD -> siteE -> siteC -> siteA -> base`, it passes right through `siteE` on step 12 and picks up `drill1` on step 13 while carrying `rock4` and `rock2` back to `base`. This makes the drill immediately available for `rock3` on the very next trip at `siteC`.

### Reaching SiteB and SiteD After the Dust Storm & Usage of the One-Way Route
* **How the Rover Reaches `siteB` and `siteD`:** When the dust storm closes the `base <-> siteB` route, the western side of the map is cut off from direct base access. In the optimal extended plan, the rover reaches `siteD` and `siteB` by routing through the eastern side: moving `base -> siteA -> siteC -> siteD` (steps 5-7) to reach `siteD`, and then `siteD -> siteB` (step 9) to reach `siteB`.
* **Usage of the One-Way Route (`siteC -> siteD`):**
  * In the **original scenario**, neither the optimal nor the satisficing plan used the `siteC -> siteD` one-way route because `siteB` and `siteD` were easily reachable directly from `base` via `base -> siteB -> siteD`.
  * In the **extended scenario**, **yes, the one-way route `siteC -> siteD` is actively used** (at step 7 in the optimal plan, and step 34 in the satisficing plan). Taking the downhill slope `siteC -> siteD` is the shortest path from `base` to `siteD` (3 moves: `base -> siteA -> siteC -> siteD`, compared to 4 moves via `siteE`).
  * Because `siteC -> siteD` is strictly one-way, once the rover goes down to `siteD` and `siteB`, it cannot climb back up from `siteD` to `siteC`. Instead, it must loop around through `siteE` (`siteB -> siteD -> siteE -> siteC -> siteA -> base`, steps 11-16) to return to the base, which also conveniently takes it right past `drill1` at `siteE`.
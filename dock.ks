// ***********************************
// FUNCTIONS
// ***********************************

function match_velocity_rcs {
    declare global targetspeed to 0.
    rcs on.
    sas off.
    lock steering to "kill".
    until v_error:mag < 0.01 {
        set mult to 1.
        if v_error:mag < 0.5 {
            set mult to 0.15.
        }
        set targetforce to v_error:normalized * mult.
        set fore to vdot(ship:facing:forevector, targetforce).
        set star to vdot(ship:facing:starvector, targetforce).
        set top to vdot(ship:facing:topvector, targetforce).
        set ship:control:translation to V(star, top, fore).
    }
    rcs off.
    unlock steering.
}

function approach {
    parameter targetoffset.
    parameter targetspeed_max.
    parameter targetspeed_div.

    until offset:mag < targetoffset {
        sas off.
        until v_error:mag < 0.1 {
            declare global targetspeed to min(targetspeed_max, offset:mag / targetspeed_div).
            lock steering to v_error.
            if vdot(ship:facing:vector, v_error:normalized) > 0.99 {
                set a to ship:maxthrust / ship:mass.
                set timetochange to v_error:mag / a.
                if timetochange > 1 {
                    lock throttle to 1.
                }
                else {
                    lock throttle to max(timetochange, 0.1).
                }
            }
            else {
                lock throttle to 0.
            }

        }
        unlock throttle.
        unlock steering.
        sas on.
        wait 1.
    }
}

function rcs_shift {
    // TODO this uses a bit too much monopropellant
    // mandatory global paramter is the targetspeed
    // mandatory global paramter is the offset (offset should contain the vector relative to the desired position)
    // mandatory global paramter is the v_error
    parameter tolerance to 1.
    rcs on.
    sas off.
    until offset:mag < tolerance {
        set targetspeed to min(targetspeed, offset:mag / 5).
        set targetvec_draw TO VECDRAW(ship:controlpart:position, offset * -1, RGB(1, 0, 0), "", 1, TRUE, 0.2, TRUE, TRUE).
        if v_error:mag > 0.1 or targetspeed < 0.2 {
            rcs on.
            set mult to 1.
            if targetspeed < 0.2 {
                set mult to 0.15.
            }
            set targetforce to v_error:normalized * mult.
            set fore to vdot(ship:facing:forevector, targetforce).
            set star to vdot(ship:facing:starvector, targetforce).
            set top to vdot(ship:facing:topvector, targetforce).
            set ship:control:translation to V(star, top, fore).
        }
        else {
            set ship:control:neutralize to true.
            rcs off.
        }
    }
    set ship:control:neutralize to true.
    clearvecdraws().
}

function dock {
    if not ship:controlpart:istype("DockingPort") {
        print "A docking port is supposed to be the CONTROL PART during docking".
        return.
    }
    if not target:istype("DockingPort") {
        print "A docking port is supposed to be the TARGET during docking".
        return.
    }
    lock steeringtarget to lookdirup(-1 * target:facing:vector, -1 * target:facing:topvector).
    lock steering to steeringtarget.
    wait until vdot(facing:vector, steeringtarget:vector) > 0.99 and vdot(facing:topvector, steeringtarget:topvector) > 0.99.
    print "Direction matched, approach target".

    lock offset to ship:controlpart:position - (target:position + target:facing:vector:normalized * 3).
    set targetspeed to 2.
    rcs_shift().

    lock offset to ship:controlpart:position - (target:position + target:facing:vector:normalized * 0.5).
    set targetspeed to 0.3.
    rcs_shift(0.2).
}

function get_avoidsize {
    set othersize to othership:bounds:size:mag.
    set thissize to ship:bounds:size:mag.
    set avoidsize to (thissize + othersize) * 1.5.
    // worst case scenario this has 20% margin of error. Normally 200%
    return avoidsize.
}

function move_docking_side {
    sas off.
    match_velocity_rcs().
    if not ship:controlpart:istype("DockingPort") {
        print "A docking port is supposed to be the CONTROL PART during docking".
        return.
    }
    if not target:istype("DockingPort") {
        print "A docking port is supposed to be the TARGET during docking".
        return.
    }
    // TODO this is cheating but must cancel other vessel's rotation
    set warp to 2.
    wait until kuniverse:timewarp:issettled.
    kuniverse:timewarp:cancelwarp().
    wait until kuniverse:timewarp:issettled.

    lock steeringtarget to lookdirup(-1 * target:facing:vector, -1 * target:facing:topvector).
    lock steering to steeringtarget.
    wait until vdot(facing:vector, steeringtarget:vector) > 0.99 and vdot(facing:topvector, steeringtarget:topvector) > 0.99.
    print "Direction matched, approach target".

    //TODO position itself in front of target's docking port.
    set avoidsize to get_avoidsize().
    set manouverdir to V(0, 0, 0).
    if vdot(target:facing:vector, (ship:position - target:position):normalized) < 0 {
        print "Target docking port is facing away.".
        // The target docking port is facing away
        // Get nearest avoid direction
        set p_target to target:position - ship:position.
        set projected to vdot(target:facing:vector:normalized, p_target:normalized) * p_target:normalized.
        set manouverdir to (target:facing:vector - projected):normalized.
        //set manouverdir_draw TO VECDRAW(ship:position, manouverdir * 5, RGB(0, 1, 0), "", 1, TRUE, 0.2, TRUE, TRUE).

        // should lock the position relative to other ship
        // (offset should contain the vector relative to the desired position)
        set goalposition to ship:position + manouverdir * avoidsize.
        set goalposition_rel_other to goalposition - othership:position.
        //set goalposition_draw TO VECDRAW(ship:position, goalposition, RGB(0, 1, 0), "", 1, TRUE, 0.2, TRUE, TRUE).
        lock offset to ship:position - (othership:position + goalposition_rel_other).
        set targetspeed to 2.
        rcs_shift().

        set goalposition to ship:position + target:facing:vector * avoidsize.
        set goalposition_rel_other to goalposition - othership:position.
        lock offset to ship:position - (othership:position + goalposition_rel_other).
        set targetspeed to 2.
        rcs_shift().
    }
    if vdot(target:facing:vector:normalized, (ship:position - target:position):normalized) < 0.5 {
        print "Target docking port is positioned sideways.".
        // go "outwards" along the target's facing first
        set goalposition to ship:position + target:facing:vector * avoidsize.
        set goalposition_rel_other to goalposition - othership:position.
        lock offset to ship:position - (othership:position + goalposition_rel_other).
        set targetspeed to 2.
        rcs_shift().
    }

    // go in front of the docking port directly
    print "Go directly in front of docking port".
    set goalposition to target:position + target:facing:vector * avoidsize.
    set goalposition_rel_other to goalposition - othership:position.
    lock offset to ship:controlpart:position - (othership:position + goalposition_rel_other).
    set targetspeed to 2.
    rcs_shift().
    match_velocity_rcs().
}

function position_docking {
    // Nicer docking positioning that goes around the other vessel in a V shape 
    // With only 2 edges this V could get to any side of the target vessel
    // The V can be constructed in a way that it avoids the bounding sphere of the vessel if the distance kept is large enough
    // Minimum distance is sqrt(2) * safe_radius
    // The 1.5 margin of error of avoiddistance provides this safety margin.
    print "Why is this not printing".
    if not target:istype("DockingPort") {
        print "A docking port is supposed to be the TARGET during docking".
        return.
    }
    sas off.
    match_velocity_rcs().
    // TODO this is cheating but must cancel other vessel's rotation
    set warp to 2.
    wait until kuniverse:timewarp:issettled.
    kuniverse:timewarp:cancelwarp().
    wait until kuniverse:timewarp:issettled.
    set avoidsize to get_avoidsize().
    print "Using avoid distance: " + avoidsize.

    // go to the safe radius
    // offset relative to the desired position
    print "Go to safe radius".
    lock steering to "kill".
    lock offset to ship:position - ((ship:position - target:position):normalized * avoidsize + target:position).
    set targetspeed to 5.
    rcs_shift(2).

    // do the V shaped move
    set endpoint to target:facing:vector:normalized * avoidsize + target:position.
    set startpoint to (ship:position - target:position):normalized * avoidsize + target:position.
    set averagepoint to (endpoint + startpoint) / 2.
    set midpoint to (averagepoint - target:position):normalized * avoidsize + target:position.
    set midpoint_rel_other to midpoint - target:position.
    set endpoint_rel_other to endpoint - target:position.

//    set vec1 TO VECDRAW(V(0, 0, 0), endpoint, RGB(1, 0, 0), "", 1, TRUE, 0.2, TRUE, TRUE).
//    set vec2 TO VECDRAW(V(0, 0, 0), startpoint, RGB(0, 1, 0), "", 1, TRUE, 0.2, TRUE, TRUE).
//    set vec3 TO VECDRAW(V(0, 0, 0), averagepoint, RGB(1, 1, 0), "", 1, TRUE, 0.2, TRUE, TRUE).
//    set vec4 TO VECDRAW(V(0, 0, 0), midpoint, RGB(0, 0, 1), "", 1, TRUE, 0.2, TRUE, TRUE).
//    return.

    print "Go to midpoint".
    lock steering to "kill".
    lock offset to ship:position - (target:position + midpoint_rel_other).
    set targetspeed to 5.
    rcs_shift(2).

    print "Go to endpoint".
    lock steering to "kill".
    lock offset to ship:position - (target:position + endpoint_rel_other).
    set targetspeed to 5.
    rcs_shift(2).

    match_velocity_rcs().
}

set KEY_APPROACH_MEDIUM to "m".
set KEY_APPROACH_NEAR to   "n".
set KEY_APPROACH to        "a".
set KEY_DOCK to            "d".
set KEY_POSITION to        "p".
set KEY_STOP to            "s".
set KEY_EXIT to            "x".
set KEY_HELP to            "h".

function print_help {
    print " ".
    print "Full docking suite".
    print "  Approach full routine:       " + KEY_APPROACH.
    print "  Approach medium distance:    " + KEY_APPROACH_MEDIUM.
    print "  Approach near distance:      " + KEY_APPROACH_NEAR.
    print "  Position vessel for docking: " + KEY_POSITION.
    print "  Perform docking:             " + KEY_DOCK.
    print "  Stop movement with RCS:      " + KEY_STOP.
    print "  Exit script:                 " + KEY_EXIT.
    print "  Print help:                  " + KEY_HELP.
}

// Prepare main section
set ship:control:neutralize to true.
rcs off.
sas off.
declare global targetspeed to 0.
declare global othership to target.
clearvecdraws().

if not othership:istype("Vessel"){ set othership to target:ship.}
lock offset to ship:position - target:position.
lock deltaspeed to othership:velocity:orbit - ship:velocity:orbit.
lock v_error to deltaspeed - offset:normalized * targetspeed.

print "Welcome to the docking experience!".
print_help().

set stop to false.
until stop {
    print " ".
    print "What do you want to do?".
    set ch to terminal:input:getchar().

    if ch = KEY_APPROACH_MEDIUM {
        print "Perform medium approach".
        lock offset to ship:position - target:position.
        approach(200, 40, 20).
    }

    if ch = KEY_APPROACH_NEAR {
        print "Perform near approach".
        lock offset to ship:position - target:position.
        approach(10, 10, 40).
    }

    if ch = KEY_APPROACH {
        print "Perform full approach".
        lock offset to ship:position - target:position.
        approach(400, 40, 20).
        approach(200, 20, 20).
        set avoidsize to get_avoidsize().
        approach(avoidsize, 10, 40).
        match_velocity_rcs().
    }

    if ch = KEY_DOCK {
        print "Perform docking".
        dock().
        set stop to true.
    }

    if ch = KEY_STOP {
        print "Stopping with RCS boosters".
        match_velocity_rcs().
    }

    if ch = KEY_POSITION {
        print "Position in front of docking port".
        //move_docking_side().
        position_docking().
    }

    if ch = KEY_EXIT {
        print "Stop execution. An error is to be expected.".
        set stop to true.
    }

    if ch = KEY_HELP {
        print_help().
    }
}

// Exit cleanup
set ship:control:neutralize to true.
clearvecdraws().

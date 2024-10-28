print "Select the other ship as target".
print "Select this ship as control origin".
print "When done press enter!".
terminal:input:getchar().

sas off.
rcs off.

set othership to target.
if not othership:istype("Vessel"){ set othership to target:ship.}

function rcs_shift {
    // mandatory global paramter is the targetspeed
    // mandatory global paramter is the offset
    // mandatory global paramter is the v_error
    rcs on.
    sas off.
    until offset:mag < 0.1 {
        set targetspeed to min(targetspeed, offset:mag).
        set targetvec_draw TO VECDRAW(ship:controlpart:position, offset * -1, RGB(1, 0, 0), "", 1, TRUE, 0.2, TRUE, TRUE).
        if v_error:mag > 0.1 {
            rcs on.
            set targetforce to v_error:normalized.
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


// get the other ship's docking port orientation
lock targetfacingvector to target:facing:vector.

// get in front of that docking port
// lock closestcorner_other to othership:bounds:furthestcorner(ship:position - othership:position).
lock closestcorner_this to ship:bounds:furthestcorner(othership:position - ship:position).

set targetspeed to 40.
lock offset to ship:position - target:position.
lock deltaspeed to othership:velocity:orbit - ship:velocity:orbit.
lock v_error to deltaspeed - offset:normalized * targetspeed.

function approach {
    parameter targetoffset.
    parameter targetspeed_max.
    parameter targetspeed_div.

    until offset:mag < targetoffset {
        sas off.
        declare global targetspeed to min(targetspeed_max, offset:mag / targetspeed_div).
        until v_error:mag < 0.1 {
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

print "**************************************************".
print "Starting medium approach".
print "**************************************************".
print "".
approach(200, 40, 20).

// medium approach

print "**************************************************".
print "Starting near approach".
print "**************************************************".
print "".

approach(10, 10, 35).

function match_velocity_rcs {
    declare global targetspeed to 0.
    rcs on.
    sas on.
    until v_error:mag < 0.01 {
        set targetforce to v_error:normalized * 0.15.
        set fore to vdot(ship:facing:forevector, targetforce).
        set star to vdot(ship:facing:starvector, targetforce).
        set top to vdot(ship:facing:topvector, targetforce).
        set ship:control:translation to V(star, top, fore).
    }
    rcs off.
}

print "**************************************************".
print "Match velocity with rcs boosters".
print "**************************************************".
print "".

match_velocity_rcs().


//TODO position itself in front of target's docking port.
set othersize to othership:bounds:absmax:mag.


print "**************************************************".
print "Starting docking".
print "**************************************************".
print "".
print "Select the other ship's docking port as target".
print "Select this ship's docking port as control origin".
print "When done press enter!".
terminal:input:getchar().

sas off.
rcs off.

lock steeringtarget to lookdirup(-1 * target:facing:vector, -1 * target:facing:topvector).
lock steering to steeringtarget.

wait until vdot(facing:vector, steeringtarget:vector) > 0.99 and vdot(facing:topvector, steeringtarget:topvector) > 0.99.
print "Direction matched, approach target".

lock offset to ship:controlpart:position - (target:position + target:facing:vector:normalized * 3).
set targetspeed to 2.
rcs_shift().

lock offset to ship:controlpart:position - (target:position + target:facing:vector:normalized * 0.5).
set targetspeed to 0.3.
rcs_shift().

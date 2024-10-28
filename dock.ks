print "Select the other ship as target".
print "Select this ship as control origin".
print "When done press enter!".
terminal:input:getchar().

sas off.
rcs off.

set othership to target.
if not othership:istype("Vessel"){ set othership to target:ship.}

// get the other ship's docking port orientation
lock targetfacingvector to target:facing:vector.
// set targetfacingvector_draw TO VECDRAW( target:position, target:position + targetfacingvector:normalized, RGB(1, 0, 1), "", 1, TRUE, 0.2, TRUE, TRUE).

// get in front of that docking port
// lock closestcorner_other to othership:bounds:furthestcorner(ship:position - othership:position).
lock closestcorner_this to ship:bounds:furthestcorner(othership:position - ship:position).
//set vec1 TO VECDRAW( ship:position, ship:position + closestcorner_this, RGB(0, 1, 0), "", 1, TRUE, 0.2, TRUE, TRUE).
set targetspeed to 10.


// face that docking port
// lock steering to targetfacingvector * -1.
// go towards that docking port gradually reducing speed
set targetspeed to 40.

lock offset to ship:position - target:position.
lock deltaspeed to othership:velocity:orbit - ship:velocity:orbit.
lock v_error to deltaspeed - offset:normalized * targetspeed.

print "**************************************************".
print "Starting medium approach".
print "**************************************************".
print "".

// medium approach
until offset:mag < 200 {
    sas off.
    print v_error:mag.
    set targetspeed to min(targetspeed, offset:mag/40.0).
    until v_error:mag < 1 {
        //ship:control:translation = offset * -1.
        //print "Delta: " + deltaspeed.
        //print v_error.
        lock steering to v_error.
        if vdot(ship:facing:vector, v_error:normalized) > 0.95 {
            lock throttle to 0.1.
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

print "**************************************************".
print "Starting near approach".
print "**************************************************".
print "".

until offset:mag < 10 {
    sas off.
    set targetspeed to min(targetspeed, offset:mag / 40.0).
    until v_error:mag < 0.1 {
        //print "Delta: " + deltaspeed.
        //print v_error.
        lock steering to v_error.
        if vdot(ship:facing:vector, v_error:normalized) > 0.99 {
            lock throttle to 0.03.
        }
        else {
            lock throttle to 0.
        }
    }
    unlock throttle.
    unlock steering.
    sas on.
    wait 0.2.
}

print "**************************************************".
print "Match velocity with rcs boosters".
print "**************************************************".
print "".

set targetspeed to 0.
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

//TODO position itself in front of target's docking port.

print "**************************************************".
print "Starting docking".
print "**************************************************".
print "".
print "Select the other ship's docking port as target".
print "Select this ship's docking port as control origin".
print "When done press enter!".
terminal:input:getchar().

set othersize to othership:bounds:absmax:mag.
sas off.
rcs off.

lock steeringtarget to lookdirup(-1 * target:facing:vector, -1 * target:facing:topvector).
lock steering to steeringtarget.

wait until vdot(facing:vector, steeringtarget:vector) > 0.99 and vdot(facing:topvector, steeringtarget:topvector) > 0.99.
print "Direction matched, approach target".


set targetspeed to 0.5.
lock offset to ship:controlpart:position - (target:position + target:facing:vector:normalized * 3).
rcs on.
until offset:mag < 0.1 {
    set targetspeed to min(targetspeed, offset:mag).
    set targetvec_draw TO VECDRAW(ship:controlpart:position, offset * -1, RGB(1, 0, 0), "", 1, TRUE, 0.2, TRUE, TRUE).
    //set vec1 TO VECDRAW( target:position, target:facing:vector, RGB(0, 1, 0), "", 1, TRUE, 0.2, TRUE, TRUE).
    //set vec2 TO VECDRAW( ship:controlpart:position, target:facing:inverse:vector, RGB(0, 1, 0), "", 1, TRUE, 0.2, TRUE, TRUE).
    set targetforce to v_error:normalized * 0.15.
    set fore to vdot(ship:facing:forevector, targetforce).
    set star to vdot(ship:facing:starvector, targetforce).
    set top to vdot(ship:facing:topvector, targetforce).
    //set vec3 TO VECDRAW( ship:position, targetforce:normalized, RGB(1, 0, 0), "", 1, TRUE, 0.2, TRUE, TRUE).
    set ship:control:translation to V(star, top, fore).
}
clearvecdraws().

set targetspeed to 0.1.
lock offset to ship:controlpart:position - target:position.
rcs on.
until offset:mag < 0.1 {
    set targetspeed to min(targetspeed, offset:mag).
    set targetvec_draw TO VECDRAW(ship:controlpart:position, offset * -1, RGB(1, 0, 0), "", 1, TRUE, 0.2, TRUE, TRUE).
    //set vec1 TO VECDRAW( target:position, target:facing:vector, RGB(0, 1, 0), "", 1, TRUE, 0.2, TRUE, TRUE).
    //set vec2 TO VECDRAW( ship:controlpart:position, target:facing:inverse:vector, RGB(0, 1, 0), "", 1, TRUE, 0.2, TRUE, TRUE).
    set targetforce to v_error:normalized * 0.15.
    set fore to vdot(ship:facing:forevector, targetforce).
    set star to vdot(ship:facing:starvector, targetforce).
    set top to vdot(ship:facing:topvector, targetforce).
    //set vec3 TO VECDRAW( ship:position, targetforce:normalized, RGB(1, 0, 0), "", 1, TRUE, 0.2, TRUE, TRUE).
    set ship:control:translation to V(star, top, fore).
}
clearvecdraws().

@lazyGlobal off.
run once library.

//TODO compensate for horizontal velocity
// TODO test on not so high landings
// TODO take into account the effect of speeding up horizontally due to eplliptic path
local myship to SHIP.
local mybody to body.
local B is myship:bounds.
sas off.
rcs on.
gear on.
set myship:control:mainthrottle to 0. //turn off throttle so at the end it does not fly up again.

//gravitational acceleration at stop point
local g to body:mu / ((body:radius + tolerance) ^ 2).
print "gravitational acceleration at stop point: " + round(g,2).
//calculate my maximum acceleration
//lock acc to myship:availablethrust/myship:mass - g.
lock acc to (- ship:velocity:surface:normalized * myship:availablethrust/myship:mass - ship:up:vector * g):mag.
local original_acc to myship:availablethrust/myship:mass.

//a few meters of tolerance
if NOT (defined tolerance) {declare local tolerance to 10.}
//stopspeed is the speed at which the manouver is finished (residual vertical speed after the manoveour)
// calculate for ideal suicide burn speed at stopheight
if NOT (defined stopSpeed) declare local stopSpeed to sqrt(2*acc*tolerance).

// The vertical velocity at touchdown calculated from energies
// U = - GMm/r
// deltaU = - GMm / (r1 - r2)
lock deltaU to - body:mu * ship:mass * (1.0/(ship:altitude + body:radius) - 1.0/body:radius).
print "deltau  " + deltaU.
// v2 = sqrt(2U/m + v1^2)
lock finalV to sqrt(ship:velocity:surface:mag ^ 2 + 2 * deltaU / ship:mass).

wait until ship:verticalspeed < 0.

local vv to vdot(ship:velocity:surface:normalized, ship:up:vector).
lock travel to abs(ship:bounds:bottomaltradar) * ship:velocity:surface:normalized:mag / abs(vv).


if travel > tolerance {

    lock desiredFacing to (-1 * ship:velocity:surface).
    lock steering to desiredFacing:direction. //lock against velocity
    lock throttle to 0.

    local myheight to B:bottomaltradar.
    local dh to 0.
    local rr to raycast(ship:velocity:surface, 5).
    lock distance to min(travel, rr:mag).
    until distance - tolerance - dh < ((ship:velocity:surface:mag^2 - stopSpeed^2) / (2 * acc))
    {
        set dh to myheight-B:bottomaltradar.
        set myheight to B:bottomaltradar.
        set rr to raycast(ship:velocity:surface, 5).
        clearScreen.
        print "Travel: " + round(travel).
        print "Ray:    " + round(rr:mag).
        print "Height: " + round(myheight).
        print "Burn at distance: " + round(((ship:velocity:surface:mag^2 - stopSpeed^2) / (2 * acc)) + tolerance).
        print "Waiting for last second".
        print "maximum acceleration: " + round(acc, 1).
    }

    lock idealThrust to original_acc/(myship:availablethrust/myship:mass).
    //lock throttle to idealThrust.
    lock throttle to 1.

    until myship:velocity:surface:mag < stopSpeed {
        clearScreen.
        print "Waiting to turn off".
        print "Stop speed: " + round(stopSpeed, 1).
        print "Travel: " + round(travel, 2) + "     v: " + round(ship:velocity:surface:mag, 2).
        if vDot(desiredFacing, ship:facing:vector) > 0.95 lock throttle to 1.
        else lock throttle to 0.
    }
}

lock throttle to 0.
unlock throttle.
unlock steering.
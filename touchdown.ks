@lazyGlobal off.
run once library.

rcs on.
sas off.

lock desiredVelocity to getDesiredVelocity().
//lock horizontalVelocity to ship:velocity:surface - up:vector*verticalSpeed.
lock dv to ship:velocity:surface - desiredVelocity.


lock fv to vdot(dv, ship:facing:forevector).
lock rv to vdot(dv, ship:facing:rightvector).
lock uv to vdot(dv, ship:facing:upvector).


//lock steering to (2 * up:vector - ship:velocity:surface:normalized):direction.

lock g to ship:body:mu/((ship:body:radius+ship:bounds:bottomalt)^2).
lock staticthrust to ship:mass*g/ship:maxthrust.
lock steering to up.
lock throttle to staticthrust.

print ship:bounds:bottomaltradar.

until ship:bounds:bottomaltradar < 0.1
{
clearScreen.
print "Landing in progress".
print "h: " + round(ship:bounds:bottomaltradar, 2) + "     v: " + round(ship:velocity:surface:mag, 2).
set ship:control:translation to - v(rv, uv, fv):normalized * 5.
print "translation: " + ship:control:translation.
wait 0.001.
}
// turn off inputs
lock throttle to 0.
unlock throttle.
unlock steering.
set ship:control:neutralize to true.
sas on.

function getDesiredVelocity{
    if (ship:velocity:surface - project(ship:velocity:surface, ship:up:vector)):mag > 1 { return v(0, 0, 0). }
    return v(0, 0, 0) - ship:up:vector * 2.
}
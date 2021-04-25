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

//stopspeed is the speed at which the manouver is finished (residual vertical speed after the manoveour)
if NOT (defined stopSpeed) declare local stopSpeed to 0.
//a few meters of tolerance
if NOT (defined tolerance) {global tolerance is 10.}


local gravity to constant:g*mybody:mass/(mybody:radius^2).
lock verticalVelocity to myship:up:vector * myship:verticalSpeed. // upwards vertical speed

//wait until going downwards, otherwise calculations dont work.
print "Waiting for descend".
wait until myship:verticalSpeed < -1.

//SuicideBurn test -> 1825 m/s left

// The vertical velocity at touchdown calculated from energies
// mgh = 1/2 mv^2 -> 2gh = v^2
// recalculate whenever necessary, for incremental improvements
lock finalVerticalVelocity to verticalVelocity - myship:up:vector * (sqrt(2 * gravity * (B:bottomaltradar - tolerance) - stopSpeed)).

// find horizontal velocity, in theory this does not change
local horizontalVelocity to (myship:velocity:surface - verticalVelocity).
local finalVelocity to finalVerticalVelocity + horizontalVelocity.

// The direction is against the sum of these two vetorsm
lock steering to (-finalVelocity):direction. //lock against velocity with a bias to horizontal

//calculate my maximum acceleration
local acc to myship:availablethrust/myship:mass.
// calculate the maximum vertical acceleration
lock verticalAcc to acc * (finalVerticalVelocity:mag / (finalVelocity:mag)).
//wait until speed and distance balance for a suicide burn
lock throttle to 0.


local myheight to B:bottomaltradar.
local dh to 0. // the height difference between iteration steps to make sure manoveour is not too late
wait until myship:verticalspeed < 0.

until B:bottomaltradar - tolerance - dh < ((myship:verticalspeed + stopSpeed)^2 / (2* (verticalAcc - gravity)))
{
    set dh to myheight-B:bottomaltradar.
    set myheight to B:bottomaltradar.
    clearScreen.
    print "Current Vertical velocity: " + round(verticalVelocity:mag, 1).
    print "Calculated vertical velocity at touchdown: " + round(finalVerticalVelocity:mag, 1).
    print "Waiting for last second".
    print "h: " + round(B:bottomaltradar, 2) + "     v: " + round(myship:verticalSpeed, 2) + "   dh: " + dh.
    wait 0.001.
}

lock idealThrust to acc/(myship:availablethrust/myship:mass).
lock throttle to idealThrust.
lock throttle to 1.

until myship:verticalSpeed > (-stopSpeed) OR B:bottomaltradar<0.2{
    clearScreen.
    print "Waiting to turn off".
    print "h: " + round(B:bottomaltradar, 2) + "     v: " + round(myship:verticalSpeed, 2).
}

lock throttle to 0.

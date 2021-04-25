@lazyGlobal off.
run once library.

//TODO compensate for horizontal velocity
local myship to SHIP.
local mybody to body.
local B is myship:bounds.
sas off.
rcs on.
gear on.
set myship:control:mainthrottle to 0. //turn off throttle so at the end it does not fly up again.


local gravity to constant:g*mybody:mass/(mybody:radius^2).
lock verticalVelocity to myship:up:vector * myship:verticalSpeed. // upwards vertical speed
lock steering to (- verticalVelocity - 0.1*(myship:velocity:surface-verticalVelocity)):direction. //lock against velocity with a bias to horizontal

//calculate my maximum acceleration
local acc to myship:availablethrust/myship:mass.
//wait until speed and distance balance for a suicide burn
lock throttle to 0.

//a few meters of tolerance
if NOT (defined tolerance) {global tolerance is 10.}

local myheight to B:bottomaltradar.
local dh to 0. // the height difference between iteration steps to make sure manoveour is not too late
wait until myship:verticalspeed < 0.

until B:bottomaltradar - tolerance - dh < (myship:velocity:surface:mag^2 / (2* (acc - gravity)))
{
    set dh to myheight-B:bottomaltradar.
    set myheight to B:bottomaltradar.
    clearScreen.
    print "Waiting for last second".
    print "h: " + round(B:bottomaltradar, 2) + "     v: " + round(myship:verticalSpeed, 2) + "   dh: " + dh.
    wait 0.001.
}

lock idealThrust to acc/(myship:availablethrust/myship:mass).
lock throttle to idealThrust.
lock throttle to 1.

//stopspeed is the speed at which the manouver is finished (residual vertical speed after the manoveour)
if NOT (defined stopSpeed) declare local stopSpeed to 0.
until myship:verticalSpeed>(-stopSpeed) OR B:bottomaltradar<0.2{
    clearScreen.
    print "Waiting to turn off".
    print "h: " + round(B:bottomaltradar, 2) + "     v: " + round(myship:verticalSpeed, 2).
}

lock throttle to 0.

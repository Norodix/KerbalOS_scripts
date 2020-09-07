//SETUP
sas off.
rcs on.
set ship:control:mainthrottle to 0. //turn off throttle so at the end it does not fly up again.


//deorbit
lock myvel to ship:velocity:surface.
lock horizontalVelocity to myvel-up:vector*verticalSpeed.
lock steering to (-1 * horizontalVelocity):direction. //reverse horizontal direction
wait 5. //let steering settle

lock throttle to 1.
wait until horizontalVelocity:mag < 10.

lock throttle to 0.
wait 1.
if (altitude > 100000){
    set kuniverse:timewarp:rate to 100.
    wait until altitude < 100000.
}
if (altitude > 50000){
    set kuniverse:timewarp:rate to 10.
    wait until altitude < 50000.
}
kuniverse:timewarp:cancelwarp().
wait until kuniverse:timewarp:issettled().
wait 5.

if (horizontalVelocity:mag > 10){
    lock throttle to 1.
    wait until horizontalVelocity:mag < 10.
}

if (horizontalVelocity:mag > 1){
    lock throttle to 0.1.
    wait until horizontalVelocity:mag < 1.
}

if (horizontalVelocity:mag > 0.01){
    lock throttle to 0.01.
    wait until horizontalVelocity:mag < 0.01.
}

//perform suicideburn
declare global tolerance to 50.
declare global stopSpeed to 20.
run suicideburn.

set tolerance to 1.
set stopSpeed to 0.
run suicideburn.

run touchdown.
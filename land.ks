////////LANDING PARAMETERS/////////////
declare local DeorbitPeriapsis to 5000.
declare local FastForward100 to 100000.
declare local FastForward10 to 40000.
declare local WaitBeforeHorizontal to 20000.


//////////////SETUP///////////////////
sas off.
rcs on.
set ship:control:mainthrottle to 0. //turn off throttle so at the end it does not fly up again.

//////////////DEORBIT////////////////
print "Deorbiting vessel to periapsis under " + DeorbitPeriapsis.

lock myvel to ship:velocity:surface.
lock horizontalVelocity to myvel-up:vector*verticalSpeed.
//lock steering to (-1 * horizontalVelocity):direction. //reverse horizontal direction
if (periapsis > DeorbitPeriapsis){
    lock steering to retrograde.
    wait 5. //let steering settle

    lock throttle to 1.
    wait until periapsis < DeorbitPeriapsis.
}

lock throttle to 0.

print "Fast forward until altitude < " + FastForward10.
wait 1.
if (altitude > FastForward100){
    set kuniverse:timewarp:rate to 100.
    wait until altitude < FastForward100.
}

lock steering to (-1 * horizontalVelocity):direction. //reverse horizontal direction
wait 15.

if (altitude > FastForward10){
    set kuniverse:timewarp:rate to 10.
    wait until altitude < FastForward10.
}
kuniverse:timewarp:cancelwarp().
wait until kuniverse:timewarp:issettled().

///////////HORIZONTAL BURN//////////////
//// THIS IS SHITE //////
// fix stupid turning issue
print "Kill horizontal velocity".
wait until ship:bounds:bottomaltradar<WaitBeforeHorizontal.

until horizontalVelocity:mag < 10 {
    if vectorAngle(ship:facing:forevector, horizontalVelocity) > (175){
        lock throttle to 1.
    }
    else lock throttle to 0.
    wait 0.01.
}

until (horizontalVelocity:mag < 1){
    print vectorAngle(ship:facing:forevector, horizontalVelocity).
    if vectorAngle(ship:facing:forevector, horizontalVelocity) > (175){
        lock throttle to 0.1.
    }
    else lock throttle to 0.
    wait 0.01.
}


/////////////SUICIDEBURN///////////////
print "Suicide burn".
declare global tolerance to 50.
declare global stopSpeed to 20.
declare global horizontal_factor to 0.2.
run suicideburn.

set tolerance to 1.
set stopSpeed to 0.
declare global horizontal_factor to 0.3.
run suicideburn.

///////////TOUCHDOWN/////////////////
print "Touchdown".
run touchdown.
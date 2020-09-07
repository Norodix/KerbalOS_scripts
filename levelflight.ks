//initialisation
SET SHIP:CONTROL:NEUTRALIZE to True.
sas off.
clearGuis().


set accumulator to 0.
///////MALLARD
// set kp to 2.5e-2.
// set ki to 1e-3.

//OYSTER
set kp to 1e-3.
set ki to 1e-4.


set dt to 0.1.
set targetheight to ship:bounds:BOTTOMALT.
set e to 0.
set maxspeed to 20.



SET gui TO GUI(400, 500).

set title to gui:addlabel().
set title:text to "Flight vertical height controller. Press the brake to stop this loop!".

// set heightslider to gui:addhslider().
// set heightslider:min to 0.
// set heightslider:max to 5000.
// set heightslider:onchange to heightsliderchange@.

// set heightsliderval to gui:addlabel().

set heightinput to gui:addtextfield().
set heightinput:text to "" + targetheight.

function heightInputConfirm{
    parameter NewValue.
    set NewValueNum to NewValue:toNumber(targetheight). //defaultIfError is the currently set target height, so if there is a problem, nothing changes
    set targetheight to NewValueNum.
    set heightinput:text to "" + targetheight. //show the actually set number. If the input is correct this should have no effect except for reformatting.
}

set heightinput:ONCONFIRM to heightInputConfirm@.



// function heightsliderchange{
//     parameter newValue.
//     set targetheight to round(newValue, 1).
//     //print newValue.
//     set heightsliderval:text to "Target height: " + targetheight.
//     set heightslider:value to targetheight. //make it snap
// }
//heightsliderchange(targetheight).


gui:show().
brakes off.

until brakes{
    if ship:facing:upvector*up:vector>0{ //Only perform the control steps if the ship is upside
        sas off.
        set targetvspeed to max(min((targetheight-ship:bounds:BOTTOMALT)/10, maxspeed), -maxspeed).
        set e to (ship:verticalSpeed-targetvspeed).
        set accumulator to min(accumulator + ki*(e), 1). //anti-windup
        set ship:control:pitch to -max(min(e*kp + accumulator, 1), -1).
        wait dt.
        clearScreen.
        print "Accumulator: " + accumulator.
        print "Pitch: " + WheelThrottle.
        print "e: " + e.
        print "Verticalspeed: " + ship:verticalspeed.
        print "Target Vertical Speed: " + targetvspeed.
    }
}

function cleanexit{
    PRINT "Aborting!".
    clearGuis().
    clearVecDraws().
    SET SHIP:CONTROL:NEUTRALIZE to True.
}



cleanexit().
//initialisation
SET SHIP:CONTROL:NEUTRALIZE to True.
sas off.
clearGuis().


set accumulator to 0.
///////MALLARD
 set kp to 2.5e-2.
 set ki to 1e-3.

//OYSTER
//set kp to 1e-3.
//set ki to 1e-4.


set dt to 0.1.
set targetheight to round(ship:bounds:BOTTOMALT).
set e to 0.
set maxspeed to 20.



SET gui TO GUI(400, 500).

local singleConfirm to 0.
local Stop to 0.

set title to gui:addlabel().
set title:text to "Flight vertical height controller".

// Create a slider for the GUI
set heightslider to gui:addhslider().
set heightslider:min to 0.
set heightslider:max to 5000.
set heightslider:onchange to heightsliderchange@.


// set heightsliderval to gui:addlabel().

set heightinput to gui:addtextfield().
set heightinput:text to "" + targetheight.

// Heith reference from ground or altitude
set heightreference to gui:addbutton("Surface").
set heightreference:toggle to true.

set heightreference:ONCLICK to {
    //When changed, reset the targetheith to current height
    if heightreference:pressed {
        set heightreference:text to "Sea-level".
        set targetheight to round(ship:bounds:bottomalt, 2).
    }
    else {
        set heightreference:text to "Surface".
        set targetheight to round(ship:bounds:bottomaltradar, 2).
    }
    set heightinput:text to ""+targetheight.
}.


// Create a STOP button
set stopButton to gui:addbutton("STOP").
set stopButton:onClick to cleanexit@.

function heightInputConfirm{
    parameter NewValue.
    if singleConfirm
    {
      set singleConfirm to 0.
      return.
    }
    set NewValueNum to NewValue:toNumber(targetheight). //defaultIfError is the currently set target height, so if there is a problem, nothing changes
    set targetheight to NewValueNum.
    set heightinput:text to "" + targetheight. //show the actually set number. If the input is correct this should have no effect except for reformatting.
    set singleConfirm to 1.
    set heightslider:value to targetheight.
}

set heightinput:ONCONFIRM to heightInputConfirm@.



function heightsliderchange{
    parameter newValue.
    if singleConfirm
    {
      set singleConfirm to 0.
      return.
    }
    set targetheight to round(newValue, 1).
    //print newValue.
    //set heightsliderval:text to "Target height: " + targetheight.
    //set heightslider:value to targetheight. //make it snap
    set singleConfirm to 1.
    set heightinput:text to "" + targetheight.
}
//heightsliderchange(targetheight).


gui:show().
brakes off.


// Main control loop
until Stop{
    if ship:facing:upvector*up:vector>0{ //Only perform the control steps if the ship is upside
        sas off.
        set currentheight to 0.

        // Calculate the current height based on the reference selected
        // pressed: Sea-level not pressed: surface
        if not heightreference:pressed {set currentheight to (ship:bounds:bottomaltradar).}
        else {set currentheight to (ship:bounds:bottomalt).}

        set targetvspeed to max(min((targetheight-currentheight)/10, maxspeed), -maxspeed).

        set e to (ship:verticalSpeed-targetvspeed).
        set accumulator to min(accumulator + ki*(e), 1). //anti-windup
        set ship:control:pitch to -max(min(e*kp + accumulator, 1), -1).
        wait dt.
        clearScreen.
        print "Accumulator:            " + round(accumulator, 2).
        print "Pitch:                  " + round(WheelThrottle, 2).
        print "e:                      " + round(e, 2).
        print "Verticalspeed:          " + round(ship:verticalspeed, 2).
        print "Target Vertical Speed:  " + round(targetvspeed, 2).
    }
}

function cleanexit{
    PRINT "Aborting!".
    clearGuis().
    clearVecDraws().
    SET SHIP:CONTROL:NEUTRALIZE to True.
    set Stop to 1.
}



cleanexit().

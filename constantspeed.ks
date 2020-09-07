//initialisation
set accumulator to 0.
set kp to 0.3.
set ki to 0.002.
set dt to 0.001.
set targetspeed to 10.
set e to 0.



SET gui TO GUI(400, 500).

set title to gui:addlabel().
set title:text to "Constant speed controller".

set slider to gui:addhslider().
set slider:min to 0.01.
set slider:max to 40.
set slider:onchange to sliderchange@.

set sliderval to gui:addlabel().


function sliderchange{
    parameter newValue.
    set targetspeed to round(newValue, 0.1).
    //print newValue.
    set sliderval:text to "Target speed: " + round(newValue, 0.1).
}

gui:show().



brakes off.
until brakes{
    set e to (ship:groundspeed-targetspeed).
    set accumulator to min(accumulator + ki*(e), 1). //anti-windup
    lock wheelThrottle to -max(min(e*kp + accumulator, 1), -1).
    wait dt.
    //clearScreen.
    //print "Accumulator: " + accumulator.
    // print "WheelThrottle: " + WheelThrottle.
    // print "e: " + e.
    }
clearGuis().
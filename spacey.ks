run once library.

set targetheight to 10.
set targetheading to 90.
set targetgroundspeed to 0.
set maxspeed to 5.
set kp to 0.1.
set ki to 0.//0.0001.
set kd to 2.
set dt to 0.01.
set e to 0.
set de to e.
set accumulator to 0.
set staticthrust to 0.
set stop to False.

//GUI///////////////////////////////////////////////////////
function InputConfirm{
    parameter input.
    parameter label.
    parameter targetparameter.

    set NewValueNum to input:text:toNumber(targetparameter). //defaultIfError is the currently set target height, so if there is a problem, nothing changes
    print "New value " + NewValueNum + " confirmed for " + input.
    //set label:text to "" + NewValueNum.
    return NewValueNum.
}


SET gui TO GUI(200).
set title to gui:addlabel().
set title:text to "Flight vertical height controller.".


set heightinputlabel to gui:addlabel().
set heightinputlabel:text to "Height compared to".
set heightreference to gui:addbutton("Surface").
set heightreference:toggle to true.
set heightbox to gui:addhbox().
set heightinput to heightbox:addtextfield().
set heightinput:text to "" + targetheight.
set heightlabel to heightbox:addlabel().


//set heightinput:ONCONFIRM to {parameter NewVal. set targetheight to InputConfirm(heightinput, heightlabel, targetheight, NewVal).}.

set groundspeedinputlabel to gui:addlabel().
set groundspeedinputlabel:text to "Groundspeed".
set groundbox to gui:addhbox().
set groundspeedinput to groundbox:addtextfield().
set groundspeedinput:text to "" + 0.
set groundspeedlabel to groundbox:addlabel().
//set groundspeedinput:ONCONFIRM to {parameter NewVal. set targetgroundspeed to InputConfirm(groundspeedinput, groundspeedlabel, targetgroundspeed, NewVal).}.


set headinginputlabel to gui:addlabel().
set headinginputlabel:text to "Heading".
set headingbox to gui:addhbox().
set headinginput to headingbox:addtextfield().
set headinginput:text to "" + targetheading.
set headinglabel to headingbox:addlabel().
//set headinginput:ONCONFIRM to {parameter NewVal. set targetheading to InputConfirm(headinginput, headinglabel, targetheading, NewVal).}.


set StopButton to gui:addbutton("STOP").
set StopButton:ONCLICK to {set stop to True.}.


set heightreference:ONCLICK to {
    set heightinput:text to heightlabel:text.
    set groundspeedinput:text to groundspeedlabel:text.
    set headinginput:text to headinglabel:text.
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

set gui:x to 180.
set gui:y to -325.
gui:show().
//ENDOFGUI//////////////////////////////////////////////////



set CurrentBody to ship:body.

if not ship:maxthrust stage.
lock throttle to minmax((staticthrust-(e*kp+accumulator+kd*de)), 0, 1).
lock steering to heading(
                            vcompass(ship, (ship:velocity:surface-heading(targetheading, 0):forevector*targetgroundspeed))+180,
                            90-minmax((ship:velocity:surface-heading(targetheading, 0):forevector*targetgroundspeed):mag*2, -10, 10)
                        ).

set targetgroundspeed to 10.
set targetheading to 313.
rcs on.
until stop {
    if heightinput:confirmed{set targetheight to InputConfirm(heightinput, heightlabel, targetheight).}.
    if groundspeedinput:confirmed{set targetgroundspeed to InputConfirm(groundspeedinput, groundspeedlabel, targetgroundspeed).}.
    if headinginput:confirmed{set targetheading to InputConfirm(headinginput, headinglabel, targetheading).}.

    SET northArrow TO VECDRAW( V(0,0,0), ship:north:vector*5, RGB(1,0,0), "NORTH", 1, TRUE, 0.2, TRUE, TRUE).
    
    //read pilot input and adjust the target parameters
    //Bug must be somewhere here!!!
    set targetvelocity to heading(targetheading, 0):forevector*targetgroundspeed.
    // set eastvector to  vcrs(ship:up:vector, ship:north:vector).
    // set deltavelocity to (ship:control:pilotyaw*eastvector - ship:control:pilotpitch*ship:north:vector):normalized*0.2.
    // set newtargetvelocity to targetvelocity + deltavelocity.
    // set targetheading to round(vcompass(ship, newtargetvelocity), 2).
    // set targetheading to targetheading +1.
    // set targetgroundspeed to round(newtargetvelocity:mag, 2).

    set targetheading to targetheading + ship:control:pilotyaw*5.
    set targetgroundspeed to targetgroundspeed - ship:control:pilotpitch*1.
    set targetheight to targetheight + (ship:control:PILOTROLL)*0.5.
    
    // if(e<0) set heightArrowStartVector to ship:bounds:furthestcorner(ship:up:vector).
    set heightArrowStartVector to ship:bounds:furthestcorner(-ship:up:vector)*ship:up:vector*ship:up:vector.
    // set heightArrowStartVector to V(0, 0, heightArrowStartVector*V(0, 0, 1)).
    set heightArrow TO VECDRAW( heightArrowStartVector, ship:up:vector*(-e), RGB(1, 0, 1), "", 1, TRUE, 0.2, TRUE, TRUE).
    set targetArrow TO VECDRAW( V(0,0,0), targetvelocity*4, RGB(0, 1, 0), "Targetvelocity", 1, TRUE, 0.2, TRUE, TRUE).
    // set newTargetArrow to VECDRAW( V(0,0,0), newtargetvelocity*4, RGB(1, 0, 1), "NEW Targetvelocity", 1, TRUE, 0.2, TRUE, TRUE).
    set velocityArrow TO VECDRAW( V(0,0,0), ship:velocity:surface*4, RGB(0, 0, 1), "Velocity", 1, TRUE, 0.2, TRUE, TRUE).
    // set deltaArrow to VECDRAW(V(0, 0, 0), deltavelocity*20, RGB(1, 1, 0), "Deltavelocity", 1, TRUE, 0.2, TRUE, TRUE).
    set groundspeedlabel:text to "" + targetgroundspeed.
    set headinglabel:text to "" + targetheading.
    set heightlabel:text to "" + targetheight.


    set maxth to ship:maxthrust. //to make sure that during the calculations it stays constant
    until maxth {
        stage.
        if stage:number=0 break.}
    if not maxth break.


    sas off.
    set eold to e.
    if not heightreference:pressed {set e to (ship:bounds:bottomaltradar-targetheight).}
    else {set e to (ship:bounds:bottomalt-targetheight).}
    set accumulator to minmax(accumulator + ki*(e), -0.5, 0.5). //anti-windup
    set de to e-eold.

    //calculate thrust for static hovering, around which the control loop will operate.
    //maxthrust is in kN, wetmass is in tons.
    set g to CurrentBody:mu/((CurrentBody:radius+ship:bounds:bottomalt)^2).
    set staticthrust to ship:mass*g/maxth.
    wait dt.

    // clearScreen.
    // print "Accumulator: " + accumulator.
    // //print "Throttle: " + ship:throttle.
    // print "e: " + e.
    // print "Verticalspeed: " + ship:verticalspeed.
    // print "Height: " + ship:bounds:bottomaltradar.
    // print "Maxthrust: " + maxth.
    // print "Staticthrust: " + staticthrust.
    // print "Mass: " + ship:mass.
}
clearGuis().
clearVecDraws().
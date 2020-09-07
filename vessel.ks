until not 1{
    clearScreen.
    print "Heading: " + ship:heading.


    //set B to ship:BOUNDS.
    // The furthest corner of the box in the downward (negative up) direction:
    //set bottom to B:FURTHESTCORNER( - up:vector ).
    print "Bottom distance: " + round(ship:bounds:BOTTOMALTRADAR, 1).
    
    wait 0.1.    
}
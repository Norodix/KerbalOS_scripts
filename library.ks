@lazyGlobal off.

function vcompass {
    parameter input_vessel. //eg. ship
    parameter input_vector. // i.e. ship:velocity:surface (for prograde) 
                            // or ship:facing:forevector (for facing vector rather  than vel vector).

    // What direction is up, north and east right now, as vector
    local up_vector is input_vessel:up:vector.
    local north_vector is input_vessel:north:vector.
    local east_vector is vcrs(up_vector, north_vector).
      
    // east component of vector:
    local east_vel is vdot(input_vector, east_vector). 

    // north component of vector:
    local north_vel is vdot(input_vector, north_vector).

    // inverse trig to take north and east components and make an angle:
    local compass is arctan2(east_vel, north_vel).

    // Note, compass is now in the range -180 to +180 (i.e. a heading of 270 is
    // expressed as -(90) instead.  This is entirely acceptable mathematically,
    // but if you want a number that looks like the navball compass, from 0 to 359.99,
    // you can do this to it:
    if compass < 0 {
        set compass to compass + 360.
    }

    return compass.
}

function minmax{
    parameter value.
    parameter min_bound.
    parameter max_bound.
    return min(max(value, min_bound), max_bound).
}
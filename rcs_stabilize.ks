lock dv to ship:velocity:orbit - target:ship:velocity:orbit.
print dv.
lock fv to vdot(dv, ship:facing:forevector).
lock rv to vdot(dv, ship:facing:rightvector).
lock uv to vdot(dv, ship:facing:upvector).

until dv:mag < 1 {
    set ship:control:translation to - v(rv, uv, fv):normalized.
    wait 0.01.
}

until dv:mag < 0.01 {
    set ship:control:translation to - v(rv, uv, fv):normalized * 0.1.
    wait 0.01.
}

set ship:control:neutralize to true.
//set ship:control:translation to 
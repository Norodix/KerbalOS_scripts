run once library.

set rr to (ship:north:vector - ship:up:vector) * 20.
set myvector to raycast(rr, 1).
print myvector.
set castray   to VECDRAW( V(0,0,0), rr, RGB(0,1,0), "Ray", 1, TRUE, 0.2, TRUE, TRUE).
set resultray to VECDRAW( V(0,0,0), myvector, RGB(1,0,0), "Result", 1, TRUE, 0.2, TRUE, TRUE).
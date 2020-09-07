@lazyGlobal off.

lock steering to (2 * up:vector - ship:velocity:surface:normalized):direction.

wait until ship:bounds:bottomaltradar<0.1.
lock steering to up.

wait until ship:velocity:surface:mag < 0.05.
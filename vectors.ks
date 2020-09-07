set a to 1.
set b to 2.
set c to 3.


SET anArrow TO VECDRAW(
      V(0,0,0),
      ship:facing:forevector,
      RGB(1,0,0),
      "See the arrow?",
      5,
      TRUE,
      0.2,
      TRUE,
      TRUE
    ).

// SET anArrow TO VECDRAWARGS(
//       V(0,0,0),
//       V(a,b,c),
//       RGB(1,0,0),
//       "See the arrow?",
//       1.0,
//       TRUE,
//       0.2,
//       TRUE,
//       TRUE
//     ).
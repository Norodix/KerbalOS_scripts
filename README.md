# Kerbal Operating System Scripts

This repository contains my KOS scripts.

## Space-Y
Contains:
 - spacey.ks
 - library.ks

This script hovers a rocket above the ground.
There is a GUI included, and the craft can be controlled as a drone.
The script draws arrows on the screen to represent the velocities and the target velocities.

## Land
Contains:
 - land.ks
 - suicideburn.ks
 - touchdown.ks
 - library.ks

 This script perform an automatic landing sequence to land on bodies without atmosphere.
 The parameters for the vessel and celestial body may need to be tweaked.

 The script uses the efficient suicide-burn maneuver. First it slows down to a low periapsis. Then it kills the horizontal velocity. After that it performs a 2-stage suicide-burn. The first stops somewhat above the surface with non-zero velocity, the second then performs the final landing. For the touchdown a separate script is used to compensate any remaining horizontal velocity or uneven ground.

 ## Level-flight
 Contains:
  - levelflight.ks

This script is used on aircraft for stabilizing the altitude, either relative to the surface or relative to sea-level. Control parameters must be tweaked to match the characteristics of the aircraft.

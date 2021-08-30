# real_elevators
![screenshot](https://user-images.githubusercontent.com/25750346/131409658-5a4be9cc-19b2-4b76-8922-a67887f8b64f.png)

The elevators with a real behaviour.

## Features:
* Flexible & dynamic floors net system.
* Smooth moving of elevator cabin from one point to other.
* Smooth opening/closing doors (outer/inner).
* Allows to transport all entities (not only players).
* Support for basic_materials (also luxury_decor in next versions) for crafting.

## How to build elevator shaft?
Typical shaft with two floors should look like so:
![Снимок экрана от 2021-08-31 00-52-59](https://user-images.githubusercontent.com/25750346/131410738-26f38b49-5479-473b-b6f2-baa4c6635947.png)

How it looks like without outer walls that was adjacent to the shaft in prior screenshot:
![Снимок экрана от 2021-08-31 01-04-33](https://user-images.githubusercontent.com/25750346/131412011-53910198-1e3f-402d-97a3-2c8152336fde.png)


Next materials that you will need for building: shaft nodes (corner block, back block, left/right side blocks, outer shaft wall), wall nodes (outer wall, outer wall with trigger, outer wall with left/right side slots), rope, winch, marker tool and cabin of elevator. 

Building steps (where '#' is optional):

1. Set platform from corner blocks (#).
2. Set corner blocks in back side of shaft, left side blocks in left side, right side blocks in right side correspondingly. Those blocks are intended to be set where doors are, in other cases it is recommended to use back side blocks.
##!!!Important!!!## All those shaft blocks should face to the inside of the shaft, otherwise the cabin just won't go.
3. Set outer walls with left/right side slots in the correspodning places as the screenshots show (#).
4. Set outer wall with trigger.
##!!!Important!!!## It should be set in left side and at one block above the marked floor position (on the screenshots it looks like simple outer wall, but with red luminant button), otherwise you can't just call the elevator.
5. When you built shaft with one floor, it is necessary to set a winch on top of that for cabin could move upside or downside. Connect with that more ropes if you need.
6. Hang up the elevator cabin on the rope (just set it one block below the rope, so it will connect with that).
7. Configure the elevator (create new floors net, add floor destinations). To define a position for that, there is a special marker tool 'Floor marker tool'. Right-click any block to save its position and use this position for setting floor. You can right-click other block to change target position.
8. The elevator is ready! Right-click trigger where you want the cabin to arrive and select necessary floor to transport yourself to by right-clicking the cabin.

## Craft recipes:
Use crafting guide mod or default one.

## Mod Dependencies:
default, farming, stairs, basic_materials.

## Mod License:
MIT (Code and media).

## Mod verison:
1.0.

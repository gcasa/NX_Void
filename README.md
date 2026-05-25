# NX_Void

NX_Void is a small AppKit/GNUstep space game inspired by early NeXTSTEP desktop software. It uses a single custom `NSView` to draw a wireframe cockpit scene, moving starfield, obstacles, projectiles, and a compact HUD.

The project intentionally stays close to classic Objective-C/AppKit style: no nibs, no storyboards, no asset catalogs, and no external runtime dependencies.

## Screenshot

The app renders its scene live, so there is no checked-in gameplay screenshot yet. The application icon lives in `Resources/NX_Void.svg` and is packaged as both macOS `.icns` and GNUstep-friendly `.tiff` assets.

## Building

### macOS

Requirements:

- Xcode command line tools
- `make`

Build the app bundle:

```sh
make
```

Run it:

```sh
make run
```

The build creates:

```text
NX_Void.app/
```

### GNUstep

Requirements:

- GNUstep Make
- Objective-C compiler supported by GNUstep

Build with GNUstep Make configured:

```sh
make -f GNUmakefile
```

The GNUstep build includes `Resources/NX_Void.tiff` as the application icon resource.

## Controls

| Key | Action |
| --- | --- |
| `A` / Left Arrow | Turn left |
| `D` / Right Arrow | Turn right |
| `W` / Up Arrow | Pitch up |
| `S` / Down Arrow | Pitch down |
| Space | Thrust |
| `X` | Brake |
| `F` | Fire |

## Gameplay

Avoid incoming wireframe obstacles, fire at them to score points, and keep shields above zero. Passing obstacles increases score, hits reduce shields, and shield depletion resets the run.

The HUD shows:

- Score
- Shield level
- Current velocity

## Project Layout

```text
.
|-- GNUmakefile          GNUstep build entry point
|-- Info.plist           macOS app bundle metadata
|-- Makefile             macOS/simple build
|-- NXVGameView.h/.m     game loop, input, drawing, collision logic
|-- NXVMath.h/.m         small vector/rotation helpers
|-- Resources/
|   |-- NX_Void.svg      editable icon source
|   |-- NX_Void.icns     macOS app icon
|   `-- NX_Void.tiff     GNUstep icon resource
`-- main.m              AppKit application setup
```

## Cleaning

```sh
make clean
```

This removes object files and built app output.

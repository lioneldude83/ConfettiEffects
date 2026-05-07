# ConfettiEffects

`ConfettiEffects` is a Swift package that adds a reusable SwiftUI confetti effect through a small modifier API.

```swift
import ConfettiEffects
import SwiftUI

struct CelebrationView: View {
    @State private var trigger = 0

    var body: some View {
        VStack {
            Button("Celebrate") {
                trigger += 1
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .confettiEffect(trigger: trigger)
    }
}
```

## Features

- SwiftUI-first public API
- iOS 17+ and macOS 14+
- CPU `Canvas` renderer and Metal renderer
- One-shot celebratory bursts that launch upward, spread outward, arc, and fall naturally
- Configurable particle count, motion, palette, origin, particle sizing, and Reduce Motion behavior
- Circle, rectangle, and rounded rectangle particles with configurable size ranges

## Installation

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/lioneldude83/ConfettiEffects", branch: "main")
]
```

## Usage

Use the modifier with any `Equatable` value that changes when you want a new burst:

```swift
.confettiEffect(trigger: trigger)
```

The trigger can be an `Int`, `Bool`, enum, or identifier.

Each trigger change emits a one-shot burst from the configured origin. Particles launch quickly inside an upward-facing cone, slow under gravity, tumble with randomized angular velocity, stay mostly solid through the rise and early fall, then fade near the end of their lifetimes.

The example below shows how to trigger the confetti effect only when a task first becomes completed:

```swift
import ConfettiEffects
import SwiftUI

struct TaskView: View {
    @State private var isCompleted = false
    @State private var confettiTrigger = 0

    var body: some View {
        VStack {
            Button(isCompleted ? "Completed" : "Complete Task") {
                let wasCompleted = isCompleted
                isCompleted = true

                if wasCompleted == false {
                    confettiTrigger += 1
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .confettiEffect(trigger: confettiTrigger)
    }
}
```

Attach the modifier to the container you want the effect to fill. If you attach it directly to a small `Button`, the burst is clipped to that button's layout region. For confetti that falls through the whole screen, attach the modifier to a full-screen parent container instead of the button itself.

## Configuration

Customize the burst with `ConfettiConfiguration`.

### Parameters

The following parameters are available on `ConfettiConfiguration`:

| Parameter | Description |
| --- | --- |
| `particleCount` | Number of particles generated per burst. |
| `lifetime` | Maximum visible lifetime for each particle. Individual particles are randomized up to this value, with a built-in minimum lifetime floor. |
| `launchAngle` | Base launch direction for the burst. The default is upward at `-90` degrees. |
| `spread` | Angular spread around the launch angle, used to create the upward-facing launch cone. |
| `initialVelocity` | Initial launch velocity range for the burst. Higher values make the opening burst feel snappier. |
| `gravity` | Downward acceleration applied every frame so particles reach an apex and then fall. |
| `drag` | Per-particle velocity damping applied every frame so the motion feels light and airy instead of rigid. |
| `particleScale` | Multiplies all generated particle sizes so you can make the burst larger or smaller without changing the size ranges. |
| `circleSize` | Diameter range for circular particles. |
| `rectangleSize` | Width and height ranges for rectangular and rounded rectangle particles. |
| `emissionOrigin` | A `UnitPoint` that controls where the burst starts inside the modified view. |
| `reduceMotionBehavior` | Controls how the effect responds when the user enables Reduce Motion. |
| `palette` | Built-in color palette used for generated particles. SwiftUI and Metal palette values are tuned to stay visually close across both render paths. |
| `shapes` | Shapes available when generating particles. Mixed shape arrays are supported. |
| `backend` | Renderer selection strategy: force CPU `Canvas`, use Metal when available, or let the package switch execution modes automatically. |

### Example

```swift
.confettiEffect(
    trigger: trigger,
    configuration: ConfettiConfiguration(
        emissionOrigin: .top,
        palette: .sunrise,
        shapes: [.rectangle, .roundedRectangle]
    )
)
```

The default configuration is already tuned to resemble lightweight paper confetti rather than sparks or heavy debris. Use the example above when you want to customize the burst origin, palette, or shape mix. For motion tuning, reduce `spread` for a tighter burst, lower `gravity` or `drag` for more hang time, and adjust `particleScale` if you want larger or smaller pieces without editing every size range.

## Reduce Motion

`ConfettiEffects` respects SwiftUI's `accessibilityReduceMotion` environment value.

- `.automatic` is the default. When the system's Reduce Motion setting is enabled, the effect scales the burst down and forces the CPU renderer.
- `.disable` skips emission entirely.
- `.ignore` keeps the normal behavior even when Reduce Motion is enabled.

Example:

```swift
ConfettiConfiguration(
    reduceMotionBehavior: .disable
)
```

## Backend Behavior

- `.cpu` forces the SwiftUI `Canvas` renderer.
- `.metal` uses the Metal renderer and falls back to CPU if Metal is unavailable.
- `.automatic` uses Metal when available, running smaller bursts with Metal CPU simulation and larger or denser bursts with Metal GPU compute simulation.

The current heuristic switches from Metal CPU simulation to Metal GPU simulation at `120` live particles or more, and can also choose GPU simulation earlier for high-density bursts on large, high-scale canvases.

Expired emissions are cleaned up automatically after a burst finishes, and the Metal renderer pauses itself when no live particles remain.

## Performance

`ConfettiEffects` includes a few internal optimizations to keep larger bursts efficient:

- Automatic backend selection can switch between Metal CPU simulation and Metal GPU simulation based on burst density.
- Expired emissions are cleaned up automatically so inactive overlays do not keep animating.
- Expired GPU particles are compacted out of active Metal buffers so dead instances stop contributing to draw and compute work.
- The Metal renderer reuses buffers instead of allocating new ones every frame.
- The Metal view pauses itself when no live particles remain.
- The CPU renderer uses cached shape paths, and per-particle launch properties are precomputed when bursts are generated.

In most cases, `.automatic` is the best choice unless you explicitly want to force `.cpu` or `.metal`.

## Tests

The package includes tests for configuration behavior, particle generation, mixed shapes, motion, accessibility handling, and backend selection.

Run them in Xcode or with:

```bash
swift test
```

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
- One-shot celebratory bursts that launch around a configurable angle, spread outward, arc, and fall naturally
- Configurable particle count, motion, palette, origin, particle sizing, and Reduce Motion behavior
- Convenience modifiers for bursts, edge cannons, success, subtle, sparkle, and glint effects
- Circle, rectangle, rounded rectangle, sparkle, and glint particles with configurable size ranges, sparkle sharpness, and glint backing controls

## Requirements

- Swift tools 6.0+
- iOS 17+
- macOS 14+

## Installation

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/lioneldude83/ConfettiEffects", branch: "main")
]
```

Then add `ConfettiEffects` to the target that uses it:

```swift
targets: [
    .target(
        name: "YourApp",
        dependencies: ["ConfettiEffects"]
    )
]
```

In Xcode, use File > Add Package Dependencies and enter the package URL:

```text
https://github.com/lioneldude83/ConfettiEffects
```

## Usage

Use the modifier with any `Equatable` value that changes when you want a new burst:

```swift
.confettiEffect(trigger: trigger)
```

The package also includes convenience modifiers for common celebration styles:

```swift
.confettiBurst(
    trigger: trigger,
    from: .top,
    particleCount: 140,
    lifetime: 2.0,
    launchAngle: .degrees(-90),
    spread: .degrees(72),
    initialVelocity: 220...460,
    gravity: 640,
    palette: .rainbow,
    shapes: [.rectangle, .roundedRectangle]
)
.confettiCannon(
    trigger: trigger,
    edge: .bottom,
    particleCount: 120,
    lifetime: 2.0,
    launchAngle: .degrees(-90),
    spread: .degrees(18),
    initialVelocity: 420...720,
    gravity: 680,
    palette: .sunrise,
    shapes: [.rectangle, .sparkle]
)
.successConfetti(
    trigger: trigger,
    particleCount: 150,
    lifetime: 2.3,
    launchAngle: .degrees(-90),
    spread: .degrees(92),
    initialVelocity: 280...520,
    gravity: 680,
    palette: .rainbow,
    shapes: [.roundedRectangle, .rectangle, .sparkle]
)
.subtleConfetti(
    trigger: trigger,
    particleCount: 48,
    lifetime: 1.4,
    launchAngle: .degrees(-90),
    spread: .degrees(42),
    initialVelocity: 160...280,
    gravity: 520,
    particleScale: 0.7,
    palette: .ocean,
    shapes: [.circle, .roundedRectangle]
)
.sparkleConfetti(
    trigger: trigger,
    particleCount: 120,
    lifetime: 2.1,
    launchAngle: .degrees(-90),
    spread: .degrees(66),
    initialVelocity: 220...390,
    gravity: 480,
    particleScale: 0.9,
    sparkleSharpness: 3.8,
    palette: .sunrise,
    shapes: [.sparkle, .circle]
)
.glintConfetti(
    trigger: trigger,
    particleCount: 120,
    lifetime: 2.1,
    launchAngle: .degrees(-90),
    spread: .degrees(66),
    initialVelocity: 220...390,
    gravity: 480,
    particleScale: 0.9,
    sparkleSharpness: 3.8,
    glintCircleOpacity: 0.25,
    glintCircleScale: 0.6,
    palette: .ocean,
    shapes: [.glint]
)
```

The trigger can be an `Int`, `Bool`, enum, or identifier.

Each trigger change emits a one-shot burst from the configured origin. Particles launch quickly around the configured launch angle, slow under gravity, tumble with randomized angular velocity, stay mostly solid through the rise and early fall, then fade near the end of their lifetimes.

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

### Convenience Modifiers

| Modifier | Use case |
| --- | --- |
| `confettiEffect(trigger:configuration:)` | Fully custom one-shot bursts using `ConfettiConfiguration`. |
| `confettiBurst(trigger:from:particleCount:lifetime:launchAngle:spread:initialVelocity:gravity:palette:shapes:)` | Default burst from a specific `UnitPoint`, such as `.center`, `.top`, or `.bottomTrailing`. Defaults to `180` particles, `2.4` seconds, `.degrees(-90)` launch angle, `.degrees(86)` spread, `240...480` velocity, `680` gravity, `.rainbow`, and rectangle-based shapes. |
| `confettiCannon(trigger:edge:particleCount:lifetime:launchAngle:spread:initialVelocity:gravity:palette:shapes:)` | Directional cannon from `.top`, `.bottom`, `.leading`, or `.trailing`. Defaults to `180` particles, `2.4` seconds, `.degrees(-90)` launch angle, a narrow `.degrees(24)` cone, `320...560` velocity, `680` gravity, `.rainbow`, and rectangle-based shapes. |
| `successConfetti(trigger:particleCount:lifetime:launchAngle:spread:initialVelocity:gravity:palette:shapes:)` | Higher-energy celebration for successful actions, milestones, and completed tasks. Defaults to `150` particles, `2.3` seconds, `.degrees(-90)` launch angle, `.degrees(92)` spread, `280...520` velocity, `680` gravity, `.rainbow`, and rounded rectangle, rectangle, and sparkle shapes. |
| `subtleConfetti(trigger:particleCount:lifetime:launchAngle:spread:initialVelocity:gravity:particleScale:palette:shapes:)` | Smaller confirmation effect for frequent or secondary interactions. Defaults to `64` particles, `1.6` seconds, `.degrees(-90)` launch angle, `.degrees(58)` spread, `180...320` velocity, `540` gravity, `0.72` scale, `.ocean`, and circle plus rounded rectangle shapes. |
| `sparkleConfetti(trigger:particleCount:lifetime:launchAngle:spread:initialVelocity:gravity:particleScale:sparkleSharpness:palette:shapes:)` | Compact sparkle-heavy accent. Defaults to `96` particles, `2.1` seconds, `.degrees(-90)` launch angle, `.degrees(66)` spread, `220...390` velocity, `480` gravity, `0.88` scale, `2.6` sharpness, `.sunrise`, and sparkle plus circle shapes. |
| `glintConfetti(trigger:particleCount:lifetime:launchAngle:spread:initialVelocity:gravity:particleScale:sparkleSharpness:glintCircleOpacity:glintCircleScale:palette:shapes:)` | Ocean-colored glint accent using a sparkle layered over a translucent circle. Defaults to `96` particles, `2.1` seconds, `.degrees(-90)` launch angle, `.degrees(66)` spread, `220...390` velocity, `480` gravity, `0.88` scale, `2.6` sharpness, `0.2` backing opacity, `0.6` circle scale, `.ocean`, and glint shapes. |

The convenience modifiers use the same renderer and accessibility behavior as `confettiEffect(trigger:configuration:)`. For reusable preset configuration values, use `ConfettiConfiguration.burst(from:particleCount:lifetime:launchAngle:spread:initialVelocity:gravity:palette:shapes:)`, `ConfettiConfiguration.cannon(from:particleCount:lifetime:launchAngle:spread:initialVelocity:gravity:palette:shapes:)`, `.success(particleCount:lifetime:launchAngle:spread:initialVelocity:gravity:palette:shapes:)`, `.subtle(particleCount:lifetime:launchAngle:spread:initialVelocity:gravity:particleScale:palette:shapes:)`, `.sparkle(particleCount:lifetime:launchAngle:spread:initialVelocity:gravity:particleScale:sparkleSharpness:palette:shapes:)`, or `.glint(particleCount:lifetime:launchAngle:spread:initialVelocity:gravity:particleScale:sparkleSharpness:glintCircleOpacity:glintCircleScale:palette:shapes:)`.

## Configuration

Customize the burst with `ConfettiConfiguration`.

### Parameters

The following parameters are available on `ConfettiConfiguration`:

| Parameter | Default | Description |
| --- | --- | --- |
| `particleCount` | `180` | Number of particles generated per burst. |
| `lifetime` | `2.4` | Maximum visible lifetime for each particle. Individual particles are randomized up to this value, with a built-in minimum lifetime floor. |
| `launchAngle` | `.degrees(-90)` | Base launch direction for the burst. |
| `spread` | `.degrees(86)` | Angular spread around the launch angle, used to create the launch cone. |
| `initialVelocity` | `240...480` | Initial launch velocity range for the burst. Higher values make the opening burst feel snappier. |
| `gravity` | `680` | Downward acceleration applied every frame so particles reach an apex and then fall. |
| `drag` | `0.9` | Per-particle velocity damping applied every frame so the motion feels light and airy instead of rigid. |
| `angularVelocity` | `-8...8` | Angular velocity range, in radians per second, used for particle rotation. Negative and positive values spin in opposite directions. Reduce Motion scales this to 35% in `.automatic` mode. |
| `particleScale` | `1` | Multiplies all generated particle sizes so you can make the burst larger or smaller without changing the size ranges. |
| `circleSize` | `8...14` | Diameter range for circular particles. |
| `sparkleSize` | `10...22` | Diameter range for sparkle and glint particles. This controls the overall particle size. |
| `sparkleSharpness` | `2.6` | Controls how thin or sharp sparkle and glint star arms appear. Higher values create thinner arms. Values are clamped to `1.5...5.0`. |
| `rectangleSize` | width `8...14`, height `12...22` | Width and height ranges for rectangular and rounded rectangle particles. |
| `glintCircleOpacity` | `0.2` | Opacity of the circular backing layer used behind the sparkle layer for glint particles. |
| `glintCircleScale` | `0.6` | Scale of the circular backing layer relative to the sparkle layer for glint particles. Values are clamped to `0.5...1.0`. |
| `emissionOrigin` | `.center` | A `UnitPoint` that controls where the burst starts inside the modified view. |
| `reduceMotionBehavior` | `.automatic` | Controls how the effect responds when the user enables Reduce Motion. |
| `palette` | `.rainbow` | Built-in color palette used for generated particles. SwiftUI and Metal palette values are tuned to stay visually close across both render paths. |
| `shapes` | `[.rectangle, .roundedRectangle]` | Shapes available when generating particles: `.circle`, `.rectangle`, `.roundedRectangle`, `.sparkle`, and `.glint`. Mixed shape arrays are supported. |
| `backend` | `.automatic` | Renderer selection strategy: force CPU `Canvas`, use Metal when available, or let the package switch execution modes automatically. |

### Example

```swift
.confettiEffect(
    trigger: trigger,
    configuration: ConfettiConfiguration(
        emissionOrigin: .top,
        palette: .sunrise,
        shapes: [.rectangle, .roundedRectangle, .sparkle, .glint]
    )
)
```

The default configuration is already tuned to resemble lightweight paper confetti rather than sparks or heavy debris. Use the example above when you want to customize the burst origin, palette, or shape mix. For motion tuning, adjust `launchAngle` to steer the burst, reduce `spread` for a tighter burst, lower `gravity` or `drag` for more hang time, and adjust `particleScale` if you want larger or smaller pieces without editing every size range. For calmer tumbling, try `angularVelocity: -6...6`. Use `circleSize`, `sparkleSize`, and `rectangleSize` when you need per-shape sizing. For thinner sparkle or glint arms, increase `sparkleSharpness`; overall sparkle and glint size still comes from `sparkleSize`.

## Reduce Motion

`ConfettiEffects` respects SwiftUI's `accessibilityReduceMotion` environment value.

- `.automatic` is the default. When the system's Reduce Motion setting is enabled, the effect keeps the selected backend behavior, scales particle count to 60% with an `18...60` cap, caps lifetime at `1.5` seconds, scales launch velocity to 55%, scales angular velocity to 35%, and caps spread at `50` degrees.
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

The Metal renderer uses a transparent `MTKView` over SwiftUI. Its RGB blend factor uses `.sourceAlpha`, while its alpha blend factor uses `.one`. This avoids under-writing alpha at antialiased particle edges, which can otherwise show up as a thin bright or white hard edge around circles, rectangles, sparkles, and glints during live compositing.

`ConfettiOverlay` only creates the rendering overlay when there is at least one active emission, so mounting a view with `.confettiEffect` does not create a continuously drawing Metal view by itself. In `ConfettiMetalView`, `makeMTKView()` creates a transparent `MTKView`, starts it paused, and wires renderer activity callbacks with a weak view capture so callbacks do not keep the platform view alive. `update` assigns the drawable size from SwiftUI's logical size and display scale, then unpauses the view only while there is work to draw.

Expired emissions are cleaned up automatically after a burst finishes, and the Metal view pauses itself when no live particles remain.

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

The package includes tests for configuration behavior, preset factories, particle generation, mixed shapes, motion and sampling boundaries, accessibility handling, backend selection, and Metal renderer pipeline setup.

Run them in Xcode or with:

```bash
swift test
```

## License

`ConfettiEffects` is available under the MIT License. See [LICENSE](LICENSE) for details.

# MyShakeRage Design Spec

Date: 2026-03-27
Status: Approved for planning
Target: iOS 17+, iPhone portrait only

## Product Summary

MyShakeRage is a playful SwiftUI stress-relief app for iPhone. When the user shakes the device, the app detects shake intensity in real time and plays a matching user-recorded voice clip or a bundled sample slot. The tone stays comedic, annoyed, and cute rather than explicit or sexual.

The app has three main tabs:

- Home: live shake detection, character animation, intensity feedback, daily shake count
- Recordings: record, preview, edit, delete, and categorize custom voice clips
- Settings: tune sensitivity, cooldown, haptics, playback mode, and debug visibility

## Goals

- Deliver a complete SwiftUI app structure for iOS 17 and later
- Use CoreMotion for live shake detection while the app is active
- Let users record custom `.m4a` voice clips with level assignment
- Save audio files locally in Documents and persist metadata safely
- Provide a bright, playful interface with large controls and clear feedback
- Keep architecture clean, testable, and aligned with recent SwiftUI practices

## Scope Decisions

- Project format: standard Xcode iOS app project with `.xcodeproj`
- UI language: English-first UI with Korean-friendly example data supported
- Character style: emoji plus SwiftUI shapes and animation, no external required art
- Device orientation: portrait only
- Startup content: no bundled real voice assets yet, but bundled sample slots are built into the architecture for later drop-in `.m4a` files
- Out of scope: background shake detection, cloud sync, iPad layouts, landscape support

## Architecture

The app uses a small MVVM-style structure with service objects for hardware and persistence concerns.

- `MyShakeRageApp`: app entry point, owns the top-level model graph
- `MainTabView`: hosts `Home`, `Recordings`, and `Settings`
- `AppModel`: shared observable object for app-wide state and coordination
- `ShakeEngine`: wraps `CMMotionManager`, computes acceleration magnitude, applies threshold classification and cooldown gating
- `AudioEngine`: plays user recordings and optional bundled samples with `AVAudioPlayer`
- `RecordingStore`: manages recording metadata JSON and file URLs in Documents
- `SettingsStore`: persists user preferences in `UserDefaults`
- `HapticsManager`: maps intensity and settings to `UIImpactFeedbackGenerator`
- `HomeViewModel`: connects shake events to UI state, haptics, playback, and daily count
- `RecordingsViewModel`: loads recording items, handles deletion, preview playback, and editing
- `RecordingSessionViewModel`: manages permission, `AVAudioRecorder`, timer, meters, temp file handling, and save flow

## Data Model

### `ShakeIntensity`

- `weak`
- `medium`
- `strong`
- `extreme`

Thresholds before sensitivity adjustment:

- Weak: `1.5 ..< 2.5`
- Medium: `2.5 ..< 4.0`
- Strong: `4.0 ..< 6.0`
- Extreme: `>= 6.0`

### `PlaybackMode`

- `byIntensity`
- `random`

### `RecordingItem`

- `id: UUID`
- `displayName: String`
- `intensity: ShakeIntensity`
- `fileName: String`
- `createdAt: Date`
- `updatedAt: Date`
- `duration: TimeInterval`
- `isBundledSample: Bool`

### `AppSettings`

- `baseSensitivity: Double`
- `cooldownInterval: Double`
- `hapticsEnabled: Bool`
- `hapticStrength: HapticStrength`
- `playbackMode: PlaybackMode`
- `debugOverlayEnabled: Bool`

## Storage Strategy

- User audio files: `Documents/Recordings/*.m4a`
- Metadata: `Documents/recordings.json`
- Settings: `UserDefaults`
- Daily count: `UserDefaults` keyed by day string
- Bundled sample lookup: `BundledSamples/sample_<intensity>_01.m4a`

If bundled files do not exist, the app remains functional and shows a friendly empty-state message.

## Playback Rules

### Intensity Mode

1. Detect shake intensity
2. Find user recordings for the exact same intensity
3. If present, choose one at random
4. If absent, search bundled samples for the same intensity
5. If nothing is available, show `No sound for this level yet`

### Random Mode

1. Prefer random selection across all user recordings
2. If none exist, randomize across bundled samples
3. If still empty, surface a friendly empty-state message

## Screen Design

### Home

- daily shake counter
- playback mode badge
- large animated emoji character
- `Shake it now` prompt
- live magnitude meter and intensity label
- optional debug overlay
- short status text for cooldown or missing sound feedback

### Recordings

- optional intensity filter
- recording cards with name, level, duration, date
- preview, edit, and delete actions
- prominent record button

### Recording Sheet

- microphone permission message if needed
- waveform bars driven by recorder meters
- timer
- large start/stop button
- post-stop name field, intensity picker, and save action

### Settings

- sensitivity slider
- cooldown slider from `0.8` to `3.0`
- haptics toggle and strength selector
- playback mode selection
- debug overlay toggle
- explanatory app text
- microphone permission explanation and settings shortcut when needed

## Error Handling

- Add `NSMicrophoneUsageDescription` with `사용자가 직접 빡친 소리를 녹음하기 위해 필요합니다.`
- Show a clear denied-permission message and `Open Settings` button
- Surface recorder, save, delete, and playback failures with user-friendly alerts
- No recording for a detected intensity should never crash or fail silently

## Testing Strategy

- Unit-test threshold classification and sensitivity adjustment
- Unit-test playback selection and bundled fallback rules
- Unit-test recording metadata persistence
- Unit-test day-key helper for daily counts
- Use previews and protocols to isolate hardware-dependent code where practical
- Real device validation remains required for shake, haptics, and recording

# MyShakeRage

MyShakeRage is an iOS 17+ SwiftUI toy app that plays funny rage voice clips when the user shakes an iPhone. Users can record their own clips, assign each one to a shake intensity, and tune playback behavior in settings.

## Planned Features

- Real-time shake detection with CoreMotion
- Intensity-based or random audio playback
- Local voice recording with `AVAudioRecorder`
- Recording management, editing, and deletion
- Haptic feedback tied to shake strength
- Local settings persistence and daily shake counts

## Requirements

- Xcode 16 or newer recommended
- iOS 17+ deployment target
- Real device required for shake, haptics, and microphone validation

## Bundled Sample Slots

The app is designed to support optional bundled fallback audio files in:

- `MyShakeRage/Resources/BundledSamples/sample_weak_01.m4a`
- `MyShakeRage/Resources/BundledSamples/sample_medium_01.m4a`
- `MyShakeRage/Resources/BundledSamples/sample_strong_01.m4a`
- `MyShakeRage/Resources/BundledSamples/sample_extreme_01.m4a`

These files are not included yet. The runtime will tolerate missing bundled samples and show friendly empty-state messaging instead.

## Project Structure

- `MyShakeRage/App`: app entry, shared model, and tab shell
- `MyShakeRage/Models`: recording, settings, shake, and playback models
- `MyShakeRage/Services`: motion, audio, haptics, selection, and persistence services
- `MyShakeRage/ViewModels`: Home, Recordings, and Recording Session logic
- `MyShakeRage/Views`: Home, Recordings, Settings, and shared SwiftUI components
- `MyShakeRageTests`: pure-logic and persistence tests

## Verification Notes

- Source code and project structure were authored in a Windows workspace.
- `swift` and `xcodebuild` are not available in this environment, so automated test execution is still pending.
- Before shipping, run `xcodebuild test -project MyShakeRage/MyShakeRage.xcodeproj -scheme MyShakeRage -destination 'platform=iOS Simulator,name=iPhone 16'` on macOS with Xcode installed.
- Shake detection, haptics, microphone permission prompts, and recording quality must be validated on a real iPhone.

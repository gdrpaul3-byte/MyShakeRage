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

# MyShakeRage Continuation Guide

Date: 2026-03-27
Status: Paused after initial implementation

## Purpose

This document is for any future model or developer resuming work on `MyShakeRage` from any environment.

Read this before making changes. Do not assume the app has been build-verified yet.

## Repository State

- Repo URL: `https://github.com/gdrpaul3-byte/MyShakeRage.git`
- Base branch: `main`
- Current feature branch: `feature/app-build`
- Local worktree used for implementation:
  - `C:\Users\gdrpa\OneDrive\문서\google drive\user_gdrpa_backup\codex_workspace1\MyShakeRage\.worktrees\app-build`
- Design spec:
  - `docs/superpowers/specs/2026-03-27-my-shake-rage-design.md`
- Implementation plan:
  - `docs/superpowers/plans/2026-03-27-my-shake-rage.md`

Important history note:

- The remote `main` branch originally contained only `LICENSE`.
- The feature branch was created from a new local repo, then later merged with `origin/main` using `--allow-unrelated-histories` so GitHub PRs would work.
- This is expected. Do not treat that merge as accidental corruption.

## What Has Been Implemented

### Project and Architecture

- Standard iOS app structure with `.xcodeproj`
- SwiftUI app entry and tab shell
- MVVM-style app model plus services
- Design and implementation docs saved under `docs/superpowers`

### Core Logic

- `ShakeIntensityClassifier`
- `PlaybackSelector`
- `RecordingStore`
- `SettingsStore`
- `Date.dayKey`
- data models for settings, recordings, intensities, and shake events

### Device/Platform Services

- `ShakeEngine` using `CMMotionManager`
- `AudioEngine` using `AVAudioPlayer`
- `HapticsManager` using `UIImpactFeedbackGenerator`
- `AVAudioSession` setup helpers for playback/recording

### SwiftUI Features

- Home screen
- Recordings list
- Recording sheet
- Edit recording sheet
- Settings screen
- shared UI components for intensity badge, waveform bars, and shake meter

### Tests Written

These test files exist but were not executed in this Windows environment:

- `MyShakeRageTests/ShakeIntensityClassifierTests.swift`
- `MyShakeRageTests/PlaybackSelectorTests.swift`
- `MyShakeRageTests/RecordingStoreTests.swift`
- `MyShakeRageTests/DateDayKeyTests.swift`

## What Has NOT Been Verified

The following is still unverified:

- Xcode project opens and builds
- Swift compilation succeeds
- XCTest suite passes
- iPhone runtime behavior for shake detection
- haptics feel and mapping
- microphone permission flow
- recording lifecycle on-device
- actual playback from bundled or recorded `.m4a` files

Do not claim the app works end-to-end until these are verified.

## Current Constraints

- Current machine during implementation was Windows
- `swift` was not available
- `xcodebuild` was not available
- No Mac was available
- User does have an iPhone, but without a Mac the app cannot be realistically built, signed, and installed through standard Xcode flow

## First Files To Read When Resuming

If resuming implementation, start here:

1. `MyShakeRage/MyShakeRageApp.swift`
2. `MyShakeRage/App/AppModel.swift`
3. `MyShakeRage/Services/ShakeEngine.swift`
4. `MyShakeRage/ViewModels/RecordingSessionViewModel.swift`
5. `MyShakeRage/Views/Home/HomeView.swift`
6. `MyShakeRage/Views/Recordings/RecordingsView.swift`
7. `MyShakeRage/Views/Settings/SettingsView.swift`
8. `MyShakeRage/MyShakeRage.xcodeproj/project.pbxproj`

## Most Likely Risk Areas

These are the first places likely to need fixes once opened in Xcode:

- `project.pbxproj`
  - file references or target membership may need cleanup
- `RecordingSessionViewModel`
  - AVFoundation APIs may need updates depending on Xcode/iOS SDK behavior
- `SettingsView` and `RecordingSheet`
  - UIKit and permission APIs may need import or API signature adjustments
- `RecordingsView`
  - `.sheet(item:)` behavior depends on `Identifiable` conformance and may need small fixes
- `AppModel`
  - actor isolation, alert handling, or async task warnings may show up under current Swift compiler rules

## Recommended Resume Paths

### If You Have a Mac with Xcode

1. Check out `feature/app-build`
2. Open `MyShakeRage/MyShakeRage.xcodeproj`
3. Fix compile errors first
4. Run:

```bash
xcodebuild test \
  -project MyShakeRage/MyShakeRage.xcodeproj \
  -scheme MyShakeRage \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

5. Test on a real iPhone:
   - shake detection
   - cooldown behavior
   - haptics
   - recording permission prompt
   - recording save/edit/delete
   - playback from recorded clips

### If You Only Have Windows

1. Do not guess about build success
2. Limit work to:
   - code review
   - architecture cleanup
   - documentation
   - GitHub Actions/macOS CI setup
3. If continuing code edits, assume Xcode follow-up will still be required

### If You Want Remote Verification Without a Local Mac

Possible next step:

- add a GitHub Actions workflow using a macOS runner to at least execute `xcodebuild`

This will not fully replace device validation, but it can catch compile and test failures.

## Bundled Audio Notes

- Bundled sample slots are supported by naming convention only
- No real bundled sample `.m4a` files are included
- Expected pattern:
  - `sample_weak_01.m4a`
  - `sample_medium_01.m4a`
  - `sample_strong_01.m4a`
  - `sample_extreme_01.m4a`

## Commit Trail

Key commits on `feature/app-build`:

- `70efd9d` scaffold project
- `2bbe93e` add core models and classifier
- `8123f0d` add settings persistence helpers
- `9b7afb6` add playback selection logic
- `89db132` add recording persistence store
- `0f02e34` add motion audio and haptics services
- `91503c4` add app shell and shared model
- `82c8144` add interactive home screen
- `4fc37da` add recordings management views
- `374229e` add recording capture workflow
- `1c5c8eb` add settings and runtime configuration
- `23a3652` finalize README verification notes

There is also a later merge commit that connects the feature branch history to remote `main`.

## Rules for the Next Person/Model

- Do not remove the unrelated-histories merge without understanding why it exists
- Do not claim build/test success without running actual verification
- Prefer small commits
- Preserve the current app concept and bright comedic tone
- Keep the app foreground-focused
- Do not add explicit or sexual audio content

## Suggested Immediate Next Step

Best next step:

- add macOS-based CI for `xcodebuild`, or resume on a Mac and fix compile/test issues directly

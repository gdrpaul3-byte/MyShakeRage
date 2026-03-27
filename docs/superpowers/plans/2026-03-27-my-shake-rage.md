# MyShakeRage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete iOS 17+ SwiftUI app named MyShakeRage with live shake detection, local voice recording management, intensity-based playback, haptics, and settings persistence.

**Architecture:** Use a focused MVVM structure with service objects for motion, audio, persistence, and haptics. Keep SwiftUI views declarative and lightweight, with logic concentrated in view models and testable helpers such as the intensity classifier, playback selector, and recording store.

**Tech Stack:** SwiftUI, CoreMotion, AVFoundation, UIKit haptics, UserDefaults, FileManager, XCTest

---

## File Structure Map

### App Target

- Create: `MyShakeRage/MyShakeRageApp.swift`
- Create: `MyShakeRage/App/MainTabView.swift`
- Create: `MyShakeRage/App/AppModel.swift`
- Create: `MyShakeRage/Models/ShakeIntensity.swift`
- Create: `MyShakeRage/Models/PlaybackMode.swift`
- Create: `MyShakeRage/Models/HapticStrength.swift`
- Create: `MyShakeRage/Models/RecordingItem.swift`
- Create: `MyShakeRage/Models/AppSettings.swift`
- Create: `MyShakeRage/Models/ShakeEvent.swift`
- Create: `MyShakeRage/Services/ShakeIntensityClassifier.swift`
- Create: `MyShakeRage/Services/ShakeEngine.swift`
- Create: `MyShakeRage/Services/PlaybackSelector.swift`
- Create: `MyShakeRage/Services/AudioEngine.swift`
- Create: `MyShakeRage/Services/RecordingStore.swift`
- Create: `MyShakeRage/Services/SettingsStore.swift`
- Create: `MyShakeRage/Services/HapticsManager.swift`
- Create: `MyShakeRage/ViewModels/HomeViewModel.swift`
- Create: `MyShakeRage/ViewModels/RecordingsViewModel.swift`
- Create: `MyShakeRage/ViewModels/RecordingSessionViewModel.swift`
- Create: `MyShakeRage/Views/Home/HomeView.swift`
- Create: `MyShakeRage/Views/Recordings/RecordingsView.swift`
- Create: `MyShakeRage/Views/Recordings/RecordingSheet.swift`
- Create: `MyShakeRage/Views/Recordings/EditRecordingSheet.swift`
- Create: `MyShakeRage/Views/Settings/SettingsView.swift`
- Create: `MyShakeRage/Views/Shared/IntensityBadge.swift`
- Create: `MyShakeRage/Views/Shared/WaveformBarsView.swift`
- Create: `MyShakeRage/Views/Shared/ShakeMeterView.swift`
- Create: `MyShakeRage/Extensions/AVAudioSession+Setup.swift`
- Create: `MyShakeRage/Extensions/Date+DayKey.swift`
- Create: `MyShakeRage/Resources/Assets.xcassets/Contents.json`
- Create: `MyShakeRage/Resources/BundledSamples/.gitkeep`
- Create: `MyShakeRage/Info.plist`
- Create: `MyShakeRage/MyShakeRage.xcodeproj/project.pbxproj`
- Create: `MyShakeRage/MyShakeRage.xcodeproj/project.xcworkspace/contents.xcworkspacedata`

### Test Target

- Create: `MyShakeRageTests/ShakeIntensityClassifierTests.swift`
- Create: `MyShakeRageTests/PlaybackSelectorTests.swift`
- Create: `MyShakeRageTests/RecordingStoreTests.swift`
- Create: `MyShakeRageTests/DateDayKeyTests.swift`
- Create: `MyShakeRageTests/TestSupport/TemporaryDirectory.swift`

### Documentation

- Create: `README.md`

## Task 1: Create the repository scaffold and Xcode project skeleton

**Files:**
- Create: `MyShakeRage/MyShakeRage.xcodeproj/project.pbxproj`
- Create: `MyShakeRage/MyShakeRage.xcodeproj/project.xcworkspace/contents.xcworkspacedata`
- Create: `MyShakeRage/Info.plist`
- Create: `README.md`

- [ ] **Step 1: Create the base directory layout**

Create the app, test, docs, and resource folders declared in the file structure map.

- [ ] **Step 2: Write the minimal Xcode workspace metadata**

Create `contents.xcworkspacedata` and a valid `project.pbxproj` with one app target and one test target.

- [ ] **Step 3: Write the base app plist**

Include bundle display name, portrait orientation, scene manifest, and `NSMicrophoneUsageDescription`.

- [ ] **Step 4: Write the initial README**

Document app concept, requirements, and how bundled samples should be added later.

- [ ] **Step 5: Commit**

Run:

```bash
git add README.md MyShakeRage MyShakeRageTests docs
git commit -m "chore: scaffold MyShakeRage project"
```

## Task 2: Add the core models and test the shake classification rules first

**Files:**
- Create: `MyShakeRage/Models/ShakeIntensity.swift`
- Create: `MyShakeRage/Models/PlaybackMode.swift`
- Create: `MyShakeRage/Models/HapticStrength.swift`
- Create: `MyShakeRage/Models/RecordingItem.swift`
- Create: `MyShakeRage/Models/AppSettings.swift`
- Create: `MyShakeRage/Models/ShakeEvent.swift`
- Create: `MyShakeRage/Services/ShakeIntensityClassifier.swift`
- Test: `MyShakeRageTests/ShakeIntensityClassifierTests.swift`

- [ ] **Step 1: Write the failing classifier tests**

Cover:

- magnitude below threshold returns `nil`
- weak, medium, strong, and extreme bands classify correctly
- sensitivity raises and lowers the effective threshold

- [ ] **Step 2: Run the classifier tests to confirm failure**

Run on macOS with Xcode installed:

```bash
xcodebuild test -project MyShakeRage/MyShakeRage.xcodeproj -scheme MyShakeRage -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MyShakeRageTests/ShakeIntensityClassifierTests
```

Expected: failure because the classifier and models do not exist yet.

- [ ] **Step 3: Implement the models and classifier**

Keep the classifier pure and deterministic so it is easy to test and reuse from the motion layer.

- [ ] **Step 4: Re-run the classifier tests**

Expected: all classifier tests pass.

- [ ] **Step 5: Commit**

```bash
git add MyShakeRage/Models MyShakeRage/Services/ShakeIntensityClassifier.swift MyShakeRageTests/ShakeIntensityClassifierTests.swift
git commit -m "feat: add core shake models and classifier"
```

## Task 3: Add date-key helpers and settings persistence

**Files:**
- Create: `MyShakeRage/Extensions/Date+DayKey.swift`
- Create: `MyShakeRage/Services/SettingsStore.swift`
- Test: `MyShakeRageTests/DateDayKeyTests.swift`

- [ ] **Step 1: Write the failing day-key tests**

Cover stable `yyyy-MM-dd` style output using a fixed calendar and timezone.

- [ ] **Step 2: Run the day-key tests to confirm failure**

Expected: failure because the helper does not exist yet.

- [ ] **Step 3: Implement `Date+DayKey` and `SettingsStore`**

`SettingsStore` should read and write `AppSettings` plus the per-day shake count.

- [ ] **Step 4: Re-run the day-key tests**

Expected: day-key tests pass.

- [ ] **Step 5: Commit**

```bash
git add MyShakeRage/Extensions/Date+DayKey.swift MyShakeRage/Services/SettingsStore.swift MyShakeRageTests/DateDayKeyTests.swift
git commit -m "feat: add settings persistence helpers"
```

## Task 4: Add playback selection rules with tests first

**Files:**
- Create: `MyShakeRage/Services/PlaybackSelector.swift`
- Test: `MyShakeRageTests/PlaybackSelectorTests.swift`

- [ ] **Step 1: Write the failing playback selector tests**

Cover:

- intensity mode picks only matching-intensity user clips
- intensity mode falls back to same-intensity bundled samples
- random mode chooses from all available recordings
- empty state returns no candidate

- [ ] **Step 2: Run the playback selector tests to confirm failure**

Expected: failure because the selector does not exist yet.

- [ ] **Step 3: Implement `PlaybackSelector`**

Use dependency injection for randomness so tests remain deterministic.

- [ ] **Step 4: Re-run the playback selector tests**

Expected: selector tests pass.

- [ ] **Step 5: Commit**

```bash
git add MyShakeRage/Services/PlaybackSelector.swift MyShakeRageTests/PlaybackSelectorTests.swift
git commit -m "feat: add playback selection logic"
```

## Task 5: Add recording metadata persistence with tests first

**Files:**
- Create: `MyShakeRage/Services/RecordingStore.swift`
- Create: `MyShakeRageTests/TestSupport/TemporaryDirectory.swift`
- Test: `MyShakeRageTests/RecordingStoreTests.swift`

- [ ] **Step 1: Write the failing recording store tests**

Cover:

- saving a new recording item writes metadata
- loading returns sorted recordings
- updating name and intensity persists correctly
- deleting removes both metadata and file

- [ ] **Step 2: Run the recording store tests to confirm failure**

Expected: failure because the store does not exist yet.

- [ ] **Step 3: Implement `RecordingStore`**

Use JSON encoding for metadata and isolate filesystem paths behind helpers.

- [ ] **Step 4: Re-run the recording store tests**

Expected: recording store tests pass.

- [ ] **Step 5: Commit**

```bash
git add MyShakeRage/Services/RecordingStore.swift MyShakeRageTests/TestSupport/TemporaryDirectory.swift MyShakeRageTests/RecordingStoreTests.swift
git commit -m "feat: add recording persistence store"
```

## Task 6: Build motion, audio, and haptics services

**Files:**
- Create: `MyShakeRage/Services/ShakeEngine.swift`
- Create: `MyShakeRage/Services/AudioEngine.swift`
- Create: `MyShakeRage/Services/HapticsManager.swift`
- Create: `MyShakeRage/Extensions/AVAudioSession+Setup.swift`

- [ ] **Step 1: Implement `ShakeEngine`**

Use `CMMotionManager`, publish raw magnitude, gate events with cooldown, and expose start/stop methods.

- [ ] **Step 2: Implement `AudioEngine`**

Support user recording playback, bundled sample playback, and playback error propagation.

- [ ] **Step 3: Implement `HapticsManager` and audio-session setup**

Map intensities to impact styles and centralize session configuration.

- [ ] **Step 4: Perform a static review of service boundaries**

Confirm the services do not depend on SwiftUI and that view models can consume them directly.

- [ ] **Step 5: Commit**

```bash
git add MyShakeRage/Services MyShakeRage/Extensions/AVAudioSession+Setup.swift
git commit -m "feat: add motion audio and haptics services"
```

## Task 7: Build the app model and main tab shell

**Files:**
- Create: `MyShakeRage/MyShakeRageApp.swift`
- Create: `MyShakeRage/App/AppModel.swift`
- Create: `MyShakeRage/App/MainTabView.swift`

- [ ] **Step 1: Implement `AppModel`**

Compose the settings store, recording store, selector, audio engine, and haptics manager into app-wide state.

- [ ] **Step 2: Implement the app entry point**

Create the root `@StateObject`, inject it into the tab tree, and react to scene phase.

- [ ] **Step 3: Implement the tab shell**

Add the Home, Recordings, and Settings tabs with placeholders or real view hooks.

- [ ] **Step 4: Review startup flow**

Verify the app starts cleanly even with zero recordings and zero bundled samples.

- [ ] **Step 5: Commit**

```bash
git add MyShakeRage/MyShakeRageApp.swift MyShakeRage/App
git commit -m "feat: add app shell and shared model"
```

## Task 8: Build the Home feature

**Files:**
- Create: `MyShakeRage/ViewModels/HomeViewModel.swift`
- Create: `MyShakeRage/Views/Home/HomeView.swift`
- Create: `MyShakeRage/Views/Shared/IntensityBadge.swift`
- Create: `MyShakeRage/Views/Shared/ShakeMeterView.swift`

- [ ] **Step 1: Implement `HomeViewModel`**

Bind live shake data to UI properties such as current magnitude, displayed intensity, status text, cooldown state, and daily count.

- [ ] **Step 2: Implement shared intensity and meter views**

Keep them reusable and driven only by simple input values.

- [ ] **Step 3: Implement `HomeView`**

Add the emoji character, bright theme, meter, debug overlay toggle behavior, and basic shake animation.

- [ ] **Step 4: Review empty-state messaging**

Ensure missing sound feedback and cooldown feedback are visible but lightweight.

- [ ] **Step 5: Commit**

```bash
git add MyShakeRage/ViewModels/HomeViewModel.swift MyShakeRage/Views/Home MyShakeRage/Views/Shared/IntensityBadge.swift MyShakeRage/Views/Shared/ShakeMeterView.swift
git commit -m "feat: add interactive home screen"
```

## Task 9: Build the recordings list and edit flow

**Files:**
- Create: `MyShakeRage/ViewModels/RecordingsViewModel.swift`
- Create: `MyShakeRage/Views/Recordings/RecordingsView.swift`
- Create: `MyShakeRage/Views/Recordings/EditRecordingSheet.swift`

- [ ] **Step 1: Implement `RecordingsViewModel`**

Load recordings, filter by intensity, preview playback, and handle edit/delete commands.

- [ ] **Step 2: Implement the list view**

Render recording cards with preview, edit, and delete controls plus a floating or anchored record button.

- [ ] **Step 3: Implement the edit sheet**

Allow renaming and intensity reassignment without rewriting the audio file.

- [ ] **Step 4: Review destructive flows**

Ensure deletion always requires confirmation and reports file errors properly.

- [ ] **Step 5: Commit**

```bash
git add MyShakeRage/ViewModels/RecordingsViewModel.swift MyShakeRage/Views/Recordings/RecordingsView.swift MyShakeRage/Views/Recordings/EditRecordingSheet.swift
git commit -m "feat: add recordings management views"
```

## Task 10: Build the recording sheet and waveform UI

**Files:**
- Create: `MyShakeRage/ViewModels/RecordingSessionViewModel.swift`
- Create: `MyShakeRage/Views/Recordings/RecordingSheet.swift`
- Create: `MyShakeRage/Views/Shared/WaveformBarsView.swift`

- [ ] **Step 1: Implement `RecordingSessionViewModel`**

Handle permission requests, recorder setup, meters, elapsed time, temporary file lifecycle, and save actions.

- [ ] **Step 2: Implement `WaveformBarsView`**

Keep the waveform simple and meter-driven rather than trying to render full audio analysis.

- [ ] **Step 3: Implement `RecordingSheet`**

Support permission messaging, start/stop controls, naming, intensity selection, and save/cancel behavior.

- [ ] **Step 4: Review audio-save flow**

Confirm temporary files become permanent only after successful save.

- [ ] **Step 5: Commit**

```bash
git add MyShakeRage/ViewModels/RecordingSessionViewModel.swift MyShakeRage/Views/Recordings/RecordingSheet.swift MyShakeRage/Views/Shared/WaveformBarsView.swift
git commit -m "feat: add recording capture workflow"
```

## Task 11: Build the settings screen and wire app-wide behavior

**Files:**
- Create: `MyShakeRage/Views/Settings/SettingsView.swift`
- Modify: `MyShakeRage/App/AppModel.swift`
- Modify: `MyShakeRage/ViewModels/HomeViewModel.swift`
- Modify: `MyShakeRage/Services/ShakeEngine.swift`

- [ ] **Step 1: Implement `SettingsView`**

Expose sensitivity, cooldown, haptics, playback mode, debug visibility, and permission guidance.

- [ ] **Step 2: Wire settings changes through the app model**

Propagate updated sensitivity and cooldown into the motion layer and haptic/playback settings into the runtime behavior.

- [ ] **Step 3: Revisit Home behavior with live settings**

Make sure the home screen reacts immediately to updated debug and threshold settings.

- [ ] **Step 4: Review user guidance copy**

Keep the tone playful but clear, especially for permission and empty-state messaging.

- [ ] **Step 5: Commit**

```bash
git add MyShakeRage/Views/Settings/SettingsView.swift MyShakeRage/App/AppModel.swift MyShakeRage/ViewModels/HomeViewModel.swift MyShakeRage/Services/ShakeEngine.swift
git commit -m "feat: add settings and runtime configuration"
```

## Task 12: Final polish, bundled-sample placeholders, and verification

**Files:**
- Modify: `README.md`
- Modify: `MyShakeRage/Resources/BundledSamples/.gitkeep`
- Modify: app source files as needed for final cleanup

- [ ] **Step 1: Add bundled-sample placeholder documentation**

Document naming conventions and where future `.m4a` files should be placed.

- [ ] **Step 2: Run available verification**

On macOS with Xcode:

```bash
xcodebuild test -project MyShakeRage/MyShakeRage.xcodeproj -scheme MyShakeRage -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: all unit tests pass.

In this current Windows workspace, perform file-structure and consistency checks only, and record that simulator/device verification remains pending.

- [ ] **Step 3: Review for scope drift**

Confirm no extra subsystems or unsupported platform features were introduced.

- [ ] **Step 4: Update README with verification notes**

Be explicit about what was validated locally and what still requires Xcode on macOS.

- [ ] **Step 5: Commit**

```bash
git add README.md MyShakeRage MyShakeRageTests
git commit -m "docs: finalize app setup and verification notes"
```

## Manual Review Notes

- This session cannot reliably run the skill-mandated reviewer subagent, so perform a manual plan review before execution.
- During execution, keep commits small and aligned to the task boundaries above.
- Because the current environment is Windows, implementation can be authored here but final build validation must still happen on macOS with Xcode.

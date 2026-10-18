# Fix Gradle Build Errors (25.0.3 and AndroidLocationsException)

The build is failing due to a combination of incompatible/typo version numbers, conflicting environment variables, and possibly an outdated SDK configuration being passed from Flutter.

## User Review Required

> [!IMPORTANT]
> The project is currently using extremely new/beta versions:
> - Gradle: **8.14** (Stable is 8.10)
> - AGP: **8.11.1** (Stable is 8.7)
> - Kotlin: **2.2.20** (Stable is 2.1)
> - Java: **25** (Stable is 23)
>
> I recommend downgrading these to stable versions to ensure compatibility.

> [!CAUTION]
> There is a conflict between `ANDROID_PREFS_ROOT` and `ANDROID_USER_HOME` environment variables. Both are set to `C:\Users\Sodong\.android`. Modern Android Gradle Plugin (AGP) versions require only one (preferably `ANDROID_USER_HOME`). You may need to unset `ANDROID_PREFS_ROOT` in your system environment variables.

## Proposed Changes

### Gradle Configuration

#### [MODIFY] [settings.gradle.kts](file:///D:/Flutter Code/Avance_Flutter/architecture_getx/android/settings.gradle.kts)
- Downgrade AGP and Kotlin versions to stable releases.

#### [MODIFY] [gradle-wrapper.properties](file:///D:/Flutter Code/Avance_Flutter/architecture_getx/android/gradle/wrapper/gradle-wrapper.properties)
- Downgrade Gradle to a stable version (e.g., 8.10.2).

#### [MODIFY] [build.gradle.kts (app)](file:///D:/Flutter Code/Avance_Flutter/architecture_getx/android/app/build.gradle.kts)
- Explicitly set `compileSdk`, `minSdk`, and `targetSdk` to modern values (34/21/34) instead of relying on `flutter.*` variables which seem to be providing outdated or incorrect values (e.g., `25.0.3`).

## Verification Plan

### Automated Tests
- Run `./gradlew assembleDevDebug` to verify the build completes successfully.

### Manual Verification
- Verify that the app can be installed and run on an emulator or device.

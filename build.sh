PLATFORMS="android,windows"

if [ "$1" != "" ]; then
  case "$1" in
    --platforms=*)
      PLATFORMS="${1#*=}"
      ;;
    *)
      echo "Usage: $0 [--platforms=android,windows]"
      exit 1
      ;;
  esac
fi

flutter create . --platforms="$PLATFORMS" --empty --org vadxx

# HACK: file_picker v11.0.2 conditionally skips Kotlin Gradle Plugin when
# AGP >= 9, but Flutter 3.44 defaults to builtInKotlin=false.  Apply KGP
# globally so file_picker's .kt sources still compile. Remove once
# file_picker migrates to built-in Kotlin
# (https://github.com/miguelpruivo/flutter_file_picker/issues/2031).
# Restore gradle.properties settings that flutter create drops.
grep -qF 'flutter.compileSdkVersion=36' android/gradle.properties 2>/dev/null || {
  cat >> android/gradle.properties << 'EOF'
org.gradle.parallel=true
org.gradle.caching=true
flutter.compileSdkVersion=36
EOF
}

# Apply KGP globally — file_picker v11.0.2 skips it when AGP >= 9 but
# Flutter 3.44 defaults to builtInKotlin=false.  Remove once file_picker
# migrates to built-in Kotlin (https://github.com/miguelpruivo/flutter_file_picker/issues/2031).
grep -qF 'kotlin.android' android/build.gradle.kts 2>/dev/null || {
  cat >> android/build.gradle.kts << 'EOF'

subprojects {
    apply(plugin = "org.jetbrains.kotlin.android")

    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}
EOF
}

cd packages/backend
flutter pub get
dart run build_runner build --delete-conflicting-outputs
cd -

dart run slang
dart run flutter_launcher_icons
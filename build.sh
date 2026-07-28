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

flutter create . --platforms="$PLATFORMS" --empty --org com.vadxx

# Pin Android build tool versions newer than the Flutter template defaults.
AGP_VERSION=9.3.1
KGP_VERSION=2.4.10
GRADLE_VERSION=9.6.1
sed -i "s/id(\"com.android.application\") version \"[^\"]*\"/id(\"com.android.application\") version \"$AGP_VERSION\"/" android/settings.gradle.kts
sed -i "s/id(\"org.jetbrains.kotlin.android\") version \"[^\"]*\"/id(\"org.jetbrains.kotlin.android\") version \"$KGP_VERSION\"/" android/settings.gradle.kts
sed -i "s|distributions/gradle-[^-]*-all.zip|distributions/gradle-$GRADLE_VERSION-all.zip|" android/gradle/wrapper/gradle-wrapper.properties

# Restore gradle.properties settings that flutter create drops.
grep -qF 'flutter.compileSdkVersion=36' android/gradle.properties 2>/dev/null || {
  cat >> android/gradle.properties << 'EOF'
org.gradle.parallel=true
org.gradle.caching=true
flutter.compileSdkVersion=36
EOF
}

cd packages/backend
flutter pub get
dart run build_runner build --delete-conflicting-outputs
cd -

dart run slang
dart run flutter_launcher_icons

# Generate tablet screenshots for Google Play (run manually when UI changes).
# flutter run -d windows -t tools/screenshots/main.dart -a --device=tablet_7
# flutter run -d windows -t tools/screenshots/main.dart -a --device=tablet_10
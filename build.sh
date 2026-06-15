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

cd packages/backend
flutter pub get
dart run build_runner build --delete-conflicting-outputs
cd -

dart run slang
dart run flutter_launcher_icons
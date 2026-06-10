flutter create . --platforms=android,windows --empty --org vadxx

cd packages/backend 
flutter pub get
dart run build_runner build --delete-conflicting-outputs
cd -

dart run flutter_launcher_icons
dart run slang
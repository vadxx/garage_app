# garage_app
Your garage of cars in your phone. Track their maintenance and daily spendings.

Flutter app. Supports Windows and Android platforms. Other platforms will be supported later.

**Absolutely free · No ads · No tracking**

| Task | Command |
|------|---------|
| First-time setup | `flutter create . --platforms=android,windows --empty --org vadxx; flutter pub get -C packages/backend` |
| Formatting and Analysis | `dart format .; flutter analyze` |
| Testing | `flutter test packages/backend; flutter test` |
| Debug on Host | `flutter run -d windows` |
| Debug on Android | `flutter run -d V2352A` |
| Build apk then supply | `flutter build apk; flutter install -d V2352A` |

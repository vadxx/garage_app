## Developer commands

| Task | Command |
|------|---------|
| Init and build | `sh build.sh --platforms=android,windows` |
| Formatting and Analysis | `dart format .; flutter analyze` |
| Testing | `sh test.sh` |
| Debug on Host | `flutter run -d windows` |
| Debug on Android | `flutter run -d V2352A` |
| Build apk then supply | `flutter build apk --target-platform android-arm64; flutter install -d V2352A` |

## Testing

- You can use [.CSV files from ./datasets](datasets/) to test the app with data on your local device. Upload the file to your device, then specify it on the app from empty home screen or settings.

## Screenshots

- Generate Windows app screenshots with demo data:
  ```bash
  flutter run -d windows --no-hot -t tools/screenshots/main.dart
  ```
  Output PNGs are written to `./screenshots/`.

## References

- `git worktree`'s tutorial - [link to my gist](https://gist.github.com/vadxx/b2ef4c0c3bfda0d4e7a6666fc898ad7a)

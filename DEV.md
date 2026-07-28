## Developer commands

**Setup**: Check my guide here - https://github.com/vadxx/flutter-tutorial


| Task | Command |
|------|---------|
| Init and build | `sh build.sh --platforms=android,windows` |
| Formatting and Analysis | `dart format .; flutter analyze` |
| Testing | `sh test.sh` |
| Debug on Host | `flutter run -d windows` |
| Debug on Android | `flutter run -d V2352A` |
| Build apk then supply | `flutter build apk --target-platform android-arm64 --release; flutter install -d V2352A` |

## Testing

- You can use [.CSV files from ./datasets](datasets/) to test the app with data on your local device. Upload the file to your device, then specify it on the app from empty home screen or settings.

## Screenshots

- Generate Windows app screenshots with demo data:
  ```bash
  flutter run -d windows --no-hot -t tools/screenshots/main.dart
  ```
  Output PNGs are written to `./screenshots/`.

## Release checklist

1. **Update release metadata**
   - Bump `version` in `pubspec.yaml`.
   - Add a section to `CHANGELOG.md`.

2. **Ensure the Android release keystore exists**

   If `android/app/upload-keystore.jks` is missing, generate one:

   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -alias upload \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -storepass <password> -keypass <password> -dname "CN=garage_app"
   ```

   Generate a password (use the same value for both `-storepass` and `-keypass`):

   ```bash
   openssl rand -base64 24
   ```

   Then create `android/key.properties`:

   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

   > **Important:** back up `android/app/upload-keystore.jks` and `android/key.properties` outside the repo. The same keystore is required for every update on Google Play.

3. **Run checks**

   ```bash
   sh test.sh
   flutter analyze
   cd packages/backend && dart analyze && cd ../..
   ```

4. **Build release artifacts**

   ```bash
   flutter build appbundle --release
   flutter build apk --target-platform android-arm64 --release
   ```

5. **Verify signing**

   ```bash
   jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
   java -jar "$ANDROID_SDK_ROOT/build-tools/36.0.0/lib/apksigner.jar" verify --verbose build/app/outputs/flutter-apk/app-release.apk
   ```

6. **Tag and push**

   Direct from the release branch:

   ```bash
   git tag -a vX.Y.Z-rc.N -m "Pre-release vX.Y.Z-rc.N"
   git push origin main
   git push origin vX.Y.Z-rc.N
   ```

   Or, if you merged via a pull request, tag the merge commit on `main`:

   ```bash
   git checkout main
   git pull origin main
   git tag -a vX.Y.Z-rc.N -m "Pre-release vX.Y.Z-rc.N"
   git push origin vX.Y.Z-rc.N
   ```

7. **Create a GitHub pre-release** (optional)

   ```bash
   gh release create vX.Y.Z-rc.N \
     build/app/outputs/bundle/release/app-release.aab \
     build/app/outputs/flutter-apk/app-release.apk \
     --prerelease --title "vX.Y.Z-rc.N" --notes-file CHANGELOG.md
   ```

## References

- `git worktree`'s tutorial - [link to my gist](https://gist.github.com/vadxx/b2ef4c0c3bfda0d4e7a6666fc898ad7a)

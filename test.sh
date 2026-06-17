echo 'Format:'
dart format --set-exit-if-changed .
echo 'Backend:'
cd packages/backend && dart test
cd -
echo 'App:'
flutter test
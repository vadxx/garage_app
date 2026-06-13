import 'package:backend/backend.dart' as backend;

class FakeSettingsRepository implements backend.SettingsRepository {
  backend.AppSettings _settings = const backend.AppSettings();
  @override
  backend.AppSettings load() => _settings;
  @override
  void save(backend.AppSettings s) => _settings = s;
}
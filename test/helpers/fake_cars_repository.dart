import 'package:backend/backend.dart' as backend;

class FakeCarsRepository implements backend.CarsRepository {
  final List<backend.Car> _cars = [];
  int _nextId = 1;

  @override
  List<backend.Car> load() => List.unmodifiable(_cars);

  @override
  void insert(backend.Car car) {
    _cars.add(car.copyWith(id: _nextId++));
  }

  @override
  void update(backend.Car car) {
    final i = _cars.indexWhere((c) => c.id == car.id);
    if (i >= 0) _cars[i] = car;
  }

  @override
  void delete(int id) => _cars.removeWhere((c) => c.id == id);
}
// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT
import 'package:backend/backend.dart' as backend;

class FakeCarWorksRepository implements backend.CarWorksRepository {
  final List<backend.CarWork> _works = [];
  int _nextId = 1;

  @override
  List<backend.CarWork> loadByCarId(int carId) =>
      _works.where((w) => w.carId == carId).toList();

  @override
  void insert(backend.CarWork work) {
    _works.add(work.copyWith(id: _nextId++));
  }

  @override
  void update(backend.CarWork work) {
    final i = _works.indexWhere((w) => w.id == work.id);
    if (i >= 0) _works[i] = work;
  }

  @override
  void insertWithId(backend.CarWork work) {
    _works.add(work);
  }

  @override
  void delete(int workId) {
    _works.removeWhere((w) => w.id == workId);
  }

  static const _categoryNames = [
    'oil',
    'fuel',
    'cleaning',
    'diagnostic',
    'electronics',
    'repair',
    'replacement',
    'parking',
    'insurance',
    'tiresWheels',
    'taxFees',
  ];

  @override
  String categoryName(int id) =>
      id >= 0 && id < _categoryNames.length ? _categoryNames[id] : '';

  @override
  int categoryId(String name) => _categoryNames.indexOf(name.toLowerCase());
}

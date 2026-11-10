import 'package:flutter_test/flutter_test.dart';
import 'package:projekakhirpamp/features/category_rack/data/category_rack_repository.dart';
import 'package:projekakhirpamp/features/category_rack/domain/models/category_model.dart';
import 'package:projekakhirpamp/features/category_rack/domain/models/rack_model.dart';
import 'package:projekakhirpamp/features/category_rack/domain/models/category_rack_model.dart';
import 'package:projekakhirpamp/features/category_rack/presentation/providers/category_rack_provider.dart';

class FakeRepository extends CategoryRackRepository {
  @override
  Future<List<CategoryModel>> getCategories() async => const [
    CategoryModel(id: 'c1', name: 'Teknologi'),
    CategoryModel(id: 'c2', name: 'Fiksi'),
  ];
  @override
  Future<List<RackModel>> getRacks() async => const [
    RackModel(id: 'r1', rackCode: 'RK-A', location: 'Lantai 1'),
    RackModel(id: 'r2', rackCode: 'RK-B', location: 'Lantai 2'),
  ];
  @override
  Future<List<CategoryRackModel>> getMappings() async => const [
    CategoryRackModel(id: 'm1', categoryId: 'c1', rackId: 'r1'),
    CategoryRackModel(id: 'm2', categoryId: 'c2', rackId: 'r2'),
  ];
}

void main() {
  test('hanya rak yang terkait kategori muncul di dropdown', () async {
    final provider = CategoryRackProvider(repository: FakeRepository());
    await provider.fetchCategoryRacks();
    expect(provider.hasLoaded, true);
    expect(provider.categories.length, 2);
    expect(provider.racksForCategory('c1').map((r) => r.rackCode), ['RK-A']);
    expect(provider.racksForCategory('c2').map((r) => r.rackCode), ['RK-B']);
    expect(provider.isValidPair('c1', 'r1'), true);
    expect(provider.isValidPair('c1', 'r2'), false);
    provider.dispose();
  });
}
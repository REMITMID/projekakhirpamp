import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:projekakhirpamp/features/catalog/domain/models/book_model.dart';
import 'package:projekakhirpamp/features/catalog/presentation/pages/book_form_page.dart';
import 'package:projekakhirpamp/features/catalog/presentation/providers/book_provider.dart';
import 'package:projekakhirpamp/features/category_rack/data/category_rack_repository.dart';
import 'package:projekakhirpamp/features/category_rack/domain/models/category_model.dart';
import 'package:projekakhirpamp/features/category_rack/domain/models/rack_model.dart';
import 'package:projekakhirpamp/features/category_rack/domain/models/category_rack_model.dart';
import 'package:projekakhirpamp/features/category_rack/presentation/providers/category_rack_provider.dart';

const techId = '00000000-0000-0000-0000-000000000001';
const fictionId = '00000000-0000-0000-0000-000000000002';
const rackAId = '00000000-0000-0000-0000-000000000003';
const rackBId = '00000000-0000-0000-0000-000000000004';

class FakeReferenceRepository extends CategoryRackRepository {
  @override
  Future<List<CategoryModel>> getCategories() async => const [
    CategoryModel(id: techId, name: 'Teknologi'),
    CategoryModel(id: fictionId, name: 'Fiksi'),
  ];

  @override
  Future<List<RackModel>> getRacks() async => const [
    RackModel(id: rackAId, rackCode: 'RK-A', location: 'Lantai 1'),
    RackModel(id: rackBId, rackCode: 'RK-B', location: 'Lantai 2'),
  ];

  @override
  Future<List<CategoryRackModel>> getMappings() async => const [
    CategoryRackModel(id: 'm1', categoryId: techId, rackId: rackAId),
    CategoryRackModel(id: 'm2', categoryId: fictionId, rackId: rackBId),
  ];
}

void main() {
  Widget createFormWidget({BookModel? book}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => CategoryRackProvider(
            repository: FakeReferenceRepository())),
      ],
      child: MaterialApp(home: BookFormPage(book: book)),
    );
  }

  testWidgets('form memilih ID kategori dan hanya menampilkan rak terkait',
          (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        await tester.pumpWidget(createFormWidget());
        await tester.pumpAndSettle();

        final categoryField = find.byType(DropdownButtonFormField<String>).first;
        await tester.ensureVisible(categoryField);
        await tester.tap(categoryField);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Teknologi').last);
        await tester.pumpAndSettle();

        final rackField = find.byType(DropdownButtonFormField<String>).last;
        await tester.ensureVisible(rackField);
        await tester.tap(rackField);
        await tester.pumpAndSettle();
        expect(find.text('RK-A - Lantai 1'), findsWidgets);
        expect(find.text('RK-B - Lantai 2'), findsNothing);
      });

  testWidgets('mode edit menggunakan ID yang sama walaupun nama berubah',
          (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        const book = BookModel(
          id: 'book-1', bookCode: 'BK-001', title: 'Buku Teknologi',
          author: 'Penulis', publisher: 'Penerbit', publicationYear: 2024,
          categoryId: techId, rackId: rackAId,
          categoryName: 'Teknologi Lama', rackCode: 'RK-A',
          rackLocationName: 'Lokasi Lama', stock: 5,
        );
        await tester.pumpWidget(createFormWidget(book: book));
        await tester.pumpAndSettle();
        expect(find.text('Edit Data Buku'), findsOneWidget);
        expect(find.text('BK-001'), findsOneWidget);
        expect(find.text('Buku Teknologi'), findsOneWidget);
        expect(find.text('Teknologi'), findsWidgets);
        expect(find.text('RK-A - Lantai 1'), findsWidgets);
      });
}

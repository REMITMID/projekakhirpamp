import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:projekakhirpamp/features/catalog/domain/models/book_model.dart';
import 'package:projekakhirpamp/features/catalog/presentation/pages/book_form_page.dart';
import 'package:projekakhirpamp/features/catalog/presentation/providers/book_provider.dart';

void main() {
  Widget createFormWidget({BookModel? book}) {
    return ChangeNotifierProvider(
      create: (_) => BookProvider(),
      child: MaterialApp(
        home: BookFormPage(book: book),
      ),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets(
      'Create Mode: Validates empty fields and dropdowns on save button press',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createFormWidget());
    await tester.pumpAndSettle();

    expect(find.text('Tambah Buku Baru'), findsOneWidget);

    final submitBtn = find.text('Tambah Buku');
    expect(submitBtn, findsOneWidget);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Verify error messages for required fields & dropdowns
    expect(find.text('Kode buku wajib diisi'), findsOneWidget);
    expect(find.text('Judul buku wajib diisi'), findsOneWidget);
    expect(find.text('Nama penulis wajib diisi'), findsOneWidget);
    expect(find.text('Nama penerbit wajib diisi'), findsOneWidget);
    expect(find.text('Kategori wajib dipilih'), findsOneWidget);
    expect(find.text('Lokasi rak wajib dipilih'), findsOneWidget);
  });

  testWidgets('Edit Mode: Prepopulates existing book data & dropdown selections',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final book = BookModel(
      id: 'book-1',
      bookCode: 'BK-001',
      title: 'Laskar Pelangi',
      author: 'Andrea Hirata',
      publisher: 'Bentang Pustaka',
      publicationYear: 2005,
      category: 'Sastra',
      rackLocation: 'Rak A-1',
      stock: 12,
    );

    await tester.pumpWidget(createFormWidget(book: book));
    await tester.pumpAndSettle();

    expect(find.text('Edit Data Buku'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
    expect(find.text('BK-001'), findsOneWidget);
    expect(find.text('Laskar Pelangi'), findsOneWidget);
    expect(find.text('Andrea Hirata'), findsOneWidget);
    expect(find.text('Bentang Pustaka'), findsOneWidget);
    expect(find.text('2005'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);

    // Dropdown values pre-selected in edit mode
    expect(find.text('Sastra'), findsWidgets);
    expect(find.text('Rak A-1'), findsWidgets);
  });

  testWidgets('Edit Mode: Shows validation errors when fields are cleared',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final book = BookModel(
      id: 'book-1',
      bookCode: 'BK-001',
      title: 'Laskar Pelangi',
      author: 'Andrea Hirata',
      publisher: 'Bentang Pustaka',
      publicationYear: 2005,
      category: 'Sastra',
      rackLocation: 'Rak A-1',
      stock: 12,
    );

    await tester.pumpWidget(createFormWidget(book: book));
    await tester.pumpAndSettle();

    // Clear Title field
    final titleFinder = find.widgetWithText(TextFormField, 'Judul Buku *');
    await tester.enterText(titleFinder, '');

    // Press save
    final saveBtn = find.text('Simpan Perubahan');
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    expect(find.text('Judul buku wajib diisi'), findsOneWidget);
  });
}

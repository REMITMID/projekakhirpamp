import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projekakhirpamp/features/member/data/member_repository.dart';
import 'package:projekakhirpamp/features/member/domain/models/member_model.dart';
import 'package:projekakhirpamp/features/member/presentation/pages/member_form_page.dart';
import 'package:projekakhirpamp/features/member/presentation/pages/member_list_page.dart';
import 'package:projekakhirpamp/features/member/presentation/providers/member_provider.dart';

class FakeMemberRepository extends MemberRepository {
  final List<MemberModel> saved = [];
  bool rejectDuplicate = false;
  bool failFetch = false;
  final List<String> deletedIds = [];
  Object? deleteError;
  Completer<void>? deleteCompletion;
  final List<String> updatedIds = [];
  Object? updateError;
  Completer<void>? updateCompletion;

  @override
  Future<List<MemberModel>> fetchMembers() async {
    if (failFetch) throw Exception('Offline');
    return List.of(saved);
  }

  @override
  Future<MemberModel> addMember(MemberModel member) async {
    if (rejectDuplicate) {
      throw const PostgrestException(message: 'Duplicate', code: '23505');
    }
    final result = MemberModel.fromJson({'id': 'member-1', ...member.toJson()});
    saved.add(result);
    return result;
  }

  @override
  Future<void> deleteMember(String id) async {
    deletedIds.add(id);
    final completion = deleteCompletion;
    if (completion != null) await completion.future;
    final error = deleteError;
    if (error != null) throw error;
    saved.removeWhere((member) => member.id == id);
  }

  @override
  Future<MemberModel> updateMember(MemberModel member) async {
    updatedIds.add(member.id!);
    final completion = updateCompletion;
    if (completion != null) await completion.future;
    final error = updateError;
    if (error != null) throw error;
    final index = saved.indexWhere((item) => item.id == member.id);
    if (index == -1) {
      throw const PostgrestException(
        message: 'No row returned',
        code: 'PGRST116',
      );
    }
    final updated = MemberModel.fromJson({'id': member.id, ...member.toJson()});
    saved[index] = updated;
    return updated;
  }
}

const firstMember = MemberModel(
  id: 'member-1',
  memberNumber: 'AGT-001',
  name: 'Anggota Pertama',
  email: 'pertama@example.com',
  phone: '081234567890',
  address: 'Jalan Perpustakaan 1',
);

const secondMember = MemberModel(
  id: 'member-2',
  memberNumber: 'AGT-002',
  name: 'Anggota Kedua',
  email: 'kedua@example.com',
  phone: '081234567891',
);

Future<void> openDeleteDialog(WidgetTester tester) async {
  final row = find.ancestor(
    of: find.text(firstMember.name),
    matching: find.byType(ListTile),
  );
  await tester.tap(
    find.descendant(of: row, matching: find.byTooltip('Hapus anggota')),
  );
  await tester.pumpAndSettle();
}

Future<void> openMembers(
  WidgetTester tester,
  FakeMemberRepository repository,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => MemberProvider(repository: repository),
      child: const MaterialApp(home: MemberListPage()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> openForm(WidgetTester tester) async {
  await tester.tap(find.text('Tambah Anggota'));
  await tester.pumpAndSettle();
}

Future<void> openEditForm(WidgetTester tester) async {
  final row = find.ancestor(
    of: find.text(firstMember.name),
    matching: find.byType(ListTile),
  );
  await tester.tap(
    find.descendant(of: row, matching: find.byTooltip('Edit anggota')),
  );
  await tester.pumpAndSettle();
}

Future<void> fillForm(
  WidgetTester tester, {
  String email = '  ANGGOTA@example.com  ',
}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), '  AGT-001  ');
  await tester.enterText(fields.at(1), '  Ghefira Addien  ');
  await tester.enterText(fields.at(2), email);
  await tester.enterText(fields.at(3), '081234567890');
}

Future<void> saveForm(WidgetTester tester, {bool editing = false}) async {
  final button = find.text(editing ? 'Simpan Perubahan' : 'Simpan Anggota');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Required fields prevent an empty member from being saved', (
    tester,
  ) async {
    final repository = FakeMemberRepository();
    await openMembers(tester, repository);
    await openForm(tester);
    await saveForm(tester);
    expect(find.text('Nomor anggota wajib diisi'), findsOneWidget);
    expect(find.text('Nama lengkap wajib diisi'), findsOneWidget);
    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Nomor telepon wajib diisi'), findsOneWidget);
    expect(repository.saved, isEmpty);
  });

  testWidgets('Invalid email and phone are rejected', (tester) async {
    final repository = FakeMemberRepository();
    await openMembers(tester, repository);
    await openForm(tester);
    await fillForm(tester, email: 'bukan-email');
    await tester.enterText(find.byType(TextFormField).at(3), '123');
    await saveForm(tester);
    expect(find.text('Masukkan email yang valid'), findsOneWidget);
    expect(
      find.text('Masukkan nomor telepon dengan 8–15 digit'),
      findsOneWidget,
    );
    expect(repository.saved, isEmpty);
  });

  testWidgets('Saving a member normalizes input and shows it in the list', (
    tester,
  ) async {
    final repository = FakeMemberRepository();
    await openMembers(tester, repository);
    await openForm(tester);
    await fillForm(tester);
    await saveForm(tester);
    expect(repository.saved, hasLength(1));
    expect(repository.saved.single.email, 'anggota@example.com');
    expect(repository.saved.single.memberNumber, 'AGT-001');
    expect(repository.saved.single.address, isEmpty);
    expect(find.text('Ghefira Addien'), findsOneWidget);
    expect(find.text('Anggota berhasil ditambahkan'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('Duplicate rejection preserves input and allows retry', (
    tester,
  ) async {
    final repository = FakeMemberRepository()..rejectDuplicate = true;
    await openMembers(tester, repository);
    await openForm(tester);
    await fillForm(tester);
    await saveForm(tester);
    expect(
      find.text('Nomor anggota atau email sudah terdaftar.'),
      findsOneWidget,
    );
    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(repository.saved, isEmpty);
    repository.rejectDuplicate = false;
    await saveForm(tester);
    expect(repository.saved, hasLength(1));
    expect(find.text('Ghefira Addien'), findsOneWidget);
  });

  testWidgets('Loading failure offers a working retry', (tester) async {
    final repository = FakeMemberRepository()..failFetch = true;
    await openMembers(tester, repository);
    expect(
      find.text('Gagal memuat anggota. Periksa koneksi lalu coba lagi.'),
      findsOneWidget,
    );
    repository.failFetch = false;
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada anggota.'), findsOneWidget);
  });

  testWidgets('Cancelling deletion does not send a delete request', (
    tester,
  ) async {
    final repository = FakeMemberRepository()..saved.add(firstMember);
    await openMembers(tester, repository);
    await openDeleteDialog(tester);
    expect(find.textContaining('"Anggota Pertama" (AGT-001)'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(repository.deletedIds, isEmpty);
    expect(find.text(firstMember.name), findsOneWidget);
  });

  testWidgets('Confirmed deletion removes only the selected member', (
    tester,
  ) async {
    final repository = FakeMemberRepository()
      ..saved.addAll([firstMember, secondMember]);
    await openMembers(tester, repository);
    await openDeleteDialog(tester);
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    expect(repository.deletedIds, [firstMember.id]);
    expect(repository.saved.single.id, secondMember.id);
    expect(find.text(firstMember.name), findsNothing);
    expect(find.text(secondMember.name), findsOneWidget);
    expect(find.text('Anggota berhasil dihapus'), findsOneWidget);
  });

  final deleteFailures = <String, (Object, String)>{
    'related records': (
      const PostgrestException(message: 'Foreign key violation', code: '23503'),
      'Anggota tidak dapat dihapus karena masih digunakan oleh data lain.',
    ),
    'denied permission': (
      const PostgrestException(message: 'Denied', code: '42501'),
      'Akses ditolak. Pastikan Anda sudah login dan memiliki izin menghapus anggota.',
    ),
    'no deleted row': (
      const PostgrestException(message: 'No row returned', code: 'PGRST116'),
      'Anggota tidak ditemukan atau Anda tidak memiliki izin menghapusnya. Muat ulang daftar dan periksa izin akses.',
    ),
    'connection failure': (
      Exception('Offline'),
      'Gagal menghapus anggota. Periksa koneksi lalu coba lagi.',
    ),
  };
  for (final failure in deleteFailures.entries) {
    testWidgets('Deletion with ${failure.key} keeps member visible', (
      tester,
    ) async {
      final repository = FakeMemberRepository()
        ..saved.add(firstMember)
        ..deleteError = failure.value.$1;
      await openMembers(tester, repository);
      await openDeleteDialog(tester);
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();
      expect(repository.saved, hasLength(1));
      expect(find.text(firstMember.name), findsOneWidget);
      expect(find.text(failure.value.$2), findsOneWidget);
      expect(find.text('Anggota berhasil dihapus'), findsNothing);
      expect(
        tester
            .widget<IconButton>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is IconButton && widget.tooltip == 'Hapus anggota',
              ),
            )
            .onPressed,
        isNotNull,
      );
    });
  }

  testWidgets(
    'Pending deletion keeps row visible and prevents repeated actions',
    (tester) async {
      final completion = Completer<void>();
      final repository = FakeMemberRepository()
        ..saved.add(firstMember)
        ..deleteCompletion = completion;
      await openMembers(tester, repository);
      await openDeleteDialog(tester);
      await tester.tap(find.text('Hapus'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(firstMember.name), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is IconButton && widget.tooltip == 'Muat ulang',
              ),
            )
            .onPressed,
        isNull,
      );
      final listContext = tester.element(find.byType(MemberListPage));
      final provider = listContext.read<MemberProvider>();
      expect(await provider.deleteMember(firstMember.id!), isNotNull);
      expect(repository.deletedIds, [firstMember.id]);
      completion.complete();
      await tester.pumpAndSettle();
      expect(find.text(firstMember.name), findsNothing);
      expect(find.text('Belum ada anggota.'), findsOneWidget);
    },
  );

  testWidgets('Edit form shows existing values and back discards changes', (
    tester,
  ) async {
    final repository = FakeMemberRepository()..saved.add(firstMember);
    await openMembers(tester, repository);
    await openEditForm(tester);
    expect(find.text('Edit Anggota'), findsOneWidget);
    final values = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .map((field) => field.controller!.text)
        .toList();
    expect(values, [
      firstMember.memberNumber,
      firstMember.name,
      firstMember.email,
      firstMember.phone,
      firstMember.address,
    ]);
    await tester.enterText(find.byType(TextFormField).at(1), 'Belum Disimpan');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(repository.updatedIds, isEmpty);
    expect(repository.saved.single.name, firstMember.name);
    expect(find.text(firstMember.name), findsOneWidget);
  });

  testWidgets('Editing changes only selected member and keeps its ID', (
    tester,
  ) async {
    final repository = FakeMemberRepository()
      ..saved.addAll([firstMember, secondMember]);
    await openMembers(tester, repository);
    await openEditForm(tester);
    await fillForm(tester);
    await tester.enterText(find.byType(TextFormField).at(0), ' AGT-003 ');
    await tester.enterText(find.byType(TextFormField).at(3), '081234567899');
    await tester.enterText(find.byType(TextFormField).at(4), ' Jalan Baru 2 ');
    await saveForm(tester, editing: true);
    expect(repository.updatedIds, [firstMember.id]);
    expect(repository.saved, hasLength(2));
    final updated = repository.saved.first;
    expect(updated.id, firstMember.id);
    expect(updated.memberNumber, 'AGT-003');
    expect(updated.name, 'Ghefira Addien');
    expect(updated.email, 'anggota@example.com');
    expect(updated.phone, '081234567899');
    expect(updated.address, 'Jalan Baru 2');
    expect(repository.saved.last, same(secondMember));
    expect(find.text('Ghefira Addien'), findsOneWidget);
    expect(find.text(secondMember.name), findsOneWidget);
    expect(find.text('Anggota berhasil diperbarui'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('Editing validates input before sending updates', (tester) async {
    final repository = FakeMemberRepository()..saved.add(firstMember);
    await openMembers(tester, repository);
    await openEditForm(tester);
    await tester.enterText(find.byType(TextFormField).at(1), ' ');
    await tester.enterText(find.byType(TextFormField).at(2), 'bukan-email');
    await saveForm(tester, editing: true);
    expect(find.text('Nama lengkap wajib diisi'), findsOneWidget);
    expect(find.text('Masukkan email yang valid'), findsOneWidget);
    expect(repository.updatedIds, isEmpty);
    expect(repository.saved.single.name, firstMember.name);
  });

  testWidgets('Duplicate edit keeps changes in the form and allows retry', (
    tester,
  ) async {
    final repository = FakeMemberRepository()
      ..saved.add(firstMember)
      ..updateError = const PostgrestException(
        message: 'Duplicate',
        code: '23505',
      );
    await openMembers(tester, repository);
    await openEditForm(tester);
    await fillForm(tester);
    await saveForm(tester, editing: true);
    expect(
      find.text('Nomor anggota atau email sudah terdaftar.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(1))
          .controller!
          .text,
      '  Ghefira Addien  ',
    );
    expect(repository.saved.single.name, firstMember.name);
    repository.updateError = null;
    await saveForm(tester, editing: true);
    expect(find.text('Anggota berhasil diperbarui'), findsOneWidget);
    expect(repository.saved.single.name, 'Ghefira Addien');
    expect(repository.saved.single.id, firstMember.id);
  });

  final updateFailures = <String, (Object, String)>{
    'denied permission': (
      const PostgrestException(message: 'Denied', code: '42501'),
      'Akses ditolak. Pastikan Anda sudah login dan memiliki izin mengedit anggota.',
    ),
    'no updated row': (
      const PostgrestException(message: 'No row returned', code: 'PGRST116'),
      'Anggota tidak ditemukan atau Anda tidak memiliki izin mengeditnya. Muat ulang daftar dan periksa izin akses.',
    ),
    'connection failure': (
      Exception('Offline'),
      'Gagal memperbarui anggota. Periksa koneksi lalu coba lagi.',
    ),
  };
  for (final failure in updateFailures.entries) {
    testWidgets('Editing with ${failure.key} preserves original member', (
      tester,
    ) async {
      final repository = FakeMemberRepository()
        ..saved.add(firstMember)
        ..updateError = failure.value.$1;
      await openMembers(tester, repository);
      await openEditForm(tester);
      await fillForm(tester);
      await saveForm(tester, editing: true);
      expect(find.text(failure.value.$2), findsOneWidget);
      expect(find.byType(MemberFormPage), findsOneWidget);
      expect(repository.saved.single, same(firstMember));
      final provider = tester
          .element(find.byType(MemberFormPage))
          .read<MemberProvider>();
      expect(provider.members.single.name, firstMember.name);
      expect(provider.isSaving, isFalse);
    });
  }

  testWidgets('Pending edit disables input and prevents repeated updates', (
    tester,
  ) async {
    final completion = Completer<void>();
    final repository = FakeMemberRepository()
      ..saved.add(firstMember)
      ..updateCompletion = completion;
    await openMembers(tester, repository);
    await openEditForm(tester);
    await fillForm(tester);
    await tester.ensureVisible(find.text('Simpan Perubahan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pump();
    expect(find.text('Menyimpan...'), findsOneWidget);
    expect(
      tester
          .widgetList<TextFormField>(find.byType(TextFormField))
            .every((field) => !field.enabled),
      isTrue,
    );
    final provider = tester
        .element(find.byType(MemberFormPage))
        .read<MemberProvider>();
    expect(await provider.updateMember(firstMember), isNotNull);
    expect(await provider.deleteMember(firstMember.id!), isNotNull);
    expect(repository.updatedIds, [firstMember.id]);
    expect(repository.deletedIds, isEmpty);
    expect(repository.saved.single.name, firstMember.name);
    completion.complete();
    await tester.pumpAndSettle();
    expect(find.text('Anggota berhasil diperbarui'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
  });
}

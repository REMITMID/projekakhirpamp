import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/member_repository.dart';
import '../../domain/models/member_model.dart';

class MemberProvider extends ChangeNotifier {
  MemberProvider({MemberRepository? repository})
    : _repository = repository ?? MemberRepository();

  final MemberRepository _repository;
  List<MemberModel> _members = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _deletingMemberId;
  String? _errorMessage;

  List<MemberModel> get members => List.unmodifiable(_members);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get deletingMemberId => _deletingMemberId;
  bool get isDeleting => _deletingMemberId != null;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMembers() async {
    if (_isLoading || _isSaving || isDeleting) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _members = await _repository.fetchMembers();
    } catch (_) {
      _errorMessage = 'Gagal memuat anggota. Periksa koneksi lalu coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addMember(MemberModel member) async {
    if (_isSaving) return 'Data sedang disimpan. Mohon tunggu.';
    _isSaving = true;
    notifyListeners();
    try {
      final savedMember = await _repository.addMember(member);
      _members = [savedMember, ..._members];
      _errorMessage = null;
      return null;
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        return 'Nomor anggota atau email sudah terdaftar.';
      }
      if (error.code == '42501') {
        return 'Akses ditolak. Pastikan Anda sudah login dan memiliki izin menambah anggota.';
      }
      return 'Gagal menyimpan anggota. Silakan coba lagi.';
    } catch (_) {
      return 'Gagal menyimpan anggota. Periksa koneksi lalu coba lagi.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> deleteMember(String id) async {
    if (isDeleting) return 'Penghapusan anggota sedang diproses. Mohon tunggu.';
    if (_isSaving) return 'Data sedang disimpan. Mohon tunggu.';
    if (_isLoading) return 'Tunggu hingga daftar anggota selesai dimuat.';
    _deletingMemberId = id;
    notifyListeners();
    try {
      await _repository.deleteMember(id);
      _members = _members.where((member) => member.id != id).toList();
      return null;
    } on PostgrestException catch (error) {
      if (error.code == '23503') {
        return 'Anggota tidak dapat dihapus karena masih digunakan oleh data lain.';
      }
      if (error.code == '42501') {
        return 'Akses ditolak. Pastikan Anda sudah login dan memiliki izin menghapus anggota.';
      }
      if (error.code == 'PGRST116') {
        return 'Anggota tidak ditemukan atau Anda tidak memiliki izin menghapusnya. Muat ulang daftar dan periksa izin akses.';
      }
      return 'Gagal menghapus anggota. Silakan coba lagi.';
    } catch (_) {
      return 'Gagal menghapus anggota. Periksa koneksi lalu coba lagi.';
    } finally {
      _deletingMemberId = null;
      notifyListeners();
    }
  }

  Future<String?> updateMember(MemberModel member) async {
    if (_isSaving) return 'Data sedang disimpan. Mohon tunggu.';
    if (isDeleting) return 'Penghapusan anggota sedang diproses. Mohon tunggu.';
    if (_isLoading) return 'Tunggu hingga daftar anggota selesai dimuat.';
    if (member.id == null || member.id!.isEmpty) {
      return 'Data anggota tidak valid. Muat ulang daftar lalu coba lagi.';
    }
    _isSaving = true;
    notifyListeners();
    try {
      final updatedMember = await _repository.updateMember(member);
      _members = _members
          .map((item) => item.id == member.id ? updatedMember : item)
          .toList();
      _errorMessage = null;
      return null;
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        return 'Nomor anggota atau email sudah terdaftar.';
      }
      if (error.code == '42501') {
        return 'Akses ditolak. Pastikan Anda sudah login dan memiliki izin mengedit anggota.';
      }
      if (error.code == 'PGRST116') {
        return 'Anggota tidak ditemukan atau Anda tidak memiliki izin mengeditnya. Muat ulang daftar dan periksa izin akses.';
      }
      if (error.code == '23503') {
        return 'Anggota tidak dapat diperbarui karena data ini masih digunakan oleh data lain.';
      }
      return 'Gagal memperbarui anggota. Silakan coba lagi.';
    } catch (_) {
      return 'Gagal memperbarui anggota. Periksa koneksi lalu coba lagi.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}

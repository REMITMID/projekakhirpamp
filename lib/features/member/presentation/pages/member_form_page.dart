import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/member_model.dart';
import '../providers/member_provider.dart';

class MemberFormPage extends StatefulWidget {
  const MemberFormPage({super.key, this.member});

  final MemberModel? member;

  @override
  State<MemberFormPage> createState() => _MemberFormPageState();
}

class _MemberFormPageState extends State<MemberFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _saveError;

  bool get _isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    if (member != null) {
      _numberController.text = member.memberNumber;
      _nameController.text = member.name;
      _emailController.text = member.email;
      _phoneController.text = member.phone;
      _addressController.text = member.address;
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<MemberProvider>();
    if (provider.isSaving || !_formKey.currentState!.validate()) return;
    setState(() => _saveError = null);
    FocusScope.of(context).unfocus();
    final member = MemberModel(
      id: widget.member?.id,
      memberNumber: _numberController.text,
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
    );
    final error = _isEditing
        ? await provider.updateMember(member)
        : await provider.addMember(member);
    if (!mounted) return;
    if (error != null) {
      setState(() => _saveError = error);
      return;
    }
    Navigator.pop(context, true);
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<MemberProvider>().isSaving;
    return PopScope(
      canPop: !isSaving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Anggota' : 'Tambah Anggota'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Data Anggota',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isEditing
                          ? 'Perbarui data anggota perpustakaan. Alamat boleh dikosongkan.'
                          : 'Lengkapi data anggota perpustakaan. Alamat boleh dikosongkan.',
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _numberController,
                      enabled: !isSaving,
                      maxLength: 50,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        'Nomor Anggota',
                        Icons.badge_outlined,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Nomor anggota wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      enabled: !isSaving,
                      maxLength: 150,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        'Nama Lengkap',
                        Icons.person_outline,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Nama lengkap wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      enabled: !isSaving,
                      maxLength: 254,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: _decoration('Email', Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email wajib diisi';
                        }
                        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                            .hasMatch(value.trim())) {
                          return 'Masukkan email yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      enabled: !isSaving,
                      maxLength: 25,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        'Nomor Telepon',
                        Icons.phone_outlined,
                      ),
                      validator: (value) {
                        final phone = value?.trim() ?? '';
                        if (phone.isEmpty) return 'Nomor telepon wajib diisi';
                        final digits = phone.replaceAll(RegExp(r'\D'), '');
                        if (!RegExp(r'^\+?[0-9 ()-]+$').hasMatch(phone) ||
                            digits.length < 8 ||
                            digits.length > 15) {
                          return 'Masukkan nomor telepon dengan 8–15 digit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      enabled: !isSaving,
                      maxLength: 500,
                      minLines: 2,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _decoration(
                        'Alamat (opsional)',
                        Icons.home_outlined,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_saveError != null) ...[
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _saveError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    FilledButton.icon(
                      onPressed: isSaving ? null : _save,
                      icon: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        isSaving
                            ? 'Menyimpan...'
                            : _isEditing
                            ? 'Simpan Perubahan'
                            : 'Simpan Anggota',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

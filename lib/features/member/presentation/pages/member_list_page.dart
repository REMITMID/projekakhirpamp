import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/member_model.dart';
import '../providers/member_provider.dart';
import 'member_form_page.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MemberProvider>().fetchMembers();
    });
  }

  Future<void> _openForm({MemberModel? member}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => MemberFormPage(member: member)),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          member == null
              ? 'Anggota berhasil ditambahkan'
              : 'Anggota berhasil diperbarui',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _confirmDelete(MemberModel member) async {
    final provider = context.read<MemberProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Anggota?'),
        content: Text(
          'Hapus anggota "${member.name}" (${member.memberNumber})? '
          'Data yang dihapus tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true || member.id == null) return;
    final error = await provider.deleteMember(member.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Anggota berhasil dihapus'),
        backgroundColor: error == null ? Colors.green : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemberProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Anggota'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed:
                provider.isLoading || provider.isSaving || provider.isDeleting
                ? null
                : provider.fetchMembers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(provider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            provider.isLoading || provider.isSaving || provider.isDeleting
            ? null
            : () => _openForm(),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Tambah Anggota'),
      ),
    );
  }

  Widget _buildBody(MemberProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 56),
              const SizedBox(height: 16),
              Text(provider.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: provider.fetchMembers,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (provider.members.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline, size: 72, color: Colors.grey),
              SizedBox(height: 16),
              Text('Belum ada anggota.'),
              SizedBox(height: 8),
              Text(
                'Tekan Tambah Anggota untuk mendaftarkan anggota baru.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: provider.fetchMembers,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: provider.members.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final member = provider.members[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(
                member.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                [
                  'No. Anggota: ${member.memberNumber}',
                  member.email,
                  member.phone,
                  if (member.address.isNotEmpty) member.address,
                ].join('\n'),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit anggota',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed:
                        provider.isSaving ||
                            provider.isDeleting ||
                            member.id == null
                        ? null
                        : () => _openForm(member: member),
                  ),
                  if (provider.deletingMemberId == member.id)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      tooltip: 'Hapus anggota',
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed:
                          provider.isSaving ||
                              provider.isDeleting ||
                              member.id == null
                          ? null
                          : () => _confirmDelete(member),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

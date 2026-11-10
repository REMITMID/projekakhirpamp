import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_rack_provider.dart';

/// Manajemen pasangan yang diperbolehkan pada tabel category_racks.
class CategoryRackMappingPage extends StatefulWidget {
  const CategoryRackMappingPage({super.key});

  @override
  State<CategoryRackMappingPage> createState() => _CategoryRackMappingPageState();
}

class _CategoryRackMappingPageState extends State<CategoryRackMappingPage> {
  String? _categoryId;
  String? _rackId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CategoryRackProvider>().fetchCategoryRacks();
    });
  }

  void _message(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }

  Future<void> _add() async {
    final p = context.read<CategoryRackProvider>();
    if (_categoryId == null || _rackId == null) {
      _message('Pilih kategori dan rak terlebih dahulu.', error: true);
      return;
    }
    final ok = await p.addMapping(_categoryId!, _rackId!);
    if (!mounted) return;
    if (ok) {
      setState(() { _categoryId = null; _rackId = null; });
      _message('Penempatan berhasil ditambahkan.');
    } else {
      _message(p.errorMessage ?? 'Gagal menyimpan penempatan.', error: true);
    }
  }

  Future<void> _remove(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Penempatan?'),
        content: const Text('Tidak bisa dihapus jika pasangan ini sedang digunakan buku.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final p = context.read<CategoryRackProvider>();
    final ok = await p.deleteMapping(id);
    if (!mounted) return;
    _message(ok ? 'Penempatan dihapus.' : p.errorMessage ?? 'Gagal menghapus.',
        error: !ok);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Penempatan Kategori ke Rak')),
      body: Consumer<CategoryRackProvider>(builder: (context, p, _) {
        if (p.isLoading && !p.hasLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        if (p.errorMessage != null && !p.hasLoaded) {
          return Center(child: Text(p.errorMessage!));
        }
        final selectedCategory = p.categories.any((c) => c.id == _categoryId)
            ? _categoryId : null;
        final selectedRack = p.racks.any((r) => r.id == _rackId)
            ? _rackId : null;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Daftarkan pasangan kategori–rak agar muncul di form buku.'),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              key: ValueKey('pair-cat-$selectedCategory'),
              initialValue: selectedCategory,
              decoration: const InputDecoration(labelText: 'Kategori',
                  border: OutlineInputBorder()),
              items: p.categories.map((c) => DropdownMenuItem(
                value: c.id, child: Text(c.name),
              )).toList(),
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey('pair-rack-$selectedRack'),
              initialValue: selectedRack,
              decoration: const InputDecoration(labelText: 'Rak',
                  border: OutlineInputBorder()),
              items: p.racks.map((r) => DropdownMenuItem(
                value: r.id, child: Text(r.displayName),
              )).toList(),
              onChanged: (value) => setState(() => _rackId = value),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: p.isSaving ? null : _add,
              icon: const Icon(Icons.add_link),
              label: const Text('Hubungkan Kategori & Rak'),
            ),
            const Divider(height: 28),
            const Text('Penempatan terdaftar', style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 8),
            if (p.mappings.isEmpty) const Text('Belum ada pasangan kategori–rak.'),
            ...p.mappings.map((m) {
              final category = p.categoryById(m.categoryId);
              final rack = p.rackById(m.rackId);
              return Card(child: ListTile(
                title: Text(category?.name ?? 'Kategori tidak ditemukan'),
                subtitle: Text(rack?.displayName ?? 'Rak tidak ditemukan'),
                trailing: IconButton(
                  tooltip: 'Hapus hubungan',
                  icon: const Icon(Icons.link_off, color: Colors.red),
                  onPressed: p.isSaving ? null : () => _remove(m.id),
                ),
              ));
            }),
          ],
        );
      }),
    );
  }
}

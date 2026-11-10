import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_rack_provider.dart';
import 'category_rack_form_page.dart';
import 'category_rack_mapping_page.dart';

/// Sesuai proposal: dua tab master Kategori dan Rak.
class CategoryRackListPage extends StatefulWidget {
  const CategoryRackListPage({super.key});
  @override
  State<CategoryRackListPage> createState() => _CategoryRackListPageState();
}

class _CategoryRackListPageState extends State<CategoryRackListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() { if (mounted) setState(() {}); });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CategoryRackProvider>().fetchCategoryRacks();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _delete({String? categoryId, String? rackId}) async {
    final category = categoryId != null;
    final name = category ? 'kategori' : 'rak';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus $name?'),
        content: Text('Data $name tidak dapat dihapus jika masih dipakai buku atau penempatan.'),
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
    final ok = category
        ? await p.deleteCategory(categoryId!)
        : await p.deleteRack(rackId!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Data $name berhasil dihapus.'
          : p.errorMessage ?? 'Gagal menghapus $name.'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kategori & Rak'),
        actions: [
          IconButton(
            tooltip: 'Segarkan', icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CategoryRackProvider>().fetchCategoryRacks(),
          ),
        ],
        bottom: TabBar(controller: _tabs, tabs: const [
          Tab(text: 'Kategori', icon: Icon(Icons.category_outlined)),
          Tab(text: 'Rak', icon: Icon(Icons.shelves)),
        ]),
      ),
      body: Consumer<CategoryRackProvider>(builder: (context, p, _) {
        if (p.isLoading && !p.hasLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        if (p.errorMessage != null && !p.hasLoaded) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(padding: const EdgeInsets.all(20), child: Text(p.errorMessage!)),
            TextButton(onPressed: p.fetchCategoryRacks, child: const Text('Coba Lagi')),
          ]));
        }
        return TabBarView(controller: _tabs, children: [
          _categoryList(p),
          _rackList(p),
        ]);
      }),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-master',
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => CategoryRackFormPage(
            type: _tabs.index == 0 ? MasterFormType.category : MasterFormType.rack,
          ),
        )),
        icon: const Icon(Icons.add),
        label: Text(_tabs.index == 0 ? 'Tambah Kategori' : 'Tambah Rak'),
      ),
    );
  }

  Widget _categoryList(CategoryRackProvider p) {
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 92), children: [
      if (p.categories.isEmpty) const Padding(
        padding: EdgeInsets.all(18), child: Text('Belum ada kategori.'),
      ),
      ...p.categories.map((c) => Card(child: ListTile(
        leading: const Icon(Icons.category_outlined),
        title: Text(c.name),
        subtitle: Text(c.description ?? 'Tanpa deskripsi'),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(tooltip: 'Edit kategori', icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => CategoryRackFormPage(
                  type: MasterFormType.category, category: c),
            )),
          ),
          IconButton(tooltip: 'Hapus kategori',
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: p.isSaving ? null : () => _delete(categoryId: c.id),
          ),
        ]),
      ))),
    ]);
  }

  Widget _rackList(CategoryRackProvider p) {
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 92), children: [
      FilledButton.tonalIcon(
        icon: const Icon(Icons.link),
        label: const Text('Kelola Penempatan Kategori–Rak'),
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const CategoryRackMappingPage(),
        )),
      ),
      const SizedBox(height: 12),
      if (p.racks.isEmpty) const Padding(
        padding: EdgeInsets.all(18), child: Text('Belum ada rak.'),
      ),
      ...p.racks.map((r) => Card(child: ListTile(
        leading: const Icon(Icons.shelves),
        title: Text(r.rackCode),
        subtitle: Text(r.location),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(tooltip: 'Edit rak', icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => CategoryRackFormPage(
                  type: MasterFormType.rack, rack: r),
            )),
          ),
          IconButton(tooltip: 'Hapus rak',
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: p.isSaving ? null : () => _delete(rackId: r.id),
          ),
        ]),
      ))),
    ]);
  }
}

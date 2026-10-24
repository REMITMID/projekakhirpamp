import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_rack_provider.dart';
import 'category_rack_form_page.dart';

class CategoryRackListPage extends StatefulWidget {
  const CategoryRackListPage({super.key});

  @override
  State<CategoryRackListPage> createState() => _CategoryRackListPageState();
}

class _CategoryRackListPageState extends State<CategoryRackListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => context.read<CategoryRackProvider>().fetchCategories(),
    );
  }

  // Dialog Konfirmasi Hapus Data
  void _showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus data kategori & rak ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<CategoryRackProvider>().deleteCategory(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kategori berhasil dihapus'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4E5BA6);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manajemen Kategori & Rak',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Consumer<CategoryRackProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          // Tampilan jika data kosong
          if (provider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.grid_view_outlined,
                    size: 70,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data kategori.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          // Tampilan Daftar Kartu Kategori
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final item = provider.categories[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.category_outlined, color: primaryColor),
                  ),
                  title: Text(
                    item.categoryName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    'Lokasi: ${item.rackLocation}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryRackFormPage(category: item),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _showDeleteDialog(context, item.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoryRackFormPage()),
          );
        },
      ),
    );
  }
}
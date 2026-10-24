import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/book_model.dart';
import '../providers/book_provider.dart';
import 'book_detail_page.dart';
import 'book_form_page.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BookProvider>().fetchBooks();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStockColor(int stock) {
    if (stock > 3) return Colors.green;
    if (stock > 0) return Colors.orange;
    return Colors.red;
  }

  void _confirmDelete(BuildContext context, BookModel book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus Buku'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus buku "${book.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider =
                  Provider.of<BookProvider>(context, listen: false);
              final success = await provider.deleteBook(book.id!);
              if (!context.mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Buku "${book.title}" berhasil dihapus.'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      provider.errorMessage ?? 'Gagal menghapus buku.',
                    ),
                    backgroundColor: Colors.red.shade800,
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final theme = Theme.of(context);

    // Kumpulkan daftar kategori yang tersedia
    final Set<String> categoriesSet = {'Semua'};
    for (var b in bookProvider.books) {
      if (b.category.trim().isNotEmpty) {
        categoriesSet.add(b.category.trim());
      }
    }
    final categoriesList = categoriesSet.toList();

    // Filter buku berdasarkan pencarian & kategori
    final filteredBooks = bookProvider.books.where((book) {
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.bookCode.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query) ||
          book.rackLocation.toLowerCase().contains(query) ||
          book.publisher.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == 'Semua' ||
          book.category.trim().toLowerCase() ==
              _selectedCategory.trim().toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();

    // Hitung statistik ringkas
    final totalTitles = bookProvider.books.length;
    final totalStock = bookProvider.books.fold<int>(
      0,
      (sum, item) => sum + item.stock,
    );
    final outOfStockCount =
        bookProvider.books.where((b) => b.stock <= 0).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PerpusKu',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Text(
              'Katalog & Koleksi Buku',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: bookProvider.isGridView ? 'Tampilan List' : 'Tampilan Grid',
            icon: Icon(
              bookProvider.isGridView
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
              color: Colors.black87,
            ),
            onPressed: () => bookProvider.toggleViewMode(),
          ),
          IconButton(
            tooltip: 'Segarkan Data',
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: () => bookProvider.fetchBooks(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Pencarian & Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input Pencarian
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari judul, penulis, kode, atau rak...',
                    hintStyle:
                        TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    prefixIcon:
                        const Icon(Icons.search_rounded, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Kategori Chips
                if (categoriesList.length > 1)
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoriesList.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final cat = categoriesList[idx];
                        final isSelected = _selectedCategory == cat;
                        final count = cat == 'Semua'
                            ? bookProvider.books.length
                            : bookProvider.books
                                .where((b) =>
                                    b.category.trim().toLowerCase() ==
                                    cat.trim().toLowerCase())
                                .length;

                        return ChoiceChip(
                          label: Text('$cat ($count)'),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade800,
                          ),
                          selected: isSelected,
                          selectedColor: theme.colorScheme.primary,
                          backgroundColor: Colors.grey.shade100,
                          showCheckmark: false,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.grey.shade300,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Baris Ringkasan Statistik Singkat
          if (bookProvider.books.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade50,
              child: Row(
                children: [
                  Text(
                    'Menampilkan ${filteredBooks.length} dari $totalTitles judul buku',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Total Stok: $totalStock',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.indigo.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (outOfStockCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Habis: $outOfStockCount',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Area Konten Utama
          Expanded(
            child: bookProvider.isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Memuat katalog buku...'),
                      ],
                    ),
                  )
                : bookProvider.errorMessage != null
                    ? _buildErrorView(bookProvider)
                    : filteredBooks.isEmpty
                        ? _buildEmptyView(bookProvider.books.isEmpty)
                        : RefreshIndicator(
                            onRefresh: () => bookProvider.fetchBooks(),
                            child: bookProvider.isGridView
                                ? _buildGridView(filteredBooks, theme)
                                : _buildListView(filteredBooks, theme),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Tambah Buku'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookFormPage()),
        ),
      ),
    );
  }

  Widget _buildErrorView(BookProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Katalog',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Terjadi kesalahan sistem.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => provider.fetchBooks(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(bool isCompletelyEmpty) {
    if (isCompletelyEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 64,
                  color: Colors.indigo.shade400,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Belum Ada Buku di Katalog',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Katalog perpustakaan masih kosong. Mulai tambahkan buku pertama sekarang.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookFormPage()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Buku Sekarang'),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Buku Tidak Ditemukan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada buku yang sesuai dengan kata kunci atau filter saat ini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = 'Semua';
                });
              },
              icon: const Icon(Icons.filter_alt_off_rounded),
              label: const Text('Reset Pencarian & Filter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<BookModel> books, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final stockColor = _getStockColor(book.stock);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1.5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          color: Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BookDetailPage(book: book)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Cover Buku dengan Badge Kode
                  Container(
                    width: 50,
                    height: 65,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_rounded,
                          color: theme.colorScheme.primary,
                          size: 26,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          book.bookCode,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Informasi Buku
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                book.author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Badges Kategori, Lokasi Rak & Stok
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            // Kategori
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                book.category,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            // Lokasi Rak
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                                border:
                                    Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.shelves,
                                      size: 11, color: Colors.black54),
                                  const SizedBox(width: 3),
                                  Text(
                                    book.rackLocation,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Stok
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: stockColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                book.stock > 0
                                    ? 'Stok: ${book.stock}'
                                    : 'Habis',
                                style: TextStyle(
                                  color: stockColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Aksi Tombol Cepat (Edit & Hapus)
                  Column(
                    children: [
                      IconButton(
                        tooltip: 'Edit Buku',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                        icon: const Icon(Icons.edit_outlined,
                            size: 20, color: Colors.blueAccent),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookFormPage(book: book),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      IconButton(
                        tooltip: 'Hapus Buku',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                        icon: const Icon(Icons.delete_outline,
                            size: 20, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(context, book),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<BookModel> books, ThemeData theme) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final stockColor = _getStockColor(book.stock);

        return Card(
          elevation: 1.5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          color: Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BookDetailPage(book: book)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Kartu: Kode Buku & Kategori Chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          book.bookCode,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: stockColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          book.stock > 0 ? '${book.stock}' : '0',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: stockColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Banner Icon Buku
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Judul Buku
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Penulis
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),

                  const Spacer(),

                  // Lokasi Rak
                  Row(
                    children: [
                      const Icon(Icons.shelves,
                          size: 12, color: Colors.black54),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          book.rackLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Aksi Tombol Edit & Hapus
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          icon: const Icon(Icons.edit_outlined,
                              size: 18, color: Colors.blueAccent),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookFormPage(book: book),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Hapus',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(context, book),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

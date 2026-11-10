import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/book_model.dart';
import '../providers/book_provider.dart';
import '../../../category_rack/presentation/providers/category_rack_provider.dart';

class BookFormPage extends StatefulWidget {
  final BookModel? book;

  const BookFormPage({super.key, this.book});

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeController;
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _publisherController;
  late TextEditingController _yearController;
  late TextEditingController _stockController;
  String? _selectedCategory;
  String? _selectedRack;

  bool _isSubmitting = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.book?.bookCode ?? '');
    _titleController = TextEditingController(text: widget.book?.title ?? '');
    _authorController = TextEditingController(text: widget.book?.author ?? '');
    _publisherController =
        TextEditingController(text: widget.book?.publisher ?? '');
    _yearController = TextEditingController(
      text: widget.book != null ? widget.book!.publicationYear.toString() : '',
    );
    _stockController = TextEditingController(
      text: widget.book != null ? widget.book!.stock.toString() : '',
    );
    // Saat Edit, nilai buku lama disiapkan terlebih dahulu.
    _selectedCategory = widget.book?.categoryId;
    _selectedRack = widget.book?.rackId;
    if (_selectedCategory?.isEmpty ?? false) _selectedCategory = null;
    if (_selectedRack?.isEmpty ?? false) _selectedRack = null;

    // Memuat pilihan kategori dan rak dari Supabase setelah frame pertama.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CategoryRackProvider>().fetchCategoryRacks();
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _adjustStock(int delta) {
    final current = int.tryParse(_stockController.text.trim()) ?? 0;
    final next = (current + delta).clamp(0, 99999);
    setState(() {
      _stockController.text = next.toString();
    });
  }

  Future<void> _saveForm() async {
    // Aktifkan mode autovalidasi setelah tombol simpan ditekan
    setState(() {
      _autoValidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Harap periksa dan lengkapi semua isian formulir.'),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final referenceProvider = context.read<CategoryRackProvider>();
    final finalCategory = _selectedCategory?.trim() ?? '';
    final finalRack = _selectedRack?.trim() ?? '';

    // Validasi tambahan agar pasangan kategori-rak sesuai tabel referensi.
    if (referenceProvider.isLoading ||
        referenceProvider.errorMessage != null ||
        !referenceProvider.isValidPair(finalCategory, finalRack)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih pasangan kategori dan rak yang terdaftar.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final bookData = BookModel(
      id: widget.book?.id,
      bookCode: _codeController.text.trim().toUpperCase(),
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      publisher: _publisherController.text.trim(),
      publicationYear: int.parse(_yearController.text.trim()),
      categoryId: finalCategory,
      rackId: finalRack,
      stock: int.parse(_stockController.text.trim()),
    );

    final provider = Provider.of<BookProvider>(context, listen: false);
    final isEdit = widget.book != null;
    bool success;

    if (isEdit) {
      success = await provider.updateBook(bookData);
    } else {
      success = await provider.addBook(bookData);
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEdit
                      ? 'Buku "${bookData.title}" berhasil diperbarui!'
                      : 'Buku "${bookData.title}" berhasil ditambahkan!',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  provider.errorMessage ?? 'Gagal menyimpan data buku.',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.book != null;

    final referenceProvider = context.watch<CategoryRackProvider>();
    final categoryOptions = referenceProvider.categories;
    final validCategory = categoryOptions.any((c) => c.id == _selectedCategory)
        ? _selectedCategory : null;
    final rackOptions = referenceProvider.racksForCategory(validCategory);
    final validRack = rackOptions.any((r) => r.id == _selectedRack)
        ? _selectedRack : null;
    final referenceReady = referenceProvider.hasLoaded &&
        !referenceProvider.isLoading &&
        referenceProvider.errorMessage == null;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Data Buku' : 'Tambah Buku Baru',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _autoValidateMode,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Banner Info Mode
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isEdit
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                    : Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEdit
                      ? theme.colorScheme.primary.withValues(alpha: 0.3)
                      : Colors.indigo.shade100,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEdit
                        ? Icons.edit_note_rounded
                        : Icons.auto_stories_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit
                              ? 'Mengubah Informasi Buku'
                              : 'Katalog Koleksi Baru',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEdit
                              ? 'Perbarui data yang diperlukan lalu simpan perubahan.'
                              : 'Lengkapi semua data buku untuk disimpan ke database.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 1: Informasi Pokok Buku
            _buildSectionCard(
              title: 'Informasi Pokok Buku',
              icon: Icons.menu_book_rounded,
              theme: theme,
              children: [
                // Kode Buku
                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _buildInputDecoration(
                    labelText: 'Kode Buku *',
                    hintText: 'Misal: BK-001, NVL-05',
                    helperText: 'Minimal 3 karakter, huruf kapital dan angka',
                    icon: Icons.qr_code_2_rounded,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Kode buku wajib diisi';
                    }
                    final trimmed = val.trim();
                    if (trimmed.length < 3) {
                      return 'Kode buku minimal 3 karakter';
                    }
                    if (trimmed.length > 20) {
                      return 'Kode buku maksimal 20 karakter';
                    }
                    final regex = RegExp(r'^[a-zA-Z0-9\-_]+$');
                    if (!regex.hasMatch(trimmed)) {
                      return 'Hanya boleh huruf, angka, strip (-), atau (_)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Judul Buku
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _buildInputDecoration(
                    labelText: 'Judul Buku *',
                    hintText: 'Masukkan judul buku lengkap',
                    icon: Icons.title_rounded,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Judul buku wajib diisi';
                    }
                    final trimmed = val.trim();
                    if (trimmed.length < 2) {
                      return 'Judul buku minimal 2 karakter';
                    }
                    if (trimmed.length > 255) {
                      return 'Judul buku maksimal 255 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Nama Penulis
                TextFormField(
                  controller: _authorController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _buildInputDecoration(
                    labelText: 'Nama Penulis *',
                    hintText: 'Contoh: Pramoedya Ananta Toer',
                    icon: Icons.person_outline_rounded,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama penulis wajib diisi';
                    }
                    final trimmed = val.trim();
                    if (trimmed.length < 2) {
                      return 'Nama penulis minimal 2 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Penerbit
                TextFormField(
                  controller: _publisherController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _buildInputDecoration(
                    labelText: 'Penerbit *',
                    hintText: 'Contoh: Gramedia Pustaka Utama',
                    icon: Icons.apartment_rounded,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama penerbit wajib diisi';
                    }
                    final trimmed = val.trim();
                    if (trimmed.length < 2) {
                      return 'Nama penerbit minimal 2 karakter';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card 2: Klasifikasi & Lokasi (Dropdown)
            _buildSectionCard(
              title: 'Klasifikasi & Penempatan',
              icon: Icons.shelves,
              theme: theme,
              children: [
                // Referensi kategori/rak berasal dari categories, racks, category_racks.
                if (!referenceProvider.hasLoaded || referenceProvider.isLoading) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  const Text('Memuat kategori dan lokasi rak...'),
                  const SizedBox(height: 16),
                ],
                if (referenceProvider.errorMessage != null) ...[
                  Text(
                    'Gagal memuat kategori/rak: ${referenceProvider.errorMessage}',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                  TextButton.icon(
                    onPressed: () => referenceProvider.fetchCategoryRacks(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                  const SizedBox(height: 16),
                ],
                if (referenceReady && categoryOptions.isEmpty) ...[
                  const Text(
                    'Belum ada kategori dan rak. Tambahkan dulu melalui fitur Category & Rack.',
                  ),
                  const SizedBox(height: 16),
                ],
                if (widget.book != null &&
                    referenceReady &&
                    _selectedCategory != null &&
                    validCategory == null) ...[
                  const Text(
                    'Kategori lama buku ini tidak ada di data referensi. Pilih kategori yang tersedia.',
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                  const SizedBox(height: 12),
                ],

                // Dropdown 1: ID kategori dari tabel categories.
                DropdownButtonFormField<String>(
                  key: ValueKey('category-$validCategory-${categoryOptions.length}'),
                  initialValue: validCategory,
                  isExpanded: true,
                  decoration: _buildInputDecoration(
                    labelText: 'Kategori Buku *',
                    hintText: 'Pilih Kategori',
                    icon: Icons.category_rounded,
                  ),
                  items: categoryOptions.map((cat) => DropdownMenuItem<String>(
                    value: cat.id,
                    child: Text(cat.name, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: referenceReady && categoryOptions.isNotEmpty
                      ? (value) => setState(() {
                    _selectedCategory = value;
                    _selectedRack = null;
                  })
                      : null,
                  validator: (value) =>
                  value == null || !categoryOptions.any((c) => c.id == value)
                      ? 'Kategori wajib dipilih'
                      : null,
                ),
                const SizedBox(height: 16),
                if (widget.book != null && referenceReady &&
                    validCategory != null && _selectedRack != null &&
                    validRack == null) ...[
                  const Text('Rak lama tidak tersedia untuk kategori ini.',
                      style: TextStyle(color: Colors.deepOrange)),
                  const SizedBox(height: 12),
                ],
                // Dropdown 2: hanya ID rak yang tercantum di category_racks.
                DropdownButtonFormField<String>(
                  key: ValueKey('rack-$validCategory-$validRack-${rackOptions.length}'),
                  initialValue: validRack,
                  isExpanded: true,
                  decoration: _buildInputDecoration(
                    labelText: 'Lokasi Rak *',
                    hintText: validCategory == null
                        ? 'Pilih kategori terlebih dahulu'
                        : 'Pilih Lokasi Rak',
                    icon: Icons.location_on_outlined,
                  ),
                  items: rackOptions.map((rack) => DropdownMenuItem<String>(
                    value: rack.id,
                    child: Text(rack.displayName,
                        overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: referenceReady && validCategory != null &&
                      rackOptions.isNotEmpty
                      ? (value) => setState(() => _selectedRack = value)
                      : null,
                  validator: (value) => value == null ||
                      !rackOptions.any((r) => r.id == value)
                      ? 'Pilih lokasi rak yang sesuai dengan kategori'
                      : null,
                ),
                const SizedBox(height: 16),

                // Tahun Terbit & Stok dalam 2 Kolom
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tahun Terbit
                    Expanded(
                      child: TextFormField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                          labelText: 'Tahun Terbit *',
                          hintText: 'Contoh: 2024',
                          icon: Icons.calendar_month_rounded,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Tahun wajib diisi';
                          }
                          final trimmed = val.trim();
                          final year = int.tryParse(trimmed);
                          if (year == null) {
                            return 'Harus angka';
                          }
                          final maxYear = DateTime.now().year + 1;
                          if (year < 1000 || year > maxYear) {
                            return 'Antara 1000-$maxYear';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Jumlah Stok
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration(
                              labelText: 'Stok Buku *',
                              hintText: 'Contoh: 5',
                              icon: Icons.inventory_2_rounded,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Stok wajib diisi';
                              }
                              final trimmed = val.trim();
                              final stock = int.tryParse(trimmed);
                              if (stock == null) {
                                return 'Harus angka';
                              }
                              if (stock < 0) {
                                return 'Tidak boleh < 0';
                              }
                              if (stock > 99999) {
                                return 'Maks 99999';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 4),
                          // Tombol Cepat - / + Stok
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                                tooltip: 'Kurangi 1',
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  size: 20,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _adjustStock(-1),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                                tooltip: 'Tambah 1',
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 20,
                                  color: Colors.green,
                                ),
                                onPressed: () => _adjustStock(1),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                                tooltip: 'Tambah 5',
                                icon: const Icon(
                                  Icons.exposure_plus_1,
                                  size: 20,
                                  color: Colors.indigo,
                                ),
                                onPressed: () => _adjustStock(5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tombol Simpan & Batal
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Icon(isEdit ? Icons.save_rounded : Icons.add_rounded),
                    label: Text(
                      _isSubmitting
                          ? 'Menyimpan...'
                          : isEdit
                          ? 'Simpan Perubahan'
                          : 'Tambah Buku',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    String? helperText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      prefixIcon: Icon(icon, size: 22),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.indigo, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade700, width: 2),
      ),
    );
  }
}
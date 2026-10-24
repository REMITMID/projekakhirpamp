import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/book_model.dart';
import '../providers/book_provider.dart';

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
  late TextEditingController _customCategoryController;
  late TextEditingController _customRackController;

  String? _selectedCategory;
  String? _selectedRack;
  bool _isCustomCategory = false;
  bool _isCustomRack = false;

  bool _isSubmitting = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  static const List<String> _defaultCategories = [
    'Fiksi',
    'Non-Fiksi',
    'Teknologi',
    'Sains',
    'Sejarah',
    'Sastra',
    'Bisnis',
    'Pendidikan',
    'Komik',
    'Agama',
    'Biografi',
    'Kamus & Ensiklopedia',
    'Lainnya (Ketik Manual)',
  ];

  static const List<String> _defaultRacks = [
    'Rak A-1',
    'Rak A-2',
    'Rak B-1',
    'Rak B-2',
    'Rak C-1',
    'Rak C-2',
    'Rak D-1',
    'Rak D-2',
    'Lantai 2 - A',
    'Lantai 2 - B',
    'Lantai 2 - C',
    'Lainnya (Ketik Manual)',
  ];

  late List<String> _categoriesList;
  late List<String> _racksList;

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
    _customCategoryController = TextEditingController();
    _customRackController = TextEditingController();

    _categoriesList = List<String>.from(_defaultCategories);
    _racksList = List<String>.from(_defaultRacks);

    if (widget.book != null) {
      final existingCat = widget.book!.category.trim();
      if (existingCat.isNotEmpty) {
        if (!_categoriesList.contains(existingCat)) {
          _categoriesList.insert(_categoriesList.length - 1, existingCat);
        }
        _selectedCategory = existingCat;
      }

      final existingRack = widget.book!.rackLocation.trim();
      if (existingRack.isNotEmpty) {
        if (!_racksList.contains(existingRack)) {
          _racksList.insert(_racksList.length - 1, existingRack);
        }
        _selectedRack = existingRack;
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _stockController.dispose();
    _customCategoryController.dispose();
    _customRackController.dispose();
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

    final finalCategory = _isCustomCategory
        ? _customCategoryController.text.trim()
        : (_selectedCategory ?? '').trim();

    final finalRack = _isCustomRack
        ? _customRackController.text.trim()
        : (_selectedRack ?? '').trim();

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
      category: finalCategory,
      rackLocation: finalRack,
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
                // Dropdown Kategori
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: _buildInputDecoration(
                    labelText: 'Kategori Buku *',
                    hintText: 'Pilih Kategori',
                    icon: Icons.category_rounded,
                  ),
                  items: _categoriesList.map((cat) {
                    final isManual = cat == 'Lainnya (Ketik Manual)';
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isManual ? Colors.indigo : Colors.black87,
                          fontStyle:
                              isManual ? FontStyle.italic : FontStyle.normal,
                          fontWeight:
                              isManual ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategory = val;
                      _isCustomCategory = (val == 'Lainnya (Ketik Manual)');
                    });
                  },
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Kategori wajib dipilih';
                    }
                    return null;
                  },
                ),

                // Jika memilih 'Lainnya (Ketik Manual)'
                if (_isCustomCategory) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _customCategoryController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _buildInputDecoration(
                      labelText: 'Ketik Kategori Baru *',
                      hintText: 'Contoh: Ensiklopedia Sains',
                      icon: Icons.edit_note_rounded,
                    ),
                    validator: (val) {
                      if (_isCustomCategory) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Kategori baru wajib diisi';
                        }
                        if (val.trim().length < 2) {
                          return 'Kategori minimal 2 karakter';
                        }
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),

                // Dropdown Lokasi Rak
                DropdownButtonFormField<String>(
                  value: _selectedRack,
                  decoration: _buildInputDecoration(
                    labelText: 'Lokasi Rak *',
                    hintText: 'Pilih Lokasi Rak',
                    icon: Icons.location_on_outlined,
                  ),
                  items: _racksList.map((rack) {
                    final isManual = rack == 'Lainnya (Ketik Manual)';
                    return DropdownMenuItem<String>(
                      value: rack,
                      child: Text(
                        rack,
                        style: TextStyle(
                          color: isManual ? Colors.indigo : Colors.black87,
                          fontStyle:
                              isManual ? FontStyle.italic : FontStyle.normal,
                          fontWeight:
                              isManual ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedRack = val;
                      _isCustomRack = (val == 'Lainnya (Ketik Manual)');
                    });
                  },
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Lokasi rak wajib dipilih';
                    }
                    return null;
                  },
                ),

                // Jika memilih 'Lainnya (Ketik Manual)'
                if (_isCustomRack) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _customRackController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: _buildInputDecoration(
                      labelText: 'Ketik Lokasi Rak Baru *',
                      hintText: 'Contoh: Rak E-01, Lantai 3',
                      icon: Icons.add_location_alt_outlined,
                    ),
                    validator: (val) {
                      if (_isCustomRack) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Lokasi rak baru wajib diisi';
                        }
                        if (val.trim().length < 2) {
                          return 'Lokasi rak minimal 2 karakter';
                        }
                      }
                      return null;
                    },
                  ),
                ],
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

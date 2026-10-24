import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/category_rack_model.dart';
import '../providers/category_rack_provider.dart';

class CategoryRackFormPage extends StatefulWidget {
  final CategoryRackModel? category;

  const CategoryRackFormPage({super.key, this.category});

  @override
  State<CategoryRackFormPage> createState() => _CategoryRackFormPageState();
}

class _CategoryRackFormPageState extends State<CategoryRackFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  bool _isLoading = false;

  // Daftar Pilihan Format Lokasi Rak
  final List<String> _rackOptions = [
    'Lantai 1 - Rak A',
    'Lantai 1 - Rak B',
    'Lantai 2 - Rak A',
    'Lantai 2 - Rak B',
    'Lantai 3 - Rak A',
  ];

  String? _selectedRack;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.categoryName ?? '');
    _locationController = TextEditingController(text: widget.category?.rackLocation ?? '');

    // Set nilai dropdown jika sedang dalam mode Edit
    if (widget.category != null && _rackOptions.contains(widget.category!.rackLocation)) {
      _selectedRack = widget.category!.rackLocation;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Dialog Konfirmasi Keluar / Batal Simpan
  Future<bool> _showExitConfirmation(BuildContext context) async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Batalkan Pengisian?'),
        content: const Text('Apakah Anda yakin tidak ingin menyimpan data ini? Perubahan yang dibuat akan hilang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Lanjut Isi'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CategoryRackProvider>();
    final rawName = _nameController.text.trim();
    final location = _locationController.text.trim();

    // 1. Format teks menjadi Title Case (Contoh: "kOMik" / "KOMIK" -> "Komik")
    final formattedName = rawName
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');

    // 2. Cek duplikasi nama kategori (case-insensitive)
    final isExist = provider.categories.any(
          (item) =>
      item.categoryName.toLowerCase() == formattedName.toLowerCase() &&
          item.id != widget.category?.id,
    );

    if (isExist) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategori ini sudah ada! Silakan gunakan nama lain.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.category == null) {
        await provider.addCategory(formattedName, location);
      } else {
        await provider.updateCategory(
          widget.category!.id,
          formattedName,
          location,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.category == null
                  ? 'Kategori & rak berhasil ditambahkan'
                  : 'Kategori & rak berhasil diperbarui',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4E5BA6);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation(context);
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.category == null ? 'Tambah Kategori & Rak' : 'Edit Kategori & Rak',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                // Input Nama Kategori
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nama Kategori',
                    hintText: 'Contoh: Pemrograman, Fiksi, Sains',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Nama kategori tidak boleh kosong' : null,
                ),
                const SizedBox(height: 20),

                // Dropdown Lokasi Rak
                DropdownButtonFormField<String>(
                  value: _selectedRack,
                  decoration: InputDecoration(
                    labelText: 'Lokasi Rak',
                    prefixIcon: const Icon(Icons.grid_view_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                  hint: const Text('Pilih Lokasi Rak'),
                  items: _rackOptions.map((String rack) {
                    return DropdownMenuItem<String>(
                      value: rack,
                      child: Text(rack),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRack = newValue;
                      _locationController.text = newValue ?? '';
                    });
                  },
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Pilih salah satu lokasi rak' : null,
                ),
                const SizedBox(height: 32),

                // Tombol Simpan
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: primaryColor.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Simpan Data',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
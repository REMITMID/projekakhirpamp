import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/rack_model.dart';
import '../providers/category_rack_provider.dart';

enum MasterFormType { category, rack }

/// Form terpisah untuk master kategori ATAU master rak.
class CategoryRackFormPage extends StatefulWidget {
  final MasterFormType type;
  final CategoryModel? category;
  final RackModel? rack;

  const CategoryRackFormPage({
    super.key,
    required this.type,
    this.category,
    this.rack,
  });

  @override
  State<CategoryRackFormPage> createState() => _CategoryRackFormPageState();
}

class _CategoryRackFormPageState extends State<CategoryRackFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _primary;
  late final TextEditingController _secondary;
  bool _saving = false;

  bool get _isCategory => widget.type == MasterFormType.category;
  bool get _isEdit => widget.category != null || widget.rack != null;

  @override
  void initState() {
    super.initState();
    _primary = TextEditingController(
      text: _isCategory ? widget.category?.name ?? '' : widget.rack?.rackCode ?? '',
    );
    _secondary = TextEditingController(
      text: _isCategory
          ? widget.category?.description ?? ''
          : widget.rack?.location ?? '',
    );
  }

  @override
  void dispose() {
    _primary.dispose();
    _secondary.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    final provider = context.read<CategoryRackProvider>();
    final value = _primary.text.trim();
    final extra = _secondary.text.trim();
    late final bool ok;
    if (_isCategory) {
      ok = widget.category == null
          ? await provider.addCategory(value, extra)
          : await provider.updateCategory(widget.category!.id, value, extra);
    } else {
      ok = widget.rack == null
          ? await provider.addRack(value, extra)
          : await provider.updateRack(widget.rack!.id, value, extra);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(provider.errorMessage ?? 'Gagal menyimpan data.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _isCategory ? 'Kategori' : 'Rak';
    return Scaffold(
      appBar: AppBar(title: Text('${_isEdit ? 'Edit' : 'Tambah'} $label')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _primary,
              textCapitalization: _isCategory
                  ? TextCapitalization.words
                  : TextCapitalization.characters,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: _isCategory ? 'Nama Kategori *' : 'Kode Rak *',
                hintText: _isCategory ? 'Teknologi' : 'RK-A01',
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Kolom ini wajib diisi' : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _secondary,
              minLines: 1,
              maxLines: _isCategory ? 3 : 2,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: _isCategory ? 'Deskripsi kategori' : 'Lokasi Rak *',
                hintText: _isCategory
                    ? 'Komputer dan pemrograman'
                    : 'Lantai 1 - Sisi Timur',
              ),
              validator: (v) => !_isCategory && (v == null || v.trim().isEmpty)
                  ? 'Lokasi rak wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(_saving ? 'Menyimpan...' : 'Simpan $label'),
            ),
          ],
        ),
      ),
    );
  }
}

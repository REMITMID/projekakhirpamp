import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/reservation_model.dart';
import '../providers/reservation_provider.dart';

class ReservationFormPage extends StatefulWidget {
  final ReservationModel? reservation;

  const ReservationFormPage({super.key, this.reservation});

  @override
  State<ReservationFormPage> createState() => _ReservationFormPageState();
}

class _ReservationFormPageState extends State<ReservationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _memberNameController = TextEditingController();
  final _bookTitleController = TextEditingController();
  final _reservationDateController = TextEditingController();
  final _pickupDeadlineController = TextEditingController();

  String _status = 'Menunggu';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.reservation != null) {
      _memberNameController.text = widget.reservation!.memberName;
      _bookTitleController.text = widget.reservation!.bookTitle;
      _reservationDateController.text = widget.reservation!.reservationDate;
      _pickupDeadlineController.text = widget.reservation!.pickupDeadline;
      _status = widget.reservation!.status;
    } else {
      final now = DateTime.now();
      _reservationDateController.text = _formatDate(now);
      _pickupDeadlineController.text = _formatDate(now.add(const Duration(days: 3)));
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime initial = DateTime.tryParse(controller.text) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = _formatDate(picked);
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<ReservationProvider>();
    final newReservation = ReservationModel(
      id: widget.reservation?.id,
      memberName: _memberNameController.text.trim(),
      bookTitle: _bookTitleController.text.trim(),
      reservationDate: _reservationDateController.text.trim(),
      pickupDeadline: _pickupDeadlineController.text.trim(),
      status: _status,
    );

    if (widget.reservation == null) {
      await provider.addReservation(newReservation);
    } else {
      await provider.updateReservation(newReservation);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.reservation == null
                ? 'Reservasi berhasil ditambahkan!'
                : 'Perubahan berhasil disimpan!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.reservation != null;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isEdit ? 'Edit Data Reservasi' : 'Tambah Reservasi Baru',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Indicator Card
              Card(
                elevation: 0,
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        isEdit ? Icons.edit_note_rounded : Icons.post_add_rounded,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit ? 'Mode Perubahan Data' : 'Form Entri Pemesanan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              isEdit
                                  ? 'Perbarui rincian atau status reservasi anggota.'
                                  : 'Isi data pemesan dan batas tanggal pengajuan.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Card Isian Form Input
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Pemesan & Buku',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _memberNameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Pemesan / Anggota',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (val) =>
                        val == null || val.isEmpty ? 'Nama pemesan wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bookTitleController,
                        decoration: InputDecoration(
                          labelText: 'Judul Buku',
                          prefixIcon: const Icon(Icons.menu_book_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (val) =>
                        val == null || val.isEmpty ? 'Judul buku wajib diisi' : null,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Jadwal & Status Reservasi',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reservationDateController,
                        readOnly: true,
                        onTap: () => _selectDate(_reservationDateController),
                        decoration: InputDecoration(
                          labelText: 'Tanggal Pemesanan',
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pickupDeadlineController,
                        readOnly: true,
                        onTap: () => _selectDate(_pickupDeadlineController),
                        decoration: InputDecoration(
                          labelText: 'Batas Akhir Pengambilan',
                          prefixIcon: const Icon(Icons.event_available_outlined),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: InputDecoration(
                          labelText: 'Status Reservasi',
                          prefixIcon: const Icon(Icons.info_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: ['Menunggu', 'Siap Diambil', 'Selesai', 'Dibatalkan']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _status = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Action Button Simpan
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: _isSaving
                      ? const SizedBox.shrink()
                      : Icon(isEdit ? Icons.save_rounded : Icons.check_circle_rounded),
                  label: _isSaving
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    isEdit ? 'Simpan Perubahan' : 'Simpan Data Reservasi',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
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
  final _memberNameController = TextEditingController();
  final _bookTitleController = TextEditingController();
  final _reservationDateController = TextEditingController();
  final _pickupDeadlineController = TextEditingController();
  String _status = 'Menunggu';

  @override
  void initState() {
    super.initState();
    if (widget.reservation != null) {
      _memberNameController.text = widget.reservation!.memberName;
      _bookTitleController.text = widget.reservation!.bookTitle;
      _reservationDateController.text = widget.reservation!.reservationDate;
      _pickupDeadlineController.text = widget.reservation!.pickupDeadline;
      _status = widget.reservation!.status;
    }
  }

  void _save() async {
    final provider = context.read<ReservationProvider>();
    final newReservation = ReservationModel(
      id: widget.reservation?.id,
      memberName: _memberNameController.text,
      bookTitle: _bookTitleController.text,
      reservationDate: _reservationDateController.text,
      pickupDeadline: _pickupDeadlineController.text,
      status: _status,
    );

    if (widget.reservation == null) {
      await provider.addReservation(newReservation);
    } else {
      await provider.updateReservation(newReservation);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.reservation != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Reservasi' : 'Tambah Reservasi Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _memberNameController,
              decoration: const InputDecoration(labelText: 'Nama Pemesan'),
            ),
            TextField(
              controller: _bookTitleController,
              decoration: const InputDecoration(labelText: 'Judul Buku'),
            ),
            TextField(
              controller: _reservationDateController,
              decoration: const InputDecoration(labelText: 'Tanggal Reservasi (YYYY-MM-DD)'),
            ),
            TextField(
              controller: _pickupDeadlineController,
              decoration: const InputDecoration(labelText: 'Batas Pengambilan (YYYY-MM-DD)'),
            ),
            DropdownButton<String>(
              value: _status,
              isExpanded: true,
              items: ['Menunggu', 'Siap Diambil', 'Selesai', 'Dibatalkan']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _status = val);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Data'),
            )
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../domain/models/reservation_model.dart';
import 'reservation_form_page.dart';

class ReservationDetailPage extends StatelessWidget {
  final ReservationModel reservation;

  const ReservationDetailPage({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Reservasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReservationFormPage(reservation: reservation),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Judul Buku: ${reservation.bookTitle}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Nama Pemesan: ${reservation.memberName}'),
            Text('Tanggal Reservasi: ${reservation.reservationDate}'),
            Text('Batas Pengambilan: ${reservation.pickupDeadline}'),
            Text('Status: ${reservation.status}'),
          ],
        ),
      ),
    );
  }
}
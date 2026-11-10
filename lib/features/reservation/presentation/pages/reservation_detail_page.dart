import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/reservation_model.dart';
import '../providers/reservation_provider.dart';
import 'reservation_form_page.dart';

class ReservationDetailPage extends StatelessWidget {
  final ReservationModel reservation;

  const ReservationDetailPage({super.key, required this.reservation});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Siap Diambil':
        return Colors.green;
      case 'Selesai':
        return Colors.blue;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Reservasi'),
        content: const Text('Apakah Anda yakin ingin menghapus data antrean reservasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final provider = context.read<ReservationProvider>();
              if (reservation.id != null) {
                await provider.deleteReservation(reservation.id!);
              }
              if (context.mounted) {
                Navigator.pop(ctx); // Tutup dialog
                Navigator.pop(context); // Kembali ke list page
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(reservation.status);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Detail Reservasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Hapus Data',
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header Card Informasi Utama Buku
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark_added_rounded,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      reservation.bookTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        reservation.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Card Detail Informasi
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailItem(
                      icon: Icons.person_outline,
                      label: 'Nama Pemesan',
                      value: reservation.memberName,
                    ),
                    const Divider(height: 24),
                    _buildDetailItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Tanggal Reservasi',
                      value: reservation.reservationDate,
                    ),
                    const Divider(height: 24),
                    _buildDetailItem(
                      icon: Icons.event_available_outlined,
                      label: 'Batas Pengambilan',
                      value: reservation.pickupDeadline,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Tombol Aksi Utama
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.edit_rounded),
                label: const Text(
                  'Ubah Data Reservasi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReservationFormPage(reservation: reservation),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.grey[700], size: 20),
        ),
        const SizedBox(width: 16),
        CrossAxisAlignmentColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Widget Bantu Alignment Teks
class CrossAxisAlignmentColumn extends StatelessWidget {
  final CrossAxisAlignment crossAxisAlignment;
  final List<Widget> children;

  const CrossAxisAlignmentColumn({
    super.key,
    required this.crossAxisAlignment,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}
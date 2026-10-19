import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reservation_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'reservation_form_page.dart';
import 'reservation_detail_page.dart';

class ReservationListPage extends StatefulWidget {
  const ReservationListPage({super.key});

  @override
  State<ReservationListPage> createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => context.read<ReservationProvider>().loadReservations(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Antrean Reservasi Buku'),
        actions: [
          IconButton(
            icon: Icon(provider.isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => provider.toggleViewMode(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().signOut(),
          )
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.reservations.isEmpty
          ? const Center(child: Text('Belum ada data reservasi.'))
          : provider.isGridView
          ? GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
        ),
        itemCount: provider.reservations.length,
        itemBuilder: (context, index) {
          final item = provider.reservations[index];
          return Card(
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ReservationDetailPage(reservation: item),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.bookTitle,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    Text('Pemesan: ${item.memberName}'),
                    const Spacer(),
                    Chip(label: Text(item.status)),
                  ],
                ),
              ),
            ),
          );
        },
      )
          : ListView.builder(
        itemCount: provider.reservations.length,
        itemBuilder: (context, index) {
          final item = provider.reservations[index];
          return ListTile(
            title: Text(item.bookTitle),
            subtitle: Text('Pemesan: ${item.memberName}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(label: Text(item.status)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      provider.deleteReservation(item.id!),
                ),
              ],
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ReservationDetailPage(reservation: item),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReservationFormPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
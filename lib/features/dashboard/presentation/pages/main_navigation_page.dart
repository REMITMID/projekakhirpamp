import 'package:flutter/material.dart';

// Import halaman milik Jack yang sudah selesai
import '../../../reservation/presentation/pages/reservation_list_page.dart';
import '../../../category_rack/presentation/pages/category_rack_list_page.dart';
import '../../../member/presentation/pages/member_list_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 2; // Default ke Fitur Jack (Reservasi)

  // Daftar Halaman untuk tiap Fitur
  final List<Widget> _pages = [
    // Fitur 1: Katalog Buku (Rafa) -> Sementara Dummy Page
    const DummyFeaturePage(
      title: 'Fitur 1: Katalog Buku',
      owner: 'Rafa Maritza',
    ),

    // Fitur 2: Manajemen Anggota (Ghefira)
    const MemberListPage(),

    // Fitur 3: Reservasi Buku (Jack) -> Halaman Asli milik Jack
    const ReservationListPage(),

    // Fitur 4: Kategori & Rak (Farah)
    const CategoryRackListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Anggota',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Reservasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Rak & Kategori',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable Dummy Page untuk Fitur Teman Kelompok yang Belum Selesai
// ---------------------------------------------------------------------------
class DummyFeaturePage extends StatelessWidget {
  final String title;
  final String owner;

  const DummyFeaturePage({super.key, required this.title, required this.owner});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction_rounded,
                size: 80,
                color: Colors.orange[400],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Penanggung Jawab: $owner',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: const Text(
                  'Modul ini sedang dalam tahap pengembangan.',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

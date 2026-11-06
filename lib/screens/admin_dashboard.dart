
import 'package:flutter/material.dart';

import '../widgets/app_logo.dart';
import 'login_page.dart';

class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminDashboard({
    super.key,
    required this.user,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  final Color primaryColor = const Color(0xFF8D6E63);
  final Color backgroundColor = const Color(0xFFF5F0E8);
  final Color darkColor = const Color(0xFF5D4037);

  final List<Map<String, dynamic>> menus = [
    {
      'title': 'Dashboard',
      'icon': Icons.dashboard_outlined,
    },
    {
      'title': 'Kelola Produk',
      'icon': Icons.inventory_2_outlined,
    },
    {
      'title': 'Kelola Kategori',
      'icon': Icons.category_outlined,
    },
    {
      'title': 'Data Pengguna',
      'icon': Icons.people_outline,
    },
    {
      'title': 'Pesanan',
      'icon': Icons.shopping_bag_outlined,
    },
    {
      'title': 'Pengaturan',
      'icon': Icons.settings_outlined,
    },
  ];

  String get adminName =>
      widget.user['name']?.toString() ?? 'Administrator';

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun Admin?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
          (route) => false,
    );
  }

  void _selectMenu(int index) {
    setState(() {
      selectedIndex = index;
    });

    Navigator.pop(context);
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const AppLogo(size: 75),
            const SizedBox(height: 10),
            const Text(
              'PET MARKETPLACE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                letterSpacing: 1,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              adminName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF5D4037),
              ),
            ),
            const Text(
              'Administrator',
              style: TextStyle(
                fontSize: 12,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: menus.length,
                itemBuilder: (context, index) {
                  final menu = menus[index];

                  return ListTile(
                    selected: selectedIndex == index,
                    selectedTileColor:
                    primaryColor.withOpacity(0.15),
                    leading: Icon(
                      menu['icon'],
                      color: selectedIndex == index
                          ? primaryColor
                          : Colors.brown,
                    ),
                    title: Text(
                      menu['title'],
                      style: TextStyle(
                        fontWeight: selectedIndex == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: darkColor,
                      ),
                    ),
                    onTap: () => _selectMenu(index),
                  );
                },
              ),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _logout,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title,
      String value,
      IconData icon,
      ) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryColor, size: 30),
            const SizedBox(height: 15),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                color: Colors.brown,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang, $adminName!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Berikut adalah ringkasan dashboard Admin.',
          style: TextStyle(color: Colors.brown),
        ),
        const SizedBox(height: 25),

        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 650 ? 4 : 2;

            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _buildStatCard(
                  'Total Produk',
                  '-',
                  Icons.inventory_2_outlined,
                ),
                _buildStatCard(
                  'Kategori',
                  '-',
                  Icons.category_outlined,
                ),
                _buildStatCard(
                  'Pengguna',
                  '-',
                  Icons.people_outline,
                ),
                _buildStatCard(
                  'Pesanan',
                  '-',
                  Icons.shopping_bag_outlined,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 25),
        Text(
          'Menu Utama',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkColor,
          ),
        ),
        const SizedBox(height: 12),

        ...List.generate(4, (index) {
          final menuIndex = index + 1;
          final menu = menus[menuIndex];

          return Card(
            color: Colors.white,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(menu['icon'], color: primaryColor),
              title: Text(menu['title']),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: () {
                setState(() {
                  selectedIndex = menuIndex;
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPlaceholderContent() {
    final menu = menus[selectedIndex];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            menu['icon'],
            size: 75,
            color: primaryColor,
          ),
          const SizedBox(height: 20),
          Text(
            menu['title'],
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text(
              'Halaman ini belum terhubung dengan fitur pengelolaan data.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.brown),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: darkColor,
        elevation: 0,
        title: Text(
          menus[selectedIndex]['title'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: selectedIndex == 0
            ? SingleChildScrollView(
          child: _buildDashboardContent(),
        )
            : _buildPlaceholderContent(),
      ),
    );
  }
}

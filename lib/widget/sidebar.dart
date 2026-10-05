import 'package:flutter/material.dart';
import '../ui/login.dart';
import '../ui/pasien_page.dart';
import '../ui/pegawai_page.dart';
import '../ui/poli_page.dart';
import '../helpers/user_info.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
              accountName: Text("Admin"),
              accountEmail: Text("admin@admin.com")),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Beranda"),
            onTap: () {
              Scaffold.of(context).closeDrawer();
              // Beranda adalah route paling bawah, jadi cukup dikembalikan ke
              // sana supaya halaman yang sama tidak menumpuk di stack.
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          ListTile(
            leading: const Icon(Icons.accessible),
            title: const Text("Poli"),
            onTap: () {
              Scaffold.of(context).closeDrawer();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const PoliPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Pegawai"),
            onTap: () {
              Scaffold.of(context).closeDrawer();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const PegawaiPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_box_sharp),
            title: const Text("Pasien"),
            onTap: () {
              Scaffold.of(context).closeDrawer();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const PasienPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text("Keluar"),
            onTap: () async {
              Scaffold.of(context).closeDrawer();
              await UserInfo().logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (Route<dynamic> route) => false);
            },
          )
        ],
      ),
    );
  }
}

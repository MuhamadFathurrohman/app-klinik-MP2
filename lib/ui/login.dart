import 'package:flutter/material.dart';
import '../service/login_service.dart';
import 'beranda.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _prosesLogin = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Login Admin",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                const SizedBox(height: 50),
                Center(
                  child: Form(
                    key: _formKey,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Column(
                        children: [
                          _usernameTextField(),
                          const SizedBox(height: 20),
                          _passwordTextField(),
                          const SizedBox(height: 40),
                          _tombolLogin(),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _usernameTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Username"),
      controller: _usernameCtrl,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Username tidak boleh kosong";
        }
        return null;
      },
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Password"),
      obscureText: true,
      controller: _passwordCtrl,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password tidak boleh kosong";
        }
        return null;
      },
    );
  }

  Widget _tombolLogin() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white),
            onPressed: _prosesLogin ? null : _login,
            child: _prosesLogin
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text("Login")));
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _prosesLogin = true);
    String username = _usernameCtrl.text;
    String password = _passwordCtrl.text;
    bool berhasil = false;
    try {
      berhasil = await LoginService().login(username, password);
    } finally {
      if (mounted) {
        setState(() => _prosesLogin = false);
      }
    }
    if (!mounted) return;
    if (berhasil) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Beranda()));
    } else {
      AlertDialog alertDialog = AlertDialog(
        content: const Text("Username atau Password Tidak Valid"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("OK"),
          )
        ],
      );
      showDialog(context: context, builder: (context) => alertDialog);
    }
  }
}

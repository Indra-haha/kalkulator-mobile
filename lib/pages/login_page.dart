import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/session_service.dart';
import 'home_page.dart';
import 'regis_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  // Jika masih ada session tersimpan yang valid, langsung masuk ke menu utama.
  Future<void> _restoreSession() async {
    final token = await SessionService.instance.getToken();
    if (token == null || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final user = await ApiService.instance.checkSession(token);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage(user: user)),
      );
    } catch (_) {
      await SessionService.instance.clear();
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    if (_isLoading) return;
    final String nim = _nimController.text.trim();
    final String password = _passwordController.text;

    if (nim.isEmpty || password.isEmpty) {
      _showError('NIM dan password wajib diisi');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.instance.login(
        nim: nim,
        password: password,
      );
      await SessionService.instance.saveSession(result.token, result.user);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage(user: result.user)),
      );
    } on TimeoutException {
      _showError('Server tidak merespons. Pastikan backend berjalan.');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EFFF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'lib/assets/icon/logo.png', 
                      width: 64, 
                      height: 64, 
                      fit: BoxFit.contain, 
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Everything about Numbers',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nimController,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: 'NIM',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !_isLoading,
                      onSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Login'),
                    ),
                    const SizedBox(height: 12),

TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterPage(),
      ),
    );
  },
  child: const Text(
    'Belum punya akun? Registrasi',
    style: TextStyle(
      color: Colors.deepPurple,
      fontWeight: FontWeight.w600,
    ),
  ),
),

const Text(
  'Silakan login menggunakan NIM (password = NIM)',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 12,
    color: Colors.grey,
  ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_logo.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  final Color primaryColor = const Color(0xFF8D6E63);
  final Color backgroundColor = const Color(0xFFF5F0E8);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await ApiService.register(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        phone: phoneController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registrasi berhasil! Silakan login.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  InputDecoration inputDecoration(
      String hint,
      IconData icon, {
        Widget? suffix,
      }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 17,
        horizontal: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.brown.shade100,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
    );
  }

  Widget fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 15),

                    Center(
                        child: const AppLogo(size: 200),
                      ),


                    const SizedBox(height: 20),

                    const Text(
                      'Buat Akun Baru',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Daftar sekarang dan temukan '
                          'kebutuhan hewan peliharaanmu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.brown.shade400,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Nama
                    fieldLabel('Nama Lengkap'),

                    TextFormField(
                      controller: nameController,
                      textCapitalization:
                      TextCapitalization.words,
                      decoration: inputDecoration(
                        'Masukkan nama lengkap',
                        Icons.person_outline,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Nama wajib diisi';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 17),

                    // Email
                    fieldLabel('Email'),

                    TextFormField(
                      controller: emailController,
                      keyboardType:
                      TextInputType.emailAddress,
                      decoration: inputDecoration(
                        'Masukkan email',
                        Icons.email_outlined,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Email wajib diisi';
                        }

                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(value.trim())) {
                          return 'Format email tidak valid';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 17),

                    // Nomor HP
                    fieldLabel('Nomor HP'),

                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: inputDecoration(
                        'Masukkan nomor HP',
                        Icons.phone_outlined,
                      ),
                    ),

                    const SizedBox(height: 17),

                    // Password
                    fieldLabel('Password'),

                    TextFormField(
                      controller: passwordController,
                      obscureText: !showPassword,
                      decoration: inputDecoration(
                        'Minimal 8 karakter',
                        Icons.lock_outline,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                          icon: Icon(
                            showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Password wajib diisi';
                        }

                        if (value.length < 8) {
                          return 'Password minimal 8 karakter';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 17),

                    // Konfirmasi Password
                    fieldLabel('Konfirmasi Password'),

                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: !showConfirmPassword,
                      decoration: inputDecoration(
                        'Ulangi password',
                        Icons.lock_reset_outlined,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              showConfirmPassword =
                              !showConfirmPassword;
                            });
                          },
                          icon: Icon(
                            showConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password wajib diisi';
                        }

                        if (value != passwordController.text) {
                          return 'Password tidak sama';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // Tombol Daftar
                    SizedBox(
                      height: 53,
                      child: ElevatedButton(
                        onPressed:
                        isLoading ? null : register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                          primaryColor.withOpacity(0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          height: 23,
                          width: 23,
                          child:
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : const Text(
                          'DAFTAR SEKARANG',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sudah punya akun? ',
                          style: TextStyle(fontSize: 13),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
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

// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vega_spectrum_v2/widgets/glass_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  // --- Lógica para Email/Contraseña (sin cambios) ---
  Future<void> _submitAuthForm() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Error de autenticación.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Lógica para Google (sin cambios) ---
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Error de Google.');
    } catch (e) {
      _showError('Error inesperado con Google.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Lógica para Microsoft (sin cambios) ---
  Future<void> _signInWithMicrosoft() async {
    // (Tu lógica de Microsoft que dejamos pendiente)
  }

  // --- ✅ NUEVA LÓGICA PARA INICIO ANÓNIMO ---
  Future<void> _signInAnonymously() async {
    setState(() => _isLoading = true);
    try {
      // Simplemente llamamos a este método de Firebase
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Error de inicio de sesión anónimo.');
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage("assets/images/fondo.png"),
                  fit: BoxFit.cover,
                ),
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2C2C2E).withOpacity(0.8),
                    const Color(0xFF000000).withOpacity(0.9),
                  ],
                  center: Alignment.topLeft,
                  radius: 1.2,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isLogin ? 'Bienvenido' : 'Crear Cuenta',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 50),
                    GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextField(
                        controller: _emailController,
                        // ... (resto del TextField)
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          border: InputBorder.none,
                          icon: Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.7)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextField(
                        controller: _passwordController,
                        // ... (resto del TextField)
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          border: InputBorder.none,
                          icon: Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.7)),
                        ),
                        obscureText: true,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator(color: Colors.white))
                    else ...[
                      ElevatedButton(
                        onPressed: _submitAuthForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: Text(_isLogin ? 'Iniciar Sesión' : 'Registrarse'),
                      ),
                      const SizedBox(height: 25),
                      const Text('O continúa con', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSocialButton(
                            icon: Icons.g_mobiledata, 
                            label: 'Google',
                            onPressed: _signInWithGoogle,
                            color: Colors.redAccent,
                          ),
                          _buildSocialButton(
                            icon: Icons.window,
                            label: 'Microsoft',
                            onPressed: _signInWithMicrosoft, // (Aún no implementado)
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 40),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                        _isLogin ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Inicia sesión',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    // --- ✅ NUEVO BOTÓN PARA INVITADO ---
                    TextButton(
                      onPressed: _isLoading ? null : _signInAnonymously,
                      child: Text(
                        'Continuar como invitado',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // (El widget _buildSocialButton no cambia)
  Widget _buildSocialButton({required IconData icon, required String label, required VoidCallback onPressed, required Color color}) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 50,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(icon, color: color, size: 30),
        ),
      ),
    );
  }
}
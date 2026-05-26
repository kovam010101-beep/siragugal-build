import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  final String? redirect;
  const LoginScreen({super.key, this.redirect});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _handleLogin() async {
    setState(() { _loading = true; _error = null; });
    try {
      await apiService.login(_emailController.text, _passwordController.text);
      if (mounted) {
        context.go(widget.redirect ?? '/');
      }
    } catch (e) {
      setState(() {
        _error = 'உள்நுழைவதில் பிழை ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.';
        _loading = false;
      });
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() { _loading = true; _error = null; });
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '194385765544-bg2405r1k2j0dq6khuch837rg81bj0ss.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        setState(() => _loading = false);
        return;
      }
      
      final GoogleSignInAuthentication auth = await account.authentication;
      if (auth.idToken != null) {
        await apiService.loginWithGoogle(auth.idToken!);
        if (mounted) {
          context.go(widget.redirect ?? '/');
        }
      } else {
        throw Exception('No ID token from Google');
      }
    } catch (e) {
      setState(() {
        _error = 'கூகுள் உள்நுழைவில் பிழை ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('உள்நுழைவு', style: TextStyle(fontFamily: 'NotoSerifTamil')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 40),
          const Icon(Icons.lock_open, size: 64, color: Color(0xFFE85D26)),
          const SizedBox(height: 24),
          const Text(
            'வரவேற்கிறோம்!',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'NotoSerifTamil', fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'உங்கள் கணக்கில் உள்நுழைந்து வாசிப்பைத் தொடரவும்',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 32),

          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 16),
          ],

          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              hintText: 'மின்னஞ்சல் முகவரி (Email)',
              hintStyle: TextStyle(fontFamily: 'NotoSerifTamil', fontSize: 12),
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'கடவுச்சொல் (Password)',
              hintStyle: TextStyle(fontFamily: 'NotoSerifTamil', fontSize: 12),
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _loading ? null : _handleLogin,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('உள்நுழை', style: TextStyle(fontFamily: 'NotoSerifTamil', fontSize: 15)),
          ),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: _loading ? null : _handleGoogleLogin,
            icon: const Icon(Icons.login),
            label: const Text('Continue with Google'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 20),

          TextButton(
            onPressed: () => context.push('/register'),
            child: const Text('புதிய கணக்கை உருவாக்கவும் (Register)', style: TextStyle(fontFamily: 'NotoSerifTamil', fontSize: 13)),
          ),
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test/screens/signUP_screen.dart';
import '../controller/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController authController = AuthController();

  bool isLoading = false;
  bool _passwordVisible = false; // 👁 Password toggle

  // ---------------- LOGIN FUNCTION ----------------
  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    setState(() => isLoading = true);

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    String? error = await authController.login(context, email, password);

    setState(() => isLoading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful ❤️")),
      );
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  void _googleSignIn() {
    print("Google sign in");
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = const Color(0xFF9C27B0);
    final primaryColor = const Color(0xFF2B3040);

    return Scaffold(
      appBar: AppBar(title: const Text("Login"), backgroundColor: primaryColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email field
            _buildInputField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              backgroundColor: primaryColor,
            ),

            const SizedBox(height: 16),

            // Password field WITH EYE ICON
            _buildPasswordField(primaryColor),

            const SizedBox(height: 30),

            // LOGIN BUTTON
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
                  : const Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Center(
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildGoogleButton(_googleSignIn),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?",
                    style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: buttonColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- PASSWORD FIELD WITH EYE TOGGLE ----------------

  Widget _buildPasswordField(Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: !_passwordVisible, // show/hide text
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.lock, color: Colors.grey),

          // 🔥 EYE BUTTON HERE
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),

          border: InputBorder.none,
        ),
      ),
    );
  }
}

// --------------------- REUSABLE WIDGETS ---------------------
Widget _buildInputField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required Color backgroundColor,
  TextInputType keyboardType = TextInputType.text,
  bool isPassword = false,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey),
        border: InputBorder.none,
      ),
    ),
  );
}

Widget _buildGoogleButton(VoidCallback onPressed) {
  return OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      side: const BorderSide(color: Colors.grey, width: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/logo_image/Google__G__logo.svg.webp',
          width: 30,
          height: 30,
        ),
        const SizedBox(width: 10),
        const Text(
          'Sign in with Google',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    ),
  );
}

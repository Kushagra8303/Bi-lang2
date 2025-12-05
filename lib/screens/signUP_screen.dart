import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /////////////////////////////////
  String selectedLanguage = "en-US";

  final Map<String, String> languages = {
    "en-US": "English - US",
    "en-UK": "English - UK",
    "en-IN": "English - India",
    "en-AU": "English - Australia",
    "en-SCOTT": "English - Scotland",
    "es-MX": "Spanish - Mexico",
    "es-ES": "Spanish - Spain",
    "fr-FR": "French - France",
    "de-DE": "German - Germany",
    "it-IT": "Italian - Italy",
    "nl-NL": "Dutch - Netherlands",
    "pt-BR": "Portuguese - Brazil",
    "zh-CN": "Chinese - China",
    "ja-JP": "Japanese - Japan",
    "ko-KR": "Korean - Korea",
    "hi-IN": "Hindi - India",
    "ta-IN": "Tamil - India",
    "bn-IN": "Bengali - India",
    "hr-HR": "Croatian - Croatia",
    "sk-SK": "Slovak - Slovakia",
    "pl-PL": "Polish - Poland",
    "el-GR": "Greek - Greece",
  };

  final AuthController _auth = AuthController();
  bool _passwordVisible = false;

  // ---------------- HANDLE SIGNUP -----------------
  Future<void> handleSignup() async {
    FocusScope.of(context).unfocus();

    setState(() => _auth.isLoading = true);

    try {
      String? result = await _auth.signup(
        context,
        _nameController.text.trim(),
        _numberController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        selectedLanguage, // ✅ pass selected language
      );

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Account Created Successfully 🎉 Welcome ${_nameController.text}",
            ),
          ),
        );

        // ✅ Navigate after short delay
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.pushReplacementNamed(context, "/home");
        });
      } else {
        // show Firebase error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup failed: $result")),
        );
      }
    } catch (e) {
      print("aaaaaaaaa handleSignup error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Signup failed: $e")));
    } finally {
      if (mounted) {
        setState(() => _auth.isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = const Color(0xFF9C27B0);
    final primaryColor = const Color(0xFF2B3040);

    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up"), backgroundColor: primaryColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                backgroundColor: primaryColor),
            const SizedBox(height: 16),
            _buildInputField(
                controller: _numberController,
                label: 'Mobile Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                backgroundColor: primaryColor),
            const SizedBox(height: 16),
            _buildInputField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                backgroundColor: primaryColor),
            const SizedBox(height: 16),
            _buildPasswordField(primaryColor),
            const SizedBox(height: 16),
            _buildLanguageDropdown(primaryColor),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _auth.isLoading ? null : handleSignup,
              style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: _auth.isLoading
                  ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3))
                  : const Text("SIGN UP",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            const Center(
                child: Text("OR",
                    style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
            const SizedBox(height: 30),
            _buildGoogleButton(() {}),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?",
                    style: TextStyle(color: Colors.grey)),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Login",
                        style: TextStyle(
                            color: buttonColor, fontWeight: FontWeight.bold)))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration:
      BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: _passwordController,
        obscureText: !_passwordVisible,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: "Password",
          labelStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.lock, color: Colors.grey),
          suffixIcon: IconButton(
              icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey),
              onPressed: () => setState(() => _passwordVisible = !_passwordVisible)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration:
      BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonFormField<String>(
        value: selectedLanguage,
        dropdownColor: backgroundColor,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: "Select Language",
          labelStyle: TextStyle(color: Colors.grey),
        ),
        items: languages.entries
            .map((entry) => DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        ))
            .toList(),
        onChanged: (val) {
          setState(() {
            selectedLanguage = val!;
          });
        },
      ),
    );
  }
}

Widget _buildInputField(
    {required TextEditingController controller,
      required String label,
      required IconData icon,
      required Color backgroundColor,
      TextInputType keyboardType = TextInputType.text}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration:
    BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8)),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none),
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
        Image.asset('assets/logo_image/Google__G__logo.svg.webp', width: 30, height: 30),
        const SizedBox(width: 10),
        const Text("Sign in with Google",
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ],
    ),
  );
}

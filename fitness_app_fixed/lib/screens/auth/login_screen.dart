import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class LoginScreen extends StatefulWidget {
  final VoidCallback? onSignup;
  final VoidCallback? onForgotPassword;
  const LoginScreen({super.key, this.onSignup, this.onForgotPassword});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<Database> getDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      p.join(dbPath, 'app.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS user_profile(uid TEXT PRIMARY KEY, gender TEXT, theme TEXT, onboarded INTEGER)',
        );
      },
      version: 1,
    );
  }

  Future<void> _login() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = credential.user;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final dialogTextColor = isDark ? Colors.white : Colors.black;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Success',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          content: Text(
            'Login successful!',
            style: TextStyle(color: dialogTextColor, fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: dialogTextColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      );
      if (user != null) {
        // 1. Check Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final data = doc.data();
        String? gender = data?['gender'];
        String? theme = data?['theme'];
        // 2. If missing, check SQLite
        if (gender == null || theme == null) {
          final db = await getDatabase();
          final result = await db.query(
            'user_profile',
            where: 'uid = ?',
            whereArgs: [user.uid],
          );
          if (result.isNotEmpty) {
            gender = result.first['gender'] as String?;
            theme = result.first['theme'] as String?;
          }
        }
        // 3. If still missing, show onboarding
        if (gender == null || theme == null) {
          Navigator.pushReplacementNamed(context, '/onboarding');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final dialogTextColor = isDark ? Colors.white : Colors.black;
      if (e.code == 'user-not-found') {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Account Not Found',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            content: Text(
              'No user found for that email. Would you like to sign up?',
              style: TextStyle(color: dialogTextColor, fontFamily: 'Poppins'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: dialogTextColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: dialogTextColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (e.code == 'wrong-password') {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Incorrect Password',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            content: Text(
              'The password you entered is incorrect.',
              style: TextStyle(color: dialogTextColor, fontFamily: 'Poppins'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: dialogTextColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Login Failed',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            content: Text(
              e.message ?? 'Login failed.',
              style: TextStyle(color: dialogTextColor, fontFamily: 'Poppins'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: dialogTextColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final dialogTextColor = isDark ? Colors.white : Colors.black;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Login Failed',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          content: Text(
            e.toString(),
            style: TextStyle(color: dialogTextColor, fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: dialogTextColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black26
                      : Colors.black.withOpacity(0.07),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo_dark.png',
                  width: 220,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 2),
                Text(
                  'Sign in to your account',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email / Username',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: theme.iconTheme.color,
                    ),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF181829) : Colors.white,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: theme.iconTheme.color,
                    ),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF181829) : Colors.white,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed:
                        widget.onForgotPassword ??
                        () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFFF44336),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF44336),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.15)),
                const SizedBox(height: 18),
                TextButton(
                  onPressed:
                      widget.onSignup ??
                      () {
                        Navigator.pushNamed(context, '/signup');
                      },
                  child: Text(
                    'Don\'t have an account? Sign up',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFFF44336),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

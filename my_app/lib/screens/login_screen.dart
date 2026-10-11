import 'package:flutter/material.dart';
import '../api/api_constants.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/fcm_service.dart';
import '../utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    if (phone.length < 10) {
      _showMessage('Please enter a valid phone number.');
      return;
    }
    if (password.length < 8) {
      _showMessage('Password must be at least 8 characters.');
      return;
    }
    if (_isSignUp && password != _confirmPasswordController.text) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);
    final data = await AuthService.passwordAuth(
      phoneNumber: phone,
      password: password,
      mode: _isSignUp ? 'signup' : 'signin',
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (data['success'] != true) {
      _showMessage(data['message'] ?? 'Unable to sign in.');
      return;
    }

    final owner = data['owner'] as Map<String, dynamic>?;
    ApiConstants.token = data['token']?.toString();
    ApiConstants.phone = phone;
    ApiConstants.mahalownerId = (data['ownerId'] ?? owner?['_id'] ?? '')
        .toString();
    await AuthService.saveSession(
      token: ApiConstants.token!,
      phone: phone,
      ownerId: ApiConstants.mahalownerId,
    );
    await FcmService().registerCurrentDevice();

    final profileComplete = data['isExistingOwner'] == true;
    await AuthService.setRegistrationComplete(profileComplete);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      profileComplete ? AppRoutes.ownerHome : AppRoutes.ownerDetails,
      (route) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: const Text('Owner Account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isSignUp ? 'Create owner account' : 'Welcome back',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: 'Show or hide password',
                        onPressed: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                  if (_isSignUp) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_confirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: 'Show or hide confirm password',
                          onPressed: () => setState(
                            () => _confirmPasswordVisible =
                                !_confirmPasswordVisible,
                          ),
                          icon: Icon(
                            _confirmPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.orange1,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isSignUp ? 'Create account' : 'Sign in'),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() => _isSignUp = !_isSignUp),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.orange1,
                    ),
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Sign in'
                          : 'New owner? Create an account',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

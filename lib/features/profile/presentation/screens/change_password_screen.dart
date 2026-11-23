import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmanagement_app/core/constants/app_colors.dart';
import 'package:taskmanagement_app/core/utils/validators.dart';
import 'package:taskmanagement_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmanagement_app/shared/widgets/app_button.dart';
import 'package:taskmanagement_app/shared/widgets/custom_text_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).changePassword(
          _oldPasswordController.text,
          _newPasswordController.text,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully!'),
          backgroundColor: AppColors.statusCompleted,
        ),
      );
      context.pop();
    } else {
      final error = ref.read(authProvider).errorMessage ?? 'Failed to change password';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.priorityUrgent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _oldPasswordController,
                  label: 'Current Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureOld,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureOld ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  prefixIcon: Icons.lock_reset_outlined,
                  obscureText: _obscureNew,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  prefixIcon: Icons.lock_reset_outlined,
                  obscureText: _obscureNew,
                  validator: (val) => Validators.confirmPassword(val, _newPasswordController.text),
                ),
                const SizedBox(height: 32),
                AppButton(
                  text: 'Update Password',
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

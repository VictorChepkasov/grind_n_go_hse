import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../core/auth_navigation.dart';
import '../core/phone_input.dart';
import '../core/api_exception.dart';
import '../data/auth_repository.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/pill_text_field.dart';
import '../widgets/report_problem_link.dart';
import '../widgets/stadium_button.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final MaskTextInputFormatter _phoneFormatter = createPhoneMaskFormatter();
  final _phoneController = TextEditingController(
    text: '',
  );
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthProvider>().login(
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) {
        completeAuthFlow(context);
      }
    } on AuthException catch (error) {
      setState(() => _errorMessage = error.message);
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 8),
                const AppLogo(size: 120),
                const SizedBox(height: 32),
                PillTextField(
                  controller: _phoneController,
                  label: 'Введите свой номер телефона:',
                  hintText: '+7 (9__) ___-__-__',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneFormatter],
                  validator: (value) {
                    if (value == null || !isPhoneComplete(value, _phoneFormatter)) {
                      return 'Введите полный номер телефона';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Вы в одном шаге от вашего любимого напитка',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.accentDark,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                PillTextField(
                  controller: _passwordController,
                  label: 'Введите пароль:',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите пароль';
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                StadiumButton(
                  label: 'Войти',
                  isLoading: _isLoading,
                  backgroundColor: AppColors.coffee,
                  foregroundColor: AppColors.textOnPrimary,
                  onPressed: _submit,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const RegistrationScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Нет аккаунта? Регистрация',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const ReportProblemLink(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

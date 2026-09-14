import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/route_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/controller/toaster_controller.dart';
import 'package:khaanado/service_locator.dart';
import 'package:khaanado/ui/custom_widgets/app_text_field.dart';
import 'package:khaanado/ui/custom_widgets/brand_mark.dart';
import 'package:khaanado/ui/custom_widgets/motion.dart';
import 'package:khaanado/ui/custom_widgets/primary_button.dart';
import 'package:khaanado/ui/screens/shell/app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = RouteConstants.login;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: AppConstants.demoEmail);
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _fillDemo() {
    setState(() {
      _email.text = AppConstants.demoEmail;
      _password.text = AppConstants.demoPassword;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final error = await authController.login(
      email: _email.text.trim(),
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      toasterController.show(context, error, kind: ToasterKind.error);
      return;
    }
    toasterController.hide();
    HapticFeedback.mediumImpact();
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(AppShell.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            const FadeSlideIn(child: BrandMark(size: 72)),
            const SizedBox(height: 20),
            const FadeSlideIn(
              delay: Duration(milliseconds: 80),
              child: Text(
                StringConstants.login,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 8),
            FadeSlideIn(
              delay: const Duration(milliseconds: 140),
              child: Text(
                StringConstants.demoHint,
                style: TextStyle(color: ColorConstants.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            FadeSlideIn(
              delay: const Duration(milliseconds: 180),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ActionChip(
                  onPressed: _fillDemo,
                  backgroundColor: ColorConstants.accentSoft,
                  side: const BorderSide(color: ColorConstants.accent),
                  label: const Text(StringConstants.useDemo),
                  avatar: const Icon(
                    Icons.bolt_rounded,
                    color: ColorConstants.accent,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeSlideIn(
              delay: const Duration(milliseconds: 220),
              child: AppTextField(
                controller: _email,
                hint: StringConstants.email,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: 12),
            FadeSlideIn(
              delay: const Duration(milliseconds: 260),
              child: AppTextField(
                controller: _password,
                hint: StringConstants.password,
                icon: Icons.lock_outline,
                obscure: _obscure,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                suffix: IconButton(
                  tooltip:
                      _obscure
                          ? StringConstants.showPassword
                          : StringConstants.hidePassword,
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: ColorConstants.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeSlideIn(
              delay: const Duration(milliseconds: 320),
              child: PrimaryButton(
                label: StringConstants.login,
                loading: _loading,
                onPressed: _loading ? null : _submit,
              ),
            ),
            TextButton(
              onPressed:
                  () => Navigator.pushReplacementNamed(
                    context,
                    RouteConstants.signup,
                  ),
              child: const Text(StringConstants.noAccount),
            ),
          ],
        ),
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  static const routeName = RouteConstants.signup;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final error = await authController.signup(
      name: _name.text,
      email: _email.text.trim(),
      password: _password.text,
      confirm: _confirm.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      toasterController.show(context, error, kind: ToasterKind.error);
      return;
    }
    toasterController.hide();
    HapticFeedback.mediumImpact();
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(AppShell.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            const FadeSlideIn(child: BrandMark(size: 64)),
            const SizedBox(height: 18),
            const FadeSlideIn(
              delay: Duration(milliseconds: 80),
              child: Text(
                StringConstants.signup,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              controller: _name,
              hint: StringConstants.fullName,
              icon: Icons.person_outline,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _email,
              hint: StringConstants.email,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _password,
              hint: StringConstants.password,
              icon: Icons.lock_outline,
              obscure: _obscure,
              textInputAction: TextInputAction.next,
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: ColorConstants.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _confirm,
              hint: StringConstants.confirmPassword,
              icon: Icons.lock_outline,
              obscure: _obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: StringConstants.signup,
              loading: _loading,
              onPressed: _loading ? null : _submit,
            ),
            TextButton(
              onPressed:
                  () => Navigator.pushReplacementNamed(
                    context,
                    RouteConstants.login,
                  ),
              child: const Text(StringConstants.hasAccount),
            ),
          ],
        ),
      ),
    );
  }
}

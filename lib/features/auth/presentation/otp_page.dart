import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:customer/core/errors/app_failure.dart';
import 'package:customer/core/widgets/otp_boxes.dart';
import 'package:customer/core/widgets/prila_gradient_button.dart';
import 'package:customer/features/auth/data/auth_repository.dart';
import 'package:customer/l10n/app_localizations.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key, required this.phone, this.debugCode});

  final String phone;
  final String? debugCode;

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  var _otpCode = '';
  var _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.debugCode != null) {
      _otpCode = widget.debugCode!;
    }
  }

  Future<void> _verify() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).verifyOtp(widget.phone, _otpCode.trim());
      ref.invalidate(authSessionProvider);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      setState(() => _error = e is AppFailure ? e.message : 'Invalid OTP');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.otpTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l10n.otpSubtitle(widget.phone)),
            const SizedBox(height: 24),
            OtpBoxes(
              length: 6,
              onChanged: (code) => setState(() => _otpCode = code),
              onCompleted: (_) => _verify(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const Spacer(),
            PrilaGradientButton(label: l10n.verifyOtp, onPressed: _verify, loading: _loading),
          ],
        ),
      ),
    );
  }
}

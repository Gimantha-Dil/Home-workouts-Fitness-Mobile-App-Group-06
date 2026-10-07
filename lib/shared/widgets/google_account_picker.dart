import 'package:flutter/material.dart';
import '../../core/models/user_role.dart';
import '../../core/theme/app_theme.dart';
import 'common_widgets.dart';

class GoogleAccountOption {
  final String name;
  final String email;

  const GoogleAccountOption({
    required this.name,
    required this.email,
  });
}

Future<GoogleAccountOption?> showGoogleAccountPickerBottomSheet({
  required BuildContext context,
  required UserRole role,
}) {
  return showModalBottomSheet<GoogleAccountOption>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _GoogleAccountPickerWidget(role: role),
  );
}

class _GoogleAccountPickerWidget extends StatelessWidget {
  final UserRole role;

  const _GoogleAccountPickerWidget({required this.role});

  final List<GoogleAccountOption> _accounts = const [
    GoogleAccountOption(name: 'Gimantha Gunasekara', email: 'gimanthagunasekara908@gmail.com'),
    GoogleAccountOption(name: 'Nethmi Tharuka', email: 'nethmi.tharuka@gmail.com'),
    GoogleAccountOption(name: 'Kasun Perera', email: 'kasun.fitness@gmail.com'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const AppLogoIcon(size: 48),
          const SizedBox(height: 16),
          const Text(
            'Choose an account',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'to continue to FitPulse',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ..._accounts.map((acc) => InkWell(
                onTap: () => Navigator.of(context).pop(acc),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.brandTeal,
                        child: Text(
                          acc.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(acc.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(acc.email, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const Divider(height: 24),
          InkWell(
            onTap: () => _showAddAccountDialog(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(color: Color(0xFFF1F3F4), shape: BoxShape.circle),
                    child: const Icon(Icons.person_add_outlined, color: AppColors.textPrimary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Text('Add another account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'To continue, Google will share your name, email address, and profile picture with FitPulse.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withOpacity(0.8), height: 1.4),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Google Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Google Email', prefixIcon: Icon(Icons.email)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal),
            onPressed: () {
              final email = emailCtrl.text.trim();
              final name = nameCtrl.text.trim();
              if (email.isNotEmpty) {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(GoogleAccountOption(
                  name: name.isNotEmpty ? name : email.split('@').first,
                  email: email,
                ));
              }
            },
            child: const Text('Sign In', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

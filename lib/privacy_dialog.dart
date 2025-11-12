import 'package:flutter/material.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:etohos/methods.dart';
import 'package:etohos/privacy_config.dart';

/// 隐私政策同意对话框
class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return PopScope(
      canPop: false, // 禁止返回键关闭
      child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.privacy_tip, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t('privacy_policy_title'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('privacy_policy_content'),
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  try {
                    await methods.launchUrl(privacyPolicyUrl);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${t('failed_to_open_url')}: $e')),
                      );
                    }
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.link, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      t('privacy_policy'),
                      style: TextStyle(
                        color: colorScheme.primary,
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.open_in_new, size: 14, color: colorScheme.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 不同意，退出应用
              Navigator.of(context).pop(false);
            },
            child: Text(
              t('disagree_and_exit'),
              style: TextStyle(color: colorScheme.error),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(t('agree')),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:tma_tg_bottom_webview/presentation/core/app_colors.dart';
import 'package:tma_tg_bottom_webview/presentation/modals/dynamic_modal.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telegram TMA'),
      ),
      body: Center(
        child: OutlinedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppColors.transparent,
              builder: (context) => const DynamicModal(
                url: 'https://google.com',
              ),
            );
          },
          child: const Text('Open Modal'),
        ),
      ),
    );
  }
}

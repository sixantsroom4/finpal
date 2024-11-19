import 'dart:io';
import 'package:finpal/presentation/pages/receipt/receipt_scan_result_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/receipt/receipt_bloc.dart';
import '../../bloc/receipt/receipt_event.dart';

class ReceiptPreviewPage extends StatelessWidget {
  final String imagePath;

  const ReceiptPreviewPage({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('영수증 미리보기'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true), // 재촬영
            child: const Text('다시 찍기'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _analyzeReceipt(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('영수증 분석하기'),
            ),
          ),
        ],
      ),
    );
  }

  void _analyzeReceipt(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ReceiptBloc>().add(
            ScanReceipt(
              imagePath: imagePath,
              userId: authState.user.id,
            ),
          );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScanResultPage(
            imagePath: imagePath,
          ),
        ),
      );
    }
  }
}

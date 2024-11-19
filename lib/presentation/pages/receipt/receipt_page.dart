// lib/presentation/pages/receipt/receipt_page.dart
import 'package:finpal/domain/entities/receipt.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_event.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_state.dart';
import 'package:finpal/presentation/pages/receipt/receipt_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../bloc/receipt/receipt_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'widgets/scan_receipt_fab.dart';
import 'widgets/receipt_grid_item.dart';
import 'receipt_scan_result_page.dart';
import 'receipt_preview_page.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final _numberFormat = NumberFormat('#,###');
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReceipts();
    });
  }

  void _loadReceipts() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      debugPrint('영수증 목록 로드 시작: ${authState.user.id}');
      context.read<ReceiptBloc>().add(LoadReceipts(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('영수증'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scanReceipt(context),
        child: const Icon(Icons.document_scanner),
      ),
      body: BlocConsumer<ReceiptBloc, ReceiptState>(
        listener: (context, state) {
          if (state is ReceiptError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is ReceiptOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ReceiptLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReceiptEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '저장된 영수증이 없습니다',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '영수증을 스캔하여 자동으로 지출을 기록해보세요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // 통계 섹션
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('이번 달 영수증'),
                            Text(
                              '${state.receipts.length}장',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('총 지출액'),
                            Text(
                              '${_numberFormat.format(state.totalAmount)}원',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 영수증 그리드
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final receipt = state.receipts[index];
                      return ReceiptGridItem(
                        receipt: receipt,
                        onTap: () => _showReceiptDetails(context, receipt),
                      );
                    },
                    childCount: state.receipts.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.date_range),
            title: const Text('날짜순'),
            onTap: () {
              Navigator.pop(context);
              // TODO: 정렬 구현
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('가맹점순'),
            onTap: () {
              Navigator.pop(context);
              // TODO: 정렬 구현
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('금액순'),
            onTap: () {
              Navigator.pop(context);
              // TODO: 정렬 구현
            },
          ),
        ],
      ),
    );
  }

  void _showReceiptDetails(BuildContext context, Receipt receipt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptDetailsPage(receipt: receipt),
      ),
    );
  }

  Future<void> _scanReceipt(BuildContext context) async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null && context.mounted) {
        final shouldRetake = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptPreviewPage(
              imagePath: image.path,
            ),
          ),
        );

        if (shouldRetake == true && context.mounted) {
          _scanReceipt(context); // 재촬영
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('영수증 스캔 중 오류가 발생했습니다: ${e.toString()}')),
      );
    }
  }
}

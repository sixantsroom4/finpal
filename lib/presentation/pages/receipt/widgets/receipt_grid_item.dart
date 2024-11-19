// lib/presentation/pages/receipt/widgets/receipt_grid_item.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:finpal/domain/entities/receipt.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiptGridItem extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onTap;

  const ReceiptGridItem({
    super.key,
    required this.receipt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 영수증 이미지
            Expanded(
              child: CachedNetworkImage(
                imageUrl: receipt.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error),
                ),
              ),
            ),
            // 정보 섹션
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receipt.merchantName,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('M월 d일').format(receipt.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${NumberFormat('#,###').format(receipt.totalAmount)}원',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

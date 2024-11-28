// lib/presentation/pages/receipt/widgets/receipt_grid_item.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:finpal/domain/entities/receipt.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

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
                    _getLocalizedDate(context, receipt.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getLocalizedAmount(context, receipt.totalAmount),
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

  String _getLocalizedDate(BuildContext context, DateTime date) {
    final language = context.read<AppLanguageBloc>().state.language;
    switch (language) {
      case AppLanguage.english:
        return DateFormat('MMM d').format(date);
      case AppLanguage.japanese:
        return DateFormat('M月d日').format(date);
      case AppLanguage.korean:
      default:
        return DateFormat('M월 d일').format(date);
    }
  }

  String _getLocalizedAmount(BuildContext context, double amount) {
    final currency = receipt.currency;
    final formatter = NumberFormat('#,###');
    final formattedAmount = formatter.format(amount);

    final currencySymbols = {
      'KRW': '원',
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
    };

    final symbol = currencySymbols[currency] ?? currencySymbols['KRW']!;

    switch (currency) {
      case 'USD':
      case 'EUR':
        return '$symbol$formattedAmount';
      case 'JPY':
        return '¥$formattedAmount';
      case 'KRW':
      default:
        return '$formattedAmount$symbol';
    }
  }
}

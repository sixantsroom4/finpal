import 'package:cached_network_image/cached_network_image.dart';
import 'package:finpal/domain/entities/receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class ReceiptListItem extends StatelessWidget {
  final Receipt receipt;

  const ReceiptListItem({
    super.key,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CachedNetworkImage(
            imageUrl: receipt.imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(receipt.merchantName),
        subtitle: Text(_getLocalizedDate(context, receipt.date)),
        trailing: Text(
          _getLocalizedAmount(context, receipt.totalAmount),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
    final language = context.read<AppLanguageBloc>().state.language;
    final formatter = NumberFormat('#,###');
    switch (language) {
      case AppLanguage.english:
        return '\$${formatter.format(amount)}';
      case AppLanguage.japanese:
        return '¥${formatter.format(amount)}';
      case AppLanguage.korean:
      default:
        return '${formatter.format(amount)}원';
    }
  }
}

import 'package:finpal/presentation/bloc/user_registration/user_registration_event.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_bloc.dart';

class CurrencySettingSection extends StatelessWidget {
  const CurrencySettingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRegistrationBloc, UserRegistrationState>(
      builder: (context, state) {
        if (state is! UserRegistrationInProgress) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '기본 통화',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0C2340),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E8EC)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                value: state.currency,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                items: [
                  _buildDropdownMenuItem('KRW', '원화 (₩)'),
                  _buildDropdownMenuItem('USD', '달러 (\$)'),
                  _buildDropdownMenuItem('JPY', '엔화 (¥)'),
                  _buildDropdownMenuItem('EUR', '유로 (€)'),
                ],
                onChanged: (newValue) {
                  if (newValue != null) {
                    context.read<UserRegistrationBloc>().add(
                          CurrencyChanged(newValue),
                        );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  DropdownMenuItem<String> _buildDropdownMenuItem(String value, String label) {
    return DropdownMenuItem(
      value: value,
      child: Text(label),
    );
  }
}

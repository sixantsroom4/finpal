import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_event.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_state.dart';
import 'package:finpal/core/constants/app_locations.dart';

class LocationSettingSection extends StatelessWidget {
  const LocationSettingSection({super.key});

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
              '위치',
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
              child: Column(
                children: AppLocation.values.map((location) {
                  return RadioListTile<AppLocation>(
                    title: Text(location.displayName),
                    value: location,
                    groupValue: state.location,
                    onChanged: (AppLocation? value) {
                      if (value != null) {
                        context.read<UserRegistrationBloc>()
                          ..add(LocationChanged(value))
                          ..add(CurrencyChanged(value.currency));
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

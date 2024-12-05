// lib/presentation/pages/settings/widgets/profile_section.dart
import 'package:finpal/domain/entities/user.dart';
import 'package:finpal/presentation/pages/settings/widget/edit_profile_bottom_sheet.dart';
import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  final User user;

  const ProfileSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2C3E50),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF2C3E50).withOpacity(0.1),
                backgroundImage:
                    user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null
                    ? Text(
                        user.displayName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          color: Color(0xFF2C3E50),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF2C3E50),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF2C3E50).withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Color(0xFF2C3E50),
                ),
                onPressed: () => _showEditProfileBottomSheet(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditProfileBottomSheet(user: user),
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

@RoutePage()
class SharingHubPage extends StatelessWidget {
  const SharingHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sharing Hub'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSharingCard(
              context,
              title: 'Create Share Card',
              icon: Icons.share,
              color: AppTheme.primaryColor,
              onTap: () {
                context.router.pushNamed('/create-share-card');
              },
            ),
            const SizedBox(height: 16),
            _buildSharingCard(
              context,
              title: 'History',
              icon: Icons.history,
              color: Colors.orange,
              onTap: () {
                context.router.pushNamed('/sharing-history');
              },
            ),
            const SizedBox(height: 16),
            _buildSharingCard(
              context,
              title: 'Privacy Settings',
              icon: Icons.privacy_tip,
              color: Colors.blue,
              onTap: () {
                context.router.pushNamed('/privacy-settings');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharingCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

/// AppHeader
///
/// A defensive, preferred-size header used across the app. Keeps a compact
/// single-row layout when vertical space is limited to avoid RenderFlex
/// overflow errors.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final UserModel? user;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle = '',
    this.user,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(96);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : preferredSize.height;
            final isCompact = availableHeight < preferredSize.height;
            final avatarEdge = (availableHeight - (isCompact ? 12 : 24)).clamp(24.0, 40.0);
            final avatarRadius = (avatarEdge / 2) - 2;

            if (isCompact) return _buildCompact(context, avatarEdge, avatarRadius);

            return _buildFull(context, avatarEdge, avatarRadius);
          },
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context, double avatarEdge, double avatarRadius) {
    return SizedBox(
      height: preferredSize.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBackButton)
            IconButton(
              onPressed: onBackPressed ?? () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.subtleLight,
                foregroundColor: AppColors.primary,
              ),
            )
          else
            Container(
              width: avatarEdge,
              height: avatarEdge,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.business_center,
                color: Colors.white,
                size: 16,
              ),
            ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: () => _showUserMenu(context),
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                user?.initials ?? 'U',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: avatarRadius * 0.9,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFull(BuildContext context, double avatarEdge, double avatarRadius) {
    return SizedBox(
      height: preferredSize.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showBackButton)
                IconButton(
                  onPressed: onBackPressed ?? () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.subtleLight,
                    foregroundColor: AppColors.primary,
                  ),
                )
              else
                Container(
                  width: avatarEdge,
                  height: avatarEdge,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.business_center,
                    color: Colors.white,
                    size: 18,
                  ),
                ),

              const SizedBox(width: 16),

              Flexible(
                fit: FlexFit.loose,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return IconButton(
                            onPressed: () => themeProvider.toggleTheme(),
                            icon: Icon(
                              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.subtleLight,
                              foregroundColor: AppColors.primary,
                            ),
                          );
                        },
                      ),

                      Stack(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.notifications_outlined),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.subtleLight,
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: () => _showUserMenu(context),
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            user?.initials ?? 'U',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: avatarRadius * 0.9,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(children: actions!),
          ],
        ],
      ),
    );
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final mq = MediaQuery.of(context);
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: mq.size.height * 0.9),
            child: Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, mq.viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          Provider.of<AuthProvider>(context, listen: false).user?.initials ?? 'U',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Provider.of<AuthProvider>(context, listen: false).user?.displayName ?? 'User',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Provider.of<AuthProvider>(context, listen: false).user?.email ?? '',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildMenuTile(
                    context,
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile');
                    },
                  ),
                  _buildMenuTile(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                  _buildMenuTile(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),
                  _buildMenuTile(
                    context,
                    icon: Icons.logout,
                    title: 'Sign Out',
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        await Provider.of<AuthProvider>(context, listen: false).signOut();
                      } catch (e) {
                        // ignore errors during sign-out in dev
                        if (kDebugMode) debugPrint('Sign out error: $e');
                      }
                      if (context.mounted) context.go('/login');
                    },
                    textColor: AppColors.error,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? AppColors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}


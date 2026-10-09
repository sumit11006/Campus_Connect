import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../design_system/app_card.dart';
import '../../design_system/app_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _branchController;
  late TextEditingController _yearController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _branchController = TextEditingController(text: user?.branch ?? '');
    _yearController = TextEditingController(
        text: user?.year != null ? user!.year.toString() : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _branchController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      await ref.read(authProvider.notifier).uploadAvatar(image.path);
    }
  }

  void _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    await ref.read(authProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          bio: _bioController.text.trim(),
          branch: _branchController.text.trim(),
          year: _yearController.text.trim().isNotEmpty
              ? int.tryParse(_yearController.text.trim())
              : null,
        );

    if (mounted) {
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String avatarFullUrl = '';
    if (user.avatarUrl.isNotEmpty) {
      if (user.avatarUrl.startsWith('http')) {
        avatarFullUrl = user.avatarUrl;
      } else {
        avatarFullUrl = '${AppConstants.uploadBaseUrl}${user.avatarUrl}';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: AppTheme.spacingMd,
          right: AppTheme.spacingMd,
          bottom: AppTheme.spacing2xl,
        ),
        child: Column(
          children: [
            const SizedBox(height: AppTheme.spacingLg),
            // Avatar Header
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primaryContainer,
                        width: 4,
                      ),
                      boxShadow: AppTheme.shadowSubtle,
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      backgroundImage: avatarFullUrl.isNotEmpty
                          ? CachedNetworkImageProvider(avatarFullUrl)
                          : null,
                      child: avatarFullUrl.isEmpty
                          ? Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'U',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.surface, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 18,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    user.role == 'admin'
                        ? Icons.admin_panel_settings_rounded
                        : user.role == 'faculty'
                            ? Icons.school_rounded
                            : Icons.person_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Text(
                    user.role.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingXl),

            // Info Card or Edit Form
            AppCard(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isEditing) ...[
                    _buildInfoRow(context, Icons.person_outline_rounded, 'Name', user.name),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                      child: Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    _buildInfoRow(context, Icons.email_outlined, 'Email', user.email),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                      child: Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    _buildInfoRow(
                        context,
                        Icons.domain_outlined,
                        'Branch',
                        user.branch.isNotEmpty ? user.branch : 'Not set'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                      child: Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    _buildInfoRow(
                        context,
                        Icons.calendar_today_outlined,
                        'Year',
                        user.year != null ? 'Year ${user.year}' : 'Not set'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                      child: Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    _buildInfoRow(
                        context,
                        Icons.notes_rounded,
                        'Bio',
                        user.bio.isNotEmpty ? user.bio : 'No bio added yet'),
                  ] else ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    TextFormField(
                      controller: _branchController,
                      decoration: const InputDecoration(
                        labelText: 'Branch',
                        prefixIcon: Icon(Icons.domain_outlined),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXl),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton.primary(
                        text: 'Save Profile',
                        isLoading: _isSaving,
                        onPressed: _saveProfile,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton.secondary(
                        text: 'Cancel',
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                          });
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing2xl),
            
            // Logout Action
            if (!_isEditing)
              SizedBox(
                width: double.infinity,
                child: AppButton.secondary(
                  text: 'Log Out',
                  icon: Icons.logout_rounded,
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 22),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

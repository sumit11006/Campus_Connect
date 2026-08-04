import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;

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
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          children: [
            // Avatar Header
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: avatarFullUrl.isNotEmpty
                        ? NetworkImage(avatarFullUrl)
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Role Badge
            Chip(
              avatar: Icon(
                user.role == 'admin'
                    ? Icons.admin_panel_settings
                    : user.role == 'faculty'
                        ? Icons.school
                        : Icons.person,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              label: Text(
                user.role.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              backgroundColor: theme.colorScheme.primaryContainer,
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // Info Card or Edit Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isEditing) ...[
                      _buildInfoRow(context, Icons.person_outline, 'Name', user.name),
                      const Divider(height: 24),
                      _buildInfoRow(context, Icons.email_outlined, 'Email', user.email),
                      const Divider(height: 24),
                      _buildInfoRow(
                          context,
                          Icons.domain_outlined,
                          'Branch',
                          user.branch.isNotEmpty ? user.branch : 'Not set'),
                      const Divider(height: 24),
                      _buildInfoRow(
                          context,
                          Icons.calendar_today_outlined,
                          'Year',
                          user.year != null ? 'Year ${user.year}' : 'Not set'),
                      const Divider(height: 24),
                      _buildInfoRow(
                          context,
                          Icons.notes_outlined,
                          'Bio',
                          user.bio.isNotEmpty ? user.bio : 'No bio added yet'),
                    ] else ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      TextFormField(
                        controller: _branchController,
                        decoration: const InputDecoration(
                          labelText: 'Branch',
                          prefixIcon: Icon(Icons.domain_outlined),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      TextFormField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          prefixIcon: Icon(Icons.notes_outlined),
                        ),
                      ),
                    ],
                  ],
                ),
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
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

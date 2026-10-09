import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/club.dart';
import '../../providers/club_provider.dart';
import '../../core/theme.dart';
import '../../design_system/app_button.dart';
import '../../design_system/app_card.dart';

class ClubDetailScreen extends ConsumerStatefulWidget {
  final String clubId;

  const ClubDetailScreen({super.key, required this.clubId});

  @override
  ConsumerState<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends ConsumerState<ClubDetailScreen> {
  bool _isLoading = true;
  Club? _club;
  bool _isMember = false;
  List<ClubMemberItem> _members = [];
  String? _error;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClubDetails();
  }

  Future<void> _loadClubDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(clubServiceProvider);
      final details = await service.getClubById(widget.clubId);
      final membersList = await service.getClubMembers(widget.clubId);

      setState(() {
        _club = details['club'] as Club;
        _isMember = details['isMember'] as bool;
        _members = membersList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleMembership() async {
    if (_club == null) return;
    final service = ref.read(clubServiceProvider);

    setState(() {
      _isActionLoading = true;
    });

    try {
      if (_isMember) {
        final newCount = await service.leaveClub(_club!.id);
        setState(() {
          _isMember = false;
          _club = Club(
            id: _club!.id,
            name: _club!.name,
            description: _club!.description,
            category: _club!.category,
            bannerUrl: _club!.bannerUrl,
            coordinatorId: _club!.coordinatorId,
            coordinatorName: _club!.coordinatorName,
            memberCount: newCount,
            createdAt: _club!.createdAt,
          );
        });
      } else {
        final newCount = await service.joinClub(_club!.id);
        setState(() {
          _isMember = true;
          _club = Club(
            id: _club!.id,
            name: _club!.name,
            description: _club!.description,
            category: _club!.category,
            bannerUrl: _club!.bannerUrl,
            coordinatorId: _club!.coordinatorId,
            coordinatorName: _club!.coordinatorName,
            memberCount: newCount,
            createdAt: _club!.createdAt,
          );
        });
      }
      _loadClubDetails(); // Reload members list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      setState(() {
        _isActionLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _club == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Club Details')),
        body: Center(child: Text(_error ?? 'Club not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppTheme.spacing2xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            if (_club!.bannerUrl.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  boxShadow: AppTheme.shadowSubtle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  child: CachedNetworkImage(
                    imageUrl: _club!.bannerUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: theme.colorScheme.surfaceContainerHighest),
                    errorWidget: (context, url, error) => _buildFallbackHero(theme),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                child: _buildFallbackHero(theme),
              ),
            
            const SizedBox(height: AppTheme.spacingLg),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Text(
                      _club!.category.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    _club!.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Row(
                    children: [
                      Icon(Icons.people_alt_rounded, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: AppTheme.spacingXs),
                      Text(
                        '${_club!.memberCount} members',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Description
                  Text('About', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    _club!.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),

                  // Members Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Members (${_members.length})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  if (_members.isEmpty)
                    const Text('No members yet.')
                  else
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _members.length,
                        separatorBuilder: (context, index) => Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
                        itemBuilder: (context, index) {
                          final m = _members[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: Text(
                                m.userName.isNotEmpty ? m.userName[0].toUpperCase() : 'M',
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              m.userName.isNotEmpty ? m.userName : 'Member',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(m.userEmail, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: m.role == 'coordinator' ? theme.colorScheme.tertiaryContainer : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              ),
                              child: Text(
                                m.role.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: m.role == 'coordinator' ? theme.colorScheme.onTertiaryContainer : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: _isMember
              ? AppButton.secondary(
                  text: 'Leave Club',
                  icon: Icons.check_circle_rounded,
                  isLoading: _isActionLoading,
                  onPressed: _toggleMembership,
                )
              : AppButton.primary(
                  text: 'Join Club',
                  isLoading: _isActionLoading,
                  onPressed: _toggleMembership,
                ),
        ),
      ),
    );
  }

  Widget _buildFallbackHero(ThemeData theme) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.tertiary,
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.groups_rounded, size: 64, color: Colors.white.withValues(alpha: 0.2)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/club.dart';
import '../../providers/club_provider.dart';

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
      _loadClubDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
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
        title: Text(_club!.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Card
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  _club!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Join/Leave Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _toggleMembership,
                icon: Icon(_isMember ? Icons.check : Icons.group_add),
                label: Text(_isMember ? 'Joined' : 'Join Club'),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      _isMember ? Colors.grey[700] : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text('About', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(_club!.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),

            // Members Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Members (${_members.length})',
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final m = _members[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      m.userName.isNotEmpty ? m.userName[0].toUpperCase() : 'M',
                    ),
                  ),
                  title: Text(m.userName.isNotEmpty ? m.userName : 'Member'),
                  subtitle: Text(m.userEmail),
                  trailing: Chip(
                    label: Text(
                      m.role,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

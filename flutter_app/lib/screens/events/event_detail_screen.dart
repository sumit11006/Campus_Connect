import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../../core/theme.dart';
import '../../design_system/app_button.dart';
import '../../design_system/app_card.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isLoading = true;
  CampusEvent? _event;
  bool _isRegistered = false;
  String? _error;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(eventServiceProvider);
      final details = await service.getEventById(widget.eventId);

      setState(() {
        _event = details['event'] as CampusEvent;
        _isRegistered = details['isRegistered'] as bool;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleRegistration() async {
    if (_event == null) return;
    final service = ref.read(eventServiceProvider);

    setState(() {
      _isActionLoading = true;
    });

    try {
      if (_isRegistered) {
        final newCount = await service.unregisterFromEvent(_event!.id);
        setState(() {
          _isRegistered = false;
          _event = CampusEvent(
            id: _event!.id,
            title: _event!.title,
            description: _event!.description,
            date: _event!.date,
            location: _event!.location,
            clubId: _event!.clubId,
            clubName: _event!.clubName,
            createdBy: _event!.createdBy,
            creatorName: _event!.creatorName,
            imageUrl: _event!.imageUrl,
            capacity: _event!.capacity,
            registrationCount: newCount,
            createdAt: _event!.createdAt,
          );
        });
      } else {
        final newCount = await service.registerForEvent(_event!.id);
        setState(() {
          _isRegistered = true;
          _event = CampusEvent(
            id: _event!.id,
            title: _event!.title,
            description: _event!.description,
            date: _event!.date,
            location: _event!.location,
            clubId: _event!.clubId,
            clubName: _event!.clubName,
            createdBy: _event!.createdBy,
            creatorName: _event!.creatorName,
            imageUrl: _event!.imageUrl,
            capacity: _event!.capacity,
            registrationCount: newCount,
            createdAt: _event!.createdAt,
          );
        });
      }
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
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy • h:mm a');

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Details')),
        body: Center(child: Text(_error ?? 'Event not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppTheme.spacing2xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            if (_event!.imageUrl.isNotEmpty)
              Container(
                height: 240,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  boxShadow: AppTheme.shadowSubtle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  child: CachedNetworkImage(
                    imageUrl: _event!.imageUrl,
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
                  if (_event!.clubName != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        _event!.clubName!.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                  ],
                  Text(
                    _event!.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Metadata Cards
                  AppCard(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              ),
                              child: Icon(Icons.calendar_today_rounded, color: theme.colorScheme.secondary, size: 20),
                            ),
                            const SizedBox(width: AppTheme.spacingMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date & Time', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                  Text(dateFormat.format(_event!.date), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              ),
                              child: Icon(Icons.location_on_rounded, color: theme.colorScheme.primary, size: 20),
                            ),
                            const SizedBox(width: AppTheme.spacingMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Location', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                  Text(_event!.location, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Description
                  Text('About Event', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    _event!.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),

                  // Attendees
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(Icons.people_alt_rounded, size: 16, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Text(
                        '${_event!.registrationCount} attendees going',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
          child: _isRegistered
              ? AppButton.secondary(
                  text: 'Cancel Registration',
                  icon: Icons.check_circle_rounded,
                  isLoading: _isActionLoading,
                  onPressed: _toggleRegistration,
                )
              : AppButton.primary(
                  text: 'Register Now',
                  isLoading: _isActionLoading,
                  onPressed: _toggleRegistration,
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
        gradient: AppTheme.primaryGradient,
      ),
      child: Center(
        child: Icon(Icons.event_note_rounded, size: 64, color: Colors.white.withValues(alpha: 0.2)),
      ),
    );
  }
}

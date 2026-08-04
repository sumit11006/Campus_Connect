import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';

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
        title: Text(_event!.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & Time Banner Card
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_event!.clubName != null) ...[
                    Chip(
                      label: Text(
                        _event!.clubName!,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: Colors.white24,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    _event!.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        dateFormat.format(_event!.date),
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _event!.location,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Register/Unregister Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _toggleRegistration,
                icon: Icon(_isRegistered ? Icons.check_circle : Icons.event_available),
                label: Text(_isRegistered ? 'Registered' : 'Register for Event'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: _isRegistered
                      ? Colors.grey[700]
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Event Info
            Text('Description', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(_event!.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),

            Row(
              children: [
                Icon(Icons.people, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '${_event!.registrationCount} attendees registered',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

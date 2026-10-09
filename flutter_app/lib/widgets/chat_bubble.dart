import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../core/theme.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: AppTheme.spacingMd),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          boxShadow: isMe ? [] : AppTheme.shadowSubtle,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppTheme.radiusLg),
            topRight: const Radius.circular(AppTheme.radiusLg),
            bottomLeft: Radius.circular(isMe ? AppTheme.radiusLg : 4),
            bottomRight: Radius.circular(isMe ? 4 : AppTheme.radiusLg),
          ),
          border: isMe ? null : Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe && message.senderName.isNotEmpty) ...[
              Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message.createdAt != null
                  ? timeFormat.format(message.createdAt!)
                  : '',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isMe
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

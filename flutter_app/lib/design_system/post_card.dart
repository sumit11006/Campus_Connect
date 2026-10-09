import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/post.dart';
import 'app_card.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String avatarUrl = '';
    if (post.authorAvatar.isNotEmpty) {
      avatarUrl = post.authorAvatar.startsWith('http')
          ? post.authorAvatar
          : '${AppConstants.uploadBaseUrl}${post.authorAvatar}';
    }

    String imageUrl = '';
    if (post.imageUrl.isNotEmpty) {
      imageUrl = post.imageUrl.startsWith('http')
          ? post.imageUrl
          : '${AppConstants.uploadBaseUrl}${post.imageUrl}';
    }

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Time, Role
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primaryContainer, width: 2),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage: avatarUrl.isNotEmpty
                      ? CachedNetworkImageProvider(avatarUrl)
                      : null,
                  child: avatarUrl.isEmpty
                      ? Text(
                          post.authorName.isNotEmpty
                              ? post.authorName[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.authorName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (post.isPinned) ...[
                          const SizedBox(width: AppTheme.spacingXs),
                          Icon(
                            Icons.push_pin,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                        const SizedBox(width: AppTheme.spacingXs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Text(
                            post.authorRole.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      post.createdAt != null
                          ? timeago.format(post.createdAt!)
                          : 'Just now',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Post Content Text
          Text(
            post.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),

          // Image Attachment (if present)
          if (imageUrl.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingXs),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            ),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
            child: Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
          ),

          // Action Buttons: Like & Comment
          Row(
            children: [
              InkWell(
                onTap: onLike,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: AppTheme.spacingXs),
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 20,
                        color: post.isLiked ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppTheme.spacingXs),
                      Text(
                        '${post.likesCount}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: post.isLiked ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingLg),
              InkWell(
                onTap: onComment,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: AppTheme.spacingXs),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppTheme.spacingXs),
                      Text(
                        '${post.commentsCount}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

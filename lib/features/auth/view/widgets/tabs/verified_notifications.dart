import 'package:flutter/material.dart';
import '../../../../../core/models/notification.dart';
import 'mock_data.dart';
import 'package:lite_x/core/theme/palette.dart';
import '../empty/verified_empty.dart';

class VerifiedTab extends StatefulWidget {
  const VerifiedTab({super.key});

  @override
  State<VerifiedTab> createState() => _VerifiedTabState();
}

class _VerifiedTabState extends State<VerifiedTab>
    with AutomaticKeepAliveClientMixin {
  final List<AppNotification> _notifications = []; // Set to empty for demo

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Palette.background,
      child: _notifications.isEmpty
          ? const VerifiedEmptyStateWidget()
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: verifiedNotifications.length,
              itemBuilder: (context, index) {
                return _VerifiedNotificationCard(
                    notification: verifiedNotifications[index]);
              },
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _VerifiedNotificationCard extends StatefulWidget {
  final AppNotification notification;

  const _VerifiedNotificationCard({required this.notification});

  @override
  State<_VerifiedNotificationCard> createState() =>
      _VerifiedNotificationCardState();
}

class _VerifiedNotificationCardState extends State<_VerifiedNotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Material(
          color: Palette.cardBackground,
          borderRadius: BorderRadius.circular(16.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(16.0),
            onTap: () {},
            splashColor: Palette.primaryHover.withOpacity(0.2),
            highlightColor: Palette.primaryHover.withOpacity(0.1),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                border: Border(
                  left: BorderSide(color: Palette.primary, width: 4.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Palette.primary.withOpacity(0.5),
                              blurRadius: 8.0,
                              spreadRadius: 1.0,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              NetworkImage(widget.notification.user.avatarUrl),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.notification.user.username,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Palette.textWhite,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                Icon(
                                  Icons.verified,
                                  color: Palette.verified,
                                  size: 16,
                                ),
                              ],
                            ),
                            Text(
                              widget.notification.content,
                              style: TextStyle(color: Palette.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.notification.timestamp,
                        style: TextStyle(
                          color: Palette.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (widget.notification.postSnippet != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Palette.modalBackground,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          widget.notification.postSnippet!,
                          style: TextStyle(color: Palette.textPrimary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';

enum NotificationType {
  applicationApproved,
  applicationRejected,
  shortlistAdded,
  assignmentCreated,
  assignmentReminder,
  documentExpiring,
  newJobMatching,
  unknown;

  static NotificationType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'APPLICATION_APPROVED':
        return NotificationType.applicationApproved;
      case 'APPLICATION_REJECTED':
        return NotificationType.applicationRejected;
      case 'SHORTLIST_ADDED':
        return NotificationType.shortlistAdded;
      case 'ASSIGNMENT_CREATED':
        return NotificationType.assignmentCreated;
      case 'ASSIGNMENT_REMINDER':
        return NotificationType.assignmentReminder;
      case 'DOCUMENT_EXPIRING':
        return NotificationType.documentExpiring;
      case 'NEW_JOB_MATCHING':
        return NotificationType.newJobMatching;
      default:
        return NotificationType.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.applicationApproved:
        return 'Отклик одобрен';
      case NotificationType.applicationRejected:
        return 'Отклик отклонён';
      case NotificationType.shortlistAdded:
        return 'Добавлен в шортлист';
      case NotificationType.assignmentCreated:
        return 'Назначение создано';
      case NotificationType.assignmentReminder:
        return 'Напоминание о смене';
      case NotificationType.documentExpiring:
        return 'Документ истекает';
      case NotificationType.newJobMatching:
        return 'Новая вакансия';
      case NotificationType.unknown:
        return 'Уведомление';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.applicationApproved:
        return Icons.check_circle;
      case NotificationType.applicationRejected:
        return Icons.cancel;
      case NotificationType.shortlistAdded:
        return Icons.star;
      case NotificationType.assignmentCreated:
        return Icons.event_available;
      case NotificationType.assignmentReminder:
        return Icons.alarm;
      case NotificationType.documentExpiring:
        return Icons.warning;
      case NotificationType.newJobMatching:
        return Icons.work;
      case NotificationType.unknown:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.applicationApproved:
        return const Color(0xFF22C55E);
      case NotificationType.applicationRejected:
        return const Color(0xFFEF4444);
      case NotificationType.shortlistAdded:
        return const Color(0xFFF59E0B);
      case NotificationType.assignmentCreated:
        return const Color(0xFF3B82F6);
      case NotificationType.assignmentReminder:
        return const Color(0xFFF59E0B);
      case NotificationType.documentExpiring:
        return const Color(0xFFEF4444);
      case NotificationType.newJobMatching:
        return const Color(0xFFA855F7);
      case NotificationType.unknown:
        return const Color(0xFF6B7280);
    }
  }
}

class AppNotification {
  final int id;
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? 0,
      type: NotificationType.fromString(json['type'] ?? ''),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] ?? '',
      data: json['data'],
    );
  }
}

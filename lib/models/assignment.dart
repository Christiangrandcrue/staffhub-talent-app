enum AssignmentStatus {
  pending,
  confirmed,
  checkedIn,
  completed,
  noShow,
  cancelled;

  static AssignmentStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AssignmentStatus.pending;
      case 'CONFIRMED':
        return AssignmentStatus.confirmed;
      case 'CHECKED_IN':
        return AssignmentStatus.checkedIn;
      case 'COMPLETED':
        return AssignmentStatus.completed;
      case 'NO_SHOW':
        return AssignmentStatus.noShow;
      case 'CANCELLED':
        return AssignmentStatus.cancelled;
      default:
        return AssignmentStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case AssignmentStatus.pending:
        return 'Ожидает';
      case AssignmentStatus.confirmed:
        return 'Подтверждено';
      case AssignmentStatus.checkedIn:
        return 'На месте';
      case AssignmentStatus.completed:
        return 'Завершено';
      case AssignmentStatus.noShow:
        return 'Неявка';
      case AssignmentStatus.cancelled:
        return 'Отменено';
    }
  }
}

class Assignment {
  final int id;
  final int jobPostId;
  final AssignmentStatus status;
  final String role;
  final String scheduledStart;
  final String scheduledEnd;
  final int confirmedRate;
  final String rateCurrency;
  final String jobTitle;
  final String venueName;
  final String city;
  final String eventDate;
  final String? dressCode;

  Assignment({
    required this.id,
    required this.jobPostId,
    required this.status,
    required this.role,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.confirmedRate,
    this.rateCurrency = 'AED',
    required this.jobTitle,
    required this.venueName,
    required this.city,
    required this.eventDate,
    this.dressCode,
  });

  DateTime get startDateTime => DateTime.parse(scheduledStart);
  DateTime get endDateTime => DateTime.parse(scheduledEnd);

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] ?? 0,
      jobPostId: json['job_post_id'] ?? 0,
      status: AssignmentStatus.fromString(json['status'] ?? 'PENDING'),
      role: json['role'] ?? '',
      scheduledStart: json['scheduled_start'] ?? '',
      scheduledEnd: json['scheduled_end'] ?? '',
      confirmedRate: json['confirmed_rate'] ?? 0,
      rateCurrency: json['rate_currency'] ?? 'AED',
      jobTitle: json['job_title'] ?? '',
      venueName: json['venue_name'] ?? '',
      city: json['city'] ?? '',
      eventDate: json['event_date'] ?? '',
      dressCode: json['dress_code'],
    );
  }
}

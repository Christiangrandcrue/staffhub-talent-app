enum ApplicationStatus {
  pending,
  shortlisted,
  approved,
  confirmed,
  rejected,
  withdrawn;

  static ApplicationStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return ApplicationStatus.pending;
      case 'SHORTLISTED':
        return ApplicationStatus.shortlisted;
      case 'APPROVED':
        return ApplicationStatus.approved;
      case 'CONFIRMED':
        return ApplicationStatus.confirmed;
      case 'REJECTED':
        return ApplicationStatus.rejected;
      case 'WITHDRAWN':
        return ApplicationStatus.withdrawn;
      default:
        return ApplicationStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'На рассмотрении';
      case ApplicationStatus.shortlisted:
        return 'В шортлисте';
      case ApplicationStatus.approved:
        return 'Одобрено';
      case ApplicationStatus.confirmed:
        return 'Подтверждено';
      case ApplicationStatus.rejected:
        return 'Отклонено';
      case ApplicationStatus.withdrawn:
        return 'Отозвано';
    }
  }
}

class Application {
  final int id;
  final int jobPostId;
  final ApplicationStatus status;
  final String? coverMessage;
  final String createdAt;
  final String jobTitle;
  final String venueName;
  final String city;
  final String eventDate;
  final int ratePerHour;
  final String rateCurrency;
  final String jobStatus;

  Application({
    required this.id,
    required this.jobPostId,
    required this.status,
    this.coverMessage,
    required this.createdAt,
    required this.jobTitle,
    required this.venueName,
    required this.city,
    required this.eventDate,
    required this.ratePerHour,
    this.rateCurrency = 'AED',
    required this.jobStatus,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] ?? 0,
      jobPostId: json['job_post_id'] ?? 0,
      status: ApplicationStatus.fromString(json['status'] ?? 'PENDING'),
      coverMessage: json['cover_message'],
      createdAt: json['created_at'] ?? '',
      jobTitle: json['job_title'] ?? '',
      venueName: json['venue_name'] ?? '',
      city: json['city'] ?? '',
      eventDate: json['event_date'] ?? '',
      ratePerHour: json['rate_per_hour'] ?? 0,
      rateCurrency: json['rate_currency'] ?? 'AED',
      jobStatus: json['job_status'] ?? '',
    );
  }
}

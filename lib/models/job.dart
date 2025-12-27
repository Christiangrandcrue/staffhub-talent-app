class Job {
  final int id;
  final String title;
  final String description;
  final String roleType;
  final String venueName;
  final String? venueAddress;
  final String city;
  final String? country;
  final String eventDate;
  final String startTime;
  final String endTime;
  final int durationHours;
  final int slotsTotal;
  final int slotsFilled;
  final String? genderRequired;
  final int? minHeightCm;
  final int? maxHeightCm;
  final List<String> languagesRequired;
  final bool requiresEmiratesId;
  final List<String> skillsRequired;
  final String? dressCode;
  final int ratePerHour;
  final String rateCurrency;
  final String? paymentTerms;
  final String? specialRequirements;
  final String? contactPerson;
  final String? contactPhone;
  final String? publishedBy;
  final bool isFeatured;
  final String? publishedAt;
  final bool hasApplied;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.roleType,
    required this.venueName,
    this.venueAddress,
    required this.city,
    this.country,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.slotsTotal,
    required this.slotsFilled,
    this.genderRequired,
    this.minHeightCm,
    this.maxHeightCm,
    this.languagesRequired = const [],
    this.requiresEmiratesId = false,
    this.skillsRequired = const [],
    this.dressCode,
    required this.ratePerHour,
    this.rateCurrency = 'AED',
    this.paymentTerms,
    this.specialRequirements,
    this.contactPerson,
    this.contactPhone,
    this.publishedBy,
    this.isFeatured = false,
    this.publishedAt,
    this.hasApplied = false,
  });

  int get slotsAvailable => slotsTotal - slotsFilled;
  int get totalEarning => ratePerHour * durationHours;

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      roleType: json['role_type'] ?? '',
      venueName: json['venue_name'] ?? '',
      venueAddress: json['venue_address'],
      city: json['city'] ?? '',
      country: json['country'],
      eventDate: json['event_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      durationHours: json['duration_hours'] ?? 0,
      slotsTotal: json['slots_total'] ?? 0,
      slotsFilled: json['slots_filled'] ?? 0,
      genderRequired: json['gender_required'],
      minHeightCm: json['min_height_cm'],
      maxHeightCm: json['max_height_cm'],
      languagesRequired: json['languages_required'] != null
          ? List<String>.from(json['languages_required'])
          : [],
      requiresEmiratesId: json['requires_emirates_id'] ?? false,
      skillsRequired: json['skills_required'] != null
          ? List<String>.from(json['skills_required'])
          : [],
      dressCode: json['dress_code'],
      ratePerHour: json['rate_per_hour'] ?? 0,
      rateCurrency: json['rate_currency'] ?? 'AED',
      paymentTerms: json['payment_terms'],
      specialRequirements: json['special_requirements'],
      contactPerson: json['contact_person'],
      contactPhone: json['contact_phone'],
      publishedBy: json['published_by'],
      isFeatured: json['is_featured'] ?? false,
      publishedAt: json['published_at'],
      hasApplied: json['has_applied'] ?? false,
    );
  }
}

class JobsResponse {
  final List<Job> jobs;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  JobsResponse({
    required this.jobs,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory JobsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? [];
    final meta = json['meta'] ?? {};
    
    return JobsResponse(
      jobs: data.map((j) => Job.fromJson(j)).toList(),
      total: meta['total'] ?? 0,
      page: meta['page'] ?? 1,
      limit: meta['limit'] ?? 20,
      totalPages: meta['total_pages'] ?? 1,
    );
  }
}

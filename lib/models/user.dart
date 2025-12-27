class User {
  final int id;
  final String email;
  final String role;
  final String status;
  final String? phone;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      role: json['role'] ?? 'TALENT',
      status: json['status'] ?? 'ACTIVE',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'status': status,
      'phone': phone,
    };
  }
}

class TalentProfile {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final String? gender;
  final String? nationality;
  final int? heightCm;
  final int? weightKg;
  final String? city;
  final String? country;
  final List<String> languages;
  final List<String> skills;
  final int? experienceYears;
  final int? hourlyRateMin;
  final int? hourlyRateMax;
  final bool emiratesIdValid;
  final String? emiratesIdExpiry;
  final double avgRating;
  final int totalRatings;
  final String? bio;

  TalentProfile({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    this.gender,
    this.nationality,
    this.heightCm,
    this.weightKg,
    this.city,
    this.country,
    this.languages = const [],
    this.skills = const [],
    this.experienceYears,
    this.hourlyRateMin,
    this.hourlyRateMax,
    this.emiratesIdValid = false,
    this.emiratesIdExpiry,
    this.avgRating = 0.0,
    this.totalRatings = 0,
    this.bio,
  });

  String get fullName => '$firstName $lastName';

  factory TalentProfile.fromJson(Map<String, dynamic> json) {
    return TalentProfile(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      photoUrl: json['photo_url'],
      gender: json['gender'],
      nationality: json['nationality'],
      heightCm: json['height_cm'],
      weightKg: json['weight_kg'],
      city: json['city'],
      country: json['country'],
      languages: json['languages'] != null 
          ? List<String>.from(json['languages']) 
          : [],
      skills: json['skills'] != null 
          ? List<String>.from(json['skills']) 
          : [],
      experienceYears: json['experience_years'],
      hourlyRateMin: json['hourly_rate_min'],
      hourlyRateMax: json['hourly_rate_max'],
      emiratesIdValid: json['emirates_id_valid'] == 1 || json['emirates_id_valid'] == true,
      emiratesIdExpiry: json['emirates_id_expiry'],
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'photo_url': photoUrl,
      'gender': gender,
      'nationality': nationality,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'city': city,
      'country': country,
      'languages': languages,
      'skills': skills,
      'experience_years': experienceYears,
      'hourly_rate_min': hourlyRateMin,
      'hourly_rate_max': hourlyRateMax,
      'emirates_id_valid': emiratesIdValid ? 1 : 0,
      'emirates_id_expiry': emiratesIdExpiry,
      'avg_rating': avgRating,
      'total_ratings': totalRatings,
      'bio': bio,
    };
  }
}

class AuthResponse {
  final String token;
  final User user;
  final TalentProfile profile;

  AuthResponse({
    required this.token,
    required this.user,
    required this.profile,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return AuthResponse(
      token: data['token'] ?? '',
      user: User.fromJson(data['user'] ?? {}),
      profile: TalentProfile.fromJson(data['profile'] ?? {}),
    );
  }
}

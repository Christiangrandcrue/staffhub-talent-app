enum DocumentType {
  emiratesId,
  passport,
  visa,
  policeClearance;

  static DocumentType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'EMIRATES_ID':
        return DocumentType.emiratesId;
      case 'PASSPORT':
        return DocumentType.passport;
      case 'VISA':
        return DocumentType.visa;
      case 'POLICE_CLEARANCE':
        return DocumentType.policeClearance;
      default:
        return DocumentType.passport;
    }
  }

  String get displayName {
    switch (this) {
      case DocumentType.emiratesId:
        return 'Emirates ID';
      case DocumentType.passport:
        return 'Паспорт';
      case DocumentType.visa:
        return 'Виза';
      case DocumentType.policeClearance:
        return 'Справка о несудимости';
    }
  }

  String get icon {
    switch (this) {
      case DocumentType.emiratesId:
        return '🪪';
      case DocumentType.passport:
        return '📕';
      case DocumentType.visa:
        return '📄';
      case DocumentType.policeClearance:
        return '📋';
    }
  }
}

enum DocumentStatus {
  valid,
  expired,
  pending,
  rejected;

  static DocumentStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'VALID':
        return DocumentStatus.valid;
      case 'EXPIRED':
        return DocumentStatus.expired;
      case 'PENDING':
        return DocumentStatus.pending;
      case 'REJECTED':
        return DocumentStatus.rejected;
      default:
        return DocumentStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case DocumentStatus.valid:
        return 'Действителен';
      case DocumentStatus.expired:
        return 'Просрочен';
      case DocumentStatus.pending:
        return 'На проверке';
      case DocumentStatus.rejected:
        return 'Отклонён';
    }
  }
}

class TalentDocument {
  final int id;
  final DocumentType documentType;
  final String? documentNumber;
  final String? expiryDate;
  final DocumentStatus status;
  final String? fileUrl;

  TalentDocument({
    required this.id,
    required this.documentType,
    this.documentNumber,
    this.expiryDate,
    required this.status,
    this.fileUrl,
  });

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    try {
      final expiry = DateTime.parse(expiryDate!);
      return expiry.difference(DateTime.now()).inDays;
    } catch (_) {
      return null;
    }
  }

  bool get isExpiringSoon {
    final days = daysUntilExpiry;
    return days != null && days <= 30 && days > 0;
  }

  bool get isExpired {
    final days = daysUntilExpiry;
    return days != null && days <= 0;
  }

  factory TalentDocument.fromJson(Map<String, dynamic> json) {
    return TalentDocument(
      id: json['id'] ?? 0,
      documentType: DocumentType.fromString(json['document_type'] ?? ''),
      documentNumber: json['document_number'],
      expiryDate: json['expiry_date'],
      status: DocumentStatus.fromString(json['status'] ?? 'PENDING'),
      fileUrl: json['file_url'],
    );
  }
}

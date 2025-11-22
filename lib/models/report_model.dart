import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laporin/models/enums.dart';
import 'package:laporin/models/location_model.dart';
import 'package:laporin/models/media_model.dart';
import 'package:laporin/models/user_model.dart';

// Helper function to parse DateTime from Firestore Timestamp or String
DateTime _parseDateTime(dynamic value) {
  if (value == null) {
    return DateTime.now();
  }
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.parse(value);
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.now();
}

// Helper function to parse nullable DateTime
DateTime? _parseNullableDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.parse(value);
  }
  if (value is DateTime) {
    return value;
  }
  return null;
}

class Report {
  final String id;
  final String title;
  final String description;
  final ReportCategory category;
  final ReportPriority priority;
  final ReportStatus status;
  final User reporter;
  final LocationData? location;
  final List<MediaFile> media;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? adminNote;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime? resolvedAt;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.reporter,
    this.location,
    required this.media,
    required this.createdAt,
    required this.updatedAt,
    this.adminNote,
    this.approvedBy,
    this.approvedAt,
    this.resolvedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: ReportCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ReportCategory.lainnya,
      ),
      priority: ReportPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => ReportPriority.medium,
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.inProgress,
      ),
      reporter: json['reporter'] != null
          ? User.fromJson(json['reporter'] as Map<String, dynamic>)
          : User(id: '', name: 'Unknown', email: '', role: UserRole.mahasiswa, createdAt: DateTime.now()),
      location: json['location'] != null
          ? LocationData.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      media: (json['media'] as List<dynamic>?)
              ?.map((e) => MediaFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      adminNote: json['admin_note'] as String?,
      approvedBy: json['approved_by'] as String?,
      approvedAt: _parseNullableDateTime(json['approved_at']),
      resolvedAt: _parseNullableDateTime(json['resolved_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'status': status.name,
      'reporter': reporter.toJson(),
      'location': location?.toJson(),
      'media': media.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'admin_note': adminNote,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  Report copyWith({
    String? id,
    String? title,
    String? description,
    ReportCategory? category,
    ReportPriority? priority,
    ReportStatus? status,
    User? reporter,
    LocationData? location,
    List<MediaFile>? media,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminNote,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? resolvedAt,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      reporter: reporter ?? this.reporter,
      location: location ?? this.location,
      media: media ?? this.media,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminNote: adminNote ?? this.adminNote,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  String get statusBadgeText {
    return status.displayName;
  }

  bool get canBeEdited {
    return status == ReportStatus.inProgress;
  }

  bool get canBeApproved {
    return status == ReportStatus.inProgress;
  }

  bool get canBeRejected {
    return status == ReportStatus.inProgress;
  }

  bool get canBeResolved {
    return status == ReportStatus.approved || status == ReportStatus.inProgress;
  }
}

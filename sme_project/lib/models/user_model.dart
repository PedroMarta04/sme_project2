// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String provider;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final UserSettings settings;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.provider,
    required this.createdAt,
    required this.lastLoginAt,
    required this.settings,
  });

  // From Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'User',
      photoURL: data['photoURL'],
      provider: data['provider'] ?? 'email',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      settings: UserSettings.fromMap(data['settings'] ?? {}),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'provider': provider,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'settings': settings.toMap(),
    };
  }

  // Copy with
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? provider,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    UserSettings? settings,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      settings: settings ?? this.settings,
    );
  }
}

class UserSettings {
  final String baseCurrency;
  final bool budgetAlerts;
  final String theme; // 'light', 'dark', 'system'
  final bool biometricEnabled;
  final bool notificationsEnabled;
  final String dateFormat; // 'MM/dd/yyyy', 'dd/MM/yyyy'
  final String language;

  UserSettings({
    this.baseCurrency = 'USD',
    this.budgetAlerts = true,
    this.theme = 'system',
    this.biometricEnabled = false,
    this.notificationsEnabled = true,
    this.dateFormat = 'MM/dd/yyyy',
    this.language = 'en',
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      baseCurrency: map['baseCurrency'] ?? 'USD',
      budgetAlerts: map['budgetAlerts'] ?? true,
      theme: map['theme'] ?? 'system',
      biometricEnabled: map['biometricEnabled'] ?? false,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      dateFormat: map['dateFormat'] ?? 'MM/dd/yyyy',
      language: map['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'baseCurrency': baseCurrency,
      'budgetAlerts': budgetAlerts,
      'theme': theme,
      'biometricEnabled': biometricEnabled,
      'notificationsEnabled': notificationsEnabled,
      'dateFormat': dateFormat,
      'language': language,
    };
  }

  UserSettings copyWith({
    String? baseCurrency,
    bool? budgetAlerts,
    String? theme,
    bool? biometricEnabled,
    bool? notificationsEnabled,
    String? dateFormat,
    String? language,
  }) {
    return UserSettings(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      theme: theme ?? this.theme,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dateFormat: dateFormat ?? this.dateFormat,
      language: language ?? this.language,
    );
  }
}
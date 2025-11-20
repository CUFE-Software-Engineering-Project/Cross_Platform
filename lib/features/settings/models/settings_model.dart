class SettingsModel {
  final String username;
  final bool protectedAccount;
  final bool allowTagging;
  final bool directMessagesFromEveryone;
  final bool personalizedAds;
  final bool dataSharingWithPartners;
  final bool spacesEnabled;
  final List<String> mutedWords;
  final DateTime? lastUpdated;

  const SettingsModel({
    required this.username,
    required this.protectedAccount,
    required this.allowTagging,
    required this.directMessagesFromEveryone,
    required this.personalizedAds,
    required this.dataSharingWithPartners,
    required this.spacesEnabled,
    required this.mutedWords,
    required this.lastUpdated,
  });

  SettingsModel copyWith({
    String? username,
    bool? protectedAccount,
    bool? allowTagging,
    bool? directMessagesFromEveryone,
    bool? personalizedAds,
    bool? dataSharingWithPartners,
    bool? spacesEnabled,
    List<String>? mutedWords,
    DateTime? lastUpdated,
  }) {
    return SettingsModel(
      username: username ?? this.username,
      protectedAccount: protectedAccount ?? this.protectedAccount,
      allowTagging: allowTagging ?? this.allowTagging,
      directMessagesFromEveryone:
          directMessagesFromEveryone ?? this.directMessagesFromEveryone,
      personalizedAds: personalizedAds ?? this.personalizedAds,
      dataSharingWithPartners:
          dataSharingWithPartners ?? this.dataSharingWithPartners,
      spacesEnabled: spacesEnabled ?? this.spacesEnabled,
      mutedWords: mutedWords ?? this.mutedWords,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory SettingsModel.initial(String username) => SettingsModel(
        username: username,
        protectedAccount: false,
        allowTagging: true,
        directMessagesFromEveryone: false,
        personalizedAds: true,
        dataSharingWithPartners: false,
        spacesEnabled: true,
        mutedWords: const [],
        lastUpdated: null,
      );

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        username: json['username'] as String? ?? '',
        protectedAccount: json['protectedAccount'] as bool? ?? false,
        allowTagging: json['allowTagging'] as bool? ?? true,
        directMessagesFromEveryone:
            json['directMessagesFromEveryone'] as bool? ?? false,
        personalizedAds: json['personalizedAds'] as bool? ?? true,
        dataSharingWithPartners:
            json['dataSharingWithPartners'] as bool? ?? false,
        spacesEnabled: json['spacesEnabled'] as bool? ?? true,
        mutedWords: (json['mutedWords'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.tryParse(json['lastUpdated'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'protectedAccount': protectedAccount,
        'allowTagging': allowTagging,
        'directMessagesFromEveryone': directMessagesFromEveryone,
        'personalizedAds': personalizedAds,
        'dataSharingWithPartners': dataSharingWithPartners,
        'spacesEnabled': spacesEnabled,
        'mutedWords': mutedWords,
        'lastUpdated': lastUpdated?.toIso8601String(),
      };
}

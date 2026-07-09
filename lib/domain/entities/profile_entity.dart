class ProfileEntity {
  final String id;
  final String username;
  final String name;
  final String bio;
  final String city;
  final String avatarUrl;
  final DateTime? birthDate;

  const ProfileEntity({
    required this.id,
    required this.username,
    required this.name,
    required this.bio,
    required this.city,
    required this.avatarUrl,
    this.birthDate,
  });

  int? get age {
    final birth = birthDate;
    if (birth == null) return null;
    final now = DateTime.now();
    int years = now.year - birth.year;
    final hadBirthdayThisYear =
        (now.month > birth.month) || (now.month == birth.month && now.day >= birth.day);
    if (!hadBirthdayThisYear) years--;
    return years;
  }

  factory ProfileEntity.fromJson(Map<String, dynamic> json) {
    return ProfileEntity(
      id: json['id'] as String,
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      city: json['city'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      birthDate: json['birth_date'] != null ? DateTime.tryParse(json['birth_date'] as String) : null,
    );
  }

  ProfileEntity copyWith({
    String? name,
    String? bio,
    String? city,
    String? avatarUrl,
  }) {
    return ProfileEntity(
      id: id,
      username: username,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthDate: birthDate,
    );
  }
}

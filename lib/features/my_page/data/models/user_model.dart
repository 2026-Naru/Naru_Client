class UserModel {
  final int id;
  final String email;
  final String name;
  final String? phone;
  final String? profileImageUrl;
  final int balanceKrw;
  final double balanceUsd;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.profileImageUrl,
    required this.balanceKrw,
    required this.balanceUsd,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      balanceKrw: (json['balance_krw'] as num?)?.toInt() ?? 0,
      balanceUsd: (json['balance_usd'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

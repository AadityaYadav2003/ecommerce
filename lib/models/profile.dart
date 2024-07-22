class Profile {
  final String? image;
  final String? username;
  final String? email;
  final String? mobile;

  Profile({this.image, this.username, this.email, this.mobile});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      image: json['Image'],
      username: json['username'],
      email: json['email'],
      mobile: json['mobile'],
    );
  }
}

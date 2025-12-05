class UserModel {
  String? id;
  String? name;
  String? email;
  String? profileImage;
  String? mobileNumber;
  String? about;
  String? status;              // online / offline
  String? lastOnlineStatus;    // "2 min ago"
  String? language;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.profileImage,
    this.mobileNumber,
    this.about,
    this.status,
    this.lastOnlineStatus,
    this.language,
  });

  Map<String, dynamic> toJson() {
    print("uuuuuuu UserModel.toJson called for ID: ${id ?? 'NULL'}");
    return {
      "id": id ?? "",
      "name": name ?? "",
      "email": email ?? "",
      "profileImage": profileImage ?? "",
      "mobileNumber": mobileNumber ?? "",
      "about": about ?? "",
      "status": status ?? "offline",
      "lastOnlineStatus": lastOnlineStatus ?? "",
      "language": language ?? "",
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("uuuuuuu UserModel.fromJson called for ID: ${json["id"] ?? 'NULL'}");
    return UserModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      profileImage: json["profileImage"] ?? "",
      mobileNumber: json["mobileNumber"] ?? "",
      about: json["about"] ?? "",
      status: json["status"] ?? "offline",
      lastOnlineStatus: json["lastOnlineStatus"] ?? "",
      language: json["language"] ?? "",
    );
  }
}
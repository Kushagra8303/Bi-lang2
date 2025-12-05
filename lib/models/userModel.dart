class UserModel {
  String? id;
  String? name;
  String? email;
  String? profileImage;
  String? mobileNumber;
  String? about;
  String? status;
  String? lastOnlineStatus;
  String? language; // 🔹 Added language

  UserModel({
    this.id,
    this.name,
    this.email,
    this.profileImage,
    this.mobileNumber,
    this.about,
    this.status,
    this.lastOnlineStatus,
    this.language, // 🔹 Added language
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id ?? "",
      "name": name ?? "",
      "email": email ?? "",
      "profileImage": profileImage ?? "",
      "mobileNumber": mobileNumber ?? "",
      "about": about ?? "",
      "status": status ?? "",
      "lastOnlineStatus": lastOnlineStatus ?? "",
      "language": language ?? "", // 🔹 Added language
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      profileImage: json["profileImage"],
      mobileNumber: json["mobileNumber"],
      about: json["about"],
      status: json["status"],
      lastOnlineStatus: json["lastOnlineStatus"],
      language: json["language"], // 🔹 Added language
    );
  }
}

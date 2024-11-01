class UserModel {
  String? id;
  String? name;
  String? phone;
  String? childEmail;
  String? parentEmail;
  String? type;
  String? profilePic;

  UserModel({this.id, this.name, this.phone, this.childEmail, this.parentEmail, this.type, this.profilePic});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'childEmail': childEmail,
    'parentEmail': parentEmail,
    'type': type,
    'profilePic': profilePic
  };
}

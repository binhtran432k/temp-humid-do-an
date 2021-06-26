class UserModel {
  static UserModel? instance;
  static late Function(void Function()) callback;

  String id;
  String email;
  String name;
  String role;
  String sex;
  String roomId;

  UserModel(this.id, this.email, this.name, this.role, this.sex, this.roomId);

  bool change(
      String? email, String? name, String? role, String? sex, String? roomId) {
    if (email != null) {
      this.email = email;
    }
    if (name != null) {
      this.name = name;
    }
    if (role != null) {
      this.role = role;
    }
    if (sex != null) {
      this.sex = sex;
    }
    if (roomId != null) {
      this.roomId = roomId;
    }
    return true;
  }
}

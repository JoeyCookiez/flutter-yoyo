/// 用户模型
/// 对应后端返回的用户信息结构：
/// {"token":"...","admin":true,"nickName":"王皓","userId":"915445853510","meetingNo":null,"sex":null,"avatar":"..."}
class UserModel {
  final String? token;
  final bool? admin;
  final String? nickName;
  final String? userId;
  final String? meetingNo;
  final String? sex;
  final String? avatar;
  
  // 兼容旧字段（向后兼容）
  String? get id => userId;
  String? get name => nickName;
  String? get email => null; // 后端返回中没有email字段

  UserModel({
    this.token,
    this.admin,
    this.nickName,
    this.userId,
    this.meetingNo,
    this.sex,
    this.avatar,
  });

  /// 从JSON创建UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token']?.toString(),
      admin: json['admin'] as bool?,
      nickName: json['nickName']?.toString(),
      userId: json['userId']?.toString(),
      meetingNo: json['meetingNo']?.toString(),
      sex: json['sex']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'admin': admin,
      'nickName': nickName,
      'userId': userId,
      'meetingNo': meetingNo,
      'sex': sex,
      'avatar': avatar,
    };
  }
}











/// 信令消息模型，对应后端的 MessageSendDto
class MessageSendDto {
  final int? messageSend2Type;
  final String? meetingId;
  final int? messageType;
  final String? sendUserId;
  final String? sendUserNickName;
  final dynamic messageContent;
  final String? receiveUserId;
  final int? sendTime;
  final int? messageId;
  final int? status;
  final String? filename;
  final int? fileType;
  final int? fileSize;

  MessageSendDto({
    this.messageSend2Type,
    this.meetingId,
    this.messageType,
    this.sendUserId,
    this.sendUserNickName,
    this.messageContent,
    this.receiveUserId,
    this.sendTime,
    this.messageId,
    this.status,
    this.filename,
    this.fileType,
    this.fileSize,
  });

  factory MessageSendDto.fromJson(Map<String, dynamic> json) {
    return MessageSendDto(
      messageSend2Type: json['messageSend2Type'] as int?,
      meetingId: json['meetingId']?.toString(),
      messageType: json['messageType'] as int?,
      sendUserId: json['sendUserId']?.toString(),
      sendUserNickName: json['sendUserNickName']?.toString(),
      messageContent: json['messageContent'],
      receiveUserId: json['receiveUserId']?.toString(),
      sendTime: _toInt(json['sendTime']),
      messageId: _toInt(json['messageId']),
      status: json['status'] as int?,
      filename: json['filename']?.toString(),
      fileType: json['fileType'] as int?,
      fileSize: _toInt(json['fileSize']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageSend2Type': messageSend2Type,
      'meetingId': meetingId,
      'messageType': messageType,
      'sendUserId': sendUserId,
      'sendUserNickName': sendUserNickName,
      'messageContent': messageContent,
      'receiveUserId': receiveUserId,
      'sendTime': sendTime,
      'messageId': messageId,
      'status': status,
      'filename': filename,
      'fileType': fileType,
      'fileSize': fileSize,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}







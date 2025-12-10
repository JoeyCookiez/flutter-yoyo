import 'package:characters/characters.dart';

class JoinMeetingRequest {
  JoinMeetingRequest({
    required this.meetingNo,
    required this.nickName,
    required this.audioOn,
    required this.videoOpen,
    required this.microOpen,
  });

  final String meetingNo;
  final String nickName;
  final bool audioOn;
  final bool videoOpen;
  final bool microOpen;

  Map<String, dynamic> toPreJoinPayload() {
    return {
      'meetingNo': meetingNo,
      'nickName': nickName,
      'audioOn': audioOn ? '1' : '0',
      'videoOpen': videoOpen ? '1' : '0',
      'microOpen': microOpen ? '1' : '0',
    };
  }

  Map<String, dynamic> toJoinPayload() {
    return {
      'meetingNo': meetingNo,
      'nickName': nickName,
      'videoOpen': videoOpen ? '1' : '0',
      'microOpen': microOpen ? '1' : '0',
    };
  }
}

class MeetingRoomArgs {
  MeetingRoomArgs({
    required this.meetingNo,
    required this.nickName,
    required this.audioOn,
    required this.videoOn,
    required this.microOn,
  });

  final String meetingNo;
  final String nickName;
  final bool audioOn;
  final bool videoOn;
  final bool microOn;
}

class MeetingMember {
  MeetingMember({
    required this.userId,
    required this.nickName,
    this.avatarUrl,
    this.isSelf = false,
    this.openVideo = false,
    this.openMicro = true,
  });

  final String userId;
  final String nickName;
  final String? avatarUrl;
  final bool isSelf;
  bool openVideo;
  bool openMicro;

  MeetingMember copy() {
    return MeetingMember(
      userId: userId,
      nickName: nickName,
      avatarUrl: avatarUrl,
      isSelf: isSelf,
      openVideo: openVideo,
      openMicro: openMicro,
    );
  }

  String get displayInitial {
    final trimmed = nickName.trim();
    if (trimmed.isEmpty) return '友';
    return trimmed.characters.first;
  }
}


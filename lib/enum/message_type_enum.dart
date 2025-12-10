enum MessageTypeEnum {
  ADD_MEETING_ROOM(1,"加入会议"),
  PEER(2,"对等连接信息"),
  EXIT_MEETING_ROOM(3,"退出会议"),
  CHAT_TEXT_MESSAGE(5,"聊天消息"),
  CHAT_MEDIA_MESSAGE(6,"聊天媒体消息"),
  USER_CONTACT_APPLY(8,"用户添加好友申请"),
  INVITE_MEMBER_MEETING(9,"邀请用户进入会议"),
  FORCE_OFF_LINE(10,"强制离线"),
  MEETING_USER_VIDEO_CHANGE(11,"会议用户视频信息修改")
  ;


  final int code;
  final String desc; 
  const MessageTypeEnum(this.code,this.desc);

  static MessageTypeEnum ? fromCode(int code){
    for(var type in MessageTypeEnum.values){
      if(type.code == code) return type;
    }
    return null;
  }
}
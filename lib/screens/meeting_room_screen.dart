import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_yoyo/enum/message_type_enum.dart';
import 'package:flutter_yoyo/models/meeting_models.dart';
import 'package:flutter_yoyo/models/user_model.dart';
import 'package:flutter_yoyo/services/meeting_service.dart';
import 'package:flutter_yoyo/services/signal_service.dart';
import 'package:flutter_yoyo/services/storage_service.dart';

import '../models/message_model.dart';

class MeetingRoomScreen extends StatefulWidget {
  const MeetingRoomScreen({super.key, required this.args});

  final MeetingRoomArgs args;

  @override
  State<MeetingRoomScreen> createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends State<MeetingRoomScreen> {
  final MeetingService _meetingService = MeetingService();
  late bool _micOn;
  late bool _cameraOn;
  late bool _audioOn;
  UserModel? _userInfo;
  bool _isSharingScreen = false;
  bool _isRecording = false;
  bool _isLeaving = false;
  bool _showMembersPanel = false;
  bool _showChatPanel = false;
  int _currentLayout = 4;
  int _currentPage = 0;
  late List<MeetingMember> _members;
  late DateTime _startAt;
  Timer? _timer;
  StreamSubscription? _signalMsgSub;
  StreamSubscription? _signalStatusSub;
  late Map<String, RTCPeerConnection> peerConnectionMap;
  
  int get _pageSize => _currentLayout == 4 ? 4 : 9;
  int get _totalPages => max(1, (_members.length / _pageSize).ceil());

  List<MeetingMember> get _visibleMembers {
    final start = _currentPage * _pageSize;
    return _members.skip(start).take(_pageSize).toList();
  }

  @override
  void initState() {
    super.initState();
    _micOn = widget.args.microOn;
    _cameraOn = widget.args.videoOn;
    _audioOn = widget.args.audioOn;
    _members = _buildMockMembers();
    _startAt = DateTime.now();
    peerConnectionMap = {};
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _initAsync();
  }

  Future<void> _initAsync() async {
    // 获取 userInfo
    _userInfo = await StorageService.instance.getUserInfo();
    // 订阅信令服务器回调
    _signalMsgSub = SignalService.instance.messageStream.listen(_handleSignalMessage);
    _signalStatusSub = SignalService.instance.statusStream.listen(_handleSignalStatus);
    // 初始化房间状态（不等待）
    initRoomState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _signalMsgSub?.cancel();
    _signalStatusSub?.cancel();
    super.dispose();
  }
  /* 初始化会议室
    1、获取当前会议中的所有成员信息
   */
  void initRoomState() async {
    if (_userInfo == null) return;
    // 作为新加入的会议成员，其作为发起方向其他用户发送 P2P 连接请求 offer
    for (var member in _members) {
      if (_userInfo!.userId != member.userId) {
        final RTCPeerConnection peerConnection = await createWebRTC();
        peerConnectionMap[member.userId] = peerConnection;

        final offer = await peerConnection.createOffer();
        await peerConnection.setLocalDescription(offer);

        sendPeerMessage({
          'sendUserId': _userInfo?.userId,
          'receiveUserId': member.userId,
          'signalType': 'offer',
          'signalData': {'sdp': offer.sdp, 'type': offer.type},
        });
      }
    }
  }

  void sendPeerMessage(Map<String, dynamic> params) {
    final signalData = params['signalData'];
    SignalService.instance.send({
      'type': MessageTypeEnum.PEER.code,
      'sendUserId': params['sendUserId'],
      'receiveUserId': params['receiveUserId'],
      'signalType': params['signalType'],
      // 与桌面端保持一致：signalData 序列化为字符串
      'signalData': jsonEncode(signalData),
    });
  }

  Future<RTCPeerConnection> createWebRTC() async {
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    // 创建 PeerConnection 约束
    final Map<String, dynamic> offerSdpConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [],
    };

    final RTCPeerConnection peerConnection =
        await createPeerConnection(configuration, offerSdpConstraints);

    return peerConnection;
  }


  List<MeetingMember> _buildMockMembers() {
    final self = MeetingMember(
      userId: 'self',
      nickName: widget.args.nickName,
      isSelf: true,
      openVideo: _cameraOn,
      openMicro: _micOn,
    );
    final others = [
    ];
    return [self, ...others];
  }

  void _syncSelfMember() {
    final index = _members.indexWhere((member) => member.isSelf);
    if (index != -1) {
      _members[index].openVideo = _cameraOn;
      _members[index].openMicro = _micOn;
    }
  }

  void _toggleMic() {
    setState(() {
      _micOn = !_micOn;
      _syncSelfMember();
    });
    _showSnack(_micOn ? '麦克风已开启' : '麦克风已静音');
  }

  void _toggleCamera() {
    setState(() {
      _cameraOn = !_cameraOn;
      _syncSelfMember();
    });
    _showSnack(_cameraOn ? '摄像头已开启' : '摄像头已关闭');
  }

  void _toggleShareScreen() {
    setState(() {
      _isSharingScreen = !_isSharingScreen;
    });
    _showSnack(_isSharingScreen ? '开始共享屏幕' : '已停止共享屏幕');
  }

  void _toggleRecord() {
    setState(() {
      _isRecording = !_isRecording;
    });
    _showSnack(_isRecording ? '开始录制会议' : '录制已结束');
  }

  void _toggleMembersPanel() {
    setState(() {
      _showMembersPanel = !_showMembersPanel;
      if (_showMembersPanel) _showChatPanel = false;
    });
  }

  void _toggleChatPanel() {
    setState(() {
      _showChatPanel = !_showChatPanel;
      if (_showChatPanel) _showMembersPanel = false;
    });
  }

  void _changeLayout(int layout) {
    if (_currentLayout == layout) return;
    setState(() {
      _currentLayout = layout;
      _currentPage = 0;
    });
  }

  void _changePage(int delta) {
    final next = (_currentPage + delta).clamp(0, _totalPages - 1);
    if (next != _currentPage) {
      setState(() => _currentPage = next);
    }
  }

  Future<void> _handleLeaveMeeting() async {
    if (_isLeaving) return;
    setState(() => _isLeaving = true);
    final response = await _meetingService.exitMeeting();
    if (!mounted) return;
    setState(() => _isLeaving = false);
    if (!response.isSuccess) {
      _showSnack(response.message);
    }
    Navigator.of(context).pop();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String get _durationText {
    final diff = DateTime.now().difference(_startAt);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// 处理信令消息
  void _handleSignalMessage(dynamic message) async {
    // 根据实际协议进行解析，这里先简单提示
    if (!mounted) return;
    print('收到消息 ${message}');
    // WebSocket 消息可能是字符串，需要先解析为 Map
    Map<String, dynamic>? messageMap;
    if (message is String) {
      try {
        messageMap = Map<String, dynamic>.from(
          jsonDecode(message) as Map,
        );
      } catch (e) {
        print('解析信令消息失败: $e, message: $message');
        return;
      }
    } else if (message is Map) {
      messageMap = Map<String, dynamic>.from(message);
    } else {
      print('未知的消息格式: ${message.runtimeType}');
      return;
    }
    
    try {
      final MessageSendDto messageSendDto = MessageSendDto.fromJson(messageMap);
      print('messageType ${messageSendDto.messageType}');
      final int? messageType = messageSendDto.messageType;
      final sendUserId = messageSendDto.sendUserId;


      // 解析消息内容：可能是 String / Map / List
      final dynamic contentRaw = messageSendDto.messageContent;
      final Map<String, dynamic>? content = _asMap(contentRaw);
      if (content == null) {
        print('无法解析 messageContent: ${contentRaw.runtimeType}');
        return;
      }

      switch (messageType) {
        // 1: 加入会议
        case 1:
          print("收到新增用户消息 $message");
          break;
        // 2: 对等连接信令
        case 2:
          // 如果是自己发出的 peer 消息，忽略
          if (sendUserId == _userInfo?.userId) break;

          final peerType = content["signalType"];
          final signalData = content["signalData"];
          RTCPeerConnection? remotePeerConnection = peerConnectionMap[sendUserId];
          if (remotePeerConnection == null) {
            print('未找到对应的 PeerConnection $sendUserId');
            break;
          }
          switch (peerType) {
            case 'offer':
              try {
                final offerData = _asMap(signalData);
                if (offerData == null) {
                  print('offerData 解析失败');
                  break;
                }
                await remotePeerConnection.setRemoteDescription(
                  RTCSessionDescription(offerData['sdp'], offerData['type'] ?? 'offer'),
                );
                final answer = await remotePeerConnection.createAnswer();
                await remotePeerConnection.setLocalDescription(answer);
                sendPeerMessage({
                  "sendUserId": _userInfo?.userId,
                  "signalType": 'answer',
                  "signalData": {'sdp': answer.sdp, 'type': answer.type},
                  "receiveUserId": sendUserId,
                });
                print('answer 已发送');
              } catch (e) {
                print('处理 offer 报错 $e');
              }
              break;
            case 'answer':
              try {
                final answerData = _asMap(signalData);
                if (answerData == null) {
                  print('answerData 解析失败');
                  break;
                }
                await remotePeerConnection.setRemoteDescription(
                  RTCSessionDescription(answerData['sdp'], answerData['type'] ?? 'answer'),
                );
              } catch (e) {
                print('处理 answer 报错 $e');
              }
              break;
            case 'candidate':
              try {
                final candidateData = _asMap(signalData);
                if (candidateData != null && candidateData['candidate'] != null) {
                  await remotePeerConnection.addCandidate(
                    RTCIceCandidate(
                      candidateData['candidate'],
                      candidateData['sdpMid'],
                      candidateData['sdpMLineIndex'],
                    ),
                  );
                }
              } catch (e) {
                print('处理 ICE candidate 时出错: $e');
              }
              break;
          }
          break;
        // 3: 退出会议
        case 3:
        // 5: 聊天文本
        case 5:
        // 6: 聊天媒体
        case 6:
        // 8: 添加好友申请
        case 8:
        // 9: 邀请成员
        case 9:
        // 10: 强制下线
        case 10:
        // 11: 会议用户视频状态变化
        case 11:
        default:
          // 暂不处理或待补充
          break;
      }
    } catch (e) {
      print('处理信令消息时出错: $e');
    }
    // _showSnack('收到信令消息: $message');
  }

  /// 将任意类型转为 Map，如果失败返回 null
  Map<String, dynamic>? _asMap(dynamic data) {
    if (data == null) return null;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  /// 处理连接状态变化
  void _handleSignalStatus(SignalConnectionState state) {
    if (!mounted) return;
    switch (state) {
      case SignalConnectionState.connected:
        // _showSnack('信令已连接');
        print('信令服务器已连接');
        break;
      case SignalConnectionState.reconnecting:
        print('信令重连中...');
        break;
      case SignalConnectionState.disconnected:
        print('信令已断开');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1114),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatusChips(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF191B20),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Expanded(child: _buildVideoGrid()),
                            if (_totalPages > 1) ...[
                              const SizedBox(height: 8),
                              _buildPagination()
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAuxiliaryPanel(),
                    const SizedBox(height: 12),
                    _buildBottomControls(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF616ED0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '会议 ${widget.args.meetingNo}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '您以「${widget.args.nickName}」身份加入',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<int>(
            color: Colors.white,
            tooltip: '切换布局',
            onSelected: _changeLayout,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 4,
                child: Text('四宫格'),
              ),
              PopupMenuItem(
                value: 9,
                child: Text('九宫格'),
              ),
            ],
            child: Row(
              children: [
                const Icon(Icons.grid_view, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  _currentLayout == 4 ? '四宫格' : '九宫格',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatusChip(
          icon: Icons.wifi_tethering,
          label: '网络良好',
        ),
        _StatusChip(
          icon: Icons.schedule,
          label: '时长 $_durationText',
        ),
        _StatusChip(
          icon: Icons.headset_mic,
          label: _audioOn ? '音频已连接' : '音频未连接',
        ),
      ],
    );
  }

  Widget _buildVideoGrid() {
    final crossAxisCount = _currentLayout == 4 ? 2 : 3;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 4 / 3,
      ),
      itemCount: _visibleMembers.length,
      itemBuilder: (context, index) {
        final member = _visibleMembers[index];
        return _VideoTile(member: member, isSelf: member.isSelf);
      },
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 0 ? () => _changePage(-1) : null,
          icon: const Icon(Icons.chevron_left, color: Colors.white),
        ),
        Text(
          '${_currentPage + 1}/$_totalPages',
          style: const TextStyle(color: Colors.white70),
        ),
        IconButton(
          onPressed:
              _currentPage < _totalPages - 1 ? () => _changePage(1) : null,
          icon: const Icon(Icons.chevron_right, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildAuxiliaryPanel() {
    if (!_showMembersPanel && !_showChatPanel) {
      return const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(_showMembersPanel ? 'members' : 'chat'),
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1D1F2A),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: _showMembersPanel ? _buildMemberList() : _buildChatPreview(),
      ),
    );
  }

  Widget _buildMemberList() {
    return ListView.separated(
      itemCount: _members.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white10),
      itemBuilder: (context, index) {
        final member = _members[index];
        return Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  member.isSelf ? const Color(0xFF616ED0) : Colors.blueGrey,
              child: Text(
                member.displayInitial,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                member.nickName + (member.isSelf ? '（我）' : ''),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Icon(
              member.openMicro ? Icons.mic : Icons.mic_off,
              size: 18,
              color: member.openMicro ? Colors.greenAccent : Colors.redAccent,
            ),
            const SizedBox(width: 8),
            Icon(
              member.openVideo ? Icons.videocam : Icons.videocam_off,
              size: 18,
              color: member.openVideo ? Colors.greenAccent : Colors.redAccent,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          '聊天面板（待接入）',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          '这里会展示会议聊天、表情反馈等信息。',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2030),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: MeetingControlButton(
              icon: _micOn ? Icons.mic : Icons.mic_off,
              label: _micOn ? '静音' : '解除静音',
              active: !_micOn,
              onTap: _toggleMic,
            ),
          ),
          Expanded(
            child: MeetingControlButton(
              icon: _cameraOn ? Icons.videocam : Icons.videocam_off,
              label: _cameraOn ? '停止视频' : '开启视频',
              active: !_cameraOn,
              onTap: _toggleCamera,
            ),
          ),
          Expanded(
            child: MeetingControlButton(
              icon: Icons.screen_share,
              label: _isSharingScreen ? '停止共享' : '共享屏幕',
              active: _isSharingScreen,
              onTap: _toggleShareScreen,
            ),
          ),
          Expanded(
            child: MeetingControlButton(
              icon: Icons.group,
              label: _showMembersPanel ? '关闭成员' : '成员列表',
              active: _showMembersPanel,
              onTap: _toggleMembersPanel,
            ),
          ),
        ],
      ),
    );
  }
}

class MeetingControlButton extends StatelessWidget {
  const MeetingControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.danger = false,
    this.loading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool danger;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color iconColor;

    if (danger) {
      bgColor = const Color(0xFFE53935);
      iconColor = Colors.white;
    } else if (active) {
      bgColor = const Color(0xFF616ED0);
      iconColor = Colors.white;
    } else {
      bgColor = const Color(0xFF2A2D3E);
      iconColor = Colors.white;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: loading
                ? const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Icon(icon, color: iconColor, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({
    required this.member,
    required this.isSelf,
  });

  final MeetingMember member;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: member.openVideo ? Colors.black : const Color(0xFF272B3D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelf ? const Color(0xFF616ED0) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          if (!member.openVideo)
            Center(
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Colors.blueGrey[700],
                child: Text(
                  member.displayInitial,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    member.nickName + (isSelf ? '（我）' : ''),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  member.openMicro ? Icons.mic : Icons.mic_off,
                  size: 16,
                  color: member.openMicro ? Colors.greenAccent : Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2030),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

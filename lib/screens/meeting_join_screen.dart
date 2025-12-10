import 'package:flutter/material.dart';
import 'package:flutter_yoyo/component/yo_cell.dart';
import 'package:flutter_yoyo/component/yo_switch.dart';
import 'package:flutter_yoyo/models/meeting_models.dart';
import 'package:flutter_yoyo/screens/meeting_room_screen.dart';
import 'package:flutter_yoyo/services/meeting_service.dart';
import 'package:flutter_yoyo/utils/input_formatters/meeting_id_formatter.dart';

/// 加入会议页面
class MeetingJoinScreen extends StatefulWidget {
  const MeetingJoinScreen({super.key});

  @override
  State<MeetingJoinScreen> createState() => _MeetingJoinScreenState();
}

class _MeetingJoinScreenState extends State<MeetingJoinScreen> {
  final TextEditingController _meetingIdController = TextEditingController();
  final TextEditingController _nickNameController =
      TextEditingController(text: 'Yo友');
  final MeetingService _meetingService = MeetingService();
  final MeetingIdInputFormatter _meetingIdFormatter =
      MeetingIdInputFormatter(maxDigits: 9);

  bool _audioOn = true;
  bool _micOn = true;
  bool _videoOn = false;
  bool _canJoin = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _meetingIdController.addListener(_updateCanJoinState);
  }

  @override
  void dispose() {
    _meetingIdController.removeListener(_updateCanJoinState);
    _meetingIdController.dispose();
    _nickNameController.dispose();
    super.dispose();
  }

  String get _pureMeetingNo =>
      _meetingIdController.text.replaceAll(RegExp(r'\s'), '');

  void _updateCanJoinState() {
    final isValid = _pureMeetingNo.length >= 9;
    if (isValid != _canJoin) {
      setState(() {
        _canJoin = isValid;
      });
    }
  }

  Future<void> _onJoinMeeting() async {
    if (!_canJoin || _isLoading) return;
    final meetingId = _pureMeetingNo;
    final nickName =
        _nickNameController.text.trim().isEmpty ? 'Yo友' : _nickNameController.text.trim();

    setState(() => _isLoading = true);

    final request = JoinMeetingRequest(
      meetingNo: meetingId,
      nickName: nickName,
      audioOn: _audioOn,
      videoOpen: _videoOn,
      microOpen: _micOn,
    );

    final preJoin = await _meetingService.preJoinMeeting(request);
    if (!preJoin.isSuccess) {
      _showToast(preJoin.message.isNotEmpty ? preJoin.message : '无法预检入会信息');
      setState(() => _isLoading = false);
      return;
    }

    final joinRes = await _meetingService.joinMeeting(request);
    if (!joinRes.isSuccess) {
      _showToast(joinRes.message.isNotEmpty ? joinRes.message : '加入会议失败');
      setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MeetingRoomScreen(
          args: MeetingRoomArgs(
            meetingNo: meetingId,
            nickName: nickName,
            audioOn: _audioOn,
            videoOn: _videoOn,
            microOn: _micOn,
          ),
        ),
      ),
    );
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('加入会议'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    YoCell(
                      height: 64,
                      title: '会议号',
                      background: Colors.white,
                      rightSlot: TextField(
                        controller: _meetingIdController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_meetingIdFormatter],
                        textAlignVertical: TextAlignVertical.center,
                        decoration: const InputDecoration(
                          hintText: '请输入会议号',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    YoCell(
                      height: 64,
                      title: '您的昵称',
                      background: Colors.white,
                      rightSlot: TextField(
                        controller: _nickNameController,
                        maxLength: 20,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: const InputDecoration(
                          hintText: '请输入昵称',
                          border: InputBorder.none,
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '会议设置',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF4B5675),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    YoCell(
                      height: 56,
                      title: '自动连接音频',
                      background: Colors.white,
                      rightSlot: Align(
                        alignment: Alignment.centerRight,
                        child: YoSwitch(
                          value: _audioOn,
                          onChanged: (value) => setState(() => _audioOn = value),
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    YoCell(
                      height: 56,
                      title: '开启麦克风',
                      background: Colors.white,
                      rightSlot: Align(
                        alignment: Alignment.centerRight,
                        child: YoSwitch(
                          value: _micOn,
                          onChanged: (value) => setState(() => _micOn = value),
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    YoCell(
                      height: 56,
                      title: '开启视频',
                      background: Colors.white,
                      rightSlot: Align(
                        alignment: Alignment.centerRight,
                        child: YoSwitch(
                          value: _videoOn,
                          onChanged: (value) => setState(() => _videoOn = value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: (_canJoin && !_isLoading) ? _onJoinMeeting : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _canJoin ? theme.primaryColor : Colors.grey[400],
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.white70,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('加入会议'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

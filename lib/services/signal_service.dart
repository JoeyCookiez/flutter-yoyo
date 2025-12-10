import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'storage_service.dart';

/// 信令服务器 WebSocket 管理
///
/// 对标桌面端的 initWs(wsUrl + userInfo?.token) 逻辑：
/// - 在登录成功后调用 [SignalService.instance.connectWithToken]
/// - 内部维护长连接、心跳与简单的重连机制
class SignalService {
  SignalService._();
  static final SignalService instance = SignalService._();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  /// 信令消息广播流（上层可在任意页面订阅）
  final StreamController<dynamic> _messageController =
      StreamController<dynamic>.broadcast();

  /// 连接状态广播流
  final StreamController<SignalConnectionState> _statusController =
      StreamController<SignalConnectionState>.broadcast();

  String? _wsUrlWithToken;
  bool _manuallyClosed = false;

  /// 设置信令服务器基础地址（例如：ws://host:port/ws?token=）
  /// 可以在应用启动时或根据环境配置调用一次
  String wsBaseUrl = 'ws://114.66.38.139:6061/ws?';

  /// 使用 token 连接信令服务器，对应桌面端：initWs(wsUrl + userInfo?.token)
  Future<void> connectWithToken(String token) async {
    if (wsBaseUrl.isEmpty) {
      // 未配置信令地址时直接返回
      return;
    }
    final fullUrl = '$wsBaseUrl$token';
    _wsUrlWithToken = fullUrl;
    _statusController.add(SignalConnectionState.connecting);
    await _connect(fullUrl);
  }

  /// 从本地存储中获取token并连接信令服务器
  /// 如果存储中没有token，则不进行连接
  Future<void> connectFromStorage() async {
    final token = await StorageService.instance.getToken();
    if (token != null && token.isNotEmpty) {
      await connectWithToken(token);
    }
  }

  Future<void> _connect(String url) async {
    // 先关闭旧连接，但保持“自动”状态，避免重连逻辑被认为是手动关闭
    await disconnect(manually: false);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onDone: _handleDone,
        onError: _handleError,
      );

      _statusController.add(SignalConnectionState.connected);
      _startHeartbeat();
    } catch (e) {
      _statusController.add(SignalConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic message) {
    // 将消息透传给订阅者，由上层自行解析
    _messageController.add(message);
  }

  void _handleDone() {
    _stopHeartbeat();
    if (!_manuallyClosed) {
      _statusController.add(SignalConnectionState.reconnecting);
      _scheduleReconnect();
    } else {
      _statusController.add(SignalConnectionState.disconnected);
    }
  }

  void _handleError(Object error) {
    _stopHeartbeat();
    if (!_manuallyClosed) {
      _statusController.add(SignalConnectionState.reconnecting);
      _scheduleReconnect();
    } else {
      _statusController.add(SignalConnectionState.disconnected);
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    // 简单心跳：每 20 秒发送一次 ping，你可以根据桌面端实现调整
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      // send({'type': 'ping', 'ts': DateTime.now().millisecondsSinceEpoch});
      send('ping');
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null || _wsUrlWithToken == null) return;
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      _reconnectTimer = null;
      if (!_manuallyClosed && _wsUrlWithToken != null) {
        _statusController.add(SignalConnectionState.reconnecting);
        _connect(_wsUrlWithToken!);
      }
    });
  }

  /// 发送信令消息
  void send(dynamic data) {
    try {
      final payload = (data is String || data is List<int>)
          ? data
          : jsonEncode(data);
      _channel?.sink.add(payload);
    } catch (e) {
      // 保底避免因序列化异常导致崩溃
      print('发送信令失败: $e');
    }
  }

  /// 主动断开连接（例如退出登录 / 退出应用时）
  Future<void> disconnect({bool manually = true}) async {
    _manuallyClosed = manually;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _stopHeartbeat();
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close(ws_status.normalClosure);
    _channel = null;
    _statusController.add(SignalConnectionState.disconnected);
  }

  /// 公开的消息流和状态流
  Stream<dynamic> get messageStream => _messageController.stream;
  Stream<SignalConnectionState> get statusStream => _statusController.stream;
}

/// 信令连接状态
enum SignalConnectionState {
  connecting,
  connected,
  reconnecting,
  disconnected,
}




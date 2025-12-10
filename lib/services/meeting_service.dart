import '../models/meeting_models.dart';
import '../utils/http_client.dart';

class MeetingService {
  MeetingService._();
  static final MeetingService _instance = MeetingService._();
  factory MeetingService() => _instance;

  final HttpClient _httpClient = HttpClient();

  Future<ApiResponse<Map<String, dynamic>>> preJoinMeeting(
    JoinMeetingRequest request,
  ) async {
    // 后端接口使用 @RequestParam，需要将参数放在 query string 中
    final payload = request.toPreJoinPayload();
    final queryParams = <String, String>{};
    payload.forEach((key, value) {
      queryParams[key] = value.toString();
    });
    
    final response = await _httpClient.post<Map<String, dynamic>>(
      '/meetingInfo/preJoinMeeting',
      queryParameters: queryParams,
      parser: (json) => json,
    );
    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> joinMeeting(
    JoinMeetingRequest request,
  ) async {
    // 后端接口使用 @RequestParam，只需要 videoOpen 参数（Boolean）
    // 注意：根据后端代码，joinMeeting 只需要 videoOpen，其他信息从 token 中获取
    // Spring 会将字符串 'true'/'false' 自动转换为 Boolean
    final response = await _httpClient.post<Map<String, dynamic>>(
      '/meetingInfo/joinMeeting',
      queryParameters: {
        'videoOpen': request.videoOpen ? 'true' : 'false',
      },
      parser: (json) => json,
    );
    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> quickMeeting() async {
    final response = await _httpClient.post<Map<String, dynamic>>(
      '/meetingInfo/quickMeeting',
      parser: (json) => json,
    );
    return response;
  }

  Future<ApiResponse<void>> exitMeeting() async {
    final response = await _httpClient.post<void>(
      '/meetingInfo/exitMeeting',
    );
    return response;
  }
}






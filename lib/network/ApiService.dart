import 'package:berrytalks/Widgets_Component/Enum/enum.dart';
import 'package:berrytalks/Widgets_Component/Utils/MediaUrlResolver.dart';
import 'package:berrytalks/network/ApiConfig.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';
import 'base_model/BaseResponseModel.dart';

part 'ApiService.g.dart';
part '../screens/Login_Screen/network_calls/model/LoginModel.dart';
part '../screens/Home_screen/netwrok_calls/model/conversationModel.dart';
part '../screens/Team_list_screen/network_calls/model/teamListModel.dart';
part '../screens/Settings/network_calls/model/settings_model.dart';
part '../screens/Chat_screen/network_calls/model/chatModel.dart';
part '../screens/Team_chat_screen/network calls/model/team_chat_model.dart';
part '../screens/Cust_Profile/newtork call/model/customer_profile_model.dart';

//flutter clean
//flutter pub get
//dart run build_runner build --delete-conflicting-outputs

@RestApi(baseUrl: ApiConfig.apiBaseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST("/auth/client/login")
  Future<HttpResponse<LoginModel>> login(
    @Header("Authorization") String token,
    @Body() Map<String, dynamic> map,
  );

  @GET("/auth/user-permission")
  Future<HttpResponse<dynamic>> getUserPermissions(
    @Header("Authorization") String token,
  );

  @GET("/chat/contactList/ALL")
  Future<HttpResponse<ChatContactApiModel>> getChatContactList(
    @Header("Authorization") String token,
    @Query("page") int page,
  );

  @GET("/agent/list/AGENT")
  Future<HttpResponse<TeamContactApiModel>> getTeamContactList(
    @Header("Authorization") String token,
    @Query("page") int page,
  );

  @GET("/internal-chat/details")
  Future<HttpResponse<TeamContactApiModel>> getInternalChatDetails(
    @Header("Authorization") String token,
    @Query("page") int page,
  );

  @GET("/agent/profile")
  Future<HttpResponse<AgentProfileModel>> getAgentProfile(
    @Header("Authorization") String token,
  );

  @GET('/chat/details/{number}/{companyPublicId}/{agentId}/{channelId}')
  Future<HttpResponse<dynamic>> getChatDetails(
    @Header("Authorization") String token,
    @Path("number") String number,
    @Path("companyPublicId") String companyPublicId,
    @Path("agentId") String agentId,
    @Path("channelId") String channelId,
    @Query("page") int page,
  );

  @GET('/internal-chat/details/{recipientAgentId}')
  Future<TeamChatDetailsApiModel?> getTeamChatDetails({
    @Header("Authorization") required String token,
    @Path('recipientAgentId') required String recipientAgentId,
    @Query('page') int page = 0,
    @Query('size') int size = 20,
  });

  @GET('/company/get')
  Future<HttpResponse<CompanyProfileApiModel>> getCompanyProfile(
    @Header("Authorization") String token,
  );

  @POST("/chat/transfer-chat")
  Future<HttpResponse<TransferChatResponseModel>> transferChat(
    @Header("Authorization") String token,
    @Body() Map<String, dynamic> body,
  );

  @POST("/internal-chat/send")
  Future<TeamSendMessageResponseModel> sendTeamMessage(
    @Header("Authorization") String token,
    @Body() Map<String, dynamic> body,
  );

  @POST("/chat/send-message")
  Future<SendMessageResponseModel> sendMessage(
    @Header("Authorization") String token,
    @Body() Map<String, dynamic> body,
  );

  @POST("/agent/changeStatus/{status}/{publicId}")
  Future<HttpResponse<StatusChangeResponseModel>> changeAgentStatus(
    @Path("status") String status,
    @Path("publicId") String publicId,
  );

  @POST("/chat/update-chat-status")
  Future<UpdateChatStatusResponseModel> updateChatStatus(
    @Body() List<UpdateChatStatusRequestModel> body,
  );

  /// Matches:
  /// POST /media/upload/bulk?agentPublicId=...&companyId=...
  /// Authorization: Bearer ...
  /// Accept: application/json, text/plain, */*
  /// multipart/form-data: files=@<file>
  @POST("/media/upload/bulk")
  @MultiPart()
  Future<HttpResponse<UploadDocumentApiModel>> uploadDocument(
    @Header("Authorization") String token,
    @Header("Accept") String accept,
    @Query("agentPublicId") String agentPublicId,
    @Query("companyId") String companyId,
    @Part(name: "files") List<MultipartFile> files,
  );
}

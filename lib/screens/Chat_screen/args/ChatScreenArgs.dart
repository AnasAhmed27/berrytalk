import 'package:flutter/foundation.dart';

import '../../../network/ApiService.dart';

class ChatScreenArgs {
  final ContactData contactItem;
  final CompanyProfileData? companyProfileData;

  /// Optional. Prefer refreshing the chat list after `context.push` returns
  /// instead of calling this from [State.dispose] (can hit unmounted context).
  final VoidCallback? onChatClosed;

  ChatScreenArgs({
    required this.contactItem,
    this.companyProfileData,
    this.onChatClosed,
  });
}
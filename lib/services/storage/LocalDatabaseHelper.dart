import 'dart:async';
import 'package:path/path.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:sqflite/sqflite.dart'; 

class LocalDatabaseHelper {
  static final LocalDatabaseHelper instance = LocalDatabaseHelper._init();
  static Database? _database;

  LocalDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('berry_chat.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS message_reactions (
        message_public_id TEXT PRIMARY KEY,
        reaction TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }
}

  // Local Table Schema
  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NULLABLE';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE messages (
        client_msg_id $idType,
        server_msg_id $textType,
        conversation_id $textType,
        body $textType,
        message_type $textType,
        file_path $textType,
        caption $textType,
        timestamp $textType,
        is_sent $textType,
        message_status $textType,
        sync_status $intType, 
        recipient_number $textType,
        contact_number $textType,
        name $textType,
        agent_id $textType,
        channel_id $textType,
        file_id $textType,
        media_stream $textType,
      )
    ''');
  }

  // ==================== DATABASE OPERATIONS ====================

  /// 1. Save or Update Message from Server/API
  Future<void> saveOrUpdateMessage(InboxMessage msg, {String? clientMsgId}) async {
    final db = await instance.database;

    final String uniqueId = clientMsgId ?? msg.id ?? msg.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();

    final Map<String, dynamic> row = {
      'client_msg_id': uniqueId,
      'server_msg_id': msg.id ?? msg.messageId,
      'conversation_id': msg.conversationId?.toString(),
      'body': msg.body,
      'message_type': msg.messageType,
      'file_path': msg.filePath,
      'caption': msg.caption,
      'timestamp': msg.timestamp ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'is_sent': msg.isSent?.toString() ?? 'true',
      'message_status': msg.messageStatus ?? 'sent',
      'sync_status': 1, // 1 = Successfully synced with backend
    };

    await db.insert(
      'messages',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 2. Save Pending Outgoing Message (Offline/Sending State)
  Future<String> insertPendingMessage({
    required String clientMsgId,
    required String conversationId,
    required String textBody,
    required String messageType,
    required String phoneNumber,
    required String recipientNumber,
    required String channelId,
    required String name,
    required String agentId,
    String? filePath,
    String? fileId,
    String? mediaStream,
  }) async {
    final db = await instance.database;

    final Map<String, dynamic> row = {
      'client_msg_id': clientMsgId,
      'conversation_id': conversationId,
      'body': textBody,
      'message_type': messageType,
      'file_path': filePath,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      'is_sent': 'true', // Local sent by me
      'message_status': 'sending',
      'sync_status': 0, // 0 = Pending/Unsent to server
      'contact_number': phoneNumber,
      'recipient_number': recipientNumber,
      'channel_id': channelId,
      'name': name,
      'agent_id': agentId,
      'file_id': fileId,
      'media_stream': mediaStream,
    };

    await db.insert(
      'messages',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return clientMsgId;
  }

  /// 3. Update Sync Status After Server Success/Failure
  Future<void> updateMessageSyncStatus(String clientMsgId, {required bool isSuccess, String? serverMsgId}) async {
    final db = await instance.database;

    await db.update(
      'messages',
      {
        'sync_status': isSuccess ? 1 : 2, // 1 = Sent, 2 = Failed
        'message_status': isSuccess ? 'sent' : 'failed',
        if (serverMsgId != null) 'server_msg_id': serverMsgId,
      },
      where: 'client_msg_id = ?',
      whereArgs: [clientMsgId],
    );
  }

  /// 4. Get Unsent / Pending Messages (Re-connection ke time bhejney ke liye)
  Future<List<Map<String, dynamic>>> getPendingMessages() async {
    final db = await instance.database;
    return await db.query(
      'messages',
      where: 'sync_status = ? OR sync_status = ?',
      whereArgs: [0, 2], // 0 = Pending, 2 = Failed
      orderBy: 'timestamp ASC',
    );
  }

  /// 5. Load Chat Messages for UI (Paginated / Sorted)
  Future<List<InboxMessage>> getMessagesForConversation(String conversationId) async {
    final db = await instance.database;

    final result = await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );

    return result.map((map) {
      return InboxMessage(
        id: map['server_msg_id'] as String? ?? map['client_msg_id'] as String?,
        messageId: map['client_msg_id'] as String?,
        messageType: map['message_type'] as String?,
        body: map['body'] as String?,
        timestamp: map['timestamp'] as String?,
        conversationId: map['conversation_id'],
        isSent: map['is_sent'],
        messageStatus: map['message_status'] as String?,
        filePath: map['file_path'] as String?,
        caption: map['caption'] as String?,
      );
    }).toList();
  }

  Future<void> saveReaction(String messagePublicId, String reaction) async {
  final db = await database;
  await db.insert(
    'message_reactions',
    {
      'message_public_id': messagePublicId,
      'reaction': reaction,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> removeReaction(String messagePublicId) async {
  final db = await database;
  await db.delete(
    'message_reactions',
    where: 'message_public_id = ?',
    whereArgs: [messagePublicId],
  );
}

Future<Map<String, String>> getAllReactions() async {
  final db = await database;
  final List<Map<String, dynamic>> maps =
      await db.query('message_reactions');
  return {
    for (final row in maps)
      row['message_public_id'] as String: row['reaction'] as String,
  };
}

  /// Close DB Connection
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
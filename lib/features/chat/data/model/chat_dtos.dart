import '../../domain/entities/chat_entities.dart';

class ChatEnquiryModel extends ChatEnquiry {
  const ChatEnquiryModel({
    required super.id,
    required super.sellId,
    required super.productTitle,
    required super.productPrice,
    required super.productImage,
    required super.peerName,
    required super.peerPhone,
    required super.peerEmail,
    required super.peerAddress,
    required super.peerPhoto,
    required super.myUnread,
    required super.lastMessage,
    required super.lastAt,
  });

  factory ChatEnquiryModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '') ?? 0;
    }
    return ChatEnquiryModel(
      id: parseInt(json['id']),
      sellId: parseInt(json['sell_id']),
      productTitle: json['product_title']?.toString() ?? '',
      productPrice: json['product_price']?.toString() ?? '',
      productImage: json['product_image']?.toString() ?? '',
      peerName: json['peer_name']?.toString() ?? '',
      peerPhone: json['peer_phone']?.toString() ?? '',
      peerEmail: json['peer_email']?.toString() ?? '',
      peerAddress: json['peer_address']?.toString() ?? '',
      peerPhoto: json['peer_photo']?.toString() ?? '',
      myUnread: parseInt(json['my_unread']),
      lastMessage: json['last_message']?.toString() ?? '',
      lastAt: json['last_at']?.toString() ?? '',
    );
  }
}

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.isMe,
    required super.senderName,
    required super.senderPhoto,
    required super.message,
    super.fileUrl,
    super.fileType,
    super.fileName,
    required super.isRead,
    required super.time,
    required super.date,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '') ?? 0;
    }
    return ChatMessageModel(
      id: parseInt(json['id']),
      isMe: json['is_me'] == true || json['is_me'] == 1,
      senderName: json['sender_name']?.toString() ?? '',
      senderPhoto: json['sender_photo']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      fileUrl: json['file_url']?.toString(),
      fileType: json['file_type']?.toString(),
      fileName: json['file_name']?.toString(),
      isRead: parseInt(json['is_read']),
      time: json['time']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
    );
  }
}

class ChatProductInfoModel extends ChatProductInfo {
  const ChatProductInfoModel({
    required super.title,
    required super.price,
    required super.image,
  });

  factory ChatProductInfoModel.fromJson(Map<String, dynamic> json) {
    return ChatProductInfoModel(
      title: json['title']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }
}

class ChatPeerInfoModel extends ChatPeerInfo {
  const ChatPeerInfoModel({
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    required super.photo,
  });

  factory ChatPeerInfoModel.fromJson(Map<String, dynamic> json) {
    return ChatPeerInfoModel(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      photo: json['photo']?.toString() ?? '',
    );
  }
}

class ChatInfoModel extends ChatInfo {
  const ChatInfoModel({
    required super.myRole,
    required super.peerLabel,
    required super.product,
    required super.peer,
  });

  factory ChatInfoModel.fromJson(Map<String, dynamic> json) {
    return ChatInfoModel(
      myRole: json['my_role']?.toString() ?? '',
      peerLabel: json['peer_label']?.toString() ?? '',
      product: ChatProductInfoModel.fromJson(
        Map<String, dynamic>.from(json['product'] ?? {}),
      ),
      peer: ChatPeerInfoModel.fromJson(
        Map<String, dynamic>.from(json['peer'] ?? {}),
      ),
    );
  }
}

class ChatEnquiry {
  final int id;
  final int sellId;
  final String productTitle;
  final String productPrice;
  final String productImage;
  final String peerName;
  final String peerPhone;
  final String peerEmail;
  final String peerAddress;
  final String peerPhoto;
  final int myUnread;
  final String lastMessage;
  final String lastAt;

  const ChatEnquiry({
    required this.id,
    required this.sellId,
    required this.productTitle,
    required this.productPrice,
    required this.productImage,
    required this.peerName,
    required this.peerPhone,
    required this.peerEmail,
    required this.peerAddress,
    required this.peerPhoto,
    required this.myUnread,
    required this.lastMessage,
    required this.lastAt,
  });
}

class ChatMessage {
  final int id;
  final bool isMe;
  final String senderName;
  final String senderPhoto;
  final String message;
  final String? fileUrl;
  final String? fileType;
  final String? fileName;
  final int isRead;
  final String time;
  final String date;

  const ChatMessage({
    required this.id,
    required this.isMe,
    required this.senderName,
    required this.senderPhoto,
    required this.message,
    this.fileUrl,
    this.fileType,
    this.fileName,
    required this.isRead,
    required this.time,
    required this.date,
  });
}

class ChatProductInfo {
  final String title;
  final String price;
  final String image;

  const ChatProductInfo({
    required this.title,
    required this.price,
    required this.image,
  });
}

class ChatPeerInfo {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String photo;

  const ChatPeerInfo({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.photo,
  });
}

class ChatInfo {
  final String myRole;
  final String peerLabel;
  final ChatProductInfo product;
  final ChatPeerInfo peer;

  const ChatInfo({
    required this.myRole,
    required this.peerLabel,
    required this.product,
    required this.peer,
  });
}

class ChatDetails {
  final List<ChatMessage> messages;
  final ChatInfo chatInfo;

  const ChatDetails({
    required this.messages,
    required this.chatInfo,
  });
}

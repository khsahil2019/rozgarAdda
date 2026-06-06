import '../../domain/entities/state_entity.dart';

class StateModel extends StateEntity {
  const StateModel({
    required super.id,
    required super.name,
    required super.language,
    required super.imageUrl,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: (json['s_id'] ?? 0) is int
          ? json['s_id'] as int
          : int.tryParse(json['s_id'].toString()) ?? 0,
      name: (json['s_name'] ?? '').toString(),
      language: (json['s_language'] ?? '').toString(),
      imageUrl: (json['s_image'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      's_id': id,
      's_name': name,
      's_language': language,
      's_image': imageUrl,
    };
  }
}

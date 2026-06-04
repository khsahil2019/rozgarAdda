import '../../domain/entities/job_role_entity.dart';

class JobRoleModel {
  final int id;
  final String name;
  final int categoryId;

  JobRoleModel({
    required this.id,
    required this.name,
    required this.categoryId,
  });

  factory JobRoleModel.fromJson(Map<String, dynamic> json) {
    return JobRoleModel(
      id: (json['id'] ?? 0) is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      categoryId: (json['category_id'] ?? 0) is int
          ? json['category_id'] as int
          : int.tryParse(json['category_id'].toString()) ?? 0,
    );
  }

  JobRoleEntity toEntity() {
    return JobRoleEntity(
      id: id,
      name: name,
      categoryId: categoryId,
    );
  }
}

import 'dart:convert';

class JobRole {
  final int id;
  final String name;
  final int categoryId;

  const JobRole({
    required this.id,
    required this.name,
    required this.categoryId,
  });

  factory JobRole.fromJson(Map<String, dynamic> json) {
    return JobRole(
      id: (json['id'] ?? 0) is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      categoryId: (json['category_id'] ?? 0) is int
          ? json['category_id'] as int
          : int.tryParse(json['category_id'].toString()) ?? 0,
    );
  }

  static List<JobRole> listFromResponseBody(String body) {
    final decoded = json.decode(body) as Map<String, dynamic>;
    final data = decoded['data'] as List<dynamic>? ?? <dynamic>[];
    return data
        .map((item) => JobRole.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

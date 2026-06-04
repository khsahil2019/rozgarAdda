import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/network_image_service.dart';
import '../controller/jobs_controller.dart';
import '../../domain/entities/job_category.dart';
import '../../domain/entities/job_role_entity.dart';
import 'available_jobs_screen.dart';

class ExploreJobsScreen extends StatefulWidget {
  final JobCategory initialCategory;

  const ExploreJobsScreen({super.key, required this.initialCategory});

  @override
  State<ExploreJobsScreen> createState() => _ExploreJobsScreenState();
}

class _ExploreJobsScreenState extends State<ExploreJobsScreen> {
  late final JobsController controller;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.find<JobsController>();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    // Fetch job roles for this category
    controller.fetchJobRoles(widget.initialCategory.id);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F8),
      appBar: AppBar(
        title: Text(
          widget.initialCategory.name,
          style: const TextStyle(
            color: Color(0xFF17181C),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF17181C)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Color(0xFF17181C), fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search roles...',
                    hintStyle: const TextStyle(color: Color(0xFF9AA0AA), fontSize: 15),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF72757F),
                      size: 22,
                    ),
                    suffixIcon: Obx(() {
                      if (searchQuery.value.isNotEmpty) {
                        return IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            searchController.clear();
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            // Roles Grid
            Expanded(
              child: Obx(() {
                if (controller.isLoadingJobRoles.value &&
                    controller.jobRoles.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0F5FFF),
                    ),
                  );
                }

                if (controller.jobRolesError.value != null &&
                    controller.jobRoles.isEmpty) {
                  return _buildErrorState();
                }

                final query = searchQuery.value.toLowerCase().trim();
                final filtered = controller.jobRoles.where((role) {
                  return role.name.toLowerCase().contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No roles found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF72757F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final role = filtered[index];
                    return _buildRoleCard(context, role);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, JobRoleEntity role) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              controller.selectRole(role);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AvailableJobsScreen(role: role),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: const Color(0xFFF7F8FB),
                    child: NetworkImageService(
                      imageUrl: widget.initialCategory.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.work_outline_rounded,
                          color: Color(0xFF0F5FFF),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    role.name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF17181C),
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              controller.jobRolesError.value ?? 'Unable to load roles',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.fetchJobRoles(widget.initialCategory.id),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC400),
                foregroundColor: const Color(0xFF17181C),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

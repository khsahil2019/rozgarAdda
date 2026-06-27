import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/profile_controller.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  late final ProfileController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ProfileController>();
    _ctrl.loadApplications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF17181C), size: 20),
        ),
        title: const Text(
          'My Applications',
          style: TextStyle(
            color: Color(0xFF17181C),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (_ctrl.isLoadingApplications.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1400FF)),
          );
        }
        if (_ctrl.applicationsError.value != null) {
          return _ErrorView(
            message: _ctrl.applicationsError.value!,
            onRetry: _ctrl.loadApplications,
          );
        }
        if (_ctrl.applications.isEmpty) {
          return const _EmptyView();
        }
        return RefreshIndicator(
          color: const Color(0xFF1400FF),
          onRefresh: _ctrl.loadApplications,
          child: ListView.separated(
            padding: EdgeInsets.all(16.sp),
            itemCount: _ctrl.applications.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.sp),
            itemBuilder: (_, index) =>
                _ApplicationCard(app: _ctrl.applications[index]),
          ),
        );
      }),
    );
  }
}

// ── Application Card ─────────────────────────────────────────────────────────

class _ApplicationCard extends StatelessWidget {
  final dynamic app;
  const _ApplicationCard({required this.app});

  Color get _statusColor {
    switch (app.status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF2E7D32);
      case 'rejected':
        return const Color(0xFFDD3344);
      default:
        return const Color(0xFFF57C00);
    }
  }

  Color get _statusBg {
    switch (app.status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFFE8F5E9);
      case 'rejected':
        return const Color(0xFFFFEBEB);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  String get _salaryFormatted {
    final raw = double.tryParse(app.expectedSalary) ?? 0;
    final formatter = NumberFormat('#,##,##0', 'en_IN');
    return '₹${formatter.format(raw.toInt())}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.work_outline_rounded,
                  color: Color(0xFF1400FF),
                  size: 22,
                ),
              ),
              SizedBox(width: 12.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.jobTitle,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF17181C),
                      ),
                    ),
                    SizedBox(height: 2.sp),
                    Text(
                      app.companyName,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF72757F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  app.status[0].toUpperCase() + app.status.substring(1),
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.sp),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          SizedBox(height: 12.sp),
          Row(
            children: [
              _InfoChip(
                icon: Icons.calendar_today_outlined,
                label: app.appliedOn,
              ),
              SizedBox(width: 12.sp),
              _InfoChip(
                icon: Icons.timer_outlined,
                label: app.experience,
              ),
              SizedBox(width: 12.sp),
              _InfoChip(
                icon: Icons.currency_rupee_rounded,
                label: _salaryFormatted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF8A8FA3)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF72757F),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Empty & Error Views ───────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.work_outline_rounded,
                color: Color(0xFF1400FF), size: 38),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Applications Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF17181C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start applying to jobs and\nyour applications will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF8A8FA3)),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Color(0xFF8A8FA3), size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF72757F), fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1400FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

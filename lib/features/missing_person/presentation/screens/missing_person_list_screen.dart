import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import 'package:rojgar/localization/app_localizations.dart';
import '../../domain/entities/missing_person.dart';
import '../bindings/missing_person_binding.dart';
import '../controller/missing_person_controller.dart';
import 'missing_person_detail_screen.dart';
import 'post_missing_person_screen.dart';

class _C {
  static const Color primary = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color greyText = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color fieldBg = Color(0xFFF8FAFC);
  static const Color dangerRed = Color(0xFFEF4444);
}

class MissingPersonListScreen extends GetView<MissingPersonController> {
  const MissingPersonListScreen({super.key});

  @override
  MissingPersonController get controller {
    if (!Get.isRegistered<MissingPersonController>()) {
      MissingPersonBinding().dependencies();
    }
    return Get.find<MissingPersonController>();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MissingPersonController>()) {
      MissingPersonBinding().dependencies();
    }
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
        backgroundColor: _C.scaffoldBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: AppBackButton(
              onPressed: () => Navigator.maybePop(context),
              tooltip: 'Back',
            ),
          ),
          title: Text(
            l10n.text('missing_persons').isNotEmpty ? l10n.text('missing_persons') : 'Missing Persons',
            style: const TextStyle(
              color: _C.darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              tooltip: 'Refresh Feed',
              icon: const Icon(Icons.refresh_rounded, color: _C.primary, size: 22),
              onPressed: () => controller.fetchMissingPersons(),
            ),
            const SizedBox(width: 4),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: _C.borderGrey),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: _C.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: () {
            Get.to(() => const PostMissingPersonScreen());
          },
          icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Report Missing',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search and Filter Hub
              _buildSearchAndFilters(context),
              const Divider(height: 1, color: _C.borderGrey),

              // Main Feed Area
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildLoadingState();
                  }

                  if (controller.errorMessage.isNotEmpty) {
                    return _buildErrorState();
                  }

                  final list = controller.filteredPersons;

                  if (list.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.fetchMissingPersons(),
                    color: _C.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final person = list[index];
                        return _buildMissingPersonCard(context, person);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          // Search Input
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: _C.fieldBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _C.borderGrey),
            ),
            child: TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              style: const TextStyle(color: _C.darkText, fontSize: 13.5, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Search by name, city, state, or ID...',
                hintStyle: const TextStyle(color: _C.greyText, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: _C.primary, size: 20),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear_rounded, color: _C.greyText, size: 18),
                      onPressed: () => controller.searchQuery.value = '',
                    );
                  }
                  return const SizedBox.shrink();
                }),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filters Row
          Row(
            children: [
              // Gender Filter
              Expanded(
                child: Obx(() {
                  return _buildFilterDropdown(
                    label: 'Gender',
                    value: controller.selectedGender.value,
                    options: const ['All', 'Male', 'Female'],
                    onChanged: (val) {
                      if (val != null) controller.selectedGender.value = val;
                    },
                  );
                }),
              ),
              const SizedBox(width: 10),

              // State Filter
              Expanded(
                child: Obx(() {
                  return _buildFilterDropdown(
                    label: 'State',
                    value: controller.selectedState.value,
                    options: controller.availableStates,
                    onChanged: (val) {
                      if (val != null) controller.selectedState.value = val;
                    },
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value != 'All';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? _C.primary.withValues(alpha: 0.08) : _C.fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? _C.primary : _C.borderGrey,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : options.first,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isSelected ? _C.primary : _C.greyText,
            size: 20,
          ),
          style: TextStyle(
            color: isSelected ? _C.primary : _C.darkText,
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
          hint: Text(label),
          onChanged: onChanged,
          items: options.map<DropdownMenuItem<String>>((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val == 'All' ? '$label: All' : val),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMissingPersonCard(BuildContext context, MissingPerson person) {
    final formattedDate = person.missingDatetime != null
        ? DateFormat('dd MMM yyyy').format(person.missingDatetime!)
        : 'Date Unknown';

    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.borderGrey),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MissingPersonDetailScreen(person: person),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail Photo with Emergency Badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 96,
                        height: 110,
                        child: person.fullImage1Url.isNotEmpty
                            ? Image.network(
                                person.fullImage1Url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                              )
                            : _buildImagePlaceholder(),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _C.dangerRed,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: const Text(
                          'MISSING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Case Details Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Gender/Age Chips
                      Text(
                        person.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: _C.darkText,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Age, Gender, and Relation
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (person.age > 0)
                            _buildMiniChip('${person.age} Yrs'),
                          if (person.gender.isNotEmpty)
                            _buildMiniChip(person.gender),
                          if (person.relationInfo.isNotEmpty)
                            _buildMiniChip(person.relationInfo),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Location Details
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: _C.primary),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              [person.district, person.state].where((e) => e.isNotEmpty).join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: _C.darkText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Missing Date
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: _C.greyText),
                          const SizedBox(width: 3),
                          Text(
                            'Missing since $formattedDate',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: _C.greyText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _C.borderGrey),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: _C.darkText,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFEFF6FF),
      child: const Center(
        child: Icon(Icons.person_rounded, size: 40, color: _C.primary),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: _C.primary),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: _C.dangerRed),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: _C.darkText, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => controller.fetchMissingPersons(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _C.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_search_rounded, size: 42, color: _C.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Missing Person Records',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _C.darkText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'No cases match your active search filters',
              style: TextStyle(fontSize: 13, color: _C.greyText),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.primary,
                side: const BorderSide(color: _C.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                controller.searchQuery.value = '';
                controller.selectedGender.value = 'All';
                controller.selectedState.value = 'All';
              },
              child: const Text('Reset All Filters', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

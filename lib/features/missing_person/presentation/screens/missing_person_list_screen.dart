import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rojgar/localization/app_localizations.dart';
import '../../domain/entities/missing_person.dart';
import '../bindings/missing_person_binding.dart';
import '../controller/missing_person_controller.dart';
import 'missing_person_detail_screen.dart';
import 'post_missing_person_screen.dart';

// Styling Colors (matching App Theme and News screen styles)
class _MPC {
  static const Color bg = Color(0xFFF4F5F9);
  static const Color navy = Color(0xFF1A1E3C);
  static const Color redAccent = Color(0xFFE53935);
  static const Color grey = Color(0xFF8A8FA3);
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

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const PostMissingPersonScreen());
        },
        child: const Icon(Icons.person_add_alt, color: Colors.white),
      ),
      backgroundColor: _MPC.bg,
      appBar: AppBar(
        backgroundColor: _MPC.navy,
        foregroundColor: Colors.white,
        title: Text(
          l10n.text('missing_persons'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.white,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.fetchMissingPersons(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter Bar
            _buildSearchAndFilters(context),

            // Main Content Area
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoadingState();
                }

                if (controller.errorMessage.isNotEmpty) {
                  return _buildErrorState(l10n);
                }

                if (controller.filteredPersons.isEmpty) {
                  return _buildEmptyState(l10n);
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchMissingPersons(),
                  color: _MPC.navy,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: controller.filteredPersons.length,
                    itemBuilder: (context, index) {
                      final person = controller.filteredPersons[index];
                      return _buildMissingPersonCard(context, person);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search & Filter Bars ──────────────────────────────────────────────────
  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          // Search Input
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: InputDecoration(
                hintText: 'Search by name, district, state...',
                hintStyle: const TextStyle(color: _MPC.grey, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: _MPC.grey,
                  size: 20,
                ),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        color: _MPC.grey,
                        size: 18,
                      ),
                      onPressed: () {
                        controller.searchQuery.value = '';
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filters Row (Gender & State dropdown/sheets)
          Row(
            children: [
              // Gender Filter Chip
              Expanded(
                child: Obx(() {
                  return _buildFilterDropdown(
                    context: context,
                    label: 'Gender',
                    value: controller.selectedGender.value,
                    options: const ['All', 'Male', 'Female'],
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedGender.value = val;
                      }
                    },
                  );
                }),
              ),
              const SizedBox(width: 12),
              // State Filter Chip
              Expanded(
                child: Obx(() {
                  return _buildFilterDropdown(
                    context: context,
                    label: 'State',
                    value: controller.selectedState.value,
                    options: controller.availableStates,
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedState.value = val;
                      }
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

  // ── Filter Dropdown Selector ──────────────────────────────────────────────
  Widget _buildFilterDropdown({
    required BuildContext context,
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value != 'All';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? _MPC.navy.withValues(alpha: 0.05)
            : const Color(0xFFF0F1F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? _MPC.navy : Colors.transparent,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _MPC.grey,
            size: 20,
          ),
          style: TextStyle(
            color: isSelected ? _MPC.navy : _MPC.navy.withValues(alpha: 0.8),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          hint: Text(label),
          onChanged: onChanged,
          items: options.map<DropdownMenuItem<String>>((String val) {
            return DropdownMenuItem<String>(value: val, child: Text(val));
          }).toList(),
        ),
      ),
    );
  }

  // ── Missing Person Card Renderer ──────────────────────────────────────────
  Widget _buildMissingPersonCard(BuildContext context, MissingPerson person) {
    final formattedDate = person.missingDatetime != null
        ? DateFormat('dd MMM yyyy').format(person.missingDatetime!)
        : 'Unknown';

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
              // Photo Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 96,
                  height: 104,
                  child: person.fullImage1Url.isNotEmpty
                      ? Image.network(
                          person.fullImage1Url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        )
                      : _buildImagePlaceholder(),
                ),
              ),
              const SizedBox(width: 14),

              // Detail Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge status and Gender
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _MPC.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'MISSING',
                            style: TextStyle(
                              color: _MPC.redAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F1F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            person.gender,
                            style: const TextStyle(
                              color: _MPC.navy,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Name
                    Text(
                      person.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _MPC.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Age and date
                    Row(
                      children: [
                        Text(
                          'Age: ${person.age} yrs',
                          style: const TextStyle(
                            color: _MPC.navy,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: _MPC.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Since: $formattedDate',
                            style: const TextStyle(
                              color: _MPC.grey,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Location Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: _MPC.redAccent,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${person.district}, ${person.state}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _MPC.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
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
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFE2E4EB),
      child: const Icon(Icons.person_rounded, color: _MPC.grey, size: 40),
    );
  }

  // ── Skeletons / Loading Screen ────────────────────────────────────────────
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (ctx, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 96,
                  height: 104,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.grey.shade200,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 140,
                        height: 16,
                        color: Colors.grey.shade200,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 110,
                        height: 12,
                        color: Colors.grey.shade200,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.grey.shade200,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Error View ───────────────────────────────────────────────────────────
  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: _MPC.grey),
            const SizedBox(height: 16),
            const Text(
              'Failed to load missing persons feed.',
              style: TextStyle(
                color: _MPC.navy,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              style: const TextStyle(color: _MPC.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.fetchMissingPersons(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _MPC.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty View ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.assignment_ind_outlined,
              size: 72,
              color: _MPC.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Missing Persons Found',
              style: TextStyle(
                color: _MPC.navy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting search query or filters.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _MPC.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => controller.resetFilters(),
              child: const Text(
                'Reset Filters',
                style: TextStyle(
                  color: _MPC.navy,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/missing_person.dart';

class _MPDC {
  static const Color bg = Color(0xFFF8FAFC);
  static const Color navy = Color(0xFF0F172A);
  static const Color redAccent = Color(0xFFEF4444);
  static const Color grey = Color(0xFF64748B);
  static const Color green = Color(0xFF10B981);
  static const Color border = Color(0xFFE2E8F0);
  static const Color gold = Color(0xFFD4A017);
}

class MissingPersonDetailScreen extends StatefulWidget {
  final MissingPerson person;

  const MissingPersonDetailScreen({super.key, required this.person});

  @override
  State<MissingPersonDetailScreen> createState() => _MissingPersonDetailScreenState();
}

class _MissingPersonDetailScreenState extends State<MissingPersonDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanNumber.isEmpty) {
      Get.snackbar(
        'Call Error',
        'No phone number available.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _MPDC.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    final Uri url = Uri.parse('tel:$cleanNumber');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      Get.snackbar(
        'Call Error',
        'Could not initiate phone call.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _MPDC.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _launchBrowser(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        Get.snackbar(
          'Error',
          'Could not open link.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: _MPDC.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid link format.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _MPDC.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final person = widget.person;
    final formattedDate = person.missingDatetime != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(person.missingDatetime!)
        : 'Unknown';

    // List of images to display in carousel
    final List<String> imageUrls = [
      if (person.fullImage1Url.isNotEmpty) person.fullImage1Url,
      if (person.fullImage2Url.isNotEmpty) person.fullImage2Url,
    ];

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
        backgroundColor: _MPDC.bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'Missing Person Profile',
            style: TextStyle(
              color: _MPDC.navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: false,
          leading: Center(
            child: AppBackButton(
              onPressed: () => Navigator.maybePop(context),
              tooltip: 'Back',
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _MPDC.border),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Carousel Header
              if (imageUrls.isNotEmpty)
                _buildImageCarousel(imageUrls)
              else
                _buildNoImagePlaceholder(),

              Padding(
                padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & Title
                  _buildHeaderSection(person, formattedDate),
                  const SizedBox(height: 16),

                  // Section 1: Physical Description
                  _buildSectionTitle('Physical Description', Icons.accessibility_new_rounded),
                  _buildDescriptionCard(person),
                  const SizedBox(height: 16),

                  // Section 2: Missing Circumstances
                  _buildSectionTitle('Missing Details', Icons.info_outline_rounded),
                  _buildMissingDetailsCard(person, formattedDate),
                  const SizedBox(height: 16),

                  // Section 3: Complainant & Relative Details
                  _buildSectionTitle('Contact/Relative Details', Icons.contact_phone_outlined),
                  _buildRelativeDetailsCard(person),
                  const SizedBox(height: 16),

                  // Section 4: FIR Details
                  if (person.firNumber.isNotEmpty || person.fullFirCopyUrl.isNotEmpty) ...[
                    _buildSectionTitle('Legal / FIR Information', Icons.gavel_rounded),
                    _buildFirDetailsCard(person),
                    const SizedBox(height: 16),
                  ],

                  // Section 5: Police Station Details
                  _buildSectionTitle('Investigating Authority', Icons.local_police_outlined),
                  _buildPoliceDetailsCard(person),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(person),
      ),
    );
  }

  // ── Image PageView Carousel ───────────────────────────────────────────────
  Widget _buildImageCarousel(List<String> urls) {
    return Stack(
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: urls.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                urls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFE2E4EB),
                  child: const Icon(Icons.broken_image_rounded, size: 64, color: _MPDC.grey),
                ),
              );
            },
          ),
        ),
        // Indicators
        if (urls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                urls.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == index ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index ? Colors.white : Colors.white60,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      height: 220,
      width: double.infinity,
      color: const Color(0xFFE2E4EB),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_rounded, size: 80, color: _MPDC.grey),
          SizedBox(height: 8),
          Text('No Image Available', style: TextStyle(color: _MPDC.grey, fontSize: 14)),
        ],
      ),
    );
  }

  // ── Header Section ────────────────────────────────────────────────────────
  Widget _buildHeaderSection(MissingPerson person, String formattedDate) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _MPDC.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 12, color: _MPDC.redAccent),
                    SizedBox(width: 4),
                    Text(
                      'MISSING',
                      style: TextStyle(
                        color: _MPDC.redAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Case status: ${person.status.toUpperCase()}',
                style: TextStyle(
                  color: person.status == 'approved' ? _MPDC.green : _MPDC.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            person.name,
            style: const TextStyle(
              color: _MPDC.navy,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildBadge(person.gender, Icons.wc_rounded),
              const SizedBox(width: 8),
              _buildBadge('${person.age} Years Old', Icons.calendar_today_rounded),
            ],
          ),
          const Divider(height: 24, thickness: 0.8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded, size: 16, color: _MPDC.redAccent),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last Known Location',
                      style: TextStyle(color: _MPDC.grey, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      person.fullAddress,
                      style: const TextStyle(color: _MPDC.navy, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _MPDC.navy),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: _MPDC.navy, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ── Helper Titles ─────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _MPDC.navy),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: _MPDC.navy,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ── Physical Details Card ──────────────────────────────────────────────────
  Widget _buildDescriptionCard(MissingPerson person) {
    return _buildContainerCard(
      child: Column(
        children: [
          _buildDetailRow('Height Range', '${person.heightFrom} to ${person.heightTo}'),
          _buildDetailRow('Mental Status', person.mentalStatus),
          _buildDetailRow('Clothes Worn', person.clothes),
          _buildDetailRow('Distinguishing Marks', person.identityMark, isLast: true),
        ],
      ),
    );
  }

  // ── Missing Details Card ───────────────────────────────────────────────────
  Widget _buildMissingDetailsCard(MissingPerson person, String formattedDate) {
    return _buildContainerCard(
      child: Column(
        children: [
          _buildDetailRow('Missing Since', formattedDate),
          _buildDetailRow('Reason / Circumstance', person.reason, isLast: true),
        ],
      ),
    );
  }

  // ── Relative/Contact Details Card ──────────────────────────────────────────
  Widget _buildRelativeDetailsCard(MissingPerson person) {
    return _buildContainerCard(
      child: Column(
        children: [
          _buildDetailRow('Reported By', person.complaintName),
          _buildDetailRow('Relation', person.relationType),
          _buildDetailRow('Relation Details', person.relationInfo),
          _buildDetailRow('Relative Address', person.relativeAddress),
          _buildDetailRow('Complainant Contact', person.complaintMobile),
          _buildDetailRow('Reporter Identity Mark', person.complaintIdentityMark),
          _buildDetailRow('Report Reason', person.complaintReason, isLast: true),
        ],
      ),
    );
  }

  // ── FIR Legal Card ─────────────────────────────────────────────────────────
  Widget _buildFirDetailsCard(MissingPerson person) {
    return _buildContainerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (person.firNumber.isNotEmpty)
            _buildDetailRow('FIR Number', person.firNumber, isLast: person.fullFirCopyUrl.isEmpty),
          if (person.fullFirCopyUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _launchBrowser(person.fullFirCopyUrl),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: _MPDC.navy.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _MPDC.navy.withValues(alpha: 0.15)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.file_open_rounded, color: _MPDC.navy, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'View Registered FIR Copy',
                      style: TextStyle(
                        color: _MPDC.navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Police Details Card ────────────────────────────────────────────────────
  Widget _buildPoliceDetailsCard(MissingPerson person) {
    return _buildContainerCard(
      child: Column(
        children: [
          _buildDetailRow('Assigned Sub-Inspector', person.subInspector.isEmpty ? 'Not Assigned' : person.subInspector),
          _buildDetailRow('Police Station Phone', person.policeStationNo.isEmpty ? 'N/A' : person.policeStationNo),
          _buildDetailRow('SHO Contact Number', person.shoNo.isEmpty ? 'N/A' : person.shoNo, isLast: true),
        ],
      ),
    );
  }

  // ── Card container utilities ──────────────────────────────────────────────
  Widget _buildContainerCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    final cleanValue = value.trim().isEmpty ? 'N/A' : value.trim();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _MPDC.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Text(
                  cleanValue,
                  style: const TextStyle(
                    color: _MPDC.navy,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 12, thickness: 0.5),
      ],
    );
  }

  // ── Bottom Call Actions Bar ───────────────────────────────────────────────
  Widget _buildBottomActionBar(MissingPerson person) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Complainant / Family contact button
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _MPDC.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _makePhoneCall(
                person.complaintMobile.isNotEmpty ? person.complaintMobile : person.mobile,
              ),
              icon: const Icon(Icons.call, size: 18),
              label: const Text(
                'Contact Family',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Police call button
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _MPDC.redAccent,
                side: const BorderSide(color: _MPDC.redAccent, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final policeNo = person.shoNo.isNotEmpty
                    ? person.shoNo
                    : (person.policeStationNo.isNotEmpty ? person.policeStationNo : '100');
                _makePhoneCall(policeNo);
              },
              icon: const Icon(Icons.shield_outlined, size: 18),
              label: const Text(
                'Contact Police',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

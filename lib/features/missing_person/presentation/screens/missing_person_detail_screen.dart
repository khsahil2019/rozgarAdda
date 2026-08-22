import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/missing_person.dart';

class _C {
  static const Color primary = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color greyText = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
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
        'Contact Unavailable',
        'No valid phone number is available for this case.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.dangerRed,
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
    } catch (_) {
      Get.snackbar(
        'Call Error',
        'Could not initiate phone call to $cleanNumber.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.dangerRed,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _openFirDocument(String urlString) async {
    if (urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not open FIR document.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.dangerRed,
        colorText: Colors.white,
      );
    }
  }

  void _shareCase() {
    final person = widget.person;
    final location = [person.locality, person.district, person.state].where((e) => e.isNotEmpty).join(', ');
    final date = person.missingDatetime != null
        ? DateFormat('dd MMM yyyy').format(person.missingDatetime!)
        : 'Unknown';

    final text = '🚨 *URGENT MISSING PERSON ALERT* 🚨\n\n'
        '• *Name*: ${person.name}\n'
        '• *Age*: ${person.age} Yrs (${person.gender})\n'
        '• *Missing From*: $location\n'
        '• *Missing Since*: $date\n'
        '• *Contact Family*: ${person.complaintMobile.isNotEmpty ? person.complaintMobile : person.mobile}\n\n'
        'Please share and inform authorities if you have any leads. Shared via Rozgar Adda App.';

    Share.share(text, subject: 'Missing Person: ${person.name}');
  }

  @override
  Widget build(BuildContext context) {
    final person = widget.person;
    final formattedDate = person.missingDatetime != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(person.missingDatetime!)
        : 'Date Unknown';

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
        backgroundColor: _C.scaffoldBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'Missing Person Details',
            style: TextStyle(
              color: _C.darkText,
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
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded, color: _C.primary, size: 20),
              tooltip: 'Share Alert',
              onPressed: _shareCase,
            ),
            const SizedBox(width: 6),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: _C.borderGrey),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Image Carousel ─────────────────────────
              if (imageUrls.isNotEmpty)
                _buildImageCarousel(imageUrls)
              else
                _buildNoImageHeader(),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero Title Card with Emergency Badge ───────
                    _buildHeroTitleCard(person, formattedDate),
                    const SizedBox(height: 14),

                    // ── 1-Tap Emergency Contact Bar ───────────────
                    _buildEmergencyActionButtons(person),
                    const SizedBox(height: 16),

                    // ── Physical Description Card ──────────────────
                    _buildCardSection(
                      icon: Icons.accessibility_new_rounded,
                      iconColor: _C.primary,
                      title: 'Physical Description',
                      children: [
                        _buildDetailRow('Age', '${person.age} Years'),
                        _buildDetailRow('Gender', person.gender),
                        if (person.relationInfo.isNotEmpty)
                          _buildDetailRow('Guardian Info', person.relationInfo),
                        if (person.heightFrom.isNotEmpty || person.heightTo.isNotEmpty)
                          _buildDetailRow('Height Range', '${person.heightFrom} - ${person.heightTo}'),
                        if (person.mentalStatus.isNotEmpty)
                          _buildDetailRow('Mental Condition', person.mentalStatus),
                        if (person.identityMark.isNotEmpty)
                          _buildDetailRow('Identity Marks / Tattoos', person.identityMark),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Incident & Last Seen Details ───────────────
                    _buildCardSection(
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Last Seen & Incident Circumstances',
                      children: [
                        _buildDetailRow('Missing Date/Time', formattedDate),
                        _buildDetailRow('State & District', '${person.district}, ${person.state}'),
                        if (person.locality.isNotEmpty || person.village.isNotEmpty)
                          _buildDetailRow('Locality / Village', '${person.locality} ${person.village}'.trim()),
                        if (person.pincode.isNotEmpty)
                          _buildDetailRow('Pincode', person.pincode),
                        if (person.clothes.isNotEmpty)
                          _buildDetailRow('Clothes Worn', person.clothes),
                        if (person.reason.isNotEmpty)
                          _buildDetailRow('Probable Reason', person.reason),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Police & FIR Information ──────────────────
                    _buildCardSection(
                      icon: Icons.local_police_rounded,
                      iconColor: const Color(0xFF0EA5E9),
                      title: 'Police & FIR Records',
                      children: [
                        _buildDetailRow('FIR Number', person.firNumber.isNotEmpty ? person.firNumber : 'Not registered yet'),
                        if (person.policeStationNo.isNotEmpty)
                          _buildDetailRow('Station Contact', person.policeStationNo, isPhone: true),
                        if (person.subInspector.isNotEmpty)
                          _buildDetailRow('Assigned SI', person.subInspector),
                        if (person.shoNo.isNotEmpty)
                          _buildDetailRow('SHO Contact', person.shoNo, isPhone: true),
                        if (person.fullFirCopyUrl.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _C.primary,
                              side: const BorderSide(color: _C.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _openFirDocument(person.fullFirCopyUrl),
                            icon: const Icon(Icons.description_outlined, size: 16),
                            label: const Text('View Attached FIR Copy', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Complainant / Family Information ──────────
                    _buildCardSection(
                      icon: Icons.contact_phone_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'Complainant & Family Contact',
                      children: [
                        _buildDetailRow('Reporter Name', person.complaintName),
                        if (person.relationType.isNotEmpty)
                          _buildDetailRow('Relation', person.relationType),
                        _buildDetailRow('Contact Phone', person.complaintMobile, isPhone: true),
                        if (person.relativeAddress.isNotEmpty)
                          _buildDetailRow('Residential Address', person.relativeAddress),
                        if (person.complaintReason.isNotEmpty)
                          _buildDetailRow('Complaint Reason', person.complaintReason),
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

  Widget _buildImageCarousel(List<String> imageUrls) {
    return Container(
      color: Colors.black,
      height: 280,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: imageUrls.length,
            onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
            itemBuilder: (context, idx) {
              return Image.network(
                imageUrls[idx],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildNoImageHeader(),
              );
            },
          ),
          if (imageUrls.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imageUrls.length, (idx) {
                  final active = _currentImageIndex == idx;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoImageHeader() {
    return Container(
      height: 200,
      color: const Color(0xFFEFF6FF),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_rounded, size: 64, color: _C.primary),
            SizedBox(height: 8),
            Text(
              'No Photograph Available',
              style: TextStyle(color: _C.greyText, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroTitleCard(MissingPerson person, String formattedDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.borderGrey),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
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
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.dangerRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'MISSING PERSON ALERT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'ID: #${person.id}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _C.greyText),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            person.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _C.darkText,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Missing since $formattedDate',
            style: const TextStyle(fontSize: 12.5, color: _C.greyText, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyActionButtons(MissingPerson person) {
    final familyPhone = person.complaintMobile.isNotEmpty ? person.complaintMobile : person.mobile;
    final policePhone = person.policeStationNo.isNotEmpty ? person.policeStationNo : person.shoNo;

    return Row(
      children: [
        if (familyPhone.isNotEmpty)
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.successGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => _makePhoneCall(familyPhone),
              icon: const Icon(Icons.phone_rounded, size: 16),
              label: const Text('Call Family', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ),
        if (familyPhone.isNotEmpty && policePhone.isNotEmpty)
          const SizedBox(width: 10),
        if (policePhone.isNotEmpty)
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => _makePhoneCall(policePhone),
              icon: const Icon(Icons.local_police_rounded, size: 16),
              label: const Text('Call Police', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ),
      ],
    );
  }

  Widget _buildCardSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.borderGrey),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
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
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: _C.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: _C.borderGrey),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPhone = false}) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: _C.greyText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.darkText,
                    ),
                  ),
                ),
                if (isPhone)
                  GestureDetector(
                    onTap: () => _makePhoneCall(value),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_rounded, color: Color(0xFF10B981), size: 14),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

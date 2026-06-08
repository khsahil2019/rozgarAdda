import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/floating_navbar.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/main.dart';
import '../../domain/entities/state_entity.dart';
import '../controller/select_state_controller.dart';

class AC {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color darkText = Color(0xFF111111);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color lightGrey = Color(0xFFE4E4E4);
  static const Color scaffoldBg = Color(0xFFFFFFFF);
  static const Color searchBg = Color(0xFFF4F4F8);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color hindiBlue = Color(0xFF1400FF);
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class SelectStateScreen extends StatefulWidget {
  const SelectStateScreen({
    super.key,
    this.successMessage,
    this.fromDashboard = false,
  });

  final String? successMessage;
  final bool fromDashboard;

  @override
  State<SelectStateScreen> createState() => _SelectStateScreenState();
}

class _SelectStateScreenState extends State<SelectStateScreen> {
  late final SelectStateController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SelectStateController>();
    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginSuccessDialog(widget.successMessage!);
      });
    }
  }

  void _showLoginSuccessDialog(String username) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Login Successful'),
          content: Text(
            'You logged in successfully with this email: $username',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hPad = size.width * 0.045;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AC.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AC.scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AC.darkText, size: 24),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        centerTitle: true,
        title: Text(
          l10n.text('select_state_appbar'),
          style: const TextStyle(
            color: AC.darkText,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AC.lightGrey),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),

                  // ── Progress row ──────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.text('select_state_step_label'),
                        style: const TextStyle(
                          color: AC.primaryBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        l10n.text('select_state_progress'),
                        style: const TextStyle(
                          color: AC.greyText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                       height: 6,
                       width: double.infinity,
                       color: AC.lightGrey,
                       child: FractionallySizedBox(
                         alignment: Alignment.centerLeft,
                         widthFactor: 0.66,
                         child: Container(
                           decoration: BoxDecoration(
                             color: AC.yellow,
                             borderRadius: BorderRadius.circular(8),
                           ),
                         ),
                       ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Heading ───────────────────
                  Text(
                    l10n.text('select_state_heading'),
                    style: const TextStyle(
                      color: AC.darkText,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    l10n.text('select_state_subheading'),
                    style: const TextStyle(
                      color: AC.greyText,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 22),

                  // ── Search ────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: AC.searchBg,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AC.lightGrey, width: 1.2),
                    ),
                    child: TextField(
                      style: const TextStyle(color: AC.darkText, fontSize: 14),
                      onChanged: (value) {
                        controller.updateSearchQuery(value);
                      },
                      decoration: InputDecoration(
                        hintText: l10n.text('select_state_search_hint'),
                        hintStyle: const TextStyle(
                          color: AC.greyText,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AC.greyText,
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ── State list (from API) ─────
                  Obx(() {
                    if (controller.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Center(
                          child: CircularProgressIndicator(color: AC.primaryBlue),
                        ),
                      );
                    } else if (controller.error != null && controller.states.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: controller.fetchStates,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final filteredStates = controller.filteredStates;
                    if (filteredStates.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Text(
                          'No states found',
                          style: TextStyle(color: AC.greyText, fontSize: 14),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredStates.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      itemBuilder: (context, index) {
                        final state = filteredStates[index];
                        return Obx(() {
                          final selected = state.id == controller.selectedStateId;
                          return GestureDetector(
                            onTap: () => controller.selectState(state.id),
                            child: _StateCard(state: state, selected: selected),
                          );
                        });
                      },
                    );
                  }),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Continue Button ────────────────
          Container(
            color: AC.scaffoldBg,
            padding: EdgeInsets.fromLTRB(
              hPad,
              12,
              hPad,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AC.primaryBlue,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AC.primaryBlue.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    _showLanguageDialogAndContinue(
                      context,
                      controller.selectedStateId,
                      widget.fromDashboard,
                      controller,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.text('continue'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showLanguageDialogAndContinue(
  BuildContext context,
  int? selectedStateId,
  bool fromDashboard,
  SelectStateController controller,
) async {
  final l10n = context.l10n;
  final currentCode = Localizations.localeOf(context).languageCode;
  String selectedCode = AppLocalizations.supportedLocales
          .map((e) => e.languageCode)
          .contains(currentCode)
      ? currentCode
      : 'en';

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(l10n.text('language_dialog_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.text('language_dialog_message')),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: AppLocalizations.languages.map((lang) {
                    return RadioListTile<String>(
                      title: Text('${lang.nativeName} (${lang.englishName})'),
                      value: lang.code,
                      groupValue: selectedCode,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => selectedCode = v);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.text('cancel')),
          ),
          TextButton(
            onPressed: () async {
              final locale = Locale(selectedCode);
              final appState = MyApp.of(context);
              await appState?.setLocale(locale);
              if (selectedStateId != null) {
                final selectedState = controller.states.firstWhereOrNull((s) => s.id == selectedStateId);
                if (selectedState != null) {
                  controller.saveSelection(selectedStateId, selectedState.name);
                }
              }
              if (context.mounted) {
                Navigator.of(ctx).pop();
                if (fromDashboard) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FloatingNavbarScreen(),
                    ),
                  );
                }
              }
            },
            child: Text(l10n.text('continue')),
          ),
        ],
      );
    },
  );
}

// ─────────────────────────────────────────────
// STATE CARD
// ─────────────────────────────────────────────
class LandmarkData {
  final String stateKey;
  final Color skyColor;

  const LandmarkData({required this.stateKey, required this.skyColor});
}

LandmarkData _getLandmarkData(String stateName) {
  final name = stateName.toLowerCase();
  if (name.contains('uttar pradesh')) {
    return const LandmarkData(stateKey: 'taj', skyColor: Color(0xFF87CEEB));
  } else if (name.contains('maharashtra')) {
    return const LandmarkData(stateKey: 'gateway', skyColor: Color(0xFF6B9BD2));
  } else if (name.contains('bihar')) {
    return const LandmarkData(stateKey: 'nalanda', skyColor: Color(0xFFC8860A));
  } else if (name.contains('rajasthan')) {
    return const LandmarkData(stateKey: 'hawa', skyColor: Color(0xFFE8A95C));
  } else if (name.contains('west bengal')) {
    return const LandmarkData(
      stateKey: 'victoria',
      skyColor: Color(0xFF4A8C5C),
    );
  } else if (name.contains('madhya pradesh')) {
    return const LandmarkData(
      stateKey: 'khajuraho',
      skyColor: Color(0xFF8B6914),
    );
  }
  return const LandmarkData(stateKey: 'gateway', skyColor: Color(0xFF6B9BD2));
}

class _StateCard extends StatelessWidget {
  final StateEntity state;
  final bool selected;

  const _StateCard({required this.state, required this.selected});

  @override
  Widget build(BuildContext context) {
    final lData = _getLandmarkData(state.name);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      transform: Matrix4.diagonal3Values(
        selected ? 1.03 : 1.0,
        selected ? 1.03 : 1.0,
        1.0,
      ),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        color: AC.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AC.primaryBlue : AC.lightGrey,
          width: selected ? 2.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: selected
                ? AC.primaryBlue.withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
            blurRadius: selected ? 16 : 8,
            offset: selected ? const Offset(0, 6) : const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: Container(
                    color: lData.skyColor.withOpacity(0.2),
                    child: state.imageUrl.isEmpty
                        ? _LandmarkIllustration(
                            stateKey: lData.stateKey,
                            skyColor: lData.skyColor,
                          )
                        : Image.network(
                            state.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _LandmarkIllustration(
                                stateKey: lData.stateKey,
                                skyColor: lData.skyColor,
                              );
                            },
                          ),
                  ),
                ),
              ),
              Container(height: 1.0, color: AC.lightGrey.withOpacity(0.6)),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AC.darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.language,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AC.hindiBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: AnimatedScale(
              scale: selected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AC.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AC.primaryBlue.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LANDMARK ILLUSTRATION (CustomPainter per state)
// ─────────────────────────────────────────────
class _LandmarkIllustration extends StatelessWidget {
  final String stateKey;
  final Color skyColor;

  const _LandmarkIllustration({required this.stateKey, required this.skyColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _LandmarkPainter(stateKey: stateKey, skyColor: skyColor),
      ),
    );
  }
}

class _LandmarkPainter extends CustomPainter {
  final String stateKey;
  final Color skyColor;

  const _LandmarkPainter({required this.stateKey, required this.skyColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Sky background
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [skyColor, skyColor.withOpacity(0.7)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    switch (stateKey) {
      case 'taj':
        _drawTaj(canvas, size);
        break;
      case 'gateway':
        _drawGateway(canvas, size);
        break;
      case 'nalanda':
        _drawNalanda(canvas, size);
        break;
      case 'hawa':
        _drawHawa(canvas, size);
        break;
      case 'victoria':
        _drawVictoria(canvas, size);
        break;
      case 'khajuraho':
        _drawKhajuraho(canvas, size);
        break;
      default:
        _drawGateway(canvas, size);
        break;
    }
  }

  // ── TAJ MAHAL ──
  void _drawTaj(Canvas canvas, Size s) {
    final p = Paint()..color = const Color(0xFFF5F0E8);

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.72, s.width, s.height * 0.28),
      Paint()..color = const Color(0xFF90C878),
    );

    // Reflecting pool
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.35,
          s.height * 0.6,
          s.width * 0.3,
          s.height * 0.12,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF7ABCE0),
    );

    // Main dome
    final domePath = Path();
    domePath.moveTo(s.width * 0.3, s.height * 0.6);
    domePath.lineTo(s.width * 0.3, s.height * 0.42);
    domePath.quadraticBezierTo(
      s.width * 0.5,
      s.height * 0.18,
      s.width * 0.7,
      s.height * 0.42,
    );
    domePath.lineTo(s.width * 0.7, s.height * 0.6);
    domePath.close();
    canvas.drawPath(domePath, p);

    // Small dome top spire
    canvas.drawLine(
      Offset(s.width * 0.5, s.height * 0.18),
      Offset(s.width * 0.5, s.height * 0.08),
      Paint()
        ..color = const Color(0xFFF5F0E8)
        ..strokeWidth = 2.5,
    );

    // Side minarets
    for (final x in [s.width * 0.12, s.width * 0.88]) {
      final mRect = Rect.fromLTWH(
        x - s.width * 0.04,
        s.height * 0.32,
        s.width * 0.08,
        s.height * 0.3,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(mRect, const Radius.circular(4)),
        p,
      );
      // Minaret dome
      final mp = Path();
      mp.moveTo(x - s.width * 0.04, s.height * 0.32);
      mp.quadraticBezierTo(
        x,
        s.height * 0.2,
        x + s.width * 0.04,
        s.height * 0.32,
      );
      mp.close();
      canvas.drawPath(mp, p);
    }

    // Trees
    final treePaint = Paint()..color = const Color(0xFF2D7A3A);
    for (final tx in [
      s.width * 0.1,
      s.width * 0.22,
      s.width * 0.78,
      s.width * 0.9,
    ]) {
      canvas.drawRect(
        Rect.fromLTWH(tx - 3, s.height * 0.55, 6, s.height * 0.18),
        treePaint,
      );
      canvas.drawOval(
        Rect.fromLTWH(tx - 8, s.height * 0.44, 16, s.height * 0.14),
        treePaint,
      );
    }
  }

  // ── GATEWAY OF INDIA ──
  void _drawGateway(Canvas canvas, Size s) {
    final stone = Paint()..color = const Color(0xFFD4A96A);
    final dark = Paint()..color = const Color(0xFF8B6914);

    // Water
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.78, s.width, s.height * 0.22),
      Paint()..color = const Color(0xFF4A90D9),
    );

    // Base platform
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.1,
          s.height * 0.7,
          s.width * 0.8,
          s.height * 0.1,
        ),
        const Radius.circular(2),
      ),
      stone,
    );

    // Main arch
    final archPath = Path();
    archPath.moveTo(s.width * 0.22, s.height * 0.7);
    archPath.lineTo(s.width * 0.22, s.height * 0.44);
    archPath.quadraticBezierTo(
      s.width * 0.5,
      s.height * 0.22,
      s.width * 0.78,
      s.height * 0.44,
    );
    archPath.lineTo(s.width * 0.78, s.height * 0.7);
    canvas.drawPath(archPath, stone);

    // Arch opening
    final openPath = Path();
    openPath.moveTo(s.width * 0.32, s.height * 0.7);
    openPath.lineTo(s.width * 0.32, s.height * 0.5);
    openPath.quadraticBezierTo(
      s.width * 0.5,
      s.height * 0.35,
      s.width * 0.68,
      s.height * 0.5,
    );
    openPath.lineTo(s.width * 0.68, s.height * 0.7);
    canvas.drawPath(openPath, Paint()..color = skyColor.withOpacity(0.9));

    // Side towers
    for (final tx in [s.width * 0.12, s.width * 0.80]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(tx, s.height * 0.44, s.width * 0.08, s.height * 0.28),
          const Radius.circular(3),
        ),
        stone,
      );
      // Tower dome
      final td = Path();
      td.moveTo(tx, s.height * 0.44);
      td.quadraticBezierTo(
        tx + s.width * 0.04,
        s.height * 0.32,
        tx + s.width * 0.08,
        s.height * 0.44,
      );
      td.close();
      canvas.drawPath(td, dark);
    }
  }

  // ── NALANDA (Bihar) ──
  void _drawNalanda(Canvas canvas, Size s) {
    final brick = Paint()..color = const Color(0xFFB5651D);
    final dark = Paint()..color = const Color(0xFF8B4513);

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.72, s.width, s.height * 0.28),
      Paint()..color = const Color(0xFFD2A679),
    );

    // Steps
    for (int i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          s.width * (0.1 + i * 0.025),
          s.height * (0.72 - i * 0.04),
          s.width * (0.8 - i * 0.05),
          s.height * 0.04,
        ),
        brick,
      );
    }

    // Main structure
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.2,
          s.height * 0.36,
          s.width * 0.6,
          s.height * 0.36,
        ),
        const Radius.circular(4),
      ),
      brick,
    );

    // Arched openings
    for (int i = 0; i < 3; i++) {
      final ax = s.width * (0.26 + i * 0.18);
      final archP = Path();
      archP.moveTo(ax, s.height * 0.72);
      archP.lineTo(ax, s.height * 0.56);
      archP.quadraticBezierTo(
        ax + s.width * 0.07,
        s.height * 0.46,
        ax + s.width * 0.14,
        s.height * 0.56,
      );
      archP.lineTo(ax + s.width * 0.14, s.height * 0.72);
      archP.close();
      canvas.drawPath(archP, dark);
    }

    // Top decorative row
    canvas.drawRect(
      Rect.fromLTWH(
        s.width * 0.18,
        s.height * 0.3,
        s.width * 0.64,
        s.height * 0.06,
      ),
      dark,
    );
  }

  // ── HAWA MAHAL (Rajasthan) ──
  void _drawHawa(Canvas canvas, Size s) {
    final pink = Paint()..color = const Color(0xFFE8836A);
    final dark = Paint()..color = const Color(0xFFC0603A);
    final window = Paint()..color = const Color(0xFF8B4513);

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.78, s.width, s.height * 0.22),
      Paint()..color = const Color(0xFFDEB887),
    );

    // Main facade
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.08,
          s.height * 0.22,
          s.width * 0.84,
          s.height * 0.56,
        ),
        const Radius.circular(2),
      ),
      pink,
    );

    // Rows of windows/arches
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 5; col++) {
        final wx = s.width * (0.14 + col * 0.155);
        final wy = s.height * (0.3 + row * 0.12);
        final archW = s.width * 0.1;
        final archH = s.height * 0.09;

        final wp = Path();
        wp.moveTo(wx, wy + archH);
        wp.lineTo(wx, wy + archH * 0.4);
        wp.quadraticBezierTo(wx + archW / 2, wy, wx + archW, wy + archH * 0.4);
        wp.lineTo(wx + archW, wy + archH);
        wp.close();
        canvas.drawPath(wp, dark);
        canvas.drawPath(
          wp,
          window
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
    }

    // Top decorative kiosks
    for (int i = 0; i < 5; i++) {
      final kx = s.width * (0.12 + i * 0.16);
      final kp = Path();
      kp.moveTo(kx, s.height * 0.22);
      kp.quadraticBezierTo(
        kx + s.width * 0.07,
        s.height * 0.1,
        kx + s.width * 0.14,
        s.height * 0.22,
      );
      kp.close();
      canvas.drawPath(kp, dark);
    }
  }

  // ── VICTORIA MEMORIAL (West Bengal) ──
  void _drawVictoria(Canvas canvas, Size s) {
    final white = Paint()..color = const Color(0xFFF8F4EC);
    final grey = Paint()..color = const Color(0xFFD0C8B8);

    // Garden
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.7, s.width, s.height * 0.3),
      Paint()..color = const Color(0xFF5A9E5A),
    );

    // Base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.08,
          s.height * 0.6,
          s.width * 0.84,
          s.height * 0.12,
        ),
        const Radius.circular(3),
      ),
      white,
    );

    // Main body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.18,
          s.height * 0.38,
          s.width * 0.64,
          s.height * 0.24,
        ),
        const Radius.circular(4),
      ),
      white,
    );

    // Central dome
    final domePath = Path();
    domePath.moveTo(s.width * 0.32, s.height * 0.38);
    domePath.lineTo(s.width * 0.32, s.height * 0.28);
    domePath.quadraticBezierTo(
      s.width * 0.5,
      s.height * 0.12,
      s.width * 0.68,
      s.height * 0.28,
    );
    domePath.lineTo(s.width * 0.68, s.height * 0.38);
    domePath.close();
    canvas.drawPath(domePath, white);

    // Dome spire
    canvas.drawLine(
      Offset(s.width * 0.5, s.height * 0.12),
      Offset(s.width * 0.5, s.height * 0.04),
      Paint()
        ..color = const Color(0xFFD4C090)
        ..strokeWidth = 2,
    );

    // Side towers
    for (final tx in [s.width * 0.14, s.width * 0.78]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(tx, s.height * 0.46, s.width * 0.08, s.height * 0.16),
          const Radius.circular(3),
        ),
        white,
      );
      final td = Path();
      td.moveTo(tx, s.height * 0.46);
      td.quadraticBezierTo(
        tx + s.width * 0.04,
        s.height * 0.36,
        tx + s.width * 0.08,
        s.height * 0.46,
      );
      td.close();
      canvas.drawPath(td, grey);
    }

    // Trees
    final treePaint = Paint()..color = const Color(0xFF2D5A2D);
    for (final tx in [s.width * 0.04, s.width * 0.92]) {
      canvas.drawRect(
        Rect.fromLTWH(tx - 3, s.height * 0.58, 6, s.height * 0.14),
        treePaint,
      );
      canvas.drawOval(
        Rect.fromLTWH(tx - 12, s.height * 0.46, 24, s.height * 0.15),
        treePaint,
      );
    }
  }

  // ── KHAJURAHO (MP) ──
  void _drawKhajuraho(Canvas canvas, Size s) {
    final sand = Paint()..color = const Color(0xFFD4AA70);
    final dark = Paint()..color = const Color(0xFF8B6914);

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.78, s.width, s.height * 0.22),
      Paint()..color = const Color(0xFFB8985A),
    );

    // Base platform
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.06,
          s.height * 0.7,
          s.width * 0.88,
          s.height * 0.1,
        ),
        const Radius.circular(2),
      ),
      sand,
    );

    // Temple shikhara (spire)
    void drawShikhara(double cx, double baseY, double w, double h) {
      for (int i = 0; i < 5; i++) {
        final ratio = 1.0 - i * 0.16;
        final rx = cx - (w * ratio) / 2;
        final ry = baseY - i * (h / 5);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(rx, ry, w * ratio, h / 5),
            const Radius.circular(2),
          ),
          i.isEven ? sand : dark,
        );
      }
      // Spire tip
      final tipPath = Path();
      tipPath.moveTo(cx - w * 0.08, baseY - h);
      tipPath.quadraticBezierTo(cx, baseY - h * 1.2, cx + w * 0.08, baseY - h);
      tipPath.close();
      canvas.drawPath(tipPath, dark);
    }

    drawShikhara(
      s.width * 0.5,
      s.height * 0.7,
      s.width * 0.38,
      s.height * 0.48,
    );
    drawShikhara(s.width * 0.2, s.height * 0.7, s.width * 0.2, s.height * 0.3);
    drawShikhara(s.width * 0.8, s.height * 0.7, s.width * 0.2, s.height * 0.3);

    // Decorative band
    canvas.drawRect(
      Rect.fromLTWH(
        s.width * 0.06,
        s.height * 0.66,
        s.width * 0.88,
        s.height * 0.04,
      ),
      dark,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

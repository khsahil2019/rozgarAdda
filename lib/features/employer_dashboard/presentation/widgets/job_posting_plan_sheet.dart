import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/network/api_services.dart';
import '../../../../core/services/payu_payment_service.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../jobs/domain/entities/available_job_entity.dart';
import '../../domain/entities/job_posting_plan.dart';
import '../controllers/employer_dashboard_controller.dart';

/// Full-screen responsive plan selection and PayU payment screen
class JobPostingPlanScreen extends StatefulWidget {
  final AvailableJob newJob;
  final VoidCallback onJobPublished;

  const JobPostingPlanScreen({
    super.key,
    required this.newJob,
    required this.onJobPublished,
  });

  @override
  State<JobPostingPlanScreen> createState() => _JobPostingPlanScreenState();
}

class _JobPostingPlanScreenState extends State<JobPostingPlanScreen> {
  final EmployerDashboardController controller = Get.find();

  PackageLevel _selectedLevel = PackageLevel.district;
  final List<JobPostingPlan> _districtPlans = JobPostingPlan.districtPackages();
  final List<JobPostingPlan> _statePlans = JobPostingPlan.statePackages();

  late JobPostingPlan _selectedPlan;
  bool _isProcessing = false;
  bool _isLoadingPlans = false;
  String? _errorMessage;

  static const Color primary = Color(0xFF1400FF);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color darkText = Color(0xFF0F172A);
  static const Color mediumText = Color(0xFF334155);
  static const Color greyText = Color(0xFF64748B);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color successGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _selectedPlan = _districtPlans.firstWhere(
      (p) => p.isPopular,
      orElse: () => _districtPlans[0],
    );
    _fetchPlansFromApi();
  }

  /// Fetches real-time plans from https://rozgaradda.com/api/emp/job_pricing_plans
  Future<void> _fetchPlansFromApi() async {
    setState(() => _isLoadingPlans = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('employer_token');

      final res = await ApiService.get(
        ApiRoutes.jobPricingPlans,
        accessToken: token,
      );

      if (res['status'] == true && res['plans'] is List) {
        final List<dynamic> rawList = res['plans'];
        final List<JobPostingPlan> parsedList = rawList
            .map((item) =>
                JobPostingPlan.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();

        if (parsedList.isNotEmpty && mounted) {
          final apiDistricts = parsedList
              .where((p) => p.level == PackageLevel.district)
              .toList();
          final apiStates =
              parsedList.where((p) => p.level == PackageLevel.state).toList();

          setState(() {
            if (apiDistricts.isNotEmpty) {
              _districtPlans.clear();
              _districtPlans.addAll(apiDistricts);
            }
            if (apiStates.isNotEmpty) {
              _statePlans.clear();
              _statePlans.addAll(apiStates);
            }

            final currentList = _selectedLevel == PackageLevel.district
                ? _districtPlans
                : _statePlans;
            _selectedPlan = currentList.firstWhere(
              (p) => p.isPopular,
              orElse: () => currentList.first,
            );
          });
        }
      }
    } catch (e) {
      debugPrint('[JobPostingPlanScreen] Plan API note: $e. Using local defaults.');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPlans = false);
      }
    }
  }

  List<JobPostingPlan> get _currentPlans =>
      _selectedLevel == PackageLevel.district ? _districtPlans : _statePlans;

  Future<void> _handlePaymentAndPost() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    // 1. Free plan (₹0.00) - skip payment gateway and post directly
    if (_selectedPlan.isFree) {
      try {
        final freePaymentData = <String, dynamic>{
          'id': _selectedPlan.id,
          'status': 'success',
          'mihpayid': 'FREE_${DateTime.now().millisecondsSinceEpoch}',
          'bank_ref_num': 'FREE_PROMO',
          'paid_at': DateTime.now().toUtc().toIso8601String(),
          'payment_response': 'free_plan',
        };

        await controller.postNewJob(
          widget.newJob,
          planId: _selectedPlan.id,
          paymentStatus: 'success',
          transactionStatus: 'completed',
          paymentData: freePaymentData,
        );

        if (!mounted) return;
        _showSuccessDialog('FREE_POST');
      } catch (e) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _errorMessage = 'Failed to publish job: ${e.toString()}';
          });
        }
      }
      return;
    }

    // 2. Paid Plan - Launch PayU CheckoutPro (alphanumeric transaction ID)
    final txnId = 'TXN${DateTime.now().millisecondsSinceEpoch}';

    final firstName = controller.companyName.value.isNotEmpty
        ? controller.companyName.value
        : (controller.contactPerson.value.isNotEmpty
            ? controller.contactPerson.value
            : 'Employer');
    final email = controller.email.value.isNotEmpty
        ? controller.email.value
        : 'employer@rozgaradda.com';
    final phone = controller.phone.value.isNotEmpty
        ? controller.phone.value
        : (widget.newJob.contactPhone ?? '9999999999');

    try {
      final totalPayable = _selectedPlan.totalPayable;
      final result = await PayUPaymentService.instance.openCheckout(
        txnId: txnId,
        amount: totalPayable,
        productInfo:
            'Rozgar Adda Job Post: ${_selectedPlan.name} (${_selectedLevel == PackageLevel.district ? 'District' : 'State'})',
        firstName: firstName,
        email: email,
        phone: phone,
        additionalParams: {
          PayUAdditionalParamKeys.udf1: _selectedPlan.id.toString(),
          PayUAdditionalParamKeys.udf2:
              _selectedLevel == PackageLevel.district ? 'district' : 'state',
          PayUAdditionalParamKeys.udf3: controller.employerId.value.toString(),
          PayUAdditionalParamKeys.udf4: widget.newJob.title,
          PayUAdditionalParamKeys.udf5:
              'Base: ${_selectedPlan.formattedBasePrice} | GST(18%): ${_selectedPlan.formattedGstAmount} | Total: ${_selectedPlan.formattedTotalPayable}',
        },
      );

      if (!mounted) return;

      if (result.isSuccess) {
        final paymentPayload = <String, dynamic>{
          if (result.id != null)
            'id': result.id
          else
            'id': _selectedPlan.id,
          'status': 'success',
          'amount': _selectedPlan.totalPayable,
          'base_price': _selectedPlan.price,
          'gst_amount': _selectedPlan.gstAmount,
          'gst_rate': '18%',
          'total_payable': _selectedPlan.totalPayable,
          'mihpayid':
              result.mihpayid ?? result.paymentId ?? (result.txnId ?? txnId),
          'bank_ref_num': result.bankRefNum ?? (result.txnId ?? txnId),
          'paid_at': result.paidAt ?? DateTime.now().toUtc().toIso8601String(),
          'payment_response': result.rawData ?? {},
        };

        await controller.postNewJob(
          widget.newJob,
          planId: _selectedPlan.id,
          transactionId: result.txnId ?? txnId,
          paymentId: result.paymentId ?? '',
          paymentStatus: 'success',
          transactionStatus: 'completed',
          paymentData: paymentPayload,
        );

        if (!mounted) return;
        _showSuccessDialog(result.txnId ?? txnId);
      } else if (result.isCancelled) {
        setState(() {
          _isProcessing = false;
          _errorMessage =
              'Payment was cancelled. You can review the plan and retry whenever ready.';
        });
      } else {
        setState(() {
          _isProcessing = false;
          _errorMessage = result.message ??
              'Payment failed. Please check your network and retry.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'An error occurred during payment: ${e.toString()}';
        });
      }
    }
  }

  void _showSuccessDialog(String txnId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: successGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: successGreen, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'Job Published Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your job opening for "${widget.newJob.title}" is now active and live.',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, color: greyText, height: 1.4),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderGrey),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow(
                      'Selected Plan',
                      '${_selectedPlan.name} (${_selectedLevel == PackageLevel.district ? 'District' : 'State'})',
                    ),
                    if (!_selectedPlan.isFree) ...[
                      const SizedBox(height: 8),
                      _buildReceiptRow('Base Price', _selectedPlan.formattedBasePrice),
                      const SizedBox(height: 8),
                      _buildReceiptRow('GST (18%)', '+${_selectedPlan.formattedGstAmount}'),
                    ],
                    const SizedBox(height: 8),
                    _buildReceiptRow(
                      'Total Paid',
                      _selectedPlan.isFree
                          ? 'FREE'
                          : '${_selectedPlan.formattedTotalPayable} (Incl. GST)',
                    ),
                    const SizedBox(height: 8),
                    _buildReceiptRow('Transaction ID', txnId),
                    const SizedBox(height: 8),
                    _buildReceiptRow(
                        'Validity', '${_selectedPlan.durationDays} Days'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.back(); // Pop Plan Screen
                    widget.onJobPublished(); // Pop Form Screen back to dashboard
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Go to Dashboard',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: greyText)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: darkText),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const AppBackButton(),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Job Plan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: darkText,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Step 4 of 4 • Choose Package',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: greyText.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded, size: 14, color: successGreen),
                SizedBox(width: 4),
                Text(
                  '100% Secure',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: successGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: borderGrey),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Summary Card
              _buildJobSummaryCard(),
              const SizedBox(height: 16),

              // Level Selector Tabs (District vs State)
              _buildPackageLevelSelector(),
              const SizedBox(height: 16),

              if (_isLoadingPlans)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: primary,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Loading latest pricing plans...',
                          style: TextStyle(fontSize: 13, color: greyText),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                // Plans List
                ..._currentPlans.map((plan) => _buildPlanCard(plan)),

                // Billing & Tax Breakdown (18% GST)
                if (!_selectedPlan.isFree) _buildBillingBreakdownCard(),
              ],

              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // PayU Trust Banner
              _buildPayUTrustBadge(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: borderGrey, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Payable',
                      style: TextStyle(fontSize: 12, color: greyText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedPlan.isFree
                          ? 'FREE'
                          : _selectedPlan.formattedTotalPayable,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (!_selectedPlan.isFree) ...[
                      const SizedBox(height: 1),
                      const Text(
                        '(Incl. 18% GST)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: greyText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handlePaymentAndPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedPlan.isFree ? successGreen : primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedPlan.isFree
                                    ? Icons.check_circle_rounded
                                    : Icons.lock_outline_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _selectedPlan.isFree
                                      ? 'Post Job (Free)'
                                      : 'Pay ${_selectedPlan.formattedTotalPayable} with PayU',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.work_outline_rounded, color: primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.newJob.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${widget.newJob.jobType.replaceAll('_', ' ').capitalizeFirst} • ${widget.newJob.stateName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: greyText),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: lightBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderGrey),
            ),
            child: Text(
              '${widget.newJob.vacancy} ${widget.newJob.vacancy > 1 ? 'Openings' : 'Opening'}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: mediumText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageLevelSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isProcessing) {
                  setState(() {
                    _selectedLevel = PackageLevel.district;
                    _selectedPlan = _districtPlans.firstWhere(
                      (p) => p.isPopular,
                      orElse: () => _districtPlans.first,
                    );
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedLevel == PackageLevel.district
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedLevel == PackageLevel.district
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'District Level Packages',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _selectedLevel == PackageLevel.district
                          ? primary
                          : greyText,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isProcessing) {
                  setState(() {
                    _selectedLevel = PackageLevel.state;
                    _selectedPlan = _statePlans.firstWhere(
                      (p) => p.isPopular,
                      orElse: () => _statePlans.first,
                    );
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedLevel == PackageLevel.state
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedLevel == PackageLevel.state
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'State Level Packages',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _selectedLevel == PackageLevel.state
                          ? primary
                          : greyText,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(JobPostingPlan plan) {
    final isSelected = _selectedPlan.id == plan.id;

    return GestureDetector(
      onTap: () {
        if (!_isProcessing) {
          setState(() => _selectedPlan = plan);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primary.withValues(alpha: 0.03) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primary : borderGrey,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Radio indicator
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? primary : const Color(0xFF94A3B8),
                      width: isSelected ? 6 : 2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Tagline
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              plan.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? primary : darkText,
                              ),
                            ),
                          ),
                          if (plan.tagline.isNotEmpty &&
                              plan.tagline.toLowerCase() !=
                                  plan.name.toLowerCase()) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                plan.tagline,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        plan.description.isNotEmpty
                            ? '${plan.durationDays} Days • ${plan.description}'
                            : '${plan.durationDays} Days Validity',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: greyText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Price Tag matching web portal yellow style
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: plan.isFree ? const Color(0xFFF1F5F9) : accentAmber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plan.isFree
                            ? '₹0.00'
                            : '₹${plan.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: plan.isFree ? darkText : Colors.white,
                        ),
                      ),
                      if (!plan.isFree)
                        Text(
                          '+18% GST',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: borderGrey),
            const SizedBox(height: 12),

            // Features checklist matching web portal
            ...plan.includedFeatures.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_rounded,
                        size: 16, color: successGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(
                            fontSize: 13, color: mediumText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...plan.excludedFeatures.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.close_rounded,
                        size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 13,
                          color: greyText.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingBreakdownCard() {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.receipt_long_rounded, color: primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Bill & Tax Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '18% GST Added',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: borderGrey),
          const SizedBox(height: 10),

          // Base Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${_selectedPlan.name} Plan (${_selectedPlan.durationDays} Days)',
                  style: const TextStyle(fontSize: 12.5, color: greyText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _selectedPlan.formattedBasePrice,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // GST 18%
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GST (18%)',
                style: TextStyle(fontSize: 12.5, color: greyText),
              ),
              Text(
                '+${_selectedPlan.formattedGstAmount}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: accentAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: borderGrey),
          const SizedBox(height: 10),

          // Total Payable
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount Payable',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              Text(
                _selectedPlan.formattedTotalPayable,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayUTrustBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_rounded,
              color: Color(0xFF0F172A), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '100% Secure Payments via PayU',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Supports UPI (GPay, PhonePe, Paytm), Cards, Net Banking & Wallets',
                  style: TextStyle(fontSize: 11, color: greyText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper wrapper class so existing references to JobPostingPlanSheet.show(...)
/// seamlessly navigate to the full responsive screen.
class JobPostingPlanSheet {
  static Future<void> show({
    required BuildContext context,
    required AvailableJob newJob,
    required VoidCallback onJobPublished,
  }) {
    return Get.to(
      () => JobPostingPlanScreen(
        newJob: newJob,
        onJobPublished: onJobPublished,
      ),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 300),
    )!;
  }
}

enum PackageLevel {
  district,
  state,
}

class JobPostingPlan {
  final int id;
  final String name;
  final String tagline;
  final String description;
  final double price;
  final int durationDays;
  final PackageLevel level;
  final bool isFree;
  final bool isPopular;
  final double discountValue;
  final String discountType;
  final String discountPercent;
  final double? discountedPrice;
  final double gstPer;
  final double? customGstAmount;
  final double? customTotalPayable;
  final Map<String, dynamic>? rawJson;
  final List<String> includedFeatures;
  final List<String> excludedFeatures;

  const JobPostingPlan({
    required this.id,
    required this.name,
    this.tagline = '',
    this.description = '',
    required this.price,
    required this.durationDays,
    required this.level,
    this.isFree = false,
    this.isPopular = false,
    this.discountValue = 0.0,
    this.discountType = '',
    this.discountPercent = '',
    this.discountedPrice,
    this.gstPer = 18.0,
    this.customGstAmount,
    this.customTotalPayable,
    this.rawJson,
    required this.includedFeatures,
    this.excludedFeatures = const ['Database Access'],
  });

  /// Base price of the package before discount & GST
  double get basePrice => price;

  /// Effective price after discount, before GST
  double get effectiveBasePrice =>
      (hasDiscount && discountedPrice != null) ? discountedPrice! : price;

  /// Whether this plan has an active discount
  bool get hasDiscount {
    if (isFree) return false;
    if (discountValue > 0) return true;
    if (discountedPrice != null && discountedPrice! < price) return true;
    if (discountPercent.isNotEmpty &&
        discountPercent != '0%' &&
        discountPercent != '0.00%') {
      return true;
    }
    return false;
  }

  /// Discount badge label (e.g. "50.00% OFF" or "₹10 OFF")
  String get formattedDiscountBadge {
    if (!hasDiscount) return '';
    if (discountPercent.isNotEmpty &&
        discountPercent != '0%' &&
        discountPercent != '0.00%') {
      return '$discountPercent OFF';
    }
    if (discountValue > 0) {
      return '₹${discountValue.toStringAsFixed(0)} OFF';
    }
    return 'DISCOUNT';
  }

  /// GST Rate for job posting packages
  double get gstRate => gstPer / 100.0;

  /// GST Amount rounded to 2 decimal places (uses API response if present)
  double get gstAmount => isFree
      ? 0.0
      : (customGstAmount ??
          double.parse((effectiveBasePrice * gstRate).toStringAsFixed(2)));

  /// Final total payable amount including GST (uses API response if present)
  double get totalPayable => isFree
      ? 0.0
      : (customTotalPayable ??
          double.parse((effectiveBasePrice + gstAmount).toStringAsFixed(2)));

  /// Display string for base package price
  String get formattedBasePrice =>
      isFree ? '₹0.00' : '₹${price.toStringAsFixed(2)}';

  /// Display string for effective discounted price
  String get formattedEffectivePrice =>
      isFree ? '₹0.00' : '₹${effectiveBasePrice.toStringAsFixed(2)}';

  /// Display string for GST amount
  String get formattedGstAmount =>
      isFree ? '₹0.00' : '₹${gstAmount.toStringAsFixed(2)}';

  /// Display string for total payable
  String get formattedTotalPayable =>
      isFree ? 'FREE' : '₹${totalPayable.toStringAsFixed(2)}';

  Map<String, dynamic> toJson() {
    if (rawJson != null && rawJson!.isNotEmpty) {
      return Map<String, dynamic>.from(rawJson!);
    }
    return {
      'id': id,
      'plan_name': name,
      'plan_type': level == PackageLevel.state ? 'state' : 'district',
      'plan_tagline': tagline,
      'duration_days': durationDays,
      'price': price.toStringAsFixed(2),
      'discount_value': discountValue.toStringAsFixed(2),
      'discount_type': discountType,
      'plan_discounted_per': discountPercent,
      'plan_discounted_price': effectiveBasePrice.toStringAsFixed(2),
      'gst_per': gstPer.toStringAsFixed(2),
      'gst_amount': gstAmount.toStringAsFixed(2),
      'final_plan_amount': totalPayable.toStringAsFixed(2),
      'is_popular': isPopular,
      'is_free': isFree,
    };
  }

  factory JobPostingPlan.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['plan_type'] ?? 'district').toString().toLowerCase();
    final level = typeStr == 'state' ? PackageLevel.state : PackageLevel.district;
    final priceVal = double.tryParse((json['plan_amount'] ?? json['price'] ?? '0').toString()) ?? 0.0;
    final isFreeVal = json['is_free'] == true ||
        json['is_free'] == 1 ||
        json['is_free'] == 'true' ||
        priceVal == 0.0;
    final isPopularVal = json['is_popular'] == true ||
        json['is_popular'] == 1 ||
        json['is_popular'] == 'true';
    final durationVal =
        int.tryParse((json['duration_days'] ?? '10').toString()) ?? 10;
    final nameVal = (json['plan_name'] ?? '').toString();
    final descVal = (json['description'] ?? '').toString();
    final taglineVal = (json['plan_tagline'] ?? '').toString();

    final discVal = double.tryParse((json['discount_value'] ?? '0').toString()) ?? 0.0;
    final discType = (json['discount_type'] ?? '').toString();
    final discPer = (json['plan_discounted_per'] ?? '').toString();
    final discountedPriceVal = double.tryParse(
        (json['plan_discounted_price'] ?? '').toString());
    final gstAmountVal = double.tryParse((json['gst_amount'] ?? '').toString());
    final finalAmountVal = double.tryParse((json['final_plan_amount'] ?? '').toString());
    final gstPerVal = double.tryParse((json['gst_per'] ?? '18').toString()) ?? 18.0;

    return JobPostingPlan(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: nameVal,
      tagline: taglineVal,
      description: descVal,
      price: priceVal,
      durationDays: durationVal,
      level: level,
      isFree: isFreeVal,
      isPopular: isPopularVal,
      discountValue: discVal,
      discountType: discType,
      discountPercent: discPer,
      discountedPrice: discountedPriceVal,
      gstPer: gstPerVal,
      customGstAmount: gstAmountVal,
      customTotalPayable: finalAmountVal,
      rawJson: json,
      includedFeatures: [
        'Valid for $durationVal days',
        'Candidate views',
        'Job boosts',
        'Featured listing',
        'Email support',
      ],
      excludedFeatures: const ['Database Access'],
    );
  }

  static List<JobPostingPlan> districtPackages() {
    return [
      const JobPostingPlan(
        id: 10,
        name: 'Free',
        tagline: 'First job post free',
        description: 'One free job post for new employers.',
        price: 0.0,
        durationDays: 10,
        level: PackageLevel.district,
        isFree: true,
        includedFeatures: [
          'Valid for 10 days',
          'Candidate views',
          'Job boosts',
          'Featured listing',
          'Email support',
        ],
        excludedFeatures: ['Database Access'],
        isPopular: false,
      ),
      const JobPostingPlan(
        id: 2,
        name: 'Basic',
        tagline: 'Basic Plan',
        description: 'District Level Plan',
        price: 499.0,
        durationDays: 10,
        level: PackageLevel.district,
        includedFeatures: [
          'Valid for 10 days',
          'Candidate views',
          'Job boosts',
          'Featured listing',
          'Email support',
        ],
        excludedFeatures: ['Database Access'],
        isPopular: true,
      ),
      const JobPostingPlan(
        id: 9,
        name: 'TEST',
        tagline: 'Basic Plan',
        description: 'District level plan',
        price: 1.0,
        durationDays: 5,
        level: PackageLevel.district,
        includedFeatures: [
          'Valid for 5 days',
          'Candidate views',
          'Job boosts',
          'Featured listing',
          'Email support',
        ],
        excludedFeatures: ['Database Access'],
        isPopular: false,
      ),
      const JobPostingPlan(
        id: 3,
        name: 'Premium',
        tagline: 'PRIMIUM',
        description: 'Disrict Level Plan',
        price: 999.0,
        durationDays: 20,
        level: PackageLevel.district,
        includedFeatures: [
          'Valid for 20 days',
          'Candidate views',
          'Job boosts',
          'Featured listing',
          'Email support',
        ],
        excludedFeatures: ['Database Access'],
        isPopular: false,
      ),
      const JobPostingPlan(
        id: 4,
        name: 'Premium Plus',
        tagline: 'PRIMIUM PLUS',
        description: 'District Level Visibility',
        price: 1499.0,
        durationDays: 30,
        level: PackageLevel.district,
        includedFeatures: [
          'Valid for 30 days',
          'Candidate views',
          'Job boosts',
          'Featured listing',
          'Email support',
        ],
        excludedFeatures: ['Database Access'],
        isPopular: false,
      ),
    ];
  }

  static List<JobPostingPlan> statePackages() {
    return [
      const JobPostingPlan(
        id: 5,
        name: 'Basic',
        tagline: 'Basic Plan',
        description: 'State Level Plan',
        price: 999.0,
        durationDays: 10,
        level: PackageLevel.state,
        includedFeatures: [
          'Valid for 10 days',
          'Candidate views',
          'Job boosts',
          'Featured listing',
          'Email support',
        ],
        excludedFeatures: ['Database Access'],
        isPopular: false,
      ),
      const JobPostingPlan(
        id: 6,
        name: 'Premium',
        tagline: 'Premium Plan',
        description: 'State Level Plan',
        price: 1999.0,
        durationDays: 20,
        level: PackageLevel.state,
        includedFeatures: [
          'Valid for 20 days',
          'Candidate views',
          'Job boosts',
          'Featured listing',
          'Email support',
        ],
        excludedFeatures: ['Database Access'],
        isPopular: true,
      ),
      const JobPostingPlan(
        id: 7,
        name: 'Premium Plus',
        tagline: 'Premium Plus Plan',
        description: 'State Level Plan',
        price: 2499.0,
        durationDays: 30,
        level: PackageLevel.state,
        includedFeatures: [
          'Valid for 30 days',
          'Candidate views',
          'Job boosts',
          'Featured listing',
          'Email support',
        ],
        excludedFeatures: ['Database Access'],
        isPopular: false,
      ),
    ];
  }

  static List<JobPostingPlan> allPackages() {
    return [...districtPackages(), ...statePackages()];
  }
}

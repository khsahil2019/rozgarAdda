enum AdPackageLevel {
  district,
  state,
}

class AdPostingPlan {
  final int id;
  final int? categoryId;
  final String name;
  final String tagline;
  final String description;
  final double price;
  final int durationDays;
  final AdPackageLevel level;
  final bool isFree;
  final bool isPopular;
  final bool isActive;
  final double? customGstAmount;
  final double? customTotalPayable;
  final List<String> includedFeatures;

  const AdPostingPlan({
    required this.id,
    this.categoryId,
    required this.name,
    this.tagline = '',
    this.description = '',
    required this.price,
    required this.durationDays,
    required this.level,
    this.isFree = false,
    this.isPopular = false,
    this.isActive = true,
    this.customGstAmount,
    this.customTotalPayable,
    required this.includedFeatures,
  });

  /// Base price of the package before GST
  double get basePrice => price;

  /// GST Rate for ad posting packages (18%)
  double get gstRate => 0.18;

  /// 18% GST Amount rounded to 2 decimal places (uses API response if present)
  double get gstAmount =>
      isFree ? 0.0 : (customGstAmount ?? double.parse((price * 0.18).toStringAsFixed(2)));

  /// Final total payable amount including 18% GST (uses API response if present)
  double get totalPayable =>
      isFree ? 0.0 : (customTotalPayable ?? double.parse((price + gstAmount).toStringAsFixed(2)));

  /// Display string for base package price
  String get formattedBasePrice =>
      isFree ? '₹0.00' : '₹${price.toStringAsFixed(2)}';

  /// Display string for 18% GST amount
  String get formattedGstAmount =>
      isFree ? '₹0.00' : '₹${gstAmount.toStringAsFixed(2)}';

  /// Display string for total payable
  String get formattedTotalPayable =>
      isFree ? 'FREE' : '₹${totalPayable.toStringAsFixed(2)}';

  factory AdPostingPlan.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['plan_type'] ?? 'district').toString().toLowerCase();
    final level = typeStr == 'state' ? AdPackageLevel.state : AdPackageLevel.district;
    final priceVal = double.tryParse((json['plan_amount'] ?? json['price'] ?? '0').toString()) ?? 0.0;
    final gstAmountVal = double.tryParse((json['gst_amount'] ?? '').toString());
    final finalAmountVal = double.tryParse((json['final_plan_amount'] ?? '').toString());
    final isFreeVal = json['is_free'] == true ||
        json['is_free'] == 1 ||
        json['is_free'] == 'true' ||
        priceVal == 0.0;
    final isPopularVal = json['is_popular'] == true ||
        json['is_popular'] == 1 ||
        json['is_popular'] == 'true';
    final isActiveVal = json['is_active'] != false &&
        json['is_active'] != 0 &&
        json['is_active'] != 'false';
    final durationVal =
        int.tryParse((json['duration_days'] ?? '30').toString()) ?? 30;
    final nameVal = (json['plan_name'] ?? json['name'] ?? '').toString();
    final descVal = (json['description'] ?? '').toString();
    final taglineVal = (json['plan_tagline'] ?? json['tagline'] ?? '').toString();
    final catIdVal = (json['category_id'] as num?)?.toInt() ??
        int.tryParse(json['category_id']?.toString() ?? '');

    return AdPostingPlan(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      categoryId: catIdVal,
      name: nameVal,
      tagline: taglineVal,
      description: descVal,
      price: priceVal,
      durationDays: durationVal,
      level: level,
      isFree: isFreeVal,
      isPopular: isPopularVal,
      isActive: isActiveVal,
      customGstAmount: gstAmountVal,
      customTotalPayable: finalAmountVal,
      includedFeatures: [
        'Live for $durationVal days',
        level == AdPackageLevel.state ? 'State-Wide Promotion' : 'District-Wide Promotion',
        'Direct Buyer Chat & Call',
        'Marketplace Featured Listing',
      ],
    );
  }

  static List<AdPostingPlan> districtPackages() {
    return [
      const AdPostingPlan(
        id: 101,
        name: 'Basic Ad Listing',
        tagline: 'Ideal for single item sales',
        description: 'Publish your ad across the entire district with direct WhatsApp & call support.',
        price: 199.00,
        durationDays: 15,
        level: AdPackageLevel.district,
        isPopular: false,
        includedFeatures: [
          '15 Days Active Listing',
          'District-Wide Reach',
          'Direct Buyer Call & Chat',
          'Standard Support',
        ],
      ),
      const AdPostingPlan(
        id: 102,
        name: 'Featured Ad Listing',
        tagline: 'Most popular among sellers',
        description: 'Get 3x more buyer inquiries with prominent Featured badge and top placement.',
        price: 399.00,
        durationDays: 30,
        level: AdPackageLevel.district,
        isPopular: true,
        includedFeatures: [
          '30 Days Active Listing',
          '★ Featured Seller Badge',
          'Top of Search in District',
          '3x Faster Buyer Inquiries',
          'Priority WhatsApp & Call Support',
        ],
      ),
      const AdPostingPlan(
        id: 103,
        name: 'Super Seller Ad',
        tagline: 'Maximum visibility & leads',
        description: 'Long-term active promotion with verified seller credibility and continuous reach.',
        price: 699.00,
        durationDays: 60,
        level: AdPackageLevel.district,
        isPopular: false,
        includedFeatures: [
          '60 Days Active Listing',
          '★ Verified Super Seller Badge',
          'Permanent Top Search Rank',
          'Unlimited Direct Buyer Calls',
          'Dedicated Customer Support',
        ],
      ),
    ];
  }

  static List<AdPostingPlan> statePackages() {
    return [
      const AdPostingPlan(
        id: 201,
        name: 'State-Wide Showcase',
        tagline: 'Reach buyers across the entire state',
        description: 'Promote your machinery, product, or equipment across every district in the state.',
        price: 899.00,
        durationDays: 30,
        level: AdPackageLevel.state,
        isPopular: false,
        includedFeatures: [
          '30 Days State-Wide Active',
          'Highlighted Across All Districts',
          'Instant Buyer WhatsApp Chat',
          'State Marketplace Banner',
        ],
      ),
      const AdPostingPlan(
        id: 202,
        name: 'State-Wide Mega Promotion',
        tagline: 'Ultimate commercial sales reach',
        description: 'Premium top-tier placement across the entire state for high-value commercial sales.',
        price: 1499.00,
        durationDays: 60,
        level: AdPackageLevel.state,
        isPopular: true,
        includedFeatures: [
          '60 Days State-Wide Active',
          '★ Mega Ad Top Priority Placement',
          'Maximum Inquiries & Leads',
          'Featured in Category Highlights',
          'VIP Seller Assistance',
        ],
      ),
    ];
  }
}

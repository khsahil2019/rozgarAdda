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
    required this.includedFeatures,
    this.excludedFeatures = const ['Database Access'],
  });

  /// Base price of the package before GST
  double get basePrice => price;

  /// GST Rate for job posting packages (18%)
  double get gstRate => 0.18;

  /// 18% GST Amount rounded to 2 decimal places
  double get gstAmount =>
      isFree ? 0.0 : double.parse((price * 0.18).toStringAsFixed(2));

  /// Final total payable amount including 18% GST
  double get totalPayable =>
      isFree ? 0.0 : double.parse((price + gstAmount).toStringAsFixed(2));

  /// Display string for base package price
  String get formattedBasePrice =>
      isFree ? '₹0.00' : '₹${price.toStringAsFixed(2)}';

  /// Display string for 18% GST amount
  String get formattedGstAmount =>
      isFree ? '₹0.00' : '₹${gstAmount.toStringAsFixed(2)}';

  /// Display string for total payable
  String get formattedTotalPayable =>
      isFree ? 'FREE' : '₹${totalPayable.toStringAsFixed(2)}';

  factory JobPostingPlan.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['plan_type'] ?? 'district').toString().toLowerCase();
    final level = typeStr == 'state' ? PackageLevel.state : PackageLevel.district;
    final priceVal = double.tryParse((json['price'] ?? '0').toString()) ?? 0.0;
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

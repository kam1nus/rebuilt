import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supply these at build/run time. Never commit a project URL or a real key.
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_supabaseUrl.isEmpty || _supabasePublishableKey.isEmpty) {
    throw StateError(
      'Missing Supabase configuration. Provide SUPABASE_URL and '
      'SUPABASE_PUBLISHABLE_KEY with --dart-define. See README.md.',
    );
  }
  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabasePublishableKey,
  );
  runApp(const StroyOstatokApp());
}

SupabaseClient get supabase => Supabase.instance.client;

class AppColors {
  static const paper = Color(0xFF101D2E);
  static const ink = Color(0xFFF1F6FF);
  static const muted = Color(0xFFAFBED1);
  static const blue = Color(0xFF4D73B8);
  static const teal = Color(0xFF355C95);
  static const yellow = Color(0xFF6D91CD);
  static const mint = Color(0xFF294564);
  static const surface = Color(0xFF1B2D45);
  static const surfaceRaised = Color(0xFF233954);
  static const border = Color(0xFF385371);
}

class StroyOstatokApp extends StatelessWidget {
  const StroyOstatokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReBuild',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          brightness: Brightness.dark,
          surface: AppColors.paper,
        ),
        scaffoldBackgroundColor: AppColors.paper,
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        ),
        fontFamily: 'Arial',
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Session? _session;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _session = supabase.auth.currentSession;
    _authSubscription = supabase.auth.onAuthStateChange.listen((state) {
      if (mounted) setState(() => _session = state.session);
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_session != null) return const MarketplaceScreen();

    return Scaffold(
      body: SafeArea(
        child: AuthSheet(onAuthenticated: (_) {}, fullScreen: true),
      ),
    );
  }
}

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int _tab = 0;
  int _marketRevision = 0;
  bool _signedIn = supabase.auth.currentUser != null;

  String get _profileName {
    final user = supabase.auth.currentUser;
    final metadata = user?.userMetadata;
    final firstName = metadata?['first_name']?.toString().trim() ?? '';
    final lastName = metadata?['last_name']?.toString().trim() ?? '';
    final fullName = [
      firstName,
      lastName,
    ].where((part) => part.isNotEmpty).join(' ');
    if (fullName.isNotEmpty) return fullName;
    return user?.email?.split('@').first ?? 'Profile';
  }

  String get _initials {
    final words = _profileName.split(' ').where((word) => word.isNotEmpty);
    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }

  void _signIn(String email) {
    setState(() => _signedIn = true);
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Signed in as $email')));
  }

  void _openAuth() => showDialog<void>(
    context: context,
    barrierColor: const Color(0xB3101D2E),
    builder: (_) => AuthSheet(onAuthenticated: _signIn),
  );

  void _openProfile() {
    final user = supabase.auth.currentUser;
    if (user == null) {
      _openAuth();
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => ProfileScreen(user: user)));
  }

  void _openSell() {
    if (_signedIn) {
      setState(() => _tab = 1);
    } else {
      _openAuth();
    }
  }

  void _onListingPublished() {
    setState(() {
      _tab = 0;
      _marketRevision++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your listing is now published.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compactHeader = MediaQuery.sizeOf(context).width < 400;
    final profileAvatar = CircleAvatar(
      radius: 17,
      backgroundColor: AppColors.mint,
      child: _signedIn
          ? Text(
              _initials,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            )
          : const Icon(
              Icons.sentiment_satisfied_alt,
              color: AppColors.ink,
              size: 19,
            ),
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 82,
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        titleSpacing: compactHeader ? 12 : 20,
        title: BrandLockup(compact: compactHeader),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: compactHeader ? 8 : 16),
            child: OutlinedButton(
              onPressed: _signedIn ? _openProfile : _openAuth,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: AppColors.border),
                shape: const StadiumBorder(),
                padding: EdgeInsets.all(compactHeader ? 4 : 7),
                minimumSize: compactHeader
                    ? const Size(44, 44)
                    : const Size(0, 0),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: compactHeader && _signedIn
                  ? Tooltip(
                      message: _signedIn ? _profileName : 'Sign in',
                      child: profileAvatar,
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        profileAvatar,
                        const SizedBox(width: 10),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: Text(
                            _signedIn ? _profileName : 'Sign in',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          BuyScreen(onSell: _openSell, refreshToken: _marketRevision),
          SellScreen(onPublished: _onListingPublished),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: NavButton(
                  icon: Icons.search_rounded,
                  label: 'Buy',
                  active: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NavButton(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Sell',
                  active: _tab == 1,
                  onTap: _openSell,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final User user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileSnapshot> _snapshot;

  String get _displayName {
    final metadata = widget.user.userMetadata ?? const <String, dynamic>{};
    final firstName = metadata['first_name']?.toString().trim() ?? '';
    final lastName = metadata['last_name']?.toString().trim() ?? '';
    final name = [
      firstName,
      lastName,
    ].where((part) => part.isNotEmpty).join(' ');
    if (name.isNotEmpty) return name;
    return widget.user.email?.split('@').first ?? 'Account';
  }

  String get _initials => _displayName
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();

  @override
  void initState() {
    super.initState();
    _snapshot = _loadSnapshot();
  }

  Future<ProfileSnapshot> _loadSnapshot() async {
    final listingsResponse = await supabase
        .from('listings')
        .select()
        .eq('seller_id', widget.user.id)
        .order('created_at', ascending: false);
    final metricsResponse = await supabase
        .from('listing_stats')
        .select('listing_id, unique_views, buyer_inquiries')
        .eq('seller_id', widget.user.id);
    final inquiriesResponse = await supabase
        .from('listing_inquiries')
        .select(
          'id, listing_id, message, created_at, listings!inner(title, seller_id)',
        )
        .eq('listings.seller_id', widget.user.id)
        .neq('buyer_id', widget.user.id)
        .order('created_at', ascending: false)
        .limit(50);

    final metricsByListing = <String, Map<String, dynamic>>{
      for (final row in metricsResponse)
        row['listing_id'] as String: Map<String, dynamic>.from(row),
    };
    final listings = listingsResponse.map((row) {
      final data = Map<String, dynamic>.from(row);
      final metrics = metricsByListing[data['id'] as String];
      return MaterialListing.fromMap(data, stats: metrics);
    }).toList();
    final inquiries = inquiriesResponse.map((row) {
      final data = Map<String, dynamic>.from(row);
      final joinedListing = data['listings'] as Map<String, dynamic>?;
      return BuyerInquiry(
        message: data['message'] as String,
        listingTitle: joinedListing?['title'] as String? ?? 'Your listing',
        createdAt: DateTime.tryParse(data['created_at'] as String? ?? ''),
      );
    }).toList();

    return ProfileSnapshot(listings: listings, inquiries: inquiries);
  }

  Future<void> _refresh() async {
    final future = _loadSnapshot();
    setState(() => _snapshot = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your profile'),
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder<ProfileSnapshot>(
        future: _snapshot,
        builder: (context, result) {
          if (result.hasError) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _accountCard(),
                const SizedBox(height: 20),
                _EmptyDataCard(
                  icon: Icons.cloud_off_rounded,
                  title: 'Statistics could not be loaded',
                  message: 'Check your connection and pull down to try again.',
                ),
              ],
            );
          }
          if (!result.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final snapshot = result.data!;
          final activeCount = snapshot.listings
              .where((listing) => listing.status == 'active')
              .length;
          final totalViews = snapshot.listings.fold<int>(
            0,
            (sum, listing) => sum + listing.uniqueViews,
          );
          final totalInquiries = snapshot.listings.fold<int>(
            0,
            (sum, listing) => sum + listing.buyerInquiries,
          );

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                _accountCard(),
                const SizedBox(height: 28),
                const SectionLabel('Statistics'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        value: '$activeCount',
                        label: 'Active listings',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        value: '$totalViews',
                        label: 'Unique viewers',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        value: '$totalInquiries',
                        label: 'Buyer inquiries',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const SectionLabel('Your listings'),
                const SizedBox(height: 12),
                if (snapshot.listings.isEmpty)
                  const _EmptyDataCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'No published listings',
                    message: 'When you publish a listing, it will appear here with its real view and inquiry counts.',
                  )
                else
                  for (final listing in snapshot.listings) ...[
                    _ProfileListingCard(listing: listing),
                    const SizedBox(height: 10),
                  ],
                const SizedBox(height: 18),
                const SectionLabel('Buyer inquiries'),
                const SizedBox(height: 12),
                if (snapshot.inquiries.isEmpty)
                  const _EmptyDataCard(
                    icon: Icons.mark_chat_unread_outlined,
                    title: 'No buyer inquiries',
                    message: 'Messages sent from your listing pages will appear here.',
                  )
                else
                  for (final inquiry in snapshot.inquiries) ...[
                    _InquiryCard(inquiry: inquiry),
                    const SizedBox(height: 10),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _accountCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.blue,
          child: Text(
            _initials,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.user.email ?? 'No email on this account',
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class ProfileSnapshot {
  const ProfileSnapshot({required this.listings, required this.inquiries});

  final List<MaterialListing> listings;
  final List<BuyerInquiry> inquiries;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 86),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
      ],
    ),
  );
}

class _ProfileListingCard extends StatelessWidget {
  const _ProfileListingCard({required this.listing});

  final MaterialListing listing;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                listing.title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              listing.status == 'active' ? 'Active' : listing.status,
              style: const TextStyle(color: AppColors.blue, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('₽${_formatPrice(listing.price)} · ${listing.quantity}'),
        const SizedBox(height: 8),
        Text(
          '${listing.uniqueViews} unique viewers  ·  ${listing.buyerInquiries} inquiries',
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    ),
  );
}

class _InquiryCard extends StatelessWidget {
  const _InquiryCard({required this.inquiry});

  final BuyerInquiry inquiry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          inquiry.listingTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(inquiry.message),
        if (inquiry.createdAt != null) ...[
          const SizedBox(height: 8),
          Text(
            '${inquiry.createdAt!.toLocal()}'.split('.').first,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ],
    ),
  );
}

class _EmptyDataCard extends StatelessWidget {
  const _EmptyDataCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.blue, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(color: AppColors.muted, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.all(Radius.circular(14)),
            boxShadow: [BoxShadow(color: AppColors.teal, offset: Offset(5, 6))],
          ),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Text(
                'RB',
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 9),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ReBuild',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            if (!compact)
              const Text(
                'Good materials find a new home',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
          ],
        ),
      ],
    );
  }
}

class MaterialListing {
  const MaterialListing({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.quantity,
    required this.price,
    required this.category,
    required this.condition,
    required this.photoPath,
    required this.status,
    required this.createdAt,
    this.uniqueViews = 0,
    this.buyerInquiries = 0,
  });

  final String id;
  final String sellerId;
  final String title;
  final String description;
  final String quantity;
  final double price;
  final String category;
  final String? condition;
  final String? photoPath;
  final String status;
  final DateTime? createdAt;
  final int uniqueViews;
  final int buyerInquiries;

  String? get photoUrl => photoPath == null
      ? null
      : supabase.storage.from('listing-photos').getPublicUrl(photoPath!);

  factory MaterialListing.fromMap(
    Map<String, dynamic> row, {
    Map<String, dynamic>? stats,
  }) {
    final rawPrice = row['price'];
    return MaterialListing(
      id: row['id'] as String,
      sellerId: row['seller_id'] as String,
      title: row['title'] as String,
      description: row['description'] as String? ?? '',
      quantity: row['quantity'] as String? ?? '',
      price: rawPrice is num
          ? rawPrice.toDouble()
          : double.tryParse('$rawPrice') ?? 0,
      category: row['category'] as String? ?? 'Other',
      condition: row['condition'] as String?,
      photoPath: row['photo_path'] as String?,
      status: row['status'] as String? ?? 'active',
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? ''),
      uniqueViews: (stats?['unique_views'] as num?)?.toInt() ?? 0,
      buyerInquiries: (stats?['buyer_inquiries'] as num?)?.toInt() ?? 0,
    );
  }
}

class BuyerInquiry {
  const BuyerInquiry({
    required this.message,
    required this.listingTitle,
    required this.createdAt,
  });

  final String message;
  final String listingTitle;
  final DateTime? createdAt;
}

String _formatPrice(double price) => price == price.roundToDouble()
    ? price.toStringAsFixed(0)
    : price.toStringAsFixed(2);

class BuyScreen extends StatefulWidget {
  const BuyScreen({
    super.key,
    required this.onSell,
    required this.refreshToken,
  });

  final VoidCallback onSell;
  final int refreshToken;

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  int category = 0;
  bool _loading = true;
  String? _loadError;
  List<MaterialListing> _listings = [];
  final _searchController = TextEditingController();

  static const categories = [
    Category('All', Icons.grid_view_rounded),
    Category('Tiles', Icons.dashboard_rounded),
    Category('Paint', Icons.format_paint_rounded),
    Category('Plumbing', Icons.water_drop_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  @override
  void didUpdateWidget(covariant BuyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _loadListings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadListings() async {
    if (supabase.auth.currentUser == null) {
      setState(() {
        _listings = [];
        _loadError = 'Sign in to view listings from the database.';
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final rows = await supabase
          .from('listings')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(100);
      if (!mounted) return;
      setState(() {
        _listings = rows
            .map(
              (row) => MaterialListing.fromMap(Map<String, dynamic>.from(row)),
            )
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Could not load current listings. Check your connection and try again.';
        _loading = false;
      });
    }
  }

  List<MaterialListing> get _filteredListings {
    final categoryName = categories[category].name.toLowerCase();
    final query = _searchController.text.trim().toLowerCase();
    return _listings.where((listing) {
      final matchesCategory =
          category == 0 ||
          listing.category.toLowerCase().contains(categoryName);
      final matchesSearch =
          query.isEmpty ||
          '${listing.title} ${listing.category} ${listing.description}'
              .toLowerCase()
              .contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openListing(MaterialListing listing) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ListingDetailScreen(listing: listing),
      ),
    );
  }

  Widget _materialsContent() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return _EmptyDataCard(
        icon: Icons.cloud_off_rounded,
        title: supabase.auth.currentUser == null
            ? 'Sign in to view materials'
            : 'Listings unavailable',
        message: _loadError!,
      );
    }
    final filtered = _filteredListings;
    if (filtered.isEmpty) {
      return _EmptyDataCard(
        icon: Icons.storefront_outlined,
        title: _listings.isEmpty ? 'No listings yet' : 'No matching materials',
        message: _listings.isEmpty
            ? 'There are no materials in the database yet. New listings will appear here when available.'
            : 'Try another search or category.',
      );
    }
    return Column(
      children: [
        for (final listing in filtered) ...[
          ListingCard(listing: listing, onTap: () => _openListing(listing)),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66355C95),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  child: Text(
                    'Nearby finds · Better prices',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Building materials\ndeserve a second life',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 31,
                  height: .98,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Find quality leftover materials from local renovation projects.',
                style: TextStyle(
                  color: Color(0xFFD6E2F3),
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'What are you looking for?',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.blue,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceRaised,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(6),
                    child: FilledButton(
                      onPressed: () => FocusScope.of(context).unfocus(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Search'),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const SectionLabel('Browse categories'),
        const SizedBox(height: 12),
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, index) => const SizedBox(width: 10),
            itemBuilder: (_, index) => CategoryButton(
              item: categories[index],
              active: index == category,
              onTap: () => setState(() => category = index),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const SectionLabel('Available materials'),
        const SizedBox(height: 12),
        _materialsContent(),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Got materials left over?',
                style: TextStyle(
                  color: Color(0xFFD3E0F3),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Clear some space\nand make money back',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 25,
                  height: 1.02,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 17),
              FilledButton.icon(
                onPressed: widget.onSell,
                icon: const Icon(Icons.add_rounded),
                label: const Text('List materials'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.surfaceRaised,
                  foregroundColor: AppColors.ink,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ListingCard extends StatelessWidget {
  const ListingCard({super.key, required this.listing, required this.onTap});

  final MaterialListing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photoUrl = listing.photoUrl;
    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: 82,
                  height: 82,
                  child: photoUrl == null
                      ? const ColoredBox(
                          color: AppColors.teal,
                          child: Icon(Icons.construction_rounded, size: 36),
                        )
                      : Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, error, stack) => const ColoredBox(
                            color: AppColors.teal,
                            child: Icon(Icons.broken_image_outlined, size: 30),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₽${_formatPrice(listing.price)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${listing.quantity} · ${listing.category}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key, required this.listing});

  final MaterialListing listing;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  bool _sendingInquiry = false;

  @override
  void initState() {
    super.initState();
    _recordUniqueView();
  }

  Future<void> _recordUniqueView() async {
    final viewer = supabase.auth.currentUser;
    if (viewer == null || viewer.id == widget.listing.sellerId) return;
    try {
      await supabase
          .from('listing_views')
          .upsert(
            {'listing_id': widget.listing.id, 'viewer_id': viewer.id},
            onConflict: 'listing_id,viewer_id',
            ignoreDuplicates: true,
          );
    } catch (_) {
      // Browsing remains available if event tracking is temporarily offline.
    }
  }

  Future<void> _contactSeller() async {
    final controller = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        title: const Text('Message the seller'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          maxLength: 2000,
          decoration: const InputDecoration(
            hintText: 'Ask a question about this material',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: const Text('Send inquiry'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (message == null || !mounted) return;

    setState(() => _sendingInquiry = true);
    try {
      await supabase.from('listing_inquiries').insert({
        'listing_id': widget.listing.id,
        'buyer_id': supabase.auth.currentUser!.id,
        'message': message,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your inquiry was sent to the seller.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not send your inquiry. Try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingInquiry = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final photoUrl = listing.photoUrl;
    final isOwner = supabase.auth.currentUser?.id == listing.sellerId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material details'),
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 1.35,
              child: photoUrl == null
                  ? const ColoredBox(
                      color: AppColors.surfaceRaised,
                      child: Icon(Icons.construction_rounded, size: 72),
                    )
                  : Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stack) => const ColoredBox(
                        color: AppColors.surfaceRaised,
                        child: Icon(Icons.broken_image_outlined, size: 50),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '₽${_formatPrice(listing.price)}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            listing.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '${listing.quantity} · ${listing.category}',
            style: const TextStyle(color: AppColors.muted),
          ),
          if ((listing.condition ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Condition: ${listing.condition}'),
          ],
          if (listing.description.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(listing.description, style: const TextStyle(height: 1.45)),
          ],
          if (!isOwner) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _sendingInquiry ? null : _contactSeller,
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: Text(_sendingInquiry ? 'Sending…' : 'Message seller'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SellScreen extends StatefulWidget {
  const SellScreen({super.key, required this.onPublished});
  final VoidCallback onPublished;

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _titleController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  Uint8List? _photoBytes;
  String? _photoName;
  String? _photoMimeType;
  String _category = 'Other';
  String? _condition;
  bool _analyzing = false;
  bool _publishing = false;
  String? _analysisError;
  List<String> _questions = [];

  String _mimeTypeFor(XFile photo) {
    final mimeType = photo.mimeType?.toLowerCase();
    if (mimeType != null && mimeType.startsWith('image/')) return mimeType;
    final extension = photo.name.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      _ => 'image/jpeg',
    };
  }

  Future<void> _pickPhoto() async {
    if (supabase.auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in before adding a listing.')),
      );
      return;
    }
    final photo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1800,
    );
    if (photo == null) return;

    setState(() {
      _analyzing = true;
      _analysisError = null;
      _questions = [];
    });
    try {
      final bytes = await photo.readAsBytes();
      if (bytes.length > 3_300_000) {
        throw const FormatException(
          'This photo is too large. Choose a smaller image and try again.',
        );
      }
      final mimeType = _mimeTypeFor(photo);
      if (!{
        'image/jpeg',
        'image/png',
        'image/webp',
        'image/heic',
        'image/heif',
      }.contains(mimeType)) {
        throw const FormatException(
          'Use a JPEG, PNG, WebP, HEIC, or HEIF photo.',
        );
      }
      setState(() {
        _photoBytes = bytes;
        _photoName = photo.name;
        _photoMimeType = mimeType;
      });
      final response = await supabase.functions.invoke(
        'describe-material',
        body: {'imageBase64': base64Encode(bytes), 'mimeType': mimeType},
      );
      final responseData = Map<String, dynamic>.from(response.data as Map);
      final draft = Map<String, dynamic>.from(responseData['draft'] as Map);
      final title = (draft['title'] as String? ?? '').trim();
      final description = (draft['description'] as String? ?? '').trim();
      final quantity = (draft['quantity'] as String? ?? '').trim();
      final dimensions = (draft['dimensions'] as String? ?? '').trim();
      final brand = (draft['brand'] as String? ?? '').trim();
      final condition = (draft['condition'] as String? ?? '').trim();
      final color = (draft['color'] as String? ?? '').trim();
      final attributes = <String>[];
      if (condition.isNotEmpty) attributes.add('Condition: $condition');
      if (dimensions.isNotEmpty) attributes.add('Dimensions: $dimensions');
      if (brand.isNotEmpty) attributes.add('Brand: $brand');
      if (color.isNotEmpty) attributes.add('Color: $color');
      final questions = (draft['questions'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((question) => (question['question'] as String? ?? '').trim())
          .where((question) => question.isNotEmpty)
          .take(4)
          .toList();
      if (!mounted) return;
      setState(() {
        _category = (draft['category'] as String? ?? 'Other').trim();
        _condition = condition.isEmpty ? null : condition;
        if (title.isNotEmpty) _titleController.text = title;
        _quantityController.text = quantity;
        _notesController.text = [
          description,
          ...attributes,
        ].where((line) => line.isNotEmpty).join('\n');
        _questions = questions;
      });
    } on FormatException catch (error) {
      if (mounted) {
        setState(() => _analysisError = error.message);
      }
    } on FunctionException catch (error) {
      final details = error.details;
      final message = details is Map && details['error'] is String
          ? details['error'] as String
          : switch (error.status) {
              401 => 'Please sign in again before analyzing a photo.',
              429 => 'The Gemini free-tier limit was reached. Please try again later.',
              _ => 'Could not analyze this photo. Please try again.',
            };
      if (mounted) setState(() => _analysisError = message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _analysisError = 'Could not analyze this photo. Check your connection and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  Future<void> _publishListing() async {
    final user = supabase.auth.currentUser;
    final title = _titleController.text.trim();
    final quantity = _quantityController.text.trim();
    final rawPrice = _priceController.text
        .trim()
        .replaceAll(RegExp(r'[\s₽]'), '')
        .replaceAll(',', '.');
    final price = double.tryParse(rawPrice);
    final bytes = _photoBytes;
    final mimeType = _photoMimeType;

    String? validationMessage;
    if (user == null) {
      validationMessage = 'Sign in before publishing a listing.';
    } else if (title.isEmpty) {
      validationMessage = 'Add a name for the material.';
    } else if (quantity.isEmpty) {
      validationMessage = 'Add the quantity you have left.';
    } else if (price == null || price < 0) {
      validationMessage = 'Enter a valid price, using numbers only.';
    } else if (bytes == null || mimeType == null) {
      validationMessage = 'Add a photo of the material before publishing.';
    }
    if (validationMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }

    setState(() => _publishing = true);
    final extension = switch (mimeType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      'image/heic' => 'heic',
      'image/heif' => 'heif',
      _ => 'jpg',
    };
    final photoPath =
        '${user!.id}/${DateTime.now().microsecondsSinceEpoch}.$extension';
    var uploaded = false;
    try {
      await supabase.storage
          .from('listing-photos')
          .uploadBinary(
            photoPath,
            bytes!,
            fileOptions: FileOptions(contentType: mimeType, upsert: false),
          );
      uploaded = true;
      await supabase.from('listings').insert({
        'seller_id': user.id,
        'title': title,
        'description': _notesController.text.trim(),
        'quantity': quantity,
        'price': price,
        'category': _category.isEmpty ? 'Other' : _category,
        'condition': _condition,
        'photo_path': photoPath,
        'status': 'active',
      });
      if (!mounted) return;
      _titleController.clear();
      _quantityController.clear();
      _priceController.clear();
      _notesController.clear();
      setState(() {
        _photoBytes = null;
        _photoName = null;
        _photoMimeType = null;
        _category = 'Other';
        _condition = null;
        _questions = [];
        _analysisError = null;
      });
      widget.onPublished();
    } catch (_) {
      if (uploaded) {
        try {
          await supabase.storage.from('listing-photos').remove([photoPath]);
        } catch (_) {
          // Keep the original publish error; a leftover image is harmless.
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not publish your listing. Check your connection and try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: [
        const Text(
          'Sell leftover materials',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 7),
        const Text(
          'Take a photo of your materials and we’ll help create a listing.',
          style: TextStyle(fontSize: 16, color: AppColors.muted, height: 1.3),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: AppColors.blue),
                  SizedBox(width: 8),
                  Text(
                    'AI listing assistant',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'Photo → draft description → your review',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.blue,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'AI will identify the material and suggest a description and details. If anything is unclear, it will ask you.',
                style: TextStyle(color: AppColors.muted, height: 1.3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: _analyzing ? null : _pickPhoto,
          icon: Icon(
            _analyzing
                ? Icons.hourglass_top_rounded
                : Icons.add_a_photo_outlined,
          ),
          label: Text(_analyzing ? 'Analyzing photo…' : 'Add a photo'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.blue,
            side: const BorderSide(color: AppColors.blue),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        if (_photoBytes != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _photoBytes!,
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _photoName ?? 'Material photo',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const Icon(Icons.check_circle_rounded, color: AppColors.blue),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        const Text(
          'Your photo is saved with the listing only when you publish it.',
          style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.35),
        ),
        if (_analysisError != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF512D3A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _analysisError!,
              style: const TextStyle(color: AppColors.ink, height: 1.35),
            ),
          ),
        ],
        if (_questions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A few details to confirm',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                for (final question in _questions)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '•  ',
                          style: TextStyle(color: AppColors.blue),
                        ),
                        Expanded(
                          child: Text(
                            question,
                            style: const TextStyle(
                              color: AppColors.muted,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        const SectionLabel('Review and complete your draft'),
        const SizedBox(height: 12),
        AppTextField(
          label: 'What are you selling?',
          hint: 'For example: bathroom tiles',
          controller: _titleController,
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'How much is left?',
          hint: 'For example: 12 m² or 3 packs',
          controller: _quantityController,
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Price',
          hint: 'For example: 1250',
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Notes',
          hint: 'Condition, area, pickup availability',
          maxLines: 3,
          controller: _notesController,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _publishing || _analyzing ? null : _publishListing,
          icon: const Icon(Icons.publish_rounded),
          label: Text(_publishing ? 'Publishing…' : 'Publish listing'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.teal,
            padding: const EdgeInsets.symmetric(vertical: 17),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class AuthSheet extends StatefulWidget {
  const AuthSheet({
    super.key,
    required this.onAuthenticated,
    this.fullScreen = false,
  });
  final ValueChanged<String> onAuthenticated;
  final bool fullScreen;

  @override
  State<AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<AuthSheet> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _registering = false;
  bool _loading = false;

  String _friendlyAuthError(String message) {
    final error = message.toLowerCase();
    if (error.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (error.contains('rate limit') || error.contains('too many requests')) {
      return 'Too many attempts. Please wait a few minutes and try again.';
    }
    if (error.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (error.contains('email not confirmed')) {
      return 'Confirm your email using the link we sent, then sign in.';
    }
    return 'We couldn’t sign you in. Check your details and try again.';
  }

  Future<void> _showNotice({
    required String title,
    required String message,
    bool error = false,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Icon(
          error ? Icons.error_outline_rounded : Icons.mark_email_read_outlined,
          color: error ? const Color(0xFFE18B96) : AppColors.blue,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(message, style: const TextStyle(color: AppColors.muted)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    final firstName = _firstName.text.trim();
    final lastName = _lastName.text.trim();
    if (!email.contains('@') ||
        password.length < 6 ||
        (_registering && (firstName.isEmpty || lastName.isEmpty))) {
      await _showNotice(
        title: 'Check your details',
        message: _registering
            ? 'Enter your first name, last name, a valid email, and a password of at least 6 characters.'
            : 'Enter a valid email and a password of at least 6 characters.',
        error: true,
      );
      return;
    }

    setState(() => _loading = true);
    try {
      if (_registering) {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
          data: {'first_name': firstName, 'last_name': lastName},
        );
        if (!mounted) return;
        if (response.session == null) {
          await _showNotice(
            title: 'Check your inbox',
            message: 'We sent you a confirmation email. Open the link inside, then sign in.',
          );
          setState(() => _registering = false);
        } else {
          widget.onAuthenticated(email);
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (mounted) widget.onAuthenticated(email);
      }
    } on AuthException catch (error) {
      if (mounted) {
        await _showNotice(
          title: 'Sign-in failed',
          message: _friendlyAuthError(error.message),
          error: true,
        );
      }
    } catch (_) {
      if (mounted) {
        await _showNotice(
          title: 'Connection error',
          message: 'We couldn’t reach the server. Please try again.',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _registering
                ? 'Create your ReBuild account'
                : 'Welcome back to ReBuild',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sign in to contact sellers or list leftover materials.',
            style: TextStyle(color: AppColors.muted),
          ),
          if (widget.fullScreen) ...[
            const SizedBox(height: 10),
            const Text(
              'We’ll remember you on this device.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),
          if (_registering) ...[
            AppTextField(
              label: 'First name',
              hint: 'For example: Alex',
              controller: _firstName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Last name',
              hint: 'For example: Taylor',
              controller: _lastName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
          ],
          AppTextField(
            label: 'Email address',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            controller: _email,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Password',
            hint: 'At least 6 characters',
            obscure: true,
            controller: _password,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.blue,
              minimumSize: const Size.fromHeight(54),
            ),
            child: Text(
              _loading
                  ? 'Please wait…'
                  : _registering
                  ? 'Create account'
                  : 'Sign in',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: _loading
                ? null
                : () => setState(() => _registering = !_registering),
            child: Text(
              _registering
                  ? 'Already have an account? Sign in'
                  : 'Create an account',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: panel,
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.obscure = false,
    this.keyboardType,
    this.controller,
    this.textCapitalization = TextCapitalization.none,
  });
  final String label;
  final String hint;
  final int maxLines;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          maxLines: maxLines,
          obscureText: obscure,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surfaceRaised,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}

class NavButton extends StatelessWidget {
  const NavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.blue : AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: active ? AppColors.ink : AppColors.muted),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: active ? AppColors.ink : AppColors.muted,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  const CategoryButton({
    super.key,
    required this.item,
    required this.active,
    required this.onTap,
  });
  final Category item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        width: 94,
        decoration: BoxDecoration(
          color: active ? AppColors.blue : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: active ? AppColors.blue : AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: AppColors.ink),
            const SizedBox(height: 6),
            Text(
              item.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
  );
}

class Category {
  const Category(this.name, this.icon);
  final String name;
  final IconData icon;
}

import 'package:flutter/material.dart';

void main() => runApp(const FoodieGoApp());

const _cream = Color(0xFFFFFBF4);
const _black = Color(0xFF101010);
const _hungryBrown = Color(0xFF7E2A17);

class FoodieGoApp extends StatelessWidget {
  const FoodieGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodieGo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _cream,
        colorScheme: ColorScheme.fromSeed(seedColor: _hungryBrown),
      ),
      home: const WelcomePage(),
    );
  }
}

class FoodItemData {
  final String name;
  final double price;
  final String restaurant;
  final String imageAsset;

  const FoodItemData(this.name, this.price, this.restaurant, this.imageAsset);
}

class AppState {
  static const items = <String, FoodItemData>{
    'MOMO': FoodItemData('MOMO', 6.70, 'THE HUNGRY', 'assets/foods/momo.png'),
    'YOMARI': FoodItemData('YOMARI', 6.70, 'THE HUNGRY', 'assets/foods/yomari.png'),
    'THALI SET': FoodItemData('THALI SET', 15.00, 'THE HUNGRY', 'assets/foods/thali.png'),
    'SELROTI': FoodItemData('SELROTI', 5.00, 'THE HUNGRY', 'assets/foods/selroti.png'),
    'THUKPA': FoodItemData('THUKPA', 6.00, 'THE HUNGRY', 'assets/foods/thukpa.png'),
  };

  static final Map<String, int> quantities = {
    for (final key in items.keys) key: 0,
  };

  // Remembers which restaurant the user selected each food from.
  // This keeps the cart demonstration meaningful even when browsing
  // the additional restaurants added below the original Figma screen.
  static final Map<String, String> itemRestaurants = {};

  static const descriptions = <String, String>{
    'MOMO': 'Steamed dumplings filled with seasoned meat or vegetables, served with a flavourful dipping sauce.',
    'YOMARI': 'A traditional Newari steamed rice-flour dumpling with a soft shell and a sweet filling.',
    'THALI SET': 'A complete Nepali meal served with rice, lentils, curry, vegetables, pickle and side dishes.',
    'SELROTI': 'A traditional ring-shaped Nepali rice bread with a lightly sweet taste and a crisp outside.',
    'THUKPA': 'A warm Himalayan noodle soup prepared with vegetables, herbs and a rich savoury broth.',
  };

  static String descriptionFor(String name) =>
      descriptions[name] ?? 'A freshly prepared dish made with quality ingredients and served with FoodieGo care.';

  static String restaurantFor(String name) => itemRestaurants[name] ?? items[name]?.restaurant ?? 'THE HUNGRY';

  static void addFrom(String name, String restaurant, [int amount = 1]) {
    itemRestaurants[name] = restaurant;
    add(name, amount);
  }

  static String momoRestaurant = 'THE HUNGRY';
  static String momoRestaurantSub = 'DRAGON & WOK';

  static int qty(String name) => quantities[name] ?? 0;

  static void add(String name, [int amount = 1]) {
    final next = qty(name) + amount;
    quantities[name] = next < 0 ? 0 : (next > 99 ? 99 : next);
  }

  static void setQty(String name, int quantity) {
    quantities[name] = quantity < 0 ? 0 : (quantity > 99 ? 99 : quantity);
  }

  static List<FoodItemData> get cartItems => items.values
      .where((item) => qty(item.name) > 0)
      .toList(growable: false);

  static double get itemsTotal => cartItems.fold(
        0,
        (sum, item) => sum + item.price * qty(item.name),
      );

  static const double delivery = 2.67;
  static double get grandTotal => cartItems.isEmpty ? 0 : itemsTotal + delivery;

  // Demo delivery information used by checkout and order tracking.
  static String deliveryPlace = 'ABC PLACE';
  static String deliveryStreet = 'ABC STREET';

  static String get fullAddress => '$deliveryPlace, $deliveryStreet';

  static int get deliveryMinutes {
    final text = fullAddress.toLowerCase();
    if (text.contains('city') || text.contains('central') || text.contains('main')) return 18;
    if (text.contains('north') || text.contains('hill')) return 28;
    if (text.contains('south') || text.contains('park')) return 24;
    final score = fullAddress.codeUnits.fold<int>(0, (a, b) => a + b);
    return 20 + (score % 9);
  }

  static String get etaText => '$deliveryMinutes - ${deliveryMinutes + 5} MINUTES';

  static String get orderStatus =>
      deliveryMinutes <= 20 ? 'Rider is nearby' : 'On the way to $deliveryPlace';
}

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}

void _home(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const HomePage()),
    (route) => false,
  );
}

/// Paints the exact exported Figma screen as the visual layer, then places
/// transparent/functional Flutter controls over the interactive regions.
class PrototypeScreen extends StatelessWidget {
  final String asset;
  final List<Widget> overlays;
  final Color background;

  const PrototypeScreen({
    super.key,
    required this.asset,
    this.overlays = const [],
    this.background = _cream,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox.expand(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    asset,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                  ),
                  ...overlays,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class Hotspot extends StatelessWidget {
  final double left;
  final double top;
  final double width;
  final double height;
  final VoidCallback onTap;

  /// All values are normalized 0..1 based on the Figma screen.
  const Hotspot({
    super.key,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, c) => Stack(
          children: [
            Positioned(
              left: c.maxWidth * left,
              top: c.maxHeight * top,
              width: c.maxWidth * width,
              height: c.maxHeight * height,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.black12,
                  highlightColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  onTap: onTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      asset: 'assets/screens/welcome.png',
      overlays: [
        Hotspot(
          left: .23,
          top: .64,
          width: .54,
          height: .09,
          onTap: () => _push(context, const LoginPage()),
        ),
        Hotspot(
          left: .08,
          top: .75,
          width: .84,
          height: .09,
          onTap: () => _push(context, const SignupPage()),
        ),
      ],
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      asset: 'assets/screens/login.png',
      overlays: [
        Hotspot(left: .04, top: .02, width: .18, height: .10, onTap: () => Navigator.maybePop(context)),
        const _InvisibleTextField(left: .07, top: .33, width: .86, height: .075),
        const _InvisibleTextField(left: .07, top: .44, width: .86, height: .075, obscure: true),
        Hotspot(left: .07, top: .82, width: .86, height: .09, onTap: () => _home(context)),
      ],
    );
  }
}

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      asset: 'assets/screens/signup.png',
      overlays: [
        Hotspot(left: .04, top: .02, width: .18, height: .10, onTap: () => Navigator.maybePop(context)),
        const _InvisibleTextField(left: .07, top: .33, width: .86, height: .075),
        const _InvisibleTextField(left: .07, top: .44, width: .86, height: .075, obscure: true),
        const _InvisibleTextField(left: .07, top: .55, width: .86, height: .075, obscure: true),
        Hotspot(left: .07, top: .82, width: .86, height: .09, onTap: () => _home(context)),
      ],
    );
  }
}

class _InvisibleTextField extends StatelessWidget {
  final double left;
  final double top;
  final double width;
  final double height;
  final bool obscure;

  const _InvisibleTextField({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, c) => Stack(
          children: [
            Positioned(
              left: c.maxWidth * left,
              top: c.maxHeight * top,
              width: c.maxWidth * width,
              height: c.maxHeight * height,
              child: TextField(
                obscureText: obscure,
                cursorColor: Colors.transparent,
                style: const TextStyle(color: Colors.transparent),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _OriginalPrototypeSection(
                      asset: 'assets/screens/home.png',
                      sourceWidth: 494,
                      sourceHeight: 1074,
                      cropFraction: .895,
                      overlays: [
                        _SectionHotspot(left: .04, top: .105, width: .92, height: .075, onTap: () => _push(context, const SearchPage())),
                        _SectionHotspot(left: .04, top: .295, width: .92, height: .205, onTap: () => _push(context, const MomoPage())),
                        _SectionHotspot(left: .04, top: .65, width: .92, height: .205, onTap: () => _push(context, const RestaurantPage())),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                      child: Text(
                        'MORE RESTAURANTS',
                        style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Colors.black.withOpacity(.92)),
                      ),
                    ),
                    _RestaurantChoiceCard(
                      name: 'THE HUNGRY',
                      subtitle: 'DRAGON & WOK',
                      imageAsset: 'assets/foods/momo.png',
                      onTap: () => _push(context, const RestaurantPage()),
                    ),
                    _RestaurantChoiceCard(
                      name: 'FLAVORS OF NEPAL',
                      subtitle: 'AUTHENTIC NEPALI FOOD',
                      imageAsset: 'assets/foods/thali.png',
                      onTap: () => _push(context, const SimpleRestaurantPage(name: 'FLAVORS OF NEPAL')),
                    ),
                    _RestaurantChoiceCard(
                      name: 'NEWARI HOUSE',
                      subtitle: 'TRADITIONAL NEWARI KITCHEN',
                      imageAsset: 'assets/foods/yomari.png',
                      onTap: () => _push(context, const SimpleRestaurantPage(name: 'NEWARI HOUSE')),
                    ),
                    _RestaurantChoiceCard(
                      name: 'HIMALAYAN KITCHEN',
                      subtitle: 'NEPALI & HIMALAYAN DISHES',
                      imageAsset: 'assets/foods/thukpa.png',
                      onTap: () => _push(context, const SimpleRestaurantPage(name: 'HIMALAYAN KITCHEN')),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _realNav(context, 0),
          ],
        ),
      ),
    );
  }
}

class _OriginalPrototypeSection extends StatelessWidget {
  final String asset;
  final double sourceWidth;
  final double sourceHeight;
  final double cropFraction;
  final List<Widget> overlays;

  const _OriginalPrototypeSection({
    required this.asset,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.cropFraction,
    this.overlays = const [],
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final fullHeight = c.maxWidth * sourceHeight / sourceWidth;
        final visibleHeight = fullHeight * cropFraction;
        return SizedBox(
          height: visibleHeight,
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  width: c.maxWidth,
                  height: fullHeight,
                  child: Image.asset(asset, fit: BoxFit.fill, filterQuality: FilterQuality.high, gaplessPlayback: true),
                ),
                ...overlays.map((w) => Positioned(left: 0, top: 0, width: c.maxWidth, height: fullHeight, child: w)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHotspot extends StatelessWidget {
  final double left;
  final double top;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _SectionHotspot({required this.left, required this.top, required this.width, required this.height, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => Stack(
        children: [
          Positioned(
            left: c.maxWidth * left,
            top: c.maxHeight * top,
            width: c.maxWidth * width,
            height: c.maxHeight * height,
            child: Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18))),
          ),
        ],
      ),
    );
  }
}

class _RestaurantChoiceCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String imageAsset;
  final VoidCallback onTap;

  const _RestaurantChoiceCard({required this.name, required this.subtitle, required this.imageAsset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Material(
        color: _black,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                ClipOval(child: Image.asset(imageAsset, width: 82, height: 82, fit: BoxFit.cover, filterQuality: FilterQuality.high)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 5),
                      Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      asset: 'assets/screens/search.png',
      overlays: [
        Hotspot(left: .02, top: .02, width: .18, height: .09, onTap: () => Navigator.maybePop(context)),
        Hotspot(left: .02, top: .39, width: .96, height: .22, onTap: () => _push(context, const RestaurantPage())),
        _nav(context, 1),
      ],
    );
  }
}

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({super.key});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  void _add(String item) {
    setState(() => AppState.addFrom(item, 'THE HUNGRY'));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 900),
        content: Text('$item added to cart from THE HUNGRY'),
        action: SnackBarAction(label: 'CART', onPressed: () => _push(context, const CartPage())),
      ),
    );
  }

  void _openFood(String item) {
    if (item == 'MOMO') {
      AppState.momoRestaurant = 'THE HUNGRY';
      _push(context, const MomoPage());
    } else {
      _push(context, FoodDetailPage(itemName: item, restaurant: 'THE HUNGRY'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _hungryBrown,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: _cream,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _OriginalPrototypeSection(
                        asset: 'assets/screens/restaurant.png',
                        sourceWidth: 494,
                        sourceHeight: 1088,
                        cropFraction: .895,
                        overlays: [
                          _SectionHotspot(left: .01, top: .03, width: .16, height: .10, onTap: () => Navigator.maybePop(context)),
                          _SectionHotspot(left: .02, top: .25, width: .68, height: .20, onTap: () => _openFood('MOMO')),
                          _SectionHotspot(left: .78, top: .32, width: .17, height: .11, onTap: () => _add('MOMO')),
                          _SectionHotspot(left: .03, top: .49, width: .46, height: .21, onTap: () => _openFood('YOMARI')),
                          _SectionHotspot(left: .51, top: .49, width: .46, height: .21, onTap: () => _openFood('THALI SET')),
                          _SectionHotspot(left: .03, top: .72, width: .46, height: .18, onTap: () => _openFood('SELROTI')),
                          _SectionHotspot(left: .51, top: .72, width: .46, height: .18, onTap: () => _openFood('THUKPA')),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(18, 16, 18, 5),
                        child: Text('FULL MENU', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(18, 0, 18, 8),
                        child: Text('Swipe to browse more food and tap a dish to view its description.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
                      ),
                      ...AppState.items.values.map((item) => _MenuFoodCard(
                            item: item,
                            restaurant: 'THE HUNGRY',
                            onOpen: () => _openFood(item.name),
                            onAdd: () => _add(item.name),
                          )),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Container(color: _cream, child: _realNav(context, 1)),
          ],
        ),
      ),
    );
  }
}

class _MenuFoodCard extends StatelessWidget {
  final FoodItemData item;
  final String restaurant;
  final VoidCallback onOpen;
  final VoidCallback onAdd;

  const _MenuFoodCard({required this.item, required this.restaurant, required this.onOpen, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 7, 18, 7),
      child: Material(
        color: _black,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipOval(child: Image.asset(item.imageAsset, width: 82, height: 82, fit: BoxFit.cover, filterQuality: FilterQuality.high)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text('FROM $restaurant', style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleRestaurantPage extends StatefulWidget {
  final String name;
  const SimpleRestaurantPage({super.key, required this.name});

  @override
  State<SimpleRestaurantPage> createState() => _SimpleRestaurantPageState();
}

class _SimpleRestaurantPageState extends State<SimpleRestaurantPage> {
  void _add(String item) {
    setState(() => AppState.addFrom(item, widget.name));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 900),
        content: Text('$item added to cart from ${widget.name}'),
        action: SnackBarAction(label: 'CART', onPressed: () => _push(context, const CartPage())),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: _hungryBrown,
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 18),
              child: Row(
                children: [
                  IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30)),
                  Expanded(
                    child: Column(
                      children: [
                        Text(widget.name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 3),
                        const Text('NEPALI FOOD • FOODIEGO', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Text('MOST POPULAR', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  ),
                  ...AppState.items.values.map((item) => _MenuFoodCard(
                        item: item,
                        restaurant: widget.name,
                        onOpen: () => _push(context, FoodDetailPage(itemName: item.name, restaurant: widget.name)),
                        onAdd: () => _add(item.name),
                      )),
                ],
              ),
            ),
            _realNav(context, 1),
          ],
        ),
      ),
    );
  }
}

class FoodDetailPage extends StatefulWidget {
  final String itemName;
  final String restaurant;

  const FoodDetailPage({super.key, required this.itemName, required this.restaurant});

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  void _add() {
    setState(() => AppState.addFrom(widget.itemName, widget.restaurant));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 900),
        content: Text('${widget.itemName} added from ${widget.restaurant}'),
        action: SnackBarAction(label: 'CART', onPressed: () => _push(context, const CartPage())),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = AppState.items[widget.itemName]!;
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: const Color(0xFFFFF39A),
                      height: 175,
                      child: Stack(
                        children: [
                          Positioned(left: 4, top: 8, child: IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back, size: 34))),
                          Center(child: ClipOval(child: Image.asset(item.imageAsset, width: 140, height: 140, fit: BoxFit.cover, filterQuality: FilterQuality.high))),
                          Positioned(
                            right: 12,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(color: _black, borderRadius: BorderRadius.circular(14)),
                              child: Text('FROM ${widget.restaurant}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                      child: Text(item.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 5, 18, 14),
                      child: Text(AppState.descriptionFor(item.name), textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.35)),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(18, 4, 18, 8),
                      child: Text('TYPES', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(color: _black, borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        children: [
                          ClipOval(child: Image.asset(item.imageAsset, width: 78, height: 78, fit: BoxFit.cover)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name == 'MOMO' ? 'KOTHE MOMO' : item.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                                const SizedBox(height: 8),
                                Row(children: [Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)), const SizedBox(width: 8), const Icon(Icons.star, color: Colors.white, size: 17)]),
                              ],
                            ),
                          ),
                          IconButton(onPressed: _add, icon: const Icon(Icons.add, color: Colors.white, size: 32)),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(18, 16, 18, 8),
                      child: Text('REVIEWS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: _black, borderRadius: BorderRadius.circular(22)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [CircleAvatar(radius: 17, child: Text('R')), SizedBox(width: 10), Text('RAJESH HAMAL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))]),
                          SizedBox(height: 10),
                          Text('Fresh, tasty and well prepared. I would order this again.', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          SizedBox(height: 8),
                          Align(alignment: Alignment.centerRight, child: Text('5 ★', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _realNav(context, 0),
          ],
        ),
      ),
    );
  }
}

class MomoPage extends StatefulWidget {
  const MomoPage({super.key});

  @override
  State<MomoPage> createState() => _MomoPageState();
}

class _MomoPageState extends State<MomoPage> {
  void _addMomo() {
    setState(() => AppState.addFrom('MOMO', AppState.momoRestaurant));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 900),
        content: Text('Momo added from ${AppState.momoRestaurant}'),
        action: SnackBarAction(
          label: 'CART',
          onPressed: () => _push(context, const CartPage()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      asset: 'assets/screens/momo.png',
      overlays: [
        Hotspot(left: .01, top: .02, width: .18, height: .10, onTap: () => Navigator.maybePop(context)),
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, c) => Stack(
              children: [
                Positioned(
                  right: c.maxWidth * .035,
                  top: c.maxHeight * .205,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: _black.withOpacity(.94),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'FROM ${AppState.momoRestaurant}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (c.maxWidth * .028).clamp(9, 12).toDouble(),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Hotspot(left: .76, top: .42, width: .18, height: .13, onTap: _addMomo),
        _nav(context, 0),
      ],
    );
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void _change(String name, int by) {
    setState(() => AppState.setQty(name, AppState.qty(name) + by));
  }

  @override
  Widget build(BuildContext context) {
    final items = AppState.cartItems;
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back, size: 32),
                      ),
                      const Expanded(
                        child: Text(
                          'Your Cart',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text('YOUR ITEMS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                      decoration: BoxDecoration(color: _black, borderRadius: BorderRadius.circular(22)),
                      child: const Column(
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 50, color: Colors.white),
                          SizedBox(height: 12),
                          Text('YOUR CART IS EMPTY', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                          SizedBox(height: 6),
                          Text('Add food from a restaurant to see it here.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    )
                  else
                    ...items.map((item) => _CartItemCard(
                          item: item,
                          restaurant: AppState.restaurantFor(item.name),
                          qty: AppState.qty(item.name),
                          onMinus: () => _change(item.name, -1),
                          onPlus: () => _change(item.name, 1),
                        )),
                  const SizedBox(height: 12),
                  if (items.isNotEmpty) ...[
                    Text('Items total   \$${AppState.itemsTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _black,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => _push(context, const CheckoutPage()),
                        child: const Text('CHECKOUT', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _realNav(context, 2),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final FoodItemData item;
  final String restaurant;
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _CartItemCard({required this.item, required this.restaurant, required this.qty, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _black, borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text('\$${item.price.toStringAsFixed(item.price.truncateToDouble() == item.price ? 0 : 2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
          ClipOval(
            child: Image.asset(
              item.imageAsset,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('FROM $restaurant', style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          IconButton(onPressed: onMinus, icon: const Icon(Icons.remove, color: Colors.white, size: 20)),
          Text('$qty', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          IconButton(onPressed: onPlus, icon: const Icon(Icons.add, color: Colors.white, size: 20)),
        ],
      ),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String payment = 'APPLE PAY';

  Future<void> _changeAddress() async {
    final place = TextEditingController(text: AppState.deliveryPlace);
    final street = TextEditingController(text: AppState.deliveryStreet);
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Change delivery address', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: place,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Place / suburb', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: street,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Street / address', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _black),
            onPressed: () {
              if (place.text.trim().isEmpty || street.text.trim().isEmpty) return;
              AppState.deliveryPlace = place.text.trim().toUpperCase();
              AppState.deliveryStreet = street.text.trim().toUpperCase();
              Navigator.pop(context, true);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
    if (changed == true && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = AppState.cartItems;
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                children: [
                  Row(
                    children: [
                      IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back, size: 32)),
                      const Expanded(child: Text('Checkout', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900))),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('DELIVERY ADDRESS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _changeAddress,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(color: _black, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(AppState.deliveryPlace, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 12),
                              Text(AppState.deliveryStreet, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                            ]),
                          ),
                          const Text('Change >', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text('Estimated delivery: ${AppState.etaText}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(height: 22),
                  const Text('ORDER SUMMARY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Expanded(child: Text('${item.name}  × ${AppState.qty(item.name)}', style: const TextStyle(fontWeight: FontWeight.w800))),
                            Text('\$${(item.price * AppState.qty(item.name)).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900)),
                          ],
                        ),
                      )),
                  const SizedBox(height: 4),
                  const Row(children: [Expanded(child: Text('DELIVERY', style: TextStyle(fontWeight: FontWeight.w800))), Text('\$2.67', style: TextStyle(fontWeight: FontWeight.w900))]),
                  const Divider(height: 20),
                  Row(children: [
                    const Expanded(child: Text('TOTAL', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
                    Text('\$${AppState.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  ]),
                  const SizedBox(height: 22),
                  const Text('PAYMENT METHOD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(color: _black, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          value: 'APPLE PAY',
                          groupValue: payment,
                          onChanged: (v) => setState(() => payment = v!),
                          activeColor: Colors.white,
                          title: const Text(' Pay   APPLE PAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                        ),
                        RadioListTile<String>(
                          value: 'CARD',
                          groupValue: payment,
                          onChanged: (v) => setState(() => payment = v!),
                          activeColor: Colors.white,
                          title: const Text('💳   CARD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: _black, shape: const StadiumBorder()),
                      onPressed: items.isEmpty ? null : () => _push(context, const ConfirmedPage()),
                      child: Text('PLACE ORDER • ${payment == 'CARD' ? 'CARD' : 'APPLE PAY'}', style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
            _realNav(context, 2),
          ],
        ),
      ),
    );
  }
}

class ConfirmedPage extends StatelessWidget {
  const ConfirmedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                children: [
                  Row(
                    children: [
                      IconButton(onPressed: () => _home(context), icon: const Icon(Icons.close, size: 30)),
                      const Expanded(child: Text('Order Confirmed!', textAlign: TextAlign.center, style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900))),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text('ORDER NUMBER', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  _blackInfoBox('ABI26721'),
                  const SizedBox(height: 20),
                  const Text('DELIVERY TO', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  _blackInfoBox(AppState.fullAddress),
                  const SizedBox(height: 20),
                  const Text('APPROX DELIVERY TIME', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  _blackInfoBox(AppState.etaText),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ORDER STATUS', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                      Text(AppState.orderStatus, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _push(context, const DeliveryMapPage()),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      height: 230,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F1EA),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.black12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Positioned.fill(child: CustomPaint(painter: DeliveryMapPainter(AppState.fullAddress))),
                          Positioned(
                            left: 10,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(.92), borderRadius: BorderRadius.circular(14)),
                              child: const Row(children: [Icon(Icons.map_outlined, size: 16), SizedBox(width: 5), Text('Tap map to open', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11))]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: _black, shape: const StadiumBorder()),
                      onPressed: () => _showOrder(context),
                      child: const Text('VIEW ORDER', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
            _realNav(context, 2),
          ],
        ),
      ),
    );
  }

  static Widget _blackInfoBox(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(color: _black, borderRadius: BorderRadius.circular(16)),
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      );

  void _showOrder(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: _cream,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ORDER ABI26721', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
            const SizedBox(height: 10),
            Text('Delivering to: ${AppState.fullAddress}', style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...AppState.cartItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('${item.name} × ${AppState.qty(item.name)}  •  ${AppState.restaurantFor(item.name)}', style: const TextStyle(fontWeight: FontWeight.w700)),
            )),
            const SizedBox(height: 8),
            Text('Total: \$${AppState.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Status: ${AppState.orderStatus} • ${AppState.etaText}', style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class DeliveryMapPage extends StatelessWidget {
  const DeliveryMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        surfaceTintColor: _cream,
        title: const Text('Delivery Map', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppState.fullAddress, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('${AppState.orderStatus} • ${AppState.etaText}', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFFF3F1EA), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.black12)),
                clipBehavior: Clip.antiAlias,
                child: CustomPaint(painter: DeliveryMapPainter(AppState.fullAddress), child: const SizedBox.expand()),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Demo map: the route and destination marker change with the delivery address entered at checkout.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class DeliveryMapPainter extends CustomPainter {
  final String address;
  DeliveryMapPainter(this.address);

  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()..color = Colors.white..strokeWidth = 9..strokeCap = StrokeCap.round;
    final minor = Paint()..color = const Color(0xFFE2E0D9)..strokeWidth = 2;
    final route = Paint()..color = _hungryBrown..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final seed = address.codeUnits.fold<int>(7, (a, b) => (a * 31 + b) & 0x7fffffff);

    for (int i = 1; i < 7; i++) {
      final x = size.width * i / 7;
      canvas.drawLine(Offset(x, 0), Offset(x - size.width * .12, size.height), minor);
    }
    for (int i = 1; i < 8; i++) {
      final y = size.height * i / 8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + size.height * .06), minor);
    }
    canvas.drawLine(Offset(size.width * .12, 0), Offset(size.width * .38, size.height), road);
    canvas.drawLine(Offset(size.width * .70, 0), Offset(size.width * .55, size.height), road);
    canvas.drawLine(Offset(0, size.height * .28), Offset(size.width, size.height * .42), road);
    canvas.drawLine(Offset(0, size.height * .72), Offset(size.width, size.height * .62), road);

    final endX = size.width * (.68 + (seed % 18) / 100);
    final endY = size.height * (.16 + ((seed ~/ 19) % 20) / 100);
    final path = Path()
      ..moveTo(size.width * .28, size.height * .86)
      ..lineTo(size.width * .34, size.height * .70)
      ..lineTo(size.width * .52, size.height * .68)
      ..lineTo(size.width * .53, size.height * .48)
      ..lineTo(size.width * .68, size.height * .46)
      ..lineTo(endX, endY);
    canvas.drawPath(path, route);

    canvas.drawCircle(Offset(size.width * .28, size.height * .86), 8, Paint()..color = Colors.orange.shade700);
    canvas.drawCircle(Offset(endX, endY), 11, Paint()..color = _hungryBrown);
    canvas.drawCircle(Offset(endX, endY), 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant DeliveryMapPainter oldDelegate) => oldDelegate.address != address;
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Stack(
          children: [
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: _black,
                    child: Icon(Icons.person, color: Colors.white, size: 52),
                  ),
                  SizedBox(height: 14),
                  Text('PROFILE', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                  SizedBox(height: 5),
                  Text('FoodieGo User'),
                ],
              ),
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: _realNav(context, 3)),
          ],
        ),
      ),
    );
  }
}

Widget _nav(BuildContext context, int selected) {
  return Positioned.fill(
    child: LayoutBuilder(
      builder: (context, c) {
        final bottom = c.maxHeight * .895;
        return Stack(
          children: [
            Positioned(left: 0, top: bottom, width: c.maxWidth * .25, height: c.maxHeight * .105, child: _tap(() => _home(context))),
            Positioned(left: c.maxWidth * .25, top: bottom, width: c.maxWidth * .25, height: c.maxHeight * .105, child: _tap(() => _push(context, const SearchPage()))),
            Positioned(left: c.maxWidth * .50, top: bottom, width: c.maxWidth * .25, height: c.maxHeight * .105, child: _tap(() => _push(context, const CartPage()))),
            Positioned(left: c.maxWidth * .75, top: bottom, width: c.maxWidth * .25, height: c.maxHeight * .105, child: _tap(() => _push(context, const ProfilePage()))),
          ],
        );
      },
    ),
  );
}

Widget _tap(VoidCallback onTap) => Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, splashColor: Colors.white10),
    );

Widget _realNav(BuildContext context, int selected) {
  final labels = ['HOME', 'SEARCH', 'CART', 'PROFILE'];
  return Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
    height: 54,
    decoration: BoxDecoration(color: _black, borderRadius: BorderRadius.circular(28)),
    child: Row(
      children: List.generate(labels.length, (i) {
        return Expanded(
          child: InkWell(
            onTap: () {
              if (i == 0) _home(context);
              if (i == 1) _push(context, const SearchPage());
              if (i == 2) _push(context, const CartPage());
              if (i == 3) _push(context, const ProfilePage());
            },
            child: Center(
              child: Text(
                labels[i],
                style: TextStyle(
                  color: i == selected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        );
      }),
    ),
  );
}

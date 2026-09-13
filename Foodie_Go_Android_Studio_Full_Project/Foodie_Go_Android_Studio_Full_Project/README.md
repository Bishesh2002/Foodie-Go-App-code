# FoodieGo Prototype Match

This Flutter project uses the user's Figma prototype exports as local visual assets so the Android emulator closely matches the high-fidelity design.

## Flow
Welcome -> Login / Sign Up -> Home -> Search -> The Hungry restaurant -> Momo details -> Cart -> Checkout -> Order Confirmed.

The Momo details screen also displays the source restaurant: **THE HUNGRY – DRAGON & WOK**.

## Run
```bash
flutter clean
flutter pub get
flutter run
```

Select the Android emulator as the target device in Android Studio.

## Assessment demo flow
This build is designed to demonstrate the two major front-end features required by the assessment:

1. Restaurant / food browsing
   - Welcome -> Login/Sign Up -> Home.
   - Search for The Hungry or open it from Home.
   - Browse Momo, Yomari, Thali Set, Selroti and Thukpa.
   - Open the Momo detail page; it clearly shows the restaurant (THE HUNGRY).
   - Tap + or a featured food tile to add it to the cart.

2. Shopping cart management
   - Cart starts empty.
   - Only food actually added by the user appears in the cart.
   - Use - and + to decrease/increase quantities.
   - Quantity 0 removes the item from the cart.
   - Checkout shows only current cart items and calculates totals dynamically.
   - Select Apple Pay or Card and place the order.
   - Order confirmation and View Order complete the front-end flow.

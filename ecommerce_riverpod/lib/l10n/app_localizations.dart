import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_km.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('km'),
    Locale('ko'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop Clothes'**
  String get appTitle;

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @vendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get vendor;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @seedDummyProducts.
  ///
  /// In en, this message translates to:
  /// **'Seed Dummy Products'**
  String get seedDummyProducts;

  /// No description provided for @seedDummyOrders.
  ///
  /// In en, this message translates to:
  /// **'Seed Dummy Orders'**
  String get seedDummyOrders;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @termPolicies.
  ///
  /// In en, this message translates to:
  /// **'Term & Policies'**
  String get termPolicies;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @supportAbout.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT & ABOUT'**
  String get supportAbout;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose the language'**
  String get chooseLanguage;

  /// No description provided for @findLanguage.
  ///
  /// In en, this message translates to:
  /// **'Find a language'**
  String get findLanguage;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get keepGoing;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessful;

  /// No description provided for @loginYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Login Your Account'**
  String get loginYourAccount;

  /// No description provided for @toExploreTheWorldExperience.
  ///
  /// In en, this message translates to:
  /// **'To Explore the world Experience'**
  String get toExploreTheWorldExperience;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterYourEmailError.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmailError;

  /// No description provided for @enterYourEmailHint.
  ///
  /// In en, this message translates to:
  /// **'enter your email'**
  String get enterYourEmailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterYourPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPasswordError;

  /// No description provided for @enterYourPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'enter your password'**
  String get enterYourPasswordHint;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAnAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccessful;

  /// No description provided for @registerAccount.
  ///
  /// In en, this message translates to:
  /// **'Register Account'**
  String get registerAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterYourFullNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullNameError;

  /// No description provided for @enterYourFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'enter your full name'**
  String get enterYourFullNameHint;

  /// No description provided for @alreadyAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already an account? '**
  String get alreadyAnAccount;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @myOrder.
  ///
  /// In en, this message translates to:
  /// **'My Order'**
  String get myOrder;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @recommendForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommend for you'**
  String get recommendForYou;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @popularProducts.
  ///
  /// In en, this message translates to:
  /// **'Popular Products'**
  String get popularProducts;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @promo.
  ///
  /// In en, this message translates to:
  /// **'Promo'**
  String get promo;

  /// No description provided for @errorLoadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Error loading categories'**
  String get errorLoadingCategories;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @noBannerAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Banner available'**
  String get noBannerAvailable;

  /// No description provided for @errorLoadingBanners.
  ///
  /// In en, this message translates to:
  /// **'Error loading banners'**
  String get errorLoadingBanners;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get allProducts;

  /// No description provided for @noProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No products available'**
  String get noProductsAvailable;

  /// No description provided for @noProductInCategory.
  ///
  /// In en, this message translates to:
  /// **'No product in category'**
  String get noProductInCategory;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @pleaseSelectSize.
  ///
  /// In en, this message translates to:
  /// **'Please select a size.'**
  String get pleaseSelectSize;

  /// No description provided for @addedToCartSuccess.
  ///
  /// In en, this message translates to:
  /// **'You have added product to cart successfully'**
  String get addedToCartSuccess;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check Out'**
  String get checkOut;

  /// No description provided for @searchQuery.
  ///
  /// In en, this message translates to:
  /// **'Search: {query}'**
  String searchQuery(String query);

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @unknownProduct.
  ///
  /// In en, this message translates to:
  /// **'Unknown Product'**
  String get unknownProduct;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @yourCartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get yourCartIsEmpty;

  /// No description provided for @subTotal.
  ///
  /// In en, this message translates to:
  /// **'Sub-Total'**
  String get subTotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @pleaseSelectProductToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Please select a product to checkout'**
  String get pleaseSelectProductToCheckout;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found.'**
  String get noOrdersFound;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get saveAddress;

  /// No description provided for @addressSaved.
  ///
  /// In en, this message translates to:
  /// **'Address saved successfully'**
  String get addressSaved;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully!'**
  String get orderPlaced;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @trackingNumber.
  ///
  /// In en, this message translates to:
  /// **'Tracking Number'**
  String get trackingNumber;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @myAddresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get myAddresses;

  /// No description provided for @manageDeliveryAddresses.
  ///
  /// In en, this message translates to:
  /// **'Manage your delivery addresses'**
  String get manageDeliveryAddresses;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addNewAddress;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editAddress;

  /// No description provided for @noAddressesFound.
  ///
  /// In en, this message translates to:
  /// **'No Addresses Found'**
  String get noAddressesFound;

  /// No description provided for @noAddressesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your shipping addresses for quick and hassle-free checkout.'**
  String get noAddressesSubtitle;

  /// No description provided for @addFirstAddress.
  ///
  /// In en, this message translates to:
  /// **'Add First Address'**
  String get addFirstAddress;

  /// No description provided for @pickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick on Map'**
  String get pickOnMap;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manualEntry;

  /// No description provided for @addressLabelHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get addressLabelHome;

  /// No description provided for @addressLabelOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get addressLabelOffice;

  /// No description provided for @addressLabelParents.
  ///
  /// In en, this message translates to:
  /// **'Parents\' Home'**
  String get addressLabelParents;

  /// No description provided for @addressLabelFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend\'s House'**
  String get addressLabelFriend;

  /// No description provided for @addressLabelOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get addressLabelOther;

  /// No description provided for @setAsDefaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Set as default address'**
  String get setAsDefaultAddress;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street Address / Building'**
  String get streetAddress;

  /// No description provided for @cityProvince.
  ///
  /// In en, this message translates to:
  /// **'City / Province'**
  String get cityProvince;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @deleteAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get deleteAddressTitle;

  /// No description provided for @deleteAddressConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this address?'**
  String get deleteAddressConfirm;

  /// No description provided for @addressDeleted.
  ///
  /// In en, this message translates to:
  /// **'Address deleted'**
  String get addressDeleted;

  /// No description provided for @addressDefaultSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address set as default'**
  String get addressDefaultSuccess;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortRelevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get sortRelevance;

  /// No description provided for @sortPriceLowHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get sortPriceLowHigh;

  /// No description provided for @sortPriceHighLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get sortPriceHighLow;

  /// No description provided for @sortRating.
  ///
  /// In en, this message translates to:
  /// **'Highest Rated'**
  String get sortRating;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noResultsDescription.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any matches for \"{query}\". Check your spelling or try different keywords.'**
  String noResultsDescription(String query);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @browseCategories.
  ///
  /// In en, this message translates to:
  /// **'Browse Categories'**
  String get browseCategories;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock ({count})'**
  String inStock(int count);

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock ({count})'**
  String lowStock(int count);

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @productCharacteristics.
  ///
  /// In en, this message translates to:
  /// **'Characteristics'**
  String get productCharacteristics;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @customerReviews.
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews'**
  String get customerReviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @rateProduct.
  ///
  /// In en, this message translates to:
  /// **'Rate Product'**
  String get rateProduct;

  /// No description provided for @writeReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Write your review here...'**
  String get writeReviewHint;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @reviewSuccess.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully!'**
  String get reviewSuccess;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get orderStatusProcessing;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @orderPlacedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order Placed Successfully!'**
  String get orderPlacedSuccess;

  /// No description provided for @orderPlacedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your purchase. We are preparing your order.'**
  String get orderPlacedSubtitle;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID: {id}'**
  String orderId(String id);

  /// No description provided for @viewOrder.
  ///
  /// In en, this message translates to:
  /// **'View Order'**
  String get viewOrder;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// No description provided for @khqrPayment.
  ///
  /// In en, this message translates to:
  /// **'ABA PAY (KHQR & App)'**
  String get khqrPayment;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @accountRole.
  ///
  /// In en, this message translates to:
  /// **'Account Role'**
  String get accountRole;

  /// No description provided for @vendorMode.
  ///
  /// In en, this message translates to:
  /// **'Vendor Mode'**
  String get vendorMode;

  /// No description provided for @deliveryMode.
  ///
  /// In en, this message translates to:
  /// **'Delivery Mode'**
  String get deliveryMode;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get confirmLogout;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get welcome;

  /// No description provided for @whatsOnYourList.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your list?'**
  String get whatsOnYourList;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get sale;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search Products'**
  String get searchProducts;

  /// No description provided for @exploreCategories.
  ///
  /// In en, this message translates to:
  /// **'Explore Categories'**
  String get exploreCategories;

  /// No description provided for @inStockLabel.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStockLabel;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @yourShoppingBagIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your shopping bag is empty'**
  String get yourShoppingBagIsEmpty;

  /// No description provided for @emptyCartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore our latest luxury arrivals to get started.'**
  String get emptyCartSubtitle;

  /// No description provided for @shopNow.
  ///
  /// In en, this message translates to:
  /// **'Shop Now'**
  String get shopNow;

  /// No description provided for @clearShoppingBag.
  ///
  /// In en, this message translates to:
  /// **'Clear Shopping Bag'**
  String get clearShoppingBag;

  /// No description provided for @clearCartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all items from your shopping bag?'**
  String get clearCartConfirm;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @accountAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Account & Settings'**
  String get accountAndSettings;

  /// No description provided for @switchText.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchText;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get changeProfilePhoto;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takeAPhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @chooseAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose App Language'**
  String get chooseAppLanguage;

  /// No description provided for @chooseLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language. All texts will update automatically.'**
  String get chooseLanguageSubtitle;

  /// No description provided for @availableLanguages.
  ///
  /// In en, this message translates to:
  /// **'Available Languages'**
  String get availableLanguages;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @yourWishlistIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your Wishlist is Empty'**
  String get yourWishlistIsEmpty;

  /// No description provided for @wishlistEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore products and tap the heart icon to save your favorite items here.'**
  String get wishlistEmptySubtitle;

  /// No description provided for @exploreProducts.
  ///
  /// In en, this message translates to:
  /// **'Explore Products'**
  String get exploreProducts;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get noNotifications;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up! Check back later for new updates.'**
  String get noNotificationsSubtitle;

  /// No description provided for @orderTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get orderTabActive;

  /// No description provided for @orderTabDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderTabDelivered;

  /// No description provided for @orderTabArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get orderTabArchive;

  /// No description provided for @switchAccountRole.
  ///
  /// In en, this message translates to:
  /// **'Switch Account Role'**
  String get switchAccountRole;

  /// No description provided for @switchAccountRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a portal or workspace to switch to'**
  String get switchAccountRoleSubtitle;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @shoppingBag.
  ///
  /// In en, this message translates to:
  /// **'Shopping Bag'**
  String get shoppingBag;

  /// No description provided for @orderManifest.
  ///
  /// In en, this message translates to:
  /// **'Order Manifest'**
  String get orderManifest;

  /// No description provided for @deliveryDestination.
  ///
  /// In en, this message translates to:
  /// **'Delivery Destination'**
  String get deliveryDestination;

  /// No description provided for @verifiedResidence.
  ///
  /// In en, this message translates to:
  /// **'Verified Residence'**
  String get verifiedResidence;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @noAddressSelected.
  ///
  /// In en, this message translates to:
  /// **'No Delivery Address Selected'**
  String get noAddressSelected;

  /// No description provided for @pleaseAddAddress.
  ///
  /// In en, this message translates to:
  /// **'Tap to add or select a delivery address'**
  String get pleaseAddAddress;

  /// No description provided for @courierService.
  ///
  /// In en, this message translates to:
  /// **'Courier Service'**
  String get courierService;

  /// No description provided for @handledWithCare.
  ///
  /// In en, this message translates to:
  /// **'Handled with Care'**
  String get handledWithCare;

  /// No description provided for @complimentary.
  ///
  /// In en, this message translates to:
  /// **'Complimentary'**
  String get complimentary;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @standardDelivery.
  ///
  /// In en, this message translates to:
  /// **'Standard Delivery'**
  String get standardDelivery;

  /// No description provided for @standardDeliveryDesc.
  ///
  /// In en, this message translates to:
  /// **'3–5 Business Days • Fully Tracked'**
  String get standardDeliveryDesc;

  /// No description provided for @expressDelivery.
  ///
  /// In en, this message translates to:
  /// **'Express Delivery'**
  String get expressDelivery;

  /// No description provided for @expressDeliveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Next Day Delivery • Priority Courier'**
  String get expressDeliveryDesc;

  /// No description provided for @arrivingTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Arriving Tomorrow by 2:00 PM'**
  String get arrivingTomorrow;

  /// No description provided for @defaultBilling.
  ///
  /// In en, this message translates to:
  /// **'Default Billing'**
  String get defaultBilling;

  /// No description provided for @costSummary.
  ///
  /// In en, this message translates to:
  /// **'Cost Summary'**
  String get costSummary;

  /// No description provided for @whiteGloveDelivery.
  ///
  /// In en, this message translates to:
  /// **'White Glove Delivery'**
  String get whiteGloveDelivery;

  /// No description provided for @whiteGloveCourier.
  ///
  /// In en, this message translates to:
  /// **'White Glove Courier'**
  String get whiteGloveCourier;

  /// No description provided for @estimatedTaxSurcharge.
  ///
  /// In en, this message translates to:
  /// **'Estimated Tax & Surcharge'**
  String get estimatedTaxSurcharge;

  /// No description provided for @privilegeDiscount.
  ///
  /// In en, this message translates to:
  /// **'Privilege Discount'**
  String get privilegeDiscount;

  /// No description provided for @haveVoucherHint.
  ///
  /// In en, this message translates to:
  /// **'Have another gift voucher?'**
  String get haveVoucherHint;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// No description provided for @dutiesIncluded.
  ///
  /// In en, this message translates to:
  /// **'Duties and carbon offset included'**
  String get dutiesIncluded;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address Required'**
  String get addressRequired;

  /// No description provided for @addressRequiredDesc.
  ///
  /// In en, this message translates to:
  /// **'Please select a delivery address before placing your order.'**
  String get addressRequiredDesc;

  /// No description provided for @orderFailed.
  ///
  /// In en, this message translates to:
  /// **'Order Failed'**
  String get orderFailed;

  /// No description provided for @orderFailedDesc.
  ///
  /// In en, this message translates to:
  /// **'Could not place order. Please try again.'**
  String get orderFailedDesc;

  /// No description provided for @orderConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmation'**
  String get orderConfirmation;

  /// No description provided for @orderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmed!'**
  String get orderConfirmed;

  /// No description provided for @atelierDispatchConfirmed.
  ///
  /// In en, this message translates to:
  /// **'DISPATCH CONFIRMED'**
  String get atelierDispatchConfirmed;

  /// No description provided for @orderThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you, {name}. Your order has been placed and is being prepared for dispatch.'**
  String orderThankYou(String name);

  /// No description provided for @orderCopied.
  ///
  /// In en, this message translates to:
  /// **'Order #{number} copied to clipboard'**
  String orderCopied(String number);

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get paid;

  /// No description provided for @totalAuthorized.
  ///
  /// In en, this message translates to:
  /// **'Total Authorized'**
  String get totalAuthorized;

  /// No description provided for @trackLiveOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Live Order'**
  String get trackLiveOrder;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get trackOrder;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @cannotModify.
  ///
  /// In en, this message translates to:
  /// **'Cannot Modify'**
  String get cannotModify;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order Cancelled'**
  String get orderCancelled;

  /// No description provided for @orderCancelledDesc.
  ///
  /// In en, this message translates to:
  /// **'Order #{number} was cancelled.'**
  String orderCancelledDesc(String number);

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @buyAgain.
  ///
  /// In en, this message translates to:
  /// **'Buy Again'**
  String get buyAgain;

  /// No description provided for @downloadInvoice.
  ///
  /// In en, this message translates to:
  /// **'Download Invoice'**
  String get downloadInvoice;

  /// No description provided for @receiptDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Receipt downloaded successfully'**
  String get receiptDownloaded;

  /// No description provided for @liveTracking.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get liveTracking;

  /// No description provided for @arProof.
  ///
  /// In en, this message translates to:
  /// **'Proof of Delivery'**
  String get arProof;

  /// No description provided for @leaveReview.
  ///
  /// In en, this message translates to:
  /// **'Leave Review'**
  String get leaveReview;

  /// No description provided for @orderTimeline.
  ///
  /// In en, this message translates to:
  /// **'Order Timeline'**
  String get orderTimeline;

  /// No description provided for @billingDetails.
  ///
  /// In en, this message translates to:
  /// **'Billing Details'**
  String get billingDetails;

  /// No description provided for @filterOrders.
  ///
  /// In en, this message translates to:
  /// **'Filter Orders'**
  String get filterOrders;

  /// No description provided for @searchOrdersHint.
  ///
  /// In en, this message translates to:
  /// **'Search orders or products...'**
  String get searchOrdersHint;

  /// No description provided for @noMatchingOrders.
  ///
  /// In en, this message translates to:
  /// **'No matching orders found'**
  String get noMatchingOrders;

  /// No description provided for @areYouSureCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel order #{number}?'**
  String areYouSureCancelOrder(String number);

  /// No description provided for @confirmCancellation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancellation'**
  String get confirmCancellation;

  /// No description provided for @savedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved Addresses'**
  String get savedAddresses;

  /// No description provided for @searchAddressesHint.
  ///
  /// In en, this message translates to:
  /// **'Search addresses, labels, cities...'**
  String get searchAddressesHint;

  /// No description provided for @noMatchingAddresses.
  ///
  /// In en, this message translates to:
  /// **'No matching addresses found'**
  String get noMatchingAddresses;

  /// No description provided for @addNewDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Delivery Address'**
  String get addNewDeliveryAddress;

  /// No description provided for @globalCourierConfig.
  ///
  /// In en, this message translates to:
  /// **'Global courier and delivery configurations'**
  String get globalCourierConfig;

  /// No description provided for @selectedDestination.
  ///
  /// In en, this message translates to:
  /// **'Selected Destination'**
  String get selectedDestination;

  /// No description provided for @deliverHere.
  ///
  /// In en, this message translates to:
  /// **'Deliver Here'**
  String get deliverHere;

  /// No description provided for @defaultBadge.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT'**
  String get defaultBadge;

  /// No description provided for @movePinToSetLocation.
  ///
  /// In en, this message translates to:
  /// **'Move pin to set your exact location'**
  String get movePinToSetLocation;

  /// No description provided for @addressDetails.
  ///
  /// In en, this message translates to:
  /// **'Address Details'**
  String get addressDetails;

  /// No description provided for @addressDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete address helps us deliver to you accurately'**
  String get addressDetailsSubtitle;

  /// No description provided for @selectAddressType.
  ///
  /// In en, this message translates to:
  /// **'Select Address Type'**
  String get selectAddressType;

  /// No description provided for @receiverName.
  ///
  /// In en, this message translates to:
  /// **'Receiver\'s Name'**
  String get receiverName;

  /// No description provided for @completeAddress.
  ///
  /// In en, this message translates to:
  /// **'Complete Address'**
  String get completeAddress;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @addressRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressRequiredValidation;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @colors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get colors;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favourites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favourites'**
  String get removedFromFavorites;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @filterAndSort.
  ///
  /// In en, this message translates to:
  /// **'Filter & Sort'**
  String get filterAndSort;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// No description provided for @sortOrder.
  ///
  /// In en, this message translates to:
  /// **'SORT ORDER'**
  String get sortOrder;

  /// No description provided for @categoryTitle.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get categoryTitle;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'PRICE RANGE'**
  String get priceRange;

  /// No description provided for @sizeTitle.
  ///
  /// In en, this message translates to:
  /// **'SIZE'**
  String get sizeTitle;

  /// No description provided for @palette.
  ///
  /// In en, this message translates to:
  /// **'PALETTE'**
  String get palette;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @newDrops.
  ///
  /// In en, this message translates to:
  /// **'New Drops'**
  String get newDrops;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @pieces.
  ///
  /// In en, this message translates to:
  /// **'PIECES'**
  String get pieces;

  /// No description provided for @inTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get inTransit;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @arriving.
  ///
  /// In en, this message translates to:
  /// **'Arriving'**
  String get arriving;

  /// No description provided for @placed.
  ///
  /// In en, this message translates to:
  /// **'PLACED'**
  String get placed;

  /// No description provided for @tailored.
  ///
  /// In en, this message translates to:
  /// **'TAILORED'**
  String get tailored;

  /// No description provided for @outForDelivery.
  ///
  /// In en, this message translates to:
  /// **'OUT FOR DELIVERY'**
  String get outForDelivery;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'ja',
    'km',
    'ko',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'km':
      return AppLocalizationsKm();
    case 'ko':
      return AppLocalizationsKo();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

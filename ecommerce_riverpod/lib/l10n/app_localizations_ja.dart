// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '洋服店';

  @override
  String get helloWorld => 'こんにちは世界！';

  @override
  String get vendor => 'ショップ';

  @override
  String get favorite => 'お気に入り';

  @override
  String get notification => '通知';

  @override
  String get languages => '言語';

  @override
  String get seedDummyProducts => 'サンプル商品データ生成';

  @override
  String get seedDummyOrders => 'サンプル注文データ生成';

  @override
  String get helpSupport => 'ヘルプ＆サポート';

  @override
  String get termPolicies => '利用規約とポリシー';

  @override
  String get logout => 'ログアウト';

  @override
  String get account => 'アカウント';

  @override
  String get supportAbout => 'サポート＆情報';

  @override
  String get chooseLanguage => '言語を選択';

  @override
  String get findLanguage => '言語を検索';

  @override
  String get keepGoing => '続ける';

  @override
  String get loginSuccessful => 'ログインに成功しました';

  @override
  String get loginYourAccount => 'アカウントにログイン';

  @override
  String get toExploreTheWorldExperience => '素晴らしいショッピング体験を';

  @override
  String get email => 'メールアドレス';

  @override
  String get enterYourEmailError => 'メールアドレスを入力してください';

  @override
  String get enterYourEmailHint => 'メールアドレスを入力';

  @override
  String get password => 'パスワード';

  @override
  String get enterYourPasswordError => 'パスワードを入力してください';

  @override
  String get enterYourPasswordHint => 'パスワードを入力';

  @override
  String get signIn => 'ログイン';

  @override
  String get dontHaveAnAccount => 'アカウントをお持ちでないですか？ ';

  @override
  String get signUp => '新規登録';

  @override
  String get registrationSuccessful => '登録が完了しました！';

  @override
  String get registerAccount => 'アカウント登録';

  @override
  String get fullName => '氏名';

  @override
  String get enterYourFullNameError => '氏名を入力してください';

  @override
  String get enterYourFullNameHint => '氏名を入力';

  @override
  String get alreadyAnAccount => 'すでにアカウントをお持ちですか？ ';

  @override
  String get home => 'ホーム';

  @override
  String get cart => 'カート';

  @override
  String get myOrder => '注文履歴';

  @override
  String get setting => '設定';

  @override
  String get goodMorning => 'おはようございます';

  @override
  String get guest => 'ゲスト';

  @override
  String get recommendForYou => 'おすすめ商品';

  @override
  String get viewAll => 'すべて見る';

  @override
  String get popularProducts => '人気商品';

  @override
  String get searchHint => '検索...';

  @override
  String get promo => 'セール・プロモ';

  @override
  String get errorLoadingCategories => 'カテゴリーの読み込みに失敗しました';

  @override
  String get somethingWentWrong => 'エラーが発生しました';

  @override
  String get noBannerAvailable => 'バナーがありません';

  @override
  String get errorLoadingBanners => 'バナーの読み込みに失敗しました';

  @override
  String get allProducts => 'すべての商品';

  @override
  String get noProductsAvailable => '商品がありません';

  @override
  String get noProductInCategory => 'このカテゴリーには商品がありません';

  @override
  String get size => 'サイズ';

  @override
  String get pleaseSelectSize => 'サイズを選択してください。';

  @override
  String get addedToCartSuccess => '商品をカートに追加しました';

  @override
  String get checkOut => 'レジへ進む';

  @override
  String searchQuery(String query) {
    return '検索：$query';
  }

  @override
  String get noProductsFound => '商品が見つかりませんでした';

  @override
  String get unknownProduct => '不明な商品';

  @override
  String get myCart => 'ショッピングカート';

  @override
  String get deselectAll => 'すべて解除';

  @override
  String get selectAll => 'すべて選択';

  @override
  String get yourCartIsEmpty => 'カートは空です';

  @override
  String get subTotal => '小計';

  @override
  String get discount => '割引';

  @override
  String get totalAmount => '合計金額';

  @override
  String get pleaseSelectProductToCheckout => 'レジに進む商品を選択してください';

  @override
  String get checkout => 'レジへ進む';

  @override
  String get myOrders => '注文履歴';

  @override
  String get noOrdersFound => '注文履歴がありません。';

  @override
  String get orderDetails => '注文詳細';

  @override
  String get shippingAddress => 'お届け先住所';

  @override
  String get saveAddress => '住所を保存';

  @override
  String get addressSaved => '住所が保存されました';

  @override
  String get deliveryFee => '配送料';

  @override
  String get tax => '消費税';

  @override
  String get totalPrice => '合計金額';

  @override
  String get placeOrder => '注文を確定する';

  @override
  String get orderPlaced => 'ご注文が完了しました！';

  @override
  String get paymentMethod => 'お支払い方法';

  @override
  String get orderStatus => '注文状況';

  @override
  String get trackingNumber => '追跡番号';

  @override
  String get items => '商品';

  @override
  String get quantity => '数量';

  @override
  String get price => '価格';

  @override
  String get myAddresses => 'お届け先住所一覧';

  @override
  String get manageDeliveryAddresses => 'お届け先住所の管理';

  @override
  String get addNewAddress => '新しい住所を追加';

  @override
  String get editAddress => '住所を編集';

  @override
  String get noAddressesFound => '住所が登録されていません';

  @override
  String get noAddressesSubtitle => '住所を保存すると、次回からスムーズにご注文いただけます。';

  @override
  String get addFirstAddress => '最初の住所を登録';

  @override
  String get pickOnMap => '地図から選択';

  @override
  String get currentLocation => '現在地を使用';

  @override
  String get manualEntry => '手動入力';

  @override
  String get addressLabelHome => '自宅';

  @override
  String get addressLabelOffice => '勤務先';

  @override
  String get addressLabelParents => '実家';

  @override
  String get addressLabelFriend => '知人宅';

  @override
  String get addressLabelOther => 'その他';

  @override
  String get setAsDefaultAddress => 'デフォルトの住所に設定';

  @override
  String get streetAddress => '町名・番地・建物名';

  @override
  String get cityProvince => '市区町村・都道府県';

  @override
  String get phoneNumber => '電話番号';

  @override
  String get deleteAddressTitle => '住所の削除';

  @override
  String get deleteAddressConfirm => 'この住所を削除してもよろしいですか？';

  @override
  String get addressDeleted => '住所を削除しました';

  @override
  String get addressDefaultSuccess => 'デフォルトの住所に設定しました';

  @override
  String get undo => '元に戻す';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get save => '保存';

  @override
  String get recentSearches => '最近の検索';

  @override
  String get clearAll => 'すべて削除';

  @override
  String get sortBy => '並び替え';

  @override
  String get sortRelevance => 'おすすめ順';

  @override
  String get sortPriceLowHigh => '価格：安い順';

  @override
  String get sortPriceHighLow => '価格：高い順';

  @override
  String get sortRating => '評価が高い順';

  @override
  String get sortNewest => '新着順';

  @override
  String get noResultsFound => '該当する商品が見つかりません';

  @override
  String noResultsDescription(String query) {
    return '「$query」に一致する商品は見つかりませんでした。スペルを確認するか、別のキーワードをお試しください。';
  }

  @override
  String get tryAgain => 'もう一度検索';

  @override
  String get browseCategories => 'カテゴリーを見る';

  @override
  String inStock(int count) {
    return '在庫あり ($count)';
  }

  @override
  String lowStock(int count) {
    return '残りわずか ($count)';
  }

  @override
  String get outOfStock => '在庫切れ';

  @override
  String get popular => '人気';

  @override
  String get productCharacteristics => '商品の特徴';

  @override
  String get description => '商品説明';

  @override
  String get customerReviews => 'カスタマーレビュー';

  @override
  String get noReviewsYet => 'レビューはまだありません';

  @override
  String get rateProduct => '商品を評価';

  @override
  String get writeReviewHint => 'レビューを入力してください...';

  @override
  String get submitReview => 'レビューを投稿';

  @override
  String get reviewSuccess => 'レビューを投稿しました！';

  @override
  String get addToCart => 'カートに追加';

  @override
  String get buyNow => '今すぐ購入';

  @override
  String get orderStatusPending => '注文受付中';

  @override
  String get orderStatusProcessing => '処理中';

  @override
  String get orderStatusDelivered => '配達完了';

  @override
  String get orderStatusCancelled => 'キャンセル済み';

  @override
  String get orderPlacedSuccess => 'ご注文が完了しました！';

  @override
  String get orderPlacedSubtitle => 'ご購入いただきありがとうございます。商品の発送準備を進めております。';

  @override
  String orderId(String id) {
    return '注文番号：$id';
  }

  @override
  String get viewOrder => '注文を確認';

  @override
  String get continueShopping => '買い物を続ける';

  @override
  String get cashOnDelivery => '代金引換';

  @override
  String get khqrPayment => 'ABA PAY (KHQR & アプリ)';

  @override
  String get general => '一般';

  @override
  String get accountRole => 'アカウントの役割';

  @override
  String get vendorMode => '販売者モード';

  @override
  String get deliveryMode => '配達モード';

  @override
  String get adminDashboard => '管理者ダッシュボード';

  @override
  String get active => 'アクティブ';

  @override
  String get address => '住所';

  @override
  String get other => 'その他';

  @override
  String get helpCenter => 'ヘルプセンター';

  @override
  String get confirmLogout => 'アカウントからログアウトしてもよろしいですか？';

  @override
  String get welcome => 'ようこそ、';

  @override
  String get whatsOnYourList => 'お探しのものは何ですか？';

  @override
  String get products => '商品';

  @override
  String get all => 'すべて';

  @override
  String get sale => 'セール';

  @override
  String get retry => '再試行';

  @override
  String get searchProducts => '商品を検索';

  @override
  String get exploreCategories => 'カテゴリーを見る';

  @override
  String get inStockLabel => '在庫あり';

  @override
  String get proceedToCheckout => '注文手続きへ進む';

  @override
  String get yourShoppingBagIsEmpty => '買い物かごは空です';

  @override
  String get emptyCartSubtitle => '最新の商品を見つけてショッピングを始めましょう。';

  @override
  String get shopNow => '今すぐ買い物';

  @override
  String get clearShoppingBag => '買い物かごを空にする';

  @override
  String get clearCartConfirm => '買い物かごのすべての商品を削除してもよろしいですか？';

  @override
  String get clear => 'クリア';

  @override
  String get accountAndSettings => 'アカウントと設定';

  @override
  String get switchText => '切り替え';

  @override
  String get changeProfilePhoto => 'プロフィール写真を変更';

  @override
  String get takeAPhoto => '写真を撮る';

  @override
  String get chooseFromGallery => 'ギャラリーから選択';

  @override
  String get chooseAppLanguage => 'アプリの言語を選択';

  @override
  String get chooseLanguageSubtitle => '言語を選択してください。すべてのテキストが自動的に更新されます。';

  @override
  String get availableLanguages => '利用可能な言語';

  @override
  String get favourites => 'お気に入り';

  @override
  String get wishlist => 'ウィッシュリスト';

  @override
  String get yourWishlistIsEmpty => 'お気に入りは空です';

  @override
  String get wishlistEmptySubtitle => '商品を見てハートアイコンをタップすると、お気に入りに保存されます。';

  @override
  String get exploreProducts => '商品を見る';

  @override
  String get notifications => '通知';

  @override
  String get noNotifications => '通知はありません';

  @override
  String get noNotificationsSubtitle => '新しい通知はありません。また後で確認してください。';

  @override
  String get orderTabActive => '進行中';

  @override
  String get orderTabDelivered => '配達完了';

  @override
  String get orderTabArchive => '履歴';

  @override
  String get switchAccountRole => 'アカウント権限を切り替え';

  @override
  String get switchAccountRoleSubtitle => 'ポータルまたはワークスペースを選択して切り替えます';

  @override
  String get payNow => '今すぐ支払う';

  @override
  String get shoppingBag => 'ショッピングバッグ';

  @override
  String get orderManifest => '注文明細';

  @override
  String get deliveryDestination => '配送先';

  @override
  String get verifiedResidence => '確認済みの住所';

  @override
  String get change => '変更';

  @override
  String get noAddressSelected => '配送先が選択されていません';

  @override
  String get pleaseAddAddress => 'タップして配送先を追加または選択してください';

  @override
  String get courierService => '配送サービス';

  @override
  String get handledWithCare => '丁寧にお届けします';

  @override
  String get complimentary => '無料';

  @override
  String get free => '無料';

  @override
  String get standardDelivery => '通常配送';

  @override
  String get standardDeliveryDesc => '3〜5営業日 • 追跡可能';

  @override
  String get expressDelivery => 'お急ぎ便';

  @override
  String get expressDeliveryDesc => '翌日お届け • 優先配送';

  @override
  String get arrivingTomorrow => '明日14:00までに到着';

  @override
  String get defaultBilling => 'デフォルトの請求先';

  @override
  String get costSummary => '料金内訳';

  @override
  String get whiteGloveDelivery => 'プレミアム配送';

  @override
  String get whiteGloveCourier => 'プレミアム配達員';

  @override
  String get estimatedTaxSurcharge => '概算税金・追加手数料';

  @override
  String get privilegeDiscount => '特別割引';

  @override
  String get haveVoucherHint => 'ギフトクーポンをお持ちですか？';

  @override
  String get apply => '適用';

  @override
  String get applied => '適用済み';

  @override
  String get dutiesIncluded => '関税・環境税込み';

  @override
  String get addressRequired => '住所が必要です';

  @override
  String get addressRequiredDesc => '注文を確定する前に配送先を選択してください。';

  @override
  String get orderFailed => '注文に失敗しました';

  @override
  String get orderFailedDesc => '注文を処理できませんでした。もう一度お試しください。';

  @override
  String get orderConfirmation => '注文の確認';

  @override
  String get orderConfirmed => '注文が確定しました！';

  @override
  String get atelierDispatchConfirmed => '発送手続き完了';

  @override
  String orderThankYou(String name) {
    return '$name様、ご注文ありがとうございます。発送に向けて準備を進めております。';
  }

  @override
  String orderCopied(String number) {
    return '注文番号 #$number をクリップボードにコピーしました';
  }

  @override
  String get paid => '支払済み';

  @override
  String get totalAuthorized => '決済総額';

  @override
  String get trackLiveOrder => 'リアルタイム追跡';

  @override
  String get trackOrder => '注文を追跡';

  @override
  String get cancelOrder => '注文をキャンセル';

  @override
  String get cannotModify => '変更できません';

  @override
  String get orderCancelled => '注文がキャンセルされました';

  @override
  String orderCancelledDesc(String number) {
    return '注文 #$number はキャンセルされました。';
  }

  @override
  String get reorder => '再注文';

  @override
  String get buyAgain => 'もう一度購入';

  @override
  String get downloadInvoice => '請求書をダウンロード';

  @override
  String get receiptDownloaded => '領収書をダウンロードしました';

  @override
  String get liveTracking => 'リアルタイム追跡';

  @override
  String get arProof => '配達証明';

  @override
  String get leaveReview => 'レビューを書く';

  @override
  String get orderTimeline => '注文タイムライン';

  @override
  String get billingDetails => '請求詳細';

  @override
  String get filterOrders => '注文を絞り込む';

  @override
  String get searchOrdersHint => '注文または商品を検索...';

  @override
  String get noMatchingOrders => '該当する注文が見つかりません';

  @override
  String areYouSureCancelOrder(String number) {
    return '注文 #$number をキャンセルしてもよろしいですか？';
  }

  @override
  String get confirmCancellation => 'キャンセルを確定';

  @override
  String get savedAddresses => '保存された住所';

  @override
  String get searchAddressesHint => '住所、ラベル、都市を検索...';

  @override
  String get noMatchingAddresses => '該当する住所が見つかりません';

  @override
  String get addNewDeliveryAddress => '新しい配送先を追加';

  @override
  String get globalCourierConfig => 'グローバル配送・宅配設定';

  @override
  String get selectedDestination => '選択された配送先';

  @override
  String get deliverHere => 'ここに届ける';

  @override
  String get defaultBadge => 'デフォルト';

  @override
  String get movePinToSetLocation => 'ピンを動かして正確な位置を設定してください';

  @override
  String get addressDetails => '住所詳細';

  @override
  String get addressDetailsSubtitle => '正確な住所を入力していただくと配送がスムーズになります';

  @override
  String get selectAddressType => '住所の種類を選択';

  @override
  String get receiverName => '受取人氏名';

  @override
  String get completeAddress => '完全な住所';

  @override
  String get nameRequired => '氏名は必須です';

  @override
  String get addressRequiredValidation => '住所は必須です';

  @override
  String get phoneRequired => '電話番号は必須です';

  @override
  String get colors => 'カラー';

  @override
  String get reviews => 'レビュー';

  @override
  String get share => '共有';

  @override
  String get addedToFavorites => 'お気に入りに追加しました';

  @override
  String get removedFromFavorites => 'お気に入りから削除しました';

  @override
  String get aboutUs => '私たちについて';

  @override
  String get termsOfService => '利用規約';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get filterAndSort => 'Filter & Sort';

  @override
  String get resetAll => 'Reset All';

  @override
  String get sortOrder => 'SORT ORDER';

  @override
  String get categoryTitle => 'CATEGORY';

  @override
  String get priceRange => 'PRICE RANGE';

  @override
  String get sizeTitle => 'SIZE';

  @override
  String get palette => 'PALETTE';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get newDrops => 'New Drops';

  @override
  String get featured => 'Featured';

  @override
  String get pieces => 'PIECES';

  @override
  String get inTransit => 'In Transit';

  @override
  String get delivered => 'Delivered';

  @override
  String get processing => 'Processing';

  @override
  String get invoice => 'Invoice';

  @override
  String get arriving => 'Arriving';

  @override
  String get placed => 'PLACED';

  @override
  String get tailored => 'TAILORED';

  @override
  String get outForDelivery => 'OUT FOR DELIVERY';
}

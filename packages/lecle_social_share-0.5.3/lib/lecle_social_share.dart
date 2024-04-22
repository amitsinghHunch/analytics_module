import 'package:lecle_social_share/platforms/facebook.dart';
import 'package:lecle_social_share/platforms/instagram.dart';
import 'package:lecle_social_share/platforms/messenger.dart';
import 'package:lecle_social_share/platforms/telegram.dart';
import 'package:lecle_social_share/platforms/tiktok.dart';
import 'package:lecle_social_share/platforms/twitter.dart';
import 'package:lecle_social_share/platforms/whatsapp.dart';

/// Class define the static methods for sharing files to social media platform.
///
/// Current supported platform:
///
/// * Facebook
///
/// * Instagram
///
/// * Messenger
///
/// * Telegram
///
/// * WhatsApp
///
/// * Twitter
class LecleSocialShare {
  /// Static instance to call the Facebook share functions
  static final _f = FacebookShare();

  /// Static getter to get the Facebook share instance
  static FacebookShare get F => _f;

  /// Static instance to call the Instagram share functions
  static final _i = InstagramShare();

  /// Static getter to get the Instagram share instance
  static InstagramShare get I => _i;

  /// Static instance to call the Messenger share functions
  static final _m = MessengerShare();

  /// Static getter to get the Messenger share instance
  static MessengerShare get M => _m;

  /// Static instance to call the Telegram share functions
  static final _t = TelegramShare();

  /// Static getter to get the Telegram share instance
  static TelegramShare get T => _t;

  /// Static instance to call the WhatsApp share functions
  static final _w = WhatsAppShare();

  /// Static getter to get the WhatsApp share instance
  static WhatsAppShare get W => _w;

  /// Static instance to call the Twitter share functions
  static final _tw = TwitterShare();

  /// Static getter to get the Twitter share instance
  // ignore: non_constant_identifier_names
  static TwitterShare get TW => _tw;

  /// Static instance to call the TikTok share functions
  static final _ti = TikTokShare();

  /// Static getter to get the TikTok share instance
  // ignore: non_constant_identifier_names
  static TikTokShare get TI => _ti;
}

/// The enum to define the file type you want to get
///
/// [AssetType.pdf] and [AssetType.vcard] are use for WhatsApp only
enum AssetType {
  video,
  image,
  audio,
  any,
  pdf,
  vcard,
}

enum TikTokShareFormatType {
  normal,
  greenScreen,
}

enum TikTokLandedPageType {
  clip,
  edit,
  publish,
}

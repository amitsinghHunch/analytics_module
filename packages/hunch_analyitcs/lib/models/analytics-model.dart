// ignore_for_file: file_names, non_constant_identifier_names

import 'package:hunch_analyitcs/circle/circle_analytics_events.dart';
import 'package:hunch_analyitcs/models/comment.dart';
import 'package:hunch_analyitcs/models/ads.dart';
import 'package:hunch_analyitcs/models/chat.dart';
import 'package:hunch_analyitcs/models/comment_reactions.dart';
import 'package:hunch_analyitcs/models/creator_access.dart';
import 'package:hunch_analyitcs/models/google_search_images_events.dart';
import 'package:hunch_analyitcs/models/goss-requests.dart';
import 'package:hunch_analyitcs/models/dark_mode.dart';
import 'package:hunch_analyitcs/models/default.dart';
import 'package:hunch_analyitcs/models/feed.dart';
import 'package:hunch_analyitcs/models/hunch_plus.dart';
import 'package:hunch_analyitcs/models/moderation.dart';
import 'package:hunch_analyitcs/models/navigation.dart';
import 'package:hunch_analyitcs/models/on-boarding.dart';
import 'package:hunch_analyitcs/models/others_option.dart';
import 'package:hunch_analyitcs/models/phone_login.dart';
import 'package:hunch_analyitcs/models/pn_nudge.dart';
import 'package:hunch_analyitcs/models/profile.dart';
import 'package:hunch_analyitcs/models/reveal_profile.dart';
import 'package:hunch_analyitcs/models/search.dart';
import 'package:hunch_analyitcs/models/twitter_link.dart';
import 'package:hunch_analyitcs/models/username_change.dart';

import 'ai_suggestions_events.dart';

class AnalyticsProperty extends DefaultProperty
    with
        CommentProperty,
        OnBoardingProperty,
        FeedProperty,
        ProfileProperty,
        CommentReactionProperty,
        ChatProperty,
        UsernameChangeProperty,
        NavigationProperty,
        PnNudgeProperty,
        DarkModeProperties,
        CircleAnalyticsproperty,
        CircleAnalyticspropertyData,
        AiSuggestionProperty,
        GoogleSearchImagesProperty,
        CreatorAccessProperties,
        SearchProperties,
        GossRequestsProperties,
        AdProperties,
        HunchplusProperties,
        ModerationProperty,
        PhoneLoginProperties,
        OthersOptionProperty {}

class AnalyticsPropertyValue extends FeedPropertyValue {}

class AnalyticsEvents {
  OnBoardingEvents onBoardingEvents = OnBoardingEvents();
  RevealProfileEvents revealProfileEvents = RevealProfileEvents();
  CommentEvents commentEvents = CommentEvents();
  FeedEvents feedEvents = FeedEvents();
  ProfileEvents profileEvents = ProfileEvents();
  CommentReactionsEvents commentReactionsEvents = CommentReactionsEvents();
  NavigationEvents navigationEvents = NavigationEvents();
  ChatEvents chatEvents = ChatEvents();
  SearchEvents searchEvents = SearchEvents();
  TwitterLinkEvents twitterLinkEvents = TwitterLinkEvents();
  PnNudgeEvents pnNudgeEvents = PnNudgeEvents();
  DarkModeEvents darkModeEvents = DarkModeEvents();
  CircleAnalyticsEvents circleAnalyticsEvents = CircleAnalyticsEvents();
  AiSuggestionEvents aiSuggestionEvents = AiSuggestionEvents();
  GoogleSearchImagesEvents googleSearchImagesEvents =
      GoogleSearchImagesEvents();
  UsernameChangeEvents usernameChangeEvent = UsernameChangeEvents();
  CreatorAccessEvents creatorAccessEvents = CreatorAccessEvents();
  ModerationEvents moderationEvents = ModerationEvents();
  GossRequestsEvents gossRequestsEvents = GossRequestsEvents();
  AdEvents adsEvents = AdEvents();
  HunchplusEvents hunchplusEvents = HunchplusEvents();
  PhoneLoginEvents phoneLoginEvents = PhoneLoginEvents();
  OthersOptionEvents othersOptionEvents = OthersOptionEvents();
}

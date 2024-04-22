// ignore_for_file: non_constant_identifier_names, unused_field

class FeedEvents {
  final String feed_report = "feed_report";
  final String poll_expand = "poll_expand";
  final String view_voters = "view_voters";
  final String cast_vote = "cast_vote";
  final String ai_suggestion_polls = "ai_suggestion_polls";
  final String poll_menu_action = "poll_menu_action";
  final String poll_view = "poll_view";
  final String no_polls_available = "no_polls_available";
  final String end_of_feed = "end_of_feed";
  final String poll_vote = "poll_vote";
  final String hot_take_react = "hot_take_react";
  final String hot_take_reaction = "hot_take_reaction";
  final String hot_take_view = "hot_take_view";
  final String review_submitted = "review_submitted";
  final String change_color = "change_color";
  final String add_college = "add_college";
  final String poll_view_1s = "1s_poll_view";
  final String first_cast_vote = "first_cast_vote";
  final String cast_vote_2nd = "2nd_cast_vote";
  final String cast_vote_5th = "5th_cast_vote";
  final String cast_vote_10th = "10th_cast_vote";
  final String cast_vote_15th = "15th_cast_vote";
  final String d1_cast_vote = "d1_cast_vote";
  final String d1_cast_vote_ooa = "d1_cast_vote_ooa";
  final String nsfw_filter_toggle = 'nsfw_filter_toggle';
  final String nsfw_overlay_view = 'nsfw_overlay_view';

  // UGC
  final String create_poll = "create_poll";
  final String add_description = "add_description";
  final String remove_description = "remove_description";
  final String toggle_option_type = "toggle_option_type";
  final String toggle_reset_confirm = "toggle_reset_confirm";
  final String add_option = "add_option";
  final String remove_text_option = "remove_text_option";
  final String reset_poll = "reset_poll";
  final String reset_poll_confirm = "reset_poll_confirm";
  final String preview_poll = "preview_poll";
  final String preview_poll_confirm = "preview_poll_confirm";
  final String publish_poll = "publish_poll";
  final String save_draft_confirm = "save_draft_confirm";
  final String archive_poll_confirm = "archive_poll_confirm";
  final String open_category = "open_category";
  final String select_category = "select_category";
  final String edit_image = "edit_image";
  final String add_image = "add_image";
  final String edit_image_confirm = "edit_image_confirm";
  final String publish_poll_cta = "publish_poll_cta";
  final String first_poll_published = "first_poll_published";
  final String upload_gif = "upload_gif";
  final String choose_from_giphy = "choose_from_giphy";
  final String remove_gif = "remove_gif";
  final String brokenFeed = "something_is_broken";
}

class FeedProperty {
  String? poll_id = "poll_id";
  String? tags = "tags";
  String? creator_type = "creator_type";
  String? display_type = "display_type";
  String? categories = "categories";
  String? option_id = "option_id";
  String? action = "action";
  String? poll_text = "poll_text";
  String? ends_in = "ends_in";
  String? vote_option = "vote_option";
  String? hot_take_type = "hot_take_type";
  String? reaction = "reaction";
  String? question = "question";
  String? response = "response";
  String? feedback_type = "feedback_type";
  String? recommendationId = "recommendationId";
  String? share_platform = "share_platform";
  String? change_color = "change_color";
  String? creator_username = "creator_username";
  String? options = "options";
  String? poll_type = "poll_type";
  String? level_number = "level_number";
  String? nsfwContent = "nsfwContent";
  String? filter_status = "filter_status";
  String? overlay_type = "overlay_type";
  // UGC
  String? trigger_create_poll = "trigger_create_poll";
  String? is_draft = "is_draft";
  String? description_type = "description_type";
  String? option_type = "option_type";
  String? option_change_to = "option_change_to";
  String? options_added = "options_added";
  String? option_selected = "option_selected";
  String? question_char_length = "question_char_length";
  String? no_of_options = "no_of_options";
  String? error_state = "error_state";
  String? description_added = "description_added";
  String? success = "success";
  String? image_label_added = "image_label_added";
  String? remove_from_mypolls = "remove_from_mypolls";
  String? poll_duration = "poll_duration";
  String? description = "description";
  String? no_of_votes = "no_of_votes";
  String? share_url = "share_url";
  String? pollUserId = "pollUserId";
  String? access_type = "access_type";
  String? poll_count = "poll_count";
  String? created_via = "created_via";
  String? publish_via = "publish_via";
  String? refresh_id = "refresh_id";
  String? session_id = "session_id";
  String? model_type = "model_type";
  String? score = "score";
  String? campaign_id = "campaign_id";
  String? campaign_type = "campaign_type";
  String? feed_type = "feed_type";
  String? rank = "rank";
  String? error_code = "error_code";
  String? error_description = "error_description";
  String? filtered_category = "filtered_category";
}

class FeedPropertyValue {
  String refreshId = "";
  String sessionId = DateTime.now().microsecondsSinceEpoch.toString();
  String feedType = "";
  String? search_string = "search_string";
  String? gif_category = "gif_category";
  String? gif_name = "gif_name";
}

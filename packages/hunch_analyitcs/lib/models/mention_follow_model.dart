class MentionUsersList {
  final String username;
  final String display;
  final String? dp;

  MentionUsersList({this.username = "", this.display = "", this.dp = ""});

  factory MentionUsersList.fromJson(Map<String, dynamic> json) {
    return MentionUsersList(
      username: json['username'] as String,
      display: json['display'] as String,
      dp: json['dp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'display': display,
      'dp': dp,
    };
  }
}

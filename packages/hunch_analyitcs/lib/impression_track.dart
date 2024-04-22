class ImpressionTrack {
  static List<String> impressionItemList = [];

  static void push(String item) {
    if (!impressionItemList.contains(item)) impressionItemList.add(item);
  }

  static void stash() {
    impressionItemList.clear();
  }
}

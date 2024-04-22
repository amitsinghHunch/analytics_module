class HelpersClass {
  static bool isEliteCreator(int eliteAccessTs) {
    return eliteAccessTs != -1 &&
        (DateTime.now().millisecondsSinceEpoch / 1000).floor() < eliteAccessTs;
  }

  static calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }
}

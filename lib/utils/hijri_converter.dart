class HijriDate {
  final int year;
  final int month;
  final int day;

  HijriDate({required this.year, required this.month, required this.day});

  static const _monthNames = [
    'Muharram',
    'Safar',
    "Rabi'ul Awal",
    "Rabi'ul Akhir",
    'Jumadil Awal',
    'Jumadil Akhir',
    'Rajab',
    "Sya'ban",
    'Ramadhan',
    'Syawal',
    "Dzulqa'dah",
    'Dzulhijjah',
  ];

  String get monthName => _monthNames[month - 1];

  @override
  String toString() => '$day $monthName $year H';
}

class HijriConverter {
  static HijriDate fromGregorian(DateTime date) {
    int y = date.year;
    int m = date.month;
    int d = date.day;

    if (m <= 2) {
      y--;
      m += 12;
    }
    int a = y ~/ 100;
    int b = 2 - a + a ~/ 4;
    int jd =
        (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524;

    int l = jd - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    int j =
        ((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor() +
        (l / 5670).floor() * ((43 * l) / 15238).floor();
    l =
        l -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    int hm = ((24 * l) / 709).floor();
    int hd = l - ((709 * hm) / 24).floor();
    int hy = 30 * n + j - 30;

    return HijriDate(year: hy, month: hm, day: hd);
  }
}

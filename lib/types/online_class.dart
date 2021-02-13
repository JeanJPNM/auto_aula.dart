class OnlineClass {
  OnlineClass(int hour, int minute) {
    final now = DateTime.now();
    start = DateTime(now.year, now.month, now.day, hour, minute);
    end = start.add(const Duration(minutes: 50));
  }
  late DateTime start, end;
}

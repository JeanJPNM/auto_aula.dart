extension DurationExt on Duration {
  String toLocaleString() {
    var value = inMicroseconds;
    var unit = 'microsegundo';
    if (inDays > 0) {
      value = inDays;
      unit = 'dia';
    } else if (inHours > 0) {
      value = inHours;
      unit = 'hora';
    } else if (inMinutes > 0) {
      value = inMinutes;
      unit = 'minuto';
    } else if (inSeconds > 0) {
      value = inSeconds;
      unit = 'segundo';
    } else if (inMilliseconds > 0) {
      value = inMilliseconds;
      unit = 'milisegundo';
    }
    var res = '$value $unit';
    if (value != 1) res += 's';
    return res;
  }
}

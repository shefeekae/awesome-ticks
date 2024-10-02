String formatDuration(Duration duration) {
  int weeks = duration.inDays ~/ 7;
  int days = duration.inDays.remainder(7);
  int hours = duration.inHours.remainder(24);
  int minutes = duration.inMinutes.remainder(60);
  int seconds = duration.inSeconds.remainder(60);

  String formattedDuration = '';
  if (weeks > 0) {
    formattedDuration += '${weeks}w ';
  }
  if (days > 0) {
    formattedDuration += '${days}d ';
  }
  if (hours > 0) {
    formattedDuration += '${hours}h ';
  }
  if (minutes > 0) {
    formattedDuration += '${minutes}m ';
  }
  if (seconds >= 0) {
    formattedDuration += '${seconds}s ';
  }

  if (formattedDuration.trim().startsWith("-")) {
    return "0s";
  }

  return formattedDuration.trim();
}

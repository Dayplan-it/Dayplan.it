class NoScheduleFound implements Exception {
  @override
  String toString() {
    return 'No Schedule Found';
  }
}

class TravelTimeException implements Exception {
  late int scheduleIndex;
  TravelTimeException({required this.scheduleIndex});
  @override
  String toString() {
    return 'Route Travel Time Exceeded Schedule';
  }
}

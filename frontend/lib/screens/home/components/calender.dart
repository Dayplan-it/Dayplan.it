import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:calendar_strip/calendar_strip.dart';

class WeeklyCalander extends StatefulWidget {
  final List<DateTime> marked_days;
  const WeeklyCalander(this.marked_days);

  @override
  State<WeeklyCalander> createState() => _WeeklyCalanderState();
}

class _WeeklyCalanderState extends State<WeeklyCalander> {
  @override
  void initState() {
    super.initState();
  }

  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now().add(Duration(days: 30));
  DateTime selectedDate = DateTime.now().add(Duration(days: 0));
  @override
  Widget build(BuildContext context) {
    return Container(
        child: CalendarStrip(
      startDate: startDate,
      endDate: endDate,
      selectedDate: selectedDate,
      onDateSelected: onSelect,
      onWeekSelected: onWeekSelect,
      dateTileBuilder: dateTileBuilder,
      iconColor: Colors.black87,
      monthNameWidget: _monthNameWidget,
      markedDates: widget.marked_days,
      containerDecoration: BoxDecoration(color: Colors.black12),
      addSwipeGesture: true,
    ));
  }
}

onSelect(data) {
  print("Selected Date -> $data");
}

onWeekSelect(data) {
  print("Selected week starting at -> $data");
}

_monthNameWidget(monthName) {
  return Container(
    child: Text(
      monthName,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        fontStyle: FontStyle.italic,
      ),
    ),
    padding: EdgeInsets.only(top: 8, bottom: 4),
  );
}

getMarkedIndicatorWidget() {
  return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(
      margin: EdgeInsets.only(left: 1, right: 1),
      width: 7,
      height: 7,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
    ),
    Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
    )
  ]);
}

dateTileBuilder(
    date, selectedDate, rowIndex, dayName, isDateMarked, isDateOutOfRange) {
  bool isSelectedDate = date.compareTo(selectedDate) == 0;
  Color fontColor = isDateOutOfRange ? Colors.black26 : Colors.black87;
  TextStyle normalStyle =
      TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: fontColor);
  TextStyle selectedStyle = TextStyle(
      fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black87);
  TextStyle dayNameStyle = TextStyle(fontSize: 14.5, color: fontColor);
  List<Widget> _children = [
    Text(dayName, style: dayNameStyle),
    Text(date.day.toString(),
        style: !isSelectedDate ? normalStyle : selectedStyle),
  ];

  if (isDateMarked == true) {
    _children.add(getMarkedIndicatorWidget());
  }

  return AnimatedContainer(
    duration: Duration(milliseconds: 150),
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 8, left: 5, right: 5, bottom: 5),
    decoration: BoxDecoration(
      color: !isSelectedDate ? Colors.transparent : Colors.white70,
      borderRadius: BorderRadius.all(Radius.circular(60)),
    ),
    child: Column(
      children: _children,
    ),
  );
}

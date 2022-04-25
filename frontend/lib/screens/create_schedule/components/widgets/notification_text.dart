import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';

class NotificationText extends StatelessWidget {
  const NotificationText(
      {Key? key,
      required this.title,
      this.isRed = false,
      this.isInstruction = false,
      this.makePaddingZero = false})
      : super(key: key);
  final String title;
  final bool isRed;
  final bool isInstruction;
  final bool makePaddingZero;

  @override
  Widget build(BuildContext context) {
    Color _color = (isRed ? pointColor : subTextColor);
    Widget _buildIcon() {
      if (isInstruction) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(1.5, 0, 1.5, 0),
          child: Container(
            height: 14,
            width: 14,
            decoration: BoxDecoration(
                color: subTextColor, borderRadius: BorderRadius.circular(20)),
            child: const Icon(
              Icons.question_mark_rounded,
              color: Colors.white,
              size: 11,
            ),
          ),
        );
      } else {
        return Icon(
          Icons.info,
          color: _color,
          size: 17,
        );
      }
    }

    return Column(
      children: [
        Row(
          children: [
            _buildIcon(),
            const SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                title,
                style: mainFont(
                    color: _color, fontWeight: FontWeight.w600, fontSize: 11),
              ),
            ),
          ],
        ),
        if (!makePaddingZero)
          const SizedBox(
            height: 5,
          ),
      ],
    );
  }
}

class NotificationBox extends StatefulWidget {
  const NotificationBox(
      {Key? key,
      required this.title,
      this.isRed = false,
      this.isInstruction = false})
      : super(key: key);

  final String title;
  final bool isRed;
  final bool isInstruction;

  @override
  State<NotificationBox> createState() => _NotificationBoxState();
}

class _NotificationBoxState extends State<NotificationBox> {
  bool _isNotiBoxShow = true;

  @override
  Widget build(BuildContext context) {
    return _isNotiBoxShow
        ? Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: defaultBoxShadow,
                borderRadius: defaultBoxRadius,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: NotificationText(
                      title: widget.title,
                      isRed: widget.isRed,
                      isInstruction: widget.isInstruction,
                      makePaddingZero: true,
                    ),
                  ),
                  IconButton(
                      onPressed: () => setState(() {
                            _isNotiBoxShow = false;
                          }),
                      icon: const Icon(
                        Icons.close,
                        color: subTextColor,
                        size: 16,
                      ))
                ],
              ),
            ),
          )
        : const SizedBox();
  }
}

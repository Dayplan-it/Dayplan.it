import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';

class NotificationText extends StatelessWidget {
  const NotificationText(
      {Key? key,
      required this.title,
      this.isRed = false,
      this.isInstruction = false})
      : super(key: key);
  final String title;
  final bool isRed;
  final bool isInstruction;

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
        const SizedBox(
          height: 5,
        ),
      ],
    );
  }
}

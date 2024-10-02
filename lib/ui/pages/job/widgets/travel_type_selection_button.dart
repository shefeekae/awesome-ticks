import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:sizer/sizer.dart';

class TravelTypeSelectionButton extends StatelessWidget {
  const TravelTypeSelectionButton({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.title,
    required this.onPressed,
    required this.value,
  });

  final IconData icon;
  final bool isSelected;
  final String title;
  final TravelType value;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Bounce(
      duration: const Duration(milliseconds: 100),
      onPressed: onPressed,
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                backgroundColor: isSelected ? Colors.blue : fwhite,
                radius: 30.sp,
                child: Icon(
                  icon,
                  size: 22.sp,
                  color: isSelected ? fwhite : Colors.blue,
                ),
              ),
              Visibility(
                visible: isSelected,
                child: Positioned(
                    left: 35.sp,
                    child: CircleAvatar(
                      radius: 12.sp,
                      backgroundColor: Colors.blue,
                      child: CircleAvatar(
                        radius: 11.sp,
                        backgroundColor: kWhite,
                        child: const Icon(
                          Icons.check,
                          color: Colors.blue,
                        ),
                      ),
                    )),
              )
            ],
          ),
          SizedBox(height: 5.sp),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.blue : null,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}

enum TravelType {
  alone,
  withTeam,
}

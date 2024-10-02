import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BuildDetailsCard extends StatelessWidget {
  const BuildDetailsCard({
    super.key,
    required this.title,
    this.children = const [],
    this.value = "",
    this.showTrailing = false,
    this.onTap,
  });

  final String title;
  final String value;
  final List<Widget> children;
  final bool showTrailing;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.sp),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(
                      height: 3.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.sp),
                      child: Builder(builder: (context) {
                        if (value.isEmpty) {
                          if (children.isEmpty) {
                            return const Text(
                              "N/A",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: children,
                          );
                        }

                        return Text(
                          value,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: showTrailing,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

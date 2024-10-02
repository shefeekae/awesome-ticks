import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BuildCustomSearchField extends StatelessWidget {
  const BuildCustomSearchField({
    super.key,
    this.controller,
    this.onTap,
    this.onChanged,
  });

  final TextEditingController? controller;
  final void Function()? onTap;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25.sp,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        // cursorColor: kBlack,
        decoration: InputDecoration(
          // fillColor: kWhite,
          filled: true,
          prefixIcon: const Icon(
            Icons.search,
          ),
          prefixIconColor: Colors.grey,
          hintText: "Search",
          focusColor: kBlack,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.sp),
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 0,
            ),
            borderRadius: BorderRadius.circular(6.sp),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 0,
            ),
            borderRadius: BorderRadius.circular(6.sp),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 5.sp,
            vertical: 5.sp,
          ),
        ),
      ),
    );
  }
}

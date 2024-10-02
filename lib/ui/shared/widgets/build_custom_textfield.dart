// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/themes/colors.dart';

class BuildCustomTextformField extends StatelessWidget {
  BuildCustomTextformField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.enableObscure = false,
    this.maxLines = 1,
    this.enableValidator = true,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.customValidator,
  }) : super(key: key);

  final String hintText;
  final TextEditingController controller;
  final bool enableObscure;
  final int maxLines;
  final bool enableValidator;

  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  final OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderSide: BorderSide(
      width: 1,
      color: fwhite,
    ),
    borderRadius: BorderRadius.circular(10.0),
  );

  final OutlineInputBorder errorBorder = OutlineInputBorder(
    borderSide: const BorderSide(
      // width: 1,
      color: Colors.red,
    ),
    borderRadius: BorderRadius.circular(10.0),
  );

  bool obscure = true;

  bool autoValidate = false;

  String? Function(String?)? customValidator;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => TextFormField(
        // autocorrect: true,
        // autofocus: true,

        autovalidateMode:
            autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,

        onChanged: (value) {
          if (!autoValidate) {
            setState(
              () {
                autoValidate = !autoValidate;
              },
            );
          }
        },

        controller: controller,
        cursorColor: kBlack,
        inputFormatters: inputFormatters,
        validator: enableValidator
            ? (value) {
                if (value != null && value.trim().isEmpty) {
                  return "*required";
                } else if (value!.startsWith(RegExp(r'[^\w\s]'))) {
                  return "Please avoid starting with symbols";
                } else if (customValidator != null) {
                  return customValidator!.call(value);
                }

                return null;
              }
            : null,
        obscureText: enableObscure && obscure,
        keyboardType: keyboardType,
        // obscuringCharacter: "",
        style: TextStyle(
          color: kBlack,
        ),
        maxLines: maxLines,
        decoration: InputDecoration(
          filled: true,
          fillColor: fwhite,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.black26,
            // fontWeight: FontWeight.w600,
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
          enabledBorder: outlineInputBorder,
          focusedBorder: outlineInputBorder,
          errorBorder: errorBorder,
          focusedErrorBorder: errorBorder,
          suffixIcon: enableObscure
              ? GestureDetector(
                  onTap: () {
                    setState(
                      () {
                        obscure = !obscure;
                      },
                    );
                  },
                  child: Icon(
                    obscure ? Icons.visibility : Icons.visibility_off,
                    color: kBlack,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

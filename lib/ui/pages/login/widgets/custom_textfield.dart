import 'package:awesometicks/core/services/theme_services.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../utils/themes/colors.dart';

// ignore: must_be_immutable
class BuildLoginTextFormField extends StatelessWidget {
  BuildLoginTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    this.onEditingComplete,
    this.keyboadrdType,
    this.autofillHints,
    this.enableObscure = false,
  });

  final String hintText;
  final TextEditingController controller;
  final bool enableObscure;
  final Iterable<String>? autofillHints;
  final TextInputType? keyboadrdType;
  void Function()? onEditingComplete;

  final OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderSide: BorderSide(
      width: 1,
      color: kBlack,
    ),
    borderRadius: BorderRadius.circular(5.0),
  );

  // final OutlineInputBorder errorBorder = OutlineInputBorder(
  //   borderSide: const BorderSide(
  //     width: 1,
  //     color: ThemeServices().getPrimaryFgColor(context),
  //   ),
  //   borderRadius: BorderRadius.circular(5.0),
  // );

  bool obscure = true;

  bool autoValidate = false;

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder errorBorder = OutlineInputBorder(
      borderSide: BorderSide(
        width: 1,
        color: ThemeServices().getPrimaryFgColor(context),
      ),
      borderRadius: BorderRadius.circular(5.0),
    );

    return StatefulBuilder(
      builder: (context, setState) => TextFormField(
        // autocorrect: true,
        autofocus: true,
        enableSuggestions: true,
        keyboardType: keyboadrdType,
        autocorrect: false,
        autofillHints: autofillHints,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        // autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,

        // onChanged: (value) {
        //   // if (!autoValidate) {
        //   //   setState(
        //   //     () {
        //   //       autoValidate = !autoValidate;
        //   //     },
        //   //   );
        //   // }
        // },
        onEditingComplete: onEditingComplete,
        controller: controller,
        cursorColor: kWhite,
        validator: (value) {
          if (value != null && value.trim().isEmpty) {
            return "*required";
          }
          return null;
        },
        obscureText: enableObscure && obscure,
        // obscuringCharacter: "*",
        style: const TextStyle(
          color: kWhite,
        ),
        // textAlign: TextAlign.center,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black54,
            hintText: hintText,
            // alignLabelWithHint: true,
            hintStyle: const TextStyle(
              color: Colors.white38,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12.sp,
            ),
            enabledBorder: outlineInputBorder,
            focusedBorder: outlineInputBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
            errorStyle: TextStyle(
              color: ThemeServices().getPrimaryFgColor(context),
            ),
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
                      color: kWhite,
                    ),
                  )
                : null),
      ),
    );
  }
}

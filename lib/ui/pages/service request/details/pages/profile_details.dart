// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:awesometicks/core/services/theme_services.dart';
import 'package:awesometicks/ui/shared/functions/short_letter_converter.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../../utils/themes/colors.dart';

class ProfileDetailsScreen extends StatelessWidget {
  final String name;
  final String phoneNumber;
  final String email;
  final String title;

  const ProfileDetailsScreen({
    Key? key,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20.sp,
          ),
          Center(
            child: CircleAvatar(
              radius: 50.sp,
              child: Text(
                shortLetterConverter(name),
                style: TextStyle(
                  fontSize: 35.sp,
                  color: ThemeServices().getPrimaryFgColor(context),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10.sp,
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 5.sp,
          ),
          SizedBox(
            height: 10.sp,
          ),
          buildListTile(
            iconData: Icons.phone_outlined,
            value: phoneNumber,
            context: context,
          ),
          buildListTile(
            iconData: Icons.email_outlined,
            value: email,
            context: context,
          ),
        ],
      ),
    );
  }

  // ===========================================
  // This method is used to show the listTile.

  Widget buildListTile({
    required IconData iconData,
    required String value,
    required BuildContext context,
  }) {
    return ListTile(
      leading: Icon(
        iconData,
        color: Theme.of(context).colorScheme.secondary,
      ),
      title: SelectableText(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

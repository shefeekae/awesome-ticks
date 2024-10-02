import 'dart:convert';

import 'package:app_filter_form/app_filter_form.dart';
import 'package:awesometicks/core/blocs/theme/theme_bloc.dart';
import 'package:awesometicks/core/services/theme_services.dart';
import 'package:firebase_config/services/firebase_messaging.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:secure_storage/model/user_data_model.dart';
import 'package:awesometicks/ui/pages/bottomnavbar/bottom_navbar_screen.dart';
import 'package:awesometicks/ui/pages/login/widgets/custom_textfield.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secure_storage/services/shared_prefrences_services.dart';
import 'package:secure_storage/services/storage_services.dart';
import 'package:sizer/sizer.dart';
import 'package:graphql_config/services/user_auth_services.dart';
// import '../../../core/services/userauth_services.dart';
// import '../../shared/widgets/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  static const String id = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = true;

  bool isLoading = false;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String errorMessage = "";

  UserDataSingleton userData = UserDataSingleton();

  @override
  Widget build(BuildContext context) {
    // print("error message $errorMessage");
    return Container(
      decoration: BoxDecoration(
        gradient: getGradientColors(
          context,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10.sp,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100.sp,
                  ),
                  buildHeaderLabelWidget(),
                  SizedBox(
                    height: 50.sp,
                  ),
                  BuildLoginTextFormField(
                    hintText: "Username",
                    controller: usernameController,
                    autofillHints: const [AutofillHints.username],
                    keyboadrdType: TextInputType.emailAddress,
                  ),
                  Builder(builder: (context) {
                    if (isLoading) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.sp),
                          child: LoadingIosAndroidWidget(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 10.sp,
                    );
                  }),
                  BuildLoginTextFormField(
                    hintText: "Password",
                    autofillHints: const [AutofillHints.password],
                    controller: passwordController,
                    enableObscure: true,
                    keyboadrdType: TextInputType.visiblePassword,
                    onEditingComplete: () => TextInput.finishAutofillContext(),
                  ),
                  SizedBox(
                    height: 5.sp,
                  ),
                  buildKeepMeWidget(),
                  SizedBox(
                    height: 30.sp,
                  ),
                  buildErrorMessage(),
                  buildLoginButton(context),
                  SizedBox(
                    height: 10.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // Error message

  Widget buildErrorMessage() {
    if (errorMessage.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.sp),
      child: Text(
        errorMessage,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  // ===============================================================================================
  RichText buildHeaderLabelWidget() {
    return RichText(
      text: TextSpan(
          text: "Awesome",
          style: TextStyle(
            // color: Theme.of(context).primaryColor,
            fontSize: 22.sp,
            color: ThemeServices().getPrimaryFgColor(context),
          ),
          children: [
            TextSpan(
              text: "TICKS",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 25.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]),
    );
  }

  // ==============================================================================
  ElevatedButton buildLoginButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 40.sp),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        // foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      onPressed: isLoading
          ? null
          : () async {
              bool isValid = formKey.currentState!.validate();

              if (isValid) {
                FocusManager.instance.primaryFocus?.unfocus();

                setState(() {
                  isLoading = !isLoading;
                  errorMessage = "";
                });

                String value = await UserAuthServices().loginUser(
                  username: usernameController.text.trim(),
                  password: passwordController.text.trim(),
                  allowedUserTypes: [
                    "Mechanic",
                    "Operator",
                    "Security",
                    "SiteEngineer",
                  ],
                );
                setState(() {
                  isLoading = !isLoading;
                });

                if (value.isEmpty) {
                  String domain = userData.domain;

                  String userName = userData.userName;

                  FirebaseMessagingServices().topicSubscribeHandler(
                    subscribe: true,
                    topic:
                        "nectar-awesometicks-updates-$domain-$userName-$domain",
                  );

                  StorageServices().storeRememberMe(rememberMe);

                  TextInput.finishAutofillContext();

                  // ignore: use_build_context_synchronously
                  ThemeBloc themeBloc = BlocProvider.of<ThemeBloc>(context);

                  themeBloc.add(ChangeThemeEvent());

                  // ignore: use_build_context_synchronously
                  Navigator.pushReplacementNamed(
                      context, BottomNavBarScreen.id);
                } else if (value == "Request is incomplete") {
                  setState(() {
                    errorMessage = "Username or Password is incorrect";
                  });
                } else {
                  setState(() {
                    errorMessage = value;
                  });
                }
                // setState(() {
                //   loginLabel = "Log In";
                // });
              }
              // Navigator.of(context).pushReplacementNamed(HomeScreen.id);
            },
      child: Text(
        "Log In",
        style: TextStyle(
          // color: Theme.of(context).primaryColor,
          color: ThemeServices().getSecondaryFgColor(context),
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===================================================================================
  // Remember Me

  Widget buildKeepMeWidget() {
    return StatefulBuilder(builder: (context, setState) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              unselectedWidgetColor: Colors.white,
              // backgroundColor: kWhite,
            ),
            child: Checkbox(
              activeColor: Theme.of(context).colorScheme.secondary,
              // focusColor: kWhite,
              value: rememberMe,
              onChanged: (value) {
                setState(
                  () {
                    rememberMe = value!;
                  },
                );
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(
                () {
                  rememberMe = !rememberMe;
                },
              );
            },
            child: const Text(
              "Keep me logged In",
              style: TextStyle(
                color: kWhite,
                // fontSize: 13.sp,
              ),
            ),
          ),
        ],
      );
    });
  }
}

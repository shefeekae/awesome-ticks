import 'package:awesometicks/core/services/theme_services.dart';
import 'package:awesometicks/ui/pages/profile/enum/profile_item_enums.dart';
import 'package:awesometicks/ui/shared/widgets/custom_app_bar.dart';
import 'package:graphql_config/graphql_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:awesometicks/ui/shared/functions/short_letter_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:video_tutorials/screens/video_tutorial_screen.dart';
import 'package:video_tutorials/video_tutorials.dart';
import '../../../core/blocs/internet/bloc/internet_available_bloc.dart';
import '../../../core/models/profile_model.dart';
import '../../../core/schemas/profile_schemas.dart';
import '../../../core/services/graphql_services.dart';
import '../../../core/services/platform_services.dart';
import '../../../core/services/user_auth_helpers.dart';
import '../../shared/widgets/loading_widget.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  static const String id = '/profile';

  final UserDataSingleton userDataSingleton = UserDataSingleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: "Profile",
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: 5.w,
              ),
              children: [
                BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
                  builder: (context, state) {
                    bool hasInternet = state.isInternetAvailable;

                    if (!hasInternet) {
                      Data? userData = Data(
                        userName: userDataSingleton.userName,
                        emailId: userDataSingleton.emailId,
                        contactNumber: userDataSingleton.contactNumber,
                      );

                      return buildProfileWidget(
                        userData,
                        userDataSingleton.displayName,
                      );
                    }

                    return QueryWidget(
                      options: GraphqlServices().getQueryOptions(
                        query: ProfileSchemas.finndLoggedInUser,
                        rereadPolicy: true,
                      ),
                      builder: (result, {fetchMore, refetch}) {
                        if (result.isLoading) {
                          return Column(
                            children: [
                              SizedBox(
                                height: 15.h,
                              ),
                              Center(
                                child: LoadingIosAndroidWidget(
                                  // color: primaryColor,
                                  radius: 15.sp,
                                ),
                              ),
                              SizedBox(
                                height: 15.h,
                              ),
                            ],
                          );
                        }

                        if (result.hasException) {
                          return GraphqlServices().handlingGraphqlExceptions(
                            result: result,
                            context: context,
                            refetch: refetch,
                          );
                        }

                        ProfileLoggedModel profileLoggedModel =
                            profileLoggedModelFromJson(result.data!);

                        Data? userData =
                            profileLoggedModel.findLoggedInUser?.user?.data;

                        String? firstName =
                            userData == null ? "" : userData.firstName ?? "";
                        String? lastName =
                            userData == null ? "" : userData.lastName ?? "";

                        return buildProfileWidget(
                            userData, "$firstName $lastName");
                      },
                    );
                  },
                ),
                Divider(
                  height: 20.sp,
                ),
                // buildListTile(
                //   context,
                //   title: "Help",
                //   leadingIconData: Icons.help_outline_outlined,
                //   profileItem: ProfileItem.help,
                // ),
                buildListTile(
                  context,
                  title: "Log Out",
                  leadingIconData: Icons.logout,
                  profileItem: ProfileItem.logOut,
                ),
                // Spacer(),
              ],
            ),
          ),
          buildVersionText(),
          SizedBox(
            height: 10.sp,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Displaying version

  FutureBuilder<Object?> buildVersionText() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox();
        }

        String version = snapshot.data?.version ?? '';

        return Text("v$version");
      },
    );
  }

  // =========================================================================================
  // This widget showing the user profile details.

  Widget buildProfileWidget(Data? userData, String displayName) {
    return Builder(builder: (context) {
      return Column(
        children: [
          SizedBox(
            height: 15.sp,
          ),
          CircleAvatar(
            radius: 50.sp,
            child: Text(
              shortLetterConverter(userData?.userName ?? "N/A"),
              style: TextStyle(
                fontSize: 35.sp,
                color: ThemeServices().getPrimaryFgColor(context),
              ),
            ),
          ),
          // Container(
          //   height: 15.h,
          //   decoration: BoxDecoration(
          //     color: fwhite,
          //     shape: BoxShape.circle,
          //     image: const DecorationImage(
          //       image: NetworkImage(
          //         'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png',
          //       ),
          //       fit: BoxFit.contain,
          //     ),
          //   ),
          // ),
          SizedBox(
            height: 15.sp,
          ),
          Text(
            userData?.userName ?? "N/A",
            style: TextStyle(
              fontSize: 18.sp,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 15.sp,
          ),
          buildIconandText(
            iconData: Icons.person,
            value: displayName,
          ),
          SizedBox(
            height: 15.sp,
          ),
          buildIconandText(
            iconData: Icons.phone,
            value: userData?.contactNumber ?? "N/A",
          ),
          SizedBox(
            height: 15.sp,
          ),
          buildIconandText(
            iconData: Icons.email,
            value: userData?.emailId ?? "N/A",
          ),
        ],
      );
    });
  }

  // ==========================================================================
  // Used to show the listTile.

  Widget buildListTile(
    BuildContext context, {
    required String title,
    required IconData leadingIconData,
    required ProfileItem profileItem,
  }) {
    return Builder(builder: (context) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: () {
          switch (profileItem) {
            case ProfileItem.help:
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const VideoTutorialScreen(
                  videoTutorialFolderId: VideoTutorialFolderId.awesomeTicks,
                ),
              ));

              break;

            case ProfileItem.logOut:
              PlatformServices().showPlatformDialog(
                context,
                title: "Are you sure?",
                message: "You will be returned to the login screen.",
                onPressed: () async {
                  UserAuthHelpers().logoutHelper();
                },
              );
              break;

            default:
          }
        },
        leading: Icon(
          leadingIconData,
          // color: primaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            // color: primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    });
  }

  Row buildIconandText({
    required IconData iconData,
    required String value,
  }) {
    Color color = Colors.black26;

    return Row(
      children: [
        Icon(
          iconData,
          color: color,
          size: 15.sp,
        ),
        SizedBox(
          width: 10.sp,
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}

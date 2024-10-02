import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesometicks/main.dart';
import 'package:awesometicks/ui/pages/login/login_screen.dart';
import 'package:firebase_config/services/firebase_messaging.dart';
import 'package:graphql_config/services/user_auth_services.dart';
import 'package:secure_storage/secure_storage.dart';

class UserAuthHelpers {
  UserDataSingleton userData = UserDataSingleton();

  logoutHelper() async {
    String domain = userData.domain;

    String userName = userData.userName;

    FirebaseMessagingServices().topicSubscribeHandler(
      subscribe: false,
      topic: "nectar-awesometicks-updates-$domain-$userName-$domain",
    );

    AwesomeNotifications().cancelAll();

    UserAuthServices().logOut();

    MyApp.navigatorKey.currentState
        ?.pushNamedAndRemoveUntil(LoginScreen.id, (route) => false);
  }
}

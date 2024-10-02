import 'package:awesometicks/core/blocs/action%20button%20loading/action_button_loading_bloc.dart';
import 'package:awesometicks/core/blocs/asset_checklist/asset_checklist_management_bloc.dart';
import 'package:awesometicks/core/blocs/attachments/attachments_controller_bloc.dart';
import 'package:awesometicks/core/blocs/count/count_bloc.dart';
import 'package:awesometicks/core/blocs/internet/bloc/internet_available_bloc.dart';
import 'package:awesometicks/core/blocs/job/job_management_bloc.dart';
import 'package:awesometicks/core/blocs/job_details/job_details_bloc.dart';
import 'package:awesometicks/core/blocs/pagination%20controller/pagination_controller_bloc.dart';
import 'package:awesometicks/core/blocs/parts/bloc/parts_control_bloc.dart';
import 'package:awesometicks/core/blocs/refresh%20controller/refresh_controller_bloc.dart';
import 'package:awesometicks/core/blocs/sync%20progress/sync_progress_bloc.dart';
import 'package:awesometicks/core/blocs/theme/theme_bloc.dart';
import 'package:awesometicks/core/blocs/timeline/timeline_update_bloc.dart';
import 'package:awesometicks/core/blocs/travel_time_bloc/travel_time_bloc.dart';
import 'package:awesometicks/core/models/hive%20db/job_reasons_model.dart';
import 'package:awesometicks/core/models/hive%20db/list_jobs_model.dart';
import 'package:awesometicks/core/models/hive%20db/syncing_local_db.dart';
import 'package:awesometicks/core/services/mqtt_services.dart';
import 'package:awesometicks/core/services/user_auth_helpers.dart';
import 'package:data_collection_package/bloc/point_submit/point_submit_bloc.dart';
import 'package:data_collection_package/bloc/single_point_submit/single_point_submit_bloc.dart';
import 'package:data_collection_package/bloc/single_point_update/single_point_update_bloc.dart';
import 'package:data_collection_package/data_collection_package.dart';
import 'package:awesometicks/utils/themes/app_theme_data.dart';
import 'package:firebase_config/firebase_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:awesometicks/ui/pages/splash/splash_screen.dart';
import 'package:awesometicks/ui/shared/widgets/base_widget.dart';
import 'package:awesometicks/utils/named_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:job_card/core/bloc/bloc/attachment_selection_bloc.dart';
// import 'package:job_card/core/bloc/bloc/attachment_selection_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:secure_storage/services/storage_services.dart';
import 'package:sizer/sizer.dart';
import 'package:video_tutorials/video_tutorials.dart';
import 'core/blocs/job controller/job_controller_bloc_bloc.dart';
import 'core/blocs/parts/parts_quantity_bloc.dart';
import 'core/blocs/spaces selection/spaces_selection_bloc.dart';
import 'core/services/notifications/notification_controller.dart';
import 'package:graphql_config/graphql_config.dart';
import 'package:app_filter_form/app_filter_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final document = await getApplicationDocumentsDirectory();

  await Hive.initFlutter(document.path);

  bool jobDbregistered = Hive.isAdapterRegistered(JobDetailsDbAdapter().typeId);

  if (!jobDbregistered) {
    Hive.registerAdapter(JobDetailsDbAdapter());
    Hive.registerAdapter(AssigneeAdapter());
    Hive.registerAdapter(ResourceAdapter());
    Hive.registerAdapter(ChecklistDbAdapter());
    Hive.registerAdapter(JobCommentsAdapter());
    Hive.registerAdapter(CommentsAdapter());
    Hive.registerAdapter(RepliesAdapter());
    Hive.registerAdapter(PartsAdapter());
    Hive.registerAdapter(SkillsAdapter());
    Hive.registerAdapter(ToolsAdapter());
  }

  bool syncDbregistered =
      Hive.isAdapterRegistered(SyncingLocalDbAdapter().typeId);

  if (!syncDbregistered) {
    Hive.registerAdapter(SyncingLocalDbAdapter());
  }

  bool reasonsDbregistered =
      Hive.isAdapterRegistered(ReasonsDbAdapter().typeId);

  if (!reasonsDbregistered) {
    Hive.registerAdapter(ReasonsDbAdapter());
  }
  // Adapter Type id is 13
  await VideoTutorialDbServices().registerAdapterandOpenBox();

  await Hive.openBox<JobDetailsDb>(JobDetailsDb.boxName);
  await Hive.openBox<SyncingLocalDb>(SyncingLocalDb.boxName);
  await Hive.openBox<ReasonsDb>(ReasonsDb.boxName);

  final String timeZone = await FlutterTimezone.getLocalTimezone();

  NotificationController.awesomeNotificationinitialise();

  await FirebaseConfig().init();

  await StorageServices().init();

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      // DeviceOrientation.landscapeLeft,
      // DeviceOrientation.landscapeRight,
    ],
  );

  await MqttServices().connectToMqttClient();

  runApp(
    MyApp(
      timeZone: timeZone,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({required this.timeZone, super.key});

  final String timeZone;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppThemeData appThemeData = AppThemeData();

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => GraphQlProviderWidget(
        client: ValueNotifier(
          GrapghQlClientServices().getClient(
            timeZone: widget.timeZone,
            endPointUrl:
                'http://192.168.0.214:3000/api/graphql', // office staging
            isConnectedinStaging: true,
            // endPointUrl: 'http://192.168.0.214:3000/api/graphql', //office staging
            exceptionHandler: () async {
              UserAuthHelpers().logoutHelper();
            },
          ),
        ),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => FilterSelectionBloc(),
            ),
            BlocProvider(
              create: (context) => PartsQuantityBloc(),
            ),
            BlocProvider(
              create: (context) => PayloadManagementBloc(),
            ),
            BlocProvider(
              create: (context) => ValidatorControllerBlocBloc(),
            ),
            BlocProvider(
              create: (context) => FilterAppliedBloc(),
            ),
            BlocProvider(
              create: (context) => JobManagementBloc(),
            ),
            BlocProvider(
              create: (context) => CountBloc(),
            ),
            BlocProvider(
              create: (context) => PaginationControllerBloc(),
            ),
            BlocProvider(
              create: (context) => PartsControlBloc(),
            ),
            BlocProvider(
              create: (context) => SyncProgressBloc(),
            ),
            BlocProvider(
              create: (context) => InternetAvailableBloc(),
            ),
            BlocProvider(
              create: (context) => RefreshControllerBloc(),
            ),
            BlocProvider(
              create: (context) => JobControllerBlocBloc(),
            ),
            BlocProvider(
              create: (context) => SpacesSelectionBloc(),
            ),
            BlocProvider(
              create: (context) => ThemeBloc(),
            ),
            BlocProvider(
              create: (context) => AssigneeControllerBloc(),
            ),
            BlocProvider(
              create: (context) => AttachmentsControllerBloc(),
            ),
            BlocProvider(
              create: (context) => AttachmentSelectionBloc(),
            ),
            BlocProvider(
              create: (context) => AssigneeValueBloc(),
            ),
            BlocProvider(
              create: (context) => AdditionalMembersBloc(),
            ),
            BlocProvider(
              create: (context) => TimelineUpdateBloc(),
            ),
            BlocProvider(
              create: (context) => TravelTimeBloc(),
            ),
            BlocProvider(
              create: (context) => ActionButtonLoadingBloc(),
            ),
            BlocProvider(
              create: (context) => JobDetailsBloc(),
            ),
            BlocProvider(
              create: (context) => AssetChecklistManagementBloc(),
            ),
            BlocProvider(
              create: (context) => PointUpdateBloc(),
            ),
            BlocProvider(
              create: (context) => PointSubmitBloc(),
            ),
            BlocProvider(
              create: (context) => SinglePointSubmitBloc(),
            ),
            BlocProvider(
              create: (context) => SinglePointUpdateBloc(),
            )
          ],
          child: BlocBuilder<ThemeBloc, ThemeState>(builder: (context, state) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.dark,
              theme: appThemeData.getThemeData(),
              initialRoute: SplashScreen.id,
              navigatorKey: MyApp.navigatorKey,
              builder: (context, child) => GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: BaseWidget(child: child!),
              ),
              routes: namedRoutes,
            );
          }),
        ),
      ),
    );
  }
}

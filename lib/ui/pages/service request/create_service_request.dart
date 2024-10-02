import 'dart:convert';
import 'dart:io';
import 'package:app_filter_form/app_filter_form.dart';
import 'package:awesometicks/ui/pages/service%20request/details/service_details.dart';
import 'package:awesometicks/ui/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:secure_storage/model/user_data_model.dart';
import 'package:secure_storage/secure_storage.dart';
import '../../../core/blocs/spaces selection/spaces_selection_bloc.dart';

class CreateOrEditServiceRequestScreen extends StatefulWidget {
  const CreateOrEditServiceRequestScreen({super.key});

  static const String id = 'servicerequest/create/edit';

  @override
  State<CreateOrEditServiceRequestScreen> createState() =>
      _CreateOrEditServiceRequestScreenState();
}

class _CreateOrEditServiceRequestScreenState
    extends State<CreateOrEditServiceRequestScreen> {
  // String? title;
  final TextEditingController titleController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController locationController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  File? attachedFile;

  Map<String, dynamic>? buildingMap;
  Map<String, dynamic>? site;

  String? buildingTitle;

  String? buildingTypeName;

  bool isEdit = false;

  String requestNumber = "";

  Map<String, dynamic>? requestee;

  String? selectedRequestType;

  final ValueNotifier serviceRequestNotifier = ValueNotifier<bool>(false);

  UserDataSingleton userData = UserDataSingleton();

  late SpacesSelectionBloc spaceSelectionBloc;
  late FilterSelectionBloc filterSelectionBloc;
  late FilterAppliedBloc filterAppliedBloc;

  @override
  void initState() {
    filterSelectionBloc = BlocProvider.of<FilterSelectionBloc>(context);
    filterAppliedBloc = BlocProvider.of<FilterAppliedBloc>(context);
    spaceSelectionBloc = BlocProvider.of<SpacesSelectionBloc>(context);

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // filterSelectionBloc.state.filterLabelsList = [];
    // filterAppliedBloc.state.filterAppliedCount = 0;
    // filterSelectionBloc.state.filterValues = [];
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    String? appThemeData = SharedPrefrencesServices().getData(key: "appTheme");

    bool restrictConvertSrToJob = false;

    if (appThemeData != null) {
      var data = jsonDecode(appThemeData);

      restrictConvertSrToJob =
          data?["jobConfiguration"]?["restrictConvertSrToJob"] ?? false;
    }

    if (args != null) {
      // title = args['title'];
      // requestType = args['requestType'];

      // String? location = args['location'];

      isEdit = args['isEdit'] ?? false;

      if (isEdit) {
        String? name = args['name'];
        String? description = args['description'];
        site = args['site'];
        String? siteName = args['siteName'];
        String? requestSourceLocationName = args['requestSourceLocationName'];

        requestNumber = args['requestNumber'];
        requestee = args['requestee'];
        selectedRequestType = args['requestType'];

        spaceSelectionBloc.state.spaces = args['spaces'];

        if (requestSourceLocationName != null) {
          locationController.text = requestSourceLocationName;
        }

        if (name != null && name.isNotEmpty) {
          titleController.text = name;
        }

        if (description != null && description.isNotEmpty) {
          descriptionController.text = description;
        }

        if (site != null) {
          // buildingTitle = site['data']['name'];
          if (siteName != null && siteName.isNotEmpty) {
            buildingTitle = siteName;
            buildingTypeName = args['buildingType'];
          }

          buildingMap = site;
        }
      }
    }

    return Scaffold(
      // backgroundColor: kWhite,
      appBar: buildAppbar(),
      body: FormWidget(
        isMobile: true,
        formType: FormType.serviceRequest,
        initialValues: args?['initialValues'] ?? [],
        isEdit: isEdit,
        editPayload: {
          "requestNumber": requestNumber,
          "requestTime": DateTime.now().millisecondsSinceEpoch,
          "requestStatus": "OPEN",
          "requestee": requestee,
          "convertToJob": !restrictConvertSrToJob, //
        },
        saveSuccessHandler: (arguments) {
          if (isEdit) {
            Navigator.of(context).pop(true);
            return;
          }

          Navigator.of(context).pushReplacementNamed(
            ServiceDetailsScreen.id,
            arguments: arguments,
          );
        },
      ),
    );
  }

  PreferredSizeWidget buildAppbar() {
    String title = isEdit ? "Edit" : "Create";

    return GradientAppBar(
      title: "$title Service Request",
    );
  }
}

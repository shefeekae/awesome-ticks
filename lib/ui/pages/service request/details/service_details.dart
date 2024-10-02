import 'dart:convert';
import 'package:awesometicks/core/models/spaces_data_model.dart';
import 'package:awesometicks/core/services/launcher_services.dart';
import 'package:awesometicks/ui/pages/service%20request/create_service_request.dart';
import 'package:awesometicks/ui/pages/service%20request/details/pages/profile_details.dart';
import 'package:awesometicks/ui/pages/service%20request/details/pages/timeline_screen.dart';
import 'package:awesometicks/ui/shared/widgets/custom_app_bar.dart';
import 'package:files_viewer/files_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:graphql_config/widget/mutation_widget.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:user_permission/services/user_permission_services.dart';
import 'package:user_permission/widgets/permission_checking_widget.dart';
import '../../../../core/models/service_details.dart';
import '../../../../core/schemas/jobs_schemas.dart';
import '../../../../core/schemas/service_request_schemas.dart';
import '../../../../core/services/graphql_services.dart';
import '../../../../utils/themes/colors.dart';
import '../../../shared/functions/get_color_icons.dart';
import '../../../shared/widgets/build_elvetad_button.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/label_with_textfield.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../job/job_details.dart';
import 'package:graphql_config/graphql_config.dart';
import 'package:path/path.dart' as path;
import '../../job/widgets/job_card_popupmenu.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({super.key});

  static const String id = 'servicedetails';

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  List<Map> actionsList = [
    {
      "title": "Assign",
      "icon": Icons.person,
      "key": "assign",
    },
    {
      "title": "Close",
      "icon": Icons.close,
      "key": "close",
    },
  ];

  List<Map> tenantActionsList = [
    {
      "title": "Edit",
      "icon": Icons.edit,
      "key": "edit",
    },
    // {
    //   "title": "Transfer",
    //   "icon": Icons.send,
    //   "key": "transfer",
    // },
    {
      "title": "Close",
      "icon": Icons.close,
      "key": "close",
    },
  ];

  bool? isOpen = true;

  TextEditingController remarkController = TextEditingController();

  late String requestNumber;
  int? jobId;

  double ratingValue = 0;

  UserDataSingleton userData = UserDataSingleton();

  late bool updatePermission, closePermission, ratePermission;

  @override
  void initState() {
    final UserPermissionServices userPermissionServices =
        UserPermissionServices();

    updatePermission = userPermissionServices.checkingPermission(
      featureGroup: "serviceRequestManagement",
      feature: "serviceRequests",
      permission: "update",
    );

    closePermission = userPermissionServices.checkingPermission(
      featureGroup: "serviceRequestManagement",
      feature: "serviceRequests",
      permission: "close",
    );

    ratePermission = userPermissionServices.checkingPermission(
      featureGroup: "serviceRequestManagement",
      feature: "serviceRequests",
      permission: "rate",
    );

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)?.settings.arguments as Map;

    requestNumber = args['requestNumber'];
    jobId = args['jobId'];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: GradientAppBar(
        title: "Details",
        actions: [
          Builder(builder: (context) {
            if (jobId == null) {
              return const SizedBox();
            }

            return PermissionChecking(
              featureGroup: "jobManagement",
              feature: "job",
              permission: "jobCard",
              child: JobCardPopmenuButton(
                jobId: jobId!,
                filePath: "jobs/${userData.domain}/$jobId",
              ),
            );
          }),
        ],
      ),
      body: PermissionChecking(
        featureGroup: "serviceRequestManagement",
        feature: "serviceRequests",
        permission: "view",
        paddingTop: 10.sp,
        showNoAccessWidget: true,
        child: StatefulBuilder(builder: (context, setState) {
          return QueryWidget(
            options: GraphqlServices().getQueryOptions(
              query: ServiceRequestSchemas.findServiceRequestQuery,
              variables: {
                "requestNumber": requestNumber,
              },
            ),
            builder: (result, {fetchMore, refetch}) {
              bool isLoading = result.isLoading;

              if (isLoading) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ShimmerLoadingContainerWidget(height: 10.h),
                      SizedBox(
                        height: 10.sp,
                      ),
                      ShimmerLoadingContainerWidget(height: 70.h),
                    ],
                  ),
                );
              }

              if (result.hasException) {
                return GraphqlServices().handlingGraphqlExceptions(
                  result: result,
                  context: context,
                  // refetch: refetch,
                  setState: setState,
                );
              }

              ServiceDetailsModel serviceDetailsModel =
                  ServiceDetailsModel.fromJson(result.data!);

              FindServiceRequest? findServiceRequest =
                  serviceDetailsModel.findServiceRequest;

              String? requestStatus = findServiceRequest?.requestStatus;

              String? location = findServiceRequest?.building?.geoLocation;

              Assignee? assignee = findServiceRequest?.assignee;

              String requestType = findServiceRequest?.requestType ?? "";

              // findServiceRequest?.building.name;

              String domain = findServiceRequest?.domain ?? "";

              List<ContactPersons> contactPersons =
                  findServiceRequest?.contactPersons ?? [];

              List<AvailableSlots> availableSlots =
                  findServiceRequest?.availableSlots ?? [];

              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator.adaptive(
                      onRefresh: () async {
                        setState(
                          () {},
                        );
                      },
                      child: ListView(
                        children: [
                          buildHeaderCard(
                            title:
                                findServiceRequest?.requestSubjectLine ?? "N/A",
                            subTitle:
                                findServiceRequest?.requestDescription ?? "",
                            status: findServiceRequest?.requestStatus ?? "N/A",
                            requestType:
                                findServiceRequest?.requestType ?? "N/A",
                            formatedDate: findServiceRequest?.requestTime ==
                                    null
                                ? "No Date"
                                : DateFormat("d MMM - yyyy").add_jm().format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                        findServiceRequest!.requestTime!,
                                      ),
                                    ),
                            findServiceRequest: findServiceRequest,
                          ),
                          SizedBox(
                            height: 5.sp,
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: kWhite,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.sp),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildLabelWidget(label: "Attachments"),
                                  buildAttachmentsWidget(
                                    context: context,
                                    payload: {
                                      "filePath":
                                          "serviceRequests/$domain/$requestNumber",
                                      "traverseFiles": true,
                                    },
                                  ),
                                  Visibility(
                                    // visible: isManager,
                                    child: Builder(builder: (context) {
                                      int? jobId = findServiceRequest?.jobId;

                                      if (jobId == null) {
                                        return const SizedBox();
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          buildLabelWidget(
                                            label: "Job Attachments",
                                          ),
                                          buildAttachmentsWidget(
                                            context: context,
                                            payload: {
                                              "filePath": "jobs/$domain/$jobId",
                                              "traverseFiles": true,
                                            },
                                          )
                                        ],
                                      );
                                    }),
                                  ),
                                  Builder(
                                    builder: (context) {
                                      int? jobId = findServiceRequest?.jobId;

                                      bool hasPermission =
                                          UserPermissionServices()
                                              .checkingPermission(
                                        featureGroup: "jobManagement",
                                        feature: "job",
                                        permission: "view",
                                      );

                                      return Visibility(
                                        visible: jobId != null,
                                        child: buildLabelWithTileWidget(
                                          label: "Job Id",
                                          showTrailingIcon: hasPermission,
                                          title: findServiceRequest?.jobNumber
                                                  .toString() ??
                                              "N/A",
                                          onTap: hasPermission
                                              ? () {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                    JobDetailsScreen.id,
                                                    arguments: {
                                                      "jobId": jobId,
                                                    },
                                                  );
                                                }
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                  buildLabelWithTileWidget(
                                    label: "Location",
                                    title: location == null
                                        ? "Location not available"
                                        : findServiceRequest?.building?.name ??
                                            "N/A",
                                    showTrailingIcon: location != null,
                                    onTap: () {
                                      if (location != null) {
                                        List<String> latLng = location
                                            .replaceAll('POINT(', '')
                                            .replaceAll(')', '')
                                            .split(' ');

                                        String googleUrl =
                                            'https://www.google.com/maps/search/?api=1&query=${latLng[0]},${latLng[0]}';

                                        launchUrlString(googleUrl);

                                        // Navigator.of(context).push(
                                        //   MaterialPageRoute(
                                        //     builder: (context) =>
                                        //         const ServiceLocationScreen(),
                                        //   ),
                                        // );
                                      }
                                    },
                                  ),
                                  Builder(builder: (context) {
                                    if (requestType == "MOVE_IN" ||
                                        requestType == "MOVE_OUT") {
                                      return const SizedBox();
                                    }

                                    return buildLabelWithTileWidget(
                                      label: "Timeline",
                                      title: findServiceRequest
                                                  ?.requestStatus ==
                                              "CANCELLED"
                                          ? "Job is cancelled"
                                          : findServiceRequest?.jobId == null
                                              ? "Not assigned"
                                              : "Job is assigned",
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TimeLineScreen(
                                              requestNumber: requestNumber,
                                              createdOn: findServiceRequest!
                                                  .requestTime!,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                  Visibility(
                                    visible: assignee != null,
                                    child: buildLabelWithTileWidget(
                                      label: "Assignee",
                                      title: assignee?.name ?? "N/A",
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileDetailsScreen(
                                              title: "Assignee",
                                              name: assignee?.name ?? "N/A",
                                              phoneNumber:
                                                  assignee?.contactNumber ??
                                                      "N/A",
                                              email: assignee?.emailId ?? "N/A",
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  buildLabelWithTileWidget(
                                    label: "Requester",
                                    title:
                                        findServiceRequest?.requestee?.name ??
                                            "N/A",
                                    onTap: () {
                                      Requestee? requestee =
                                          findServiceRequest?.requestee;

                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProfileDetailsScreen(
                                            title: "Requester",
                                            name: requestee?.name ?? "N/A",
                                            phoneNumber:
                                                requestee?.contactNumber ??
                                                    "N/A",
                                            email: requestee?.emailId ?? "",
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  /// This widget is used to show the Secondary Contact
                                  Visibility(
                                    visible: contactPersons.isNotEmpty,
                                    child: buildLabelWithTileWidget(
                                      label: "Secondary contact",
                                      showTrailingIcon: false,
                                      children: List.generate(
                                        contactPersons.length,
                                        (index) {
                                          ContactPersons contactPerson =
                                              contactPersons[index];

                                          String contactName =
                                              contactPerson.name ?? "";
                                          String contactNumber =
                                              contactPerson.contactNumber ?? "";

                                          return GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              LauncherServices()
                                                  .launchPhoneDialer(
                                                context,
                                                contactNumber,
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                              ),
                                              child: Text(
                                                "$contactName : $contactNumber",
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                                  /// This widget is used to show the Preferred visiting time
                                  Visibility(
                                    visible: availableSlots.isNotEmpty,
                                    child: buildLabelWithTileWidget(
                                      label: "Preferred visiting time",
                                      showTrailingIcon: false,
                                      children: List.generate(
                                          availableSlots.length, (index) {
                                        AvailableSlots? availableSlot =
                                            availableSlots[index];

                                        int? startTimeEpoch =
                                            availableSlot.startTime;

                                        String? preferredStartTime =
                                            startTimeEpoch != null
                                                ? DateFormat("d MMM yyyy,")
                                                    .add_jm()
                                                    .format(
                                                      DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                        startTimeEpoch,
                                                      ),
                                                    )
                                                : "N/A";

                                        int? endTimeEpoch =
                                            availableSlot.endTime;

                                        String? preferredEndTime =
                                            endTimeEpoch != null
                                                ? DateFormat("d MMM yyyy,")
                                                    .add_jm()
                                                    .format(
                                                      DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                        endTimeEpoch,
                                                      ),
                                                    )
                                                : "N/A";

                                        return Text(
                                            "$preferredStartTime - $preferredEndTime");
                                      }),
                                    ),
                                  ),
                                  Visibility(
                                    visible: findServiceRequest
                                            ?.customerSatisfaction !=
                                        null,
                                    child: ListTile(
                                      title:
                                          const Text("Customer Satisfaction"),
                                      trailing: RatingStars(
                                        starColor:
                                            Theme.of(context).primaryColor,
                                        value: findServiceRequest
                                                ?.customerSatisfaction
                                                ?.toDouble() ??
                                            0,
                                        valueLabelVisibility: false,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.sp,
                          ),
                          moreDetails(findServiceRequest),
                        ],
                      ),
                    ),
                  ),
                  buildElevatedButtonWidget(
                    context,
                    refetch: refetch,
                    requestStatus: requestStatus,
                    findServiceRequest: findServiceRequest,
                    customerSatisficationEnabled:
                        findServiceRequest?.customerSatisfaction != null,
                  ),
                  SizedBox(
                    height: 10.sp,
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  Widget moreDetails(FindServiceRequest? findServiceRequest) {
    String? community = findServiceRequest?.community?.clientName;
    String? subCommunity = findServiceRequest?.subCommunity?.name;
    String? building = findServiceRequest?.building?.name;
    String? spaces =
        findServiceRequest?.spaces?.map((e) => e.name ?? "").join(" - ");
    String? locationName = findServiceRequest?.requestSourceLocationName;
    String? prioriy = findServiceRequest?.priority;
    String? discipline = findServiceRequest?.discipline;

    if (community == null &&
        subCommunity == null &&
        building == null &&
        spaces == null &&
        prioriy == null &&
        discipline == null) {
      return const SizedBox();
    }

    return Container(
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: kWhite,
      ),
      child: Column(
        children: [
          buildListTile(
            title: "Location Name",
            value: locationName,
          ),
          buildListTile(
            title: "Community",
            value: community,
          ),
          buildListTile(
            title: "Sub Community",
            value: subCommunity,
          ),
          buildListTile(
            title: "Building",
            value: building,
          ),
          buildListTile(
            title: "Spaces",
            value: spaces,
          ),
          buildListTile(
            title: "Prioriy",
            value: prioriy,
          ),
          buildListTile(
            title: "Discipline",
            value: discipline,
          ),
        ],
      ),
    );
  }

  Widget buildListTile({
    required String title,
    String? value,
  }) {
    return Visibility(
      visible: value != null,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w700,
            fontSize: 10.sp,
          ),
        ),
        trailing: ConstrainedBox(
          constraints: BoxConstraints.loose(Size.fromWidth(40.w)),
          child: Builder(builder: (context) {
            return Text(
              value ?? "N/A",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            );
          }),
        ),
      ),
    );
  }

  // ==== = = = = = = = = = = = = = = == = == = == == = == = = == = = =
  void buildChecklistBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "2 Checklists",
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.done),
                      title: Text("checklist $index"),
                    );
                  },
                  itemCount: 4,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // ========================================================================================
  Widget buildElevatedButtonWidget(
    BuildContext context, {
    required String? requestStatus,
    required FindServiceRequest? findServiceRequest,
    required bool customerSatisficationEnabled,
    required Future<QueryResult<dynamic>?> Function()? refetch,
  }) {
    // String requestType = findServiceRequest?.requestType ?? "";

    if (customerSatisficationEnabled
        // ||
        // requestType == "MOVE_IN" ||
        // requestType == "MOVE_OUT",
        ) {
      return const SizedBox();
    }

    String title = getButtonTitleAnKey(
            requestType: findServiceRequest?.requestType ?? "",
            isJob: findServiceRequest?.jobId != null,
            key: requestStatus ?? "",
            isManager: false)['title'] ??
        "";

    String key = getButtonTitleAnKey(
            requestType: findServiceRequest?.requestType ?? "",
            isJob: findServiceRequest?.jobId != null,
            key: requestStatus ?? "",
            isManager: false)['key'] ??
        "";

    if (key.isEmpty) {
      return const SizedBox();
    }

    if (key == "tenantopenactions") {
      if (!updatePermission) {
        tenantActionsList.removeWhere((element) => element['key'] == "edit");
      }

      if (!closePermission) {
        tenantActionsList.removeWhere((element) => element['key'] == "close");
      }

      if (tenantActionsList.isEmpty) {
        return const SizedBox();
      }
    }

    if (key == "feedback") {
      if (!ratePermission) {
        return const SizedBox();
      }
    }

    return Padding(
      padding: EdgeInsets.all(10.sp),
      child: BuildElevatedButton(
        onPressed: () async {
          if (key == "actions") {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => Container(
                decoration: const BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
                height: 40.h,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10.sp,
                    ),
                    // Spacer(),
                    ...List.generate(actionsList.length, (index) {
                      Map map = actionsList[index];
                      String title = map['title'];

                      IconData iconData = map['icon'];

                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: fwhite,
                              child: Icon(
                                iconData,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            title: Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                            onTap: () async {
                              String key = map['key'];

                              var navigator = Navigator.of(context);

                              navigator.pop();

                              // findServiceRequest?.

                              switch (key) {
                                case "assign":

                                  //  var serviceRequest = findServiceRequest;

                                  // await navigator.push(MaterialPageRoute(
                                  //   builder: (context) => AssignServiceScreen(
                                  //     jobRemark: findServiceRequest
                                  //         ?.requestDescription,
                                  //     requesteNumber: requestNumber,
                                  //     jobName: findServiceRequest
                                  //             ?.requestSubjectLine ??
                                  //         "",
                                  //     requesteeName:
                                  //         findServiceRequest?.requestee?.name ??
                                  //             "",
                                  //     building: findServiceRequest?.building,
                                  //     locationName: findServiceRequest
                                  //         ?.requestSourceLocationName,
                                  //   ),
                                  // ));

                                  // setState(() {});

                                  break;

                                // case "transfer":
                                //   navigator.push(MaterialPageRoute(
                                //     builder: (context) =>
                                //         TransferServiceScreen(),
                                //   ));
                                //   break;

                                case "close":
                                  bool? closed =
                                      await buildCloseRemarkBottomSheet(
                                    context: context,
                                    remarkController: remarkController,
                                    jobId: findServiceRequest?.jobId,
                                  );

                                  // setState(() {});
                                  if (closed ?? false) {
                                    refetch?.call();
                                  }

                                  break;

                                default:
                              }
                            },
                          ),
                          index == actionsList.length - 1
                              ? const SizedBox()
                              : const Divider(),
                        ],
                      );
                    })
                  ],
                ),
              ),
            );
          } else if (key == "tenantopenactions") {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => Container(
                decoration: const BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
                height: 40.h,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10.sp,
                    ),
                    // Spacer(),
                    ...List.generate(tenantActionsList.length, (index) {
                      Map map = tenantActionsList[index];
                      String title = map['title'];

                      IconData iconData = map['icon'];

                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: fwhite,
                              child: Icon(
                                iconData,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            title: Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                            onTap: () async {
                              String key = map['key'];

                              var navigator = Navigator.of(context);

                              navigator.pop();

                              switch (key) {
                                case "edit":
                                  var spaces = findServiceRequest?.spaces ?? [];

                                  var spacesData = spaces
                                      .map((e) =>
                                          SpaceData(name: e.name ?? "", data: {
                                            "type": e.type,
                                            "data": {
                                              "domain": e.domain,
                                              "identifier": e.identifier
                                            }
                                          }))
                                      .toList();

                                  String requestType =
                                      findServiceRequest?.requestType ?? "";

                                  String requestSubjectLine =
                                      findServiceRequest?.requestSubjectLine ??
                                          "";
                                  String requestDescription =
                                      findServiceRequest?.requestDescription ??
                                          "";

                                  var community = findServiceRequest?.community;

                                  var communityValue = community == null
                                      ? null
                                      : [
                                          {
                                            "name": community.clientName ?? '',
                                            "data": community.clientId ?? '',
                                          }
                                        ];

                                  var subCommunity =
                                      findServiceRequest?.subCommunity;

                                  var subCommunityValue = subCommunity == null
                                      ? null
                                      : [
                                          {
                                            "name": subCommunity.name,
                                            "data": {
                                              "data": {
                                                "domain": subCommunity.domain,
                                                "identifier":
                                                    subCommunity.identifier,
                                              },
                                              "type": subCommunity.type,
                                            },
                                          }
                                        ];

                                  var building = findServiceRequest?.building;

                                  var buildingValue = building == null
                                      ? null
                                      : [
                                          {
                                            "name": building.name,
                                            "data": {
                                              "data": {
                                                "domain": building.domain,
                                                "identifier":
                                                    building.identifier,
                                                "status": building.status,
                                                "typeName": building.type,
                                              },
                                              "type": building.type,
                                            }
                                          }
                                        ];

                                  var spacesValues = spacesData
                                      .map((e) => {
                                            "name": e.name,
                                            "data": e.data,
                                          })
                                      .toList();

                                  var spacesIdentifiers =
                                      spacesData.map((e) => e.data).toList();

                                  var resource = findServiceRequest?.resource;

                                  var resourceValue = resource == null
                                      ? null
                                      : [
                                          {
                                            "name": resource.displayName,
                                            "data": {
                                              "resourceId": resource.identifier,
                                              "domain": resource.domain,
                                            },
                                          }
                                        ];

                                  String? locationName = findServiceRequest
                                      ?.requestSourceLocationName;

                                  var locationValue = locationName == null
                                      ? null
                                      : [
                                          {
                                            "name": locationName,
                                            "data": locationName,
                                          },
                                        ];

                                  bool? edited = await navigator
                                      .pushNamed<dynamic>(
                                          CreateOrEditServiceRequestScreen.id,
                                          arguments: {
                                        "initialValues": [
                                          {
                                            "key": "requestType",
                                            "identifier": requestType,
                                            "values": [
                                              {
                                                "name":
                                                    requestType.toLowerCase(),
                                                "data": requestType,
                                              },
                                            ],
                                          },
                                          {
                                            "key": "requestSubjectLine",
                                            "identifier": requestSubjectLine,
                                            "values": [
                                              {
                                                "name": requestSubjectLine,
                                                "data": requestSubjectLine,
                                              }
                                            ],
                                          },
                                          {
                                            "key": "requestDescription",
                                            "identifier": requestDescription,
                                            "values": [
                                              {
                                                "name": requestDescription,
                                                "data": requestDescription,
                                              }
                                            ],
                                          },
                                          {
                                            "key": "requestSourceLocationName",
                                            "identifier": locationName,
                                            "values": locationValue,
                                          },
                                          {
                                            "key": "community",
                                            "identifier":
                                                communityValue?.first['data'],
                                            "values": communityValue,
                                          },
                                          {
                                            "key": "subCommunity",
                                            "identifier": subCommunityValue
                                                ?.first['data'],
                                            "values": subCommunityValue,
                                          },
                                          {
                                            "key": "building",
                                            "identifier":
                                                buildingValue?.first['data'],
                                            "values": buildingValue,
                                          },
                                          {
                                            "key": "spaces",
                                            "identifier": spacesIdentifiers,
                                            "values": spacesValues,
                                          },
                                          {
                                            "key": "resource",
                                            "identifier":
                                                resourceValue?.first['data'],
                                            "values": resourceValue,
                                          },
                                          {
                                            "key": "priority",
                                            "identifier":
                                                findServiceRequest?.priority,
                                            "values": [
                                              {
                                                "name": findServiceRequest
                                                    ?.priority,
                                                "data": findServiceRequest
                                                    ?.priority,
                                              }
                                            ],
                                          },
                                          {
                                            "key": "discipline",
                                            "identifier":
                                                findServiceRequest?.discipline,
                                            "values": [
                                              {
                                                "name": findServiceRequest
                                                    ?.discipline,
                                                "data": findServiceRequest
                                                    ?.discipline,
                                              }
                                            ],
                                          },
                                        ],
                                        "isEdit": true,
                                        "title":
                                            findServiceRequest?.requestType ??
                                                "",
                                        "requestType":
                                            findServiceRequest?.requestType ??
                                                "",
                                        "requestNumber":
                                            findServiceRequest?.requestNumber ??
                                                "",
                                        "requestee": {
                                          "id":
                                              findServiceRequest?.requestee?.id
                                        },
                                        "name": findServiceRequest
                                                ?.requestSubjectLine ??
                                            "",
                                        "description": findServiceRequest
                                                ?.requestDescription ??
                                            "",
                                        "site": findServiceRequest?.building ==
                                                null
                                            ? null
                                            : {
                                                "type": findServiceRequest
                                                    ?.building?.type,
                                                "data": {
                                                  "identifier":
                                                      findServiceRequest
                                                          ?.building
                                                          ?.identifier,
                                                  "domain": findServiceRequest
                                                      ?.building?.domain,
                                                  "status": findServiceRequest
                                                      ?.building?.status
                                                }
                                              },
                                        "spaces": spacesData,
                                        "siteName": findServiceRequest
                                                ?.building?.name ??
                                            "",
                                        "buildingType":
                                            findServiceRequest?.building?.type,
                                        "location": findServiceRequest
                                                ?.building?.geoLocation ??
                                            "",
                                        "requestSourceLocationName":
                                            findServiceRequest
                                                ?.requestSourceLocationName,
                                      });

                                  if (edited ?? false) {
                                    refetch?.call();
                                  }

                                  break;

                                // case "transfer":
                                //   navigator.push(MaterialPageRoute(
                                //     builder: (context) =>
                                //         TransferServiceScreen(),
                                //   ));
                                //   break;

                                case "close":
                                  // ignore: use_build_context_synchronously
                                  bool? closed =
                                      await buildCloseRemarkBottomSheet(
                                    context: context,
                                    remarkController: remarkController,
                                    jobId: findServiceRequest?.jobId,
                                  );

                                  if (closed ?? false) {
                                    refetch?.call();
                                  }

                                  break;

                                default:
                              }
                            },
                          ),
                          index == actionsList.length - 1
                              ? const SizedBox()
                              : const Divider(),
                        ],
                      );
                    })
                  ],
                ),
              ),
            );
          } else if (key == "feedback") {
            bool? saved = await showModalBottomSheet<bool>(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) {
                return Container(
                  decoration: const BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          "Customer Satisfaction",
                          style: TextStyle(
                            fontSize: 15.sp,
                          ),
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        StatefulBuilder(
                          builder: (context, setState) => RatingStars(
                            value: ratingValue,
                            valueLabelVisibility: false,
                            starSize: 50,
                            starColor: Theme.of(context).primaryColor,
                            onValueChanged: (value) {
                              setState(
                                () {
                                  ratingValue = value;
                                },
                              );
                            },
                          ),
                        ),
                        const Spacer(),
                        MutationWidget(
                          options: GrapghQlClientServices().getMutateOptions(
                            context: context,
                            document: ServiceRequestSchemas
                                .updateCustomerSatisfactionMutation,
                            variables: {
                              "requestNumber": requestNumber,
                              "rating": ratingValue.toInt(),
                            },
                            onCompleted: (data) {
                              if (data == null) {
                                Navigator.of(context).pop(false);

                                buildSnackBar(
                                    context: context,
                                    value:
                                        "Something went wrong. Please try again");
                                return;
                              }

                              Navigator.of(context).pop(true);
                            },
                          ),
                          builder: (runMutation, result) {
                            return BuildElevatedButton(
                              isLoading: result?.isLoading ?? false,
                              onPressed: () async {
                                runMutation(
                                  {
                                    "requestNumber": requestNumber,
                                    "rating": ratingValue.toInt(),
                                  },
                                );
                              },
                              title: "Save",
                            );
                          },
                        ),
                        SizedBox(
                          height: 15.sp,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );

            saved ??= false;
            if (saved) {
              refetch?.call();
            }
          } else if (key == "close") {
            bool? closed = await buildCloseRemarkBottomSheet(
              context: context,
              remarkController: remarkController,
              jobId: findServiceRequest?.jobId,
            );

            if (closed ?? false) {
              refetch?.call();
            }
          }
        },
        title: title,
      ),
    );
  }

  // ========================  == = == = == == = = == = == = == = == = ==
  Future<bool?> buildCloseRemarkBottomSheet({
    required BuildContext context,
    required TextEditingController remarkController,
    required int? jobId,
  }) async {
    return await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      // isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(5.sp),
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                buildLabelWithTextfieldWidget(
                  title: "Remark",
                  textEditingController: remarkController,
                  hintText: "Closing Remark",
                  enabelRequiredText: false,
                  maxLines: 3,
                ),
                SizedBox(
                  height: 5.sp,
                ),
                MutationWidget(
                    options: GrapghQlClientServices().getMutateOptions(
                      context: context,
                      document: jobId != null
                          ? JobsSchemas.jobStatusUpdate
                          : ServiceRequestSchemas.closeServiceRequestMutation,
                      onCompleted: (data) {
                        if (data == null) {
                          return;
                        }

                        if (jobId != null) {
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop(true);
                          // .pushReplacementNamed(HomeScreen.id);
                          return;
                        }

                        if (data['closeServiceRequest'] == null) {
                          // ignore: use_build_context_synchronously
                          buildSnackBar(
                            context: context,
                            value: "Something went wrong. Please try again.",
                          );
                          Navigator.of(context).pop();

                          return;
                        }

                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop(true);
                        // .pushReplacementNamed(HomeScreen.id);
                      },
                    ),
                    builder: (runMutation, result) {
                      return BuildElevatedButton(
                        isLoading: result?.isLoading ?? false,
                        onPressed: () async {
                          // Navigator.of(context).pop();

                          if (jobId != null) {
                            runMutation(
                              {
                                "id": jobId,
                                "statusData": {
                                  "statusTime":
                                      DateTime.now().millisecondsSinceEpoch,
                                  "status": "CLOSED",
                                }
                              },
                            );

                            return;
                          }

                          runMutation(
                            {
                              "requestNumber": requestNumber,
                              "remark": remarkController.text.trim(),
                            },
                          );
                        },
                        title: "Close",
                      );
                    }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================================================================================
  Widget buildAttachmentsWidget(
      {required BuildContext context, required Map<String, dynamic> payload}) {
    return QueryWidget(
      options: GraphqlServices().getQueryOptions(
          query: ServiceRequestSchemas.getAllFilesFromSamePathQuery,
          variables: payload),
      builder: (result, {fetchMore, refetch}) {
        if (result.isLoading) {
          return buildLoadingPhotosWidget();
        }

        if (result.hasException) {
          return GraphqlServices().handlingGraphqlExceptions(
            result: result,
            context: context,
            refetch: refetch,
          );
        }

        List list = result.data?['getAllFilesFromSamePath']['data'] ?? [];

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 5.sp),
          child: SizedBox(
            height: 15.h,
            child: ListView.separated(
              itemCount: list.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) {
                return SizedBox(
                  width: 10.sp,
                );
              },
              itemBuilder: (context, index) {
                Map map = list[index];

                String fileName = map['fileName'];

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FilesViewerWithSwipeScreen(
                        items: list,
                        initilaIndex: index,
                        enableCommentFeature: false,
                        internetAvailable: true,
                      ),
                    ));
                  },
                  child: Hero(
                    tag: fileName,
                    child: Builder(
                      builder: (context) {
                        String fileName = map['fileName'];

                        String extension = path.extension(fileName);

                        if (extension == ".jpeg" ||
                            extension == ".png" ||
                            extension == ".jpg") {
                          var memoryImageData = base64Decode(map['data']);

                          return Container(
                            decoration: BoxDecoration(
                              color: fwhite,
                              borderRadius: BorderRadius.circular(5),
                              image: DecorationImage(
                                image: MemoryImage(memoryImageData),
                                fit: BoxFit.cover,
                              ),
                            ),
                            height: 10.h,
                            width: 30.w,
                          );
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: fwhite,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          height: 10.h,
                          width: 30.w,
                          child: Center(
                            child: getFileWidget(extension),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Padding buildLoadingPhotosWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.sp),
      child: SizedBox(
        height: 15.h,
        child: ListView.separated(
          itemCount: 2,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, index) {
            return SizedBox(
              width: 10.sp,
            );
          },
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: fwhite,
                borderRadius: BorderRadius.circular(5),
              ),
              height: 10.h,
              width: 30.w,
            );
          },
        ),
      ),
    );
  }

  // =================================================================
//  Showing the details tile of service request.

  Column buildLabelWithTileWidget({
    required String label,
    String title = "",
    void Function()? onTap,
    List<Widget> children = const [],
    bool showTrailingIcon = true,
  }) {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabelWidget(label: label),
        children.isEmpty && label.isEmpty
            ? const Text('N/A')
            : GestureDetector(
                onTap: onTap,
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10.sp,
                      ),
                      Visibility(
                        visible: title.isNotEmpty,
                        child: Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                          visible: children.isNotEmpty,
                          child: Column(
                            children: children,
                          )),
                      Visibility(
                        visible: showTrailingIcon,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 12.sp,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )
                    ],
                  ),
                ),
              ),
        SizedBox(
          height: 15.sp,
        ),
      ],
    );
  }

  // ===========================================================================
  Widget buildLabelWidget({required String label}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.sp),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ===========================================================
  Widget buildHeaderCard({
    required String title,
    required String subTitle,
    required String status,
    required String requestType,
    required String formatedDate,
    required FindServiceRequest? findServiceRequest,
  }) {
    Color statusColor = getStatusColor(status);
    Color? textColor = getStatusTextColor(status);

    if (requestType == "MOVE_OUT") {
      requestType = "MOVE OUT";
    } else if (requestType == "MOVE_IN") {
      requestType = "MOVE IN";
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 5.sp,
              ),
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 3.sp, horizontal: 5.sp),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Builder(builder: (context) {
                      if (requestType == "MOVE IN" ||
                          requestType == "MOVE OUT") {
                        if (status == "COMPLETED") {
                          status = "APPROVED";
                        } else if (status == "CANCELLED") {
                          status = "REJECTED";
                        }
                      }

                      return Text(
                        status,
                        style: TextStyle(
                          color: textColor,
                        ),
                      );
                    }),
                  ),
                  SizedBox(
                    width: 10.sp,
                  ),
                  Builder(builder: (context) {
                    return Text(
                      requestType,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(
                height: 5.sp,
              ),
              Text(
                title,
                style: TextStyle(
                  // color: primaryColor,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Builder(builder: (context) {
                if (requestType == "MOVE IN" || requestType == "MOVE OUT") {
                  return Column(
                    children: [
                      SizedBox(
                        height: 3.sp,
                      ),
                      Text(
                        "${findServiceRequest?.community?.clientName ?? "No client"} - ${findServiceRequest?.subCommunity?.name ?? "No subcommunity"} - ${findServiceRequest?.building?.name ?? "No building"} - ${findServiceRequest?.spaces?[0].name ?? "No apartment"}",
                        style: const TextStyle(
                          color: Colors.black54,
                          // fontSize: 11.sp,
                          // fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  );
                }

                return Visibility(
                  visible: subTitle.isNotEmpty,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 3.sp,
                      ),
                      Text(
                        subTitle,
                        style: const TextStyle(
                          color: Colors.black54,
                          // fontSize: 11.sp,
                          // fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(
                height: 10.sp,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.all(5.sp),
                      child: Text(
                        findServiceRequest?.serviceTicketNumber ?? "N/A",
                        style: TextStyle(
                          color: kWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ),
                  // const Spacer(),
                  SizedBox(
                    width: 10.sp,
                  ),
                  Text(
                    formatedDate,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

//  ================================================================================
  Map<String, dynamic> getButtonTitleAnKey({
    required String key,
    required bool isManager,
    required bool isJob,
    required String requestType,
  }) {
    switch (key) {
      case "OPEN":
        if (isJob) {
          return {
            // "title": "Close",
            // "key": "close",
          };
        }

        if (requestType == "MOVE_IN" || requestType == "MOVE_OUT") {
          if (isManager) {
            return {
              "title": "Actions",
              "key": "moveinactions",
            };
          } else {
            return {};
          }
        }

        return isManager
            ? {
                "title": "Actions",
                "key": "actions",
              }
            : {
                "title": "Actions",
                "key": "tenantopenactions",
              };

      case "COMPLETED":
        if (requestType == "MOVE_IN" || requestType == "MOVE_OUT") {
          if (isManager) {
            return {};
          } else {
            if (requestType == "MOVE_OUT") {
              return {
                "title": "Moved Out",
                "key": "movedout",
              };
            }

            return {
              "title": "Moved In",
              "key": "movedin",
            };
          }
        }

        return isManager
            ? {
                "title": "Close",
                "key": "close",
              }
            : {};

      case "CLOSED":
        if (requestType == "MOVE_IN") {
          if (!isManager) {
            return {
              // "title": "Move Out",
              // "key": "moveout",
            };
          }
          return {};
        } else if (requestType == "MOVE_OUT") {
          if (isManager) {
            return {};
          }
          return {
            "title": "Moved Out",
            "key": "movedout",
          };
        }

        return isManager
            ? {}
            : {
                "title": "Customer Feedback",
                "key": "feedback",
              };

      default:
        return {};
    }
  }

// ====================================================================================

  Widget getFileWidget(String key) {
    double size = double.infinity;

    switch (key) {
      case ".xls":
        return Image.asset(
          "assets/images/xls.png",
          height: size,
          width: size,
          // scale: size,
        );

      case ".pdf":
        return Image.asset(
          "assets/images/pdf.png",
          height: size,
          width: size,
        );

      default:
        return Image.asset(
          "assets/images/unknown-file.png",
          height: size,
          width: size,
          // scale: size,
        );
    }
  }
}

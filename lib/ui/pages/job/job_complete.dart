import 'dart:convert';
import 'dart:io';
import 'package:awesometicks/core/blocs/job_details/job_details_bloc.dart';
import 'package:awesometicks/core/blocs/travel_time_bloc/travel_time_bloc.dart';
import 'package:awesometicks/core/models/assets/asset_info_model.dart';
import 'package:awesometicks/core/models/hive%20db/syncing_local_db.dart';
import 'package:awesometicks/core/schemas/assets_schemas.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/core/services/jobs/jobs_action_service.dart';
import 'package:awesometicks/core/services/jobs/jobs_complete_services.dart';
import 'package:awesometicks/core/services/platform_services.dart';
import 'package:awesometicks/ui/pages/job/functions/format_duration.dart';
import 'package:awesometicks/ui/pages/job/widgets/build_label_textfield.dart';
import 'package:awesometicks/ui/shared/widgets/build_elvetad_button.dart';
import 'package:awesometicks/ui/shared/widgets/custom_app_bar.dart';
import 'package:awesometicks/ui/shared/widgets/custom_snackbar.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_config/services/notifications/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_config/widget/mutation_widget.dart';
import 'package:hive/hive.dart';

// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:signature/signature.dart';
import 'package:sizer/sizer.dart';

// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:track_location/track_location.dart';
import 'package:user_permission/widgets/permission_checking_widget.dart';
import '../../../core/blocs/job controller/job_controller_bloc_bloc.dart';
import '../../../core/models/hive db/list_jobs_model.dart';
import 'package:graphql_config/graphql_config.dart';
import '../../../core/services/jobs/jobs_services.dart';

// ignore: must_be_immutable
class JobCompleteScreen extends StatelessWidget {
  JobCompleteScreen({
    required this.jobName,
    required this.jobStartTime,
    required this.assetAttached,
    required this.jobId,
    required this.assetName,
    // required this.jobEndTime,
    required this.jobControllerBloc,
    required this.duration,
    required this.jobDomain,
    required this.assigneeId,
    required this.teamMembers,
    required this.assetEntity,
    required this.travelTimeBloc,
    required this.jobDetailsBloc,
    super.key,
  });

  final int jobStartTime;
  final List<dynamic> teamMembers;
  final int? assigneeId;
  final int jobId;
  final String jobName;
  final int duration;
  final String jobDomain;
  final String assetName;
  final JobControllerBlocBloc jobControllerBloc;
  final TravelTimeBloc travelTimeBloc;
  final Map<String, dynamic>? assetEntity;
  final JobDetailsBloc jobDetailsBloc;

  final TextEditingController remarkController = TextEditingController();
  final TextEditingController odoMeterController = TextEditingController();
  final TextEditingController runhoursMeterController = TextEditingController();
  final TextEditingController technicianNameController =
      TextEditingController();
  final TextEditingController clientNameController = TextEditingController();

  final bool assetAttached;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final SignatureController technicianSignatureController = SignatureController(
    penStrokeWidth: 3,
    exportBackgroundColor: Colors.transparent,
  );

  final SignatureController requesteeSignatureController = SignatureController(
    penStrokeWidth: 3,
    exportBackgroundColor: Colors.transparent,
  );

  int jobEndTime = DateTime.now().millisecondsSinceEpoch;

  final UserDataSingleton userData = UserDataSingleton();

  ValueNotifier<bool> saveButtonLoadingNotifier = ValueNotifier<bool>(false);

  final ValueNotifier<List<Map<String, dynamic>>> additionalMembersNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  TrackLocation trackLocation = TrackLocation();

  @override
  Widget build(BuildContext context) {
    technicianNameController.text = userData.displayName;

    return Scaffold(
        backgroundColor: kWhite,
        appBar: const GradientAppBar(
          title: "Complete Job",
        ),
        body: PermissionChecking(
          featureGroup: "jobManagement",
          feature: "job",
          permission: "completeJob",
          showNoAccessWidget: true,
          paddingTop: 10.sp,
          child: Padding(
            padding: EdgeInsets.all(10.sp),
            child: FutureBuilder(
                future: Connectivity().checkConnectivity(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }

                  // ConnectivityResult connectivityResult = snapshot.data!;

                  // bool noInternet = connectivityResult == ConnectivityResult.none;

                  return Column(
                    children: [
                      Expanded(
                        child: Form(
                          key: formKey,
                          child: ListView(
                            children: [
                              buildLabelandData(
                                title: "Job Name",
                                value: jobName,
                              ),
                              buildLabelandData(
                                title: "Asset",
                                value: assetName.isEmpty
                                    ? "Asset not attached"
                                    : assetName,
                              ),
                              buildLabelandData(
                                title: " Job StartTime",
                                value: jobStartTime == 0
                                    ? "N/A"
                                    : DateFormat("MMMM dd yyyy")
                                        .add_jm()
                                        .format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                            jobStartTime,
                                          ),
                                        ),
                              ),
                              StatefulBuilder(
                                builder: (context, setState) {
                                  return Column(
                                    children: [
                                      buildJobEndtimeWidget(context, setState),
                                      Builder(
                                        builder: (context) {
                                          DateTime startTime = DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  jobStartTime);

                                          DateTime endTime = DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  jobEndTime);

                                          Duration duration =
                                              endTime.difference(startTime);

                                          return buildLabelandData(
                                            title: "Job Duration",
                                            value: formatDuration(duration),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                              buildAdditionalMembers(context),
                              Builder(builder: (context) {
                                bool enable = assetAttached &&
                                    JobCompleteServices()
                                        .checkRunHoursMandatory();

                                return Visibility(
                                  visible: assetAttached,
                                  child: QueryWidget(
                                      options: GraphqlServices()
                                          .getQueryOptions(
                                              query:
                                                  AssetSchema.findAssetSchema,
                                              variables: {
                                            "identifier":
                                                assetEntity?['identifier'],
                                            "type": assetEntity?['type'],
                                            'domain': assetEntity?['domain'],
                                          }),
                                      builder: (result, {fetchMore, refetch}) {
                                        if (result.isLoading) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              buildLabelWidget(
                                                title:
                                                    "Run Hours meter reading",
                                                enableRequiredText: false,
                                              ),
                                              ShimmerLoadingContainerWidget(
                                                  height: 35.sp),
                                              SizedBox(
                                                height: 7.sp,
                                              ),
                                            ],
                                          );
                                        }

                                        if (result.hasException) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              buildLabelWidget(
                                                title:
                                                    "Run Hours meter reading",
                                                enableRequiredText: false,
                                              ),
                                              GraphqlServices()
                                                  .handlingGraphqlExceptions(
                                                result: result,
                                                context: context,
                                                refetch: refetch,
                                              ),
                                              SizedBox(
                                                height: 7.sp,
                                              ),
                                            ],
                                          );
                                        }

                                        AssetInfoModel assetInfoModel =
                                            assetInfoModelFromJson(
                                                result.data ?? {});

                                        bool isAttachment =
                                            assetInfoModel.findAsset?.parent ==
                                                "Attachment";

                                        return buildLabelWithTextfieldWidget(
                                          title: "Run Hours meter reading",
                                          textEditingController:
                                              runhoursMeterController,
                                          hintText: "Run Hours (In km)",
                                          enabelRequiredText:
                                              enable && !isAttachment,
                                          enableValidator:
                                              enable && !isAttachment,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                        );
                                      }),
                                );
                              }),
                              buildLabelWithTextfieldWidget(
                                title: "Completion Remark",
                                textEditingController: remarkController,
                                hintText: "Enter completion Remark",
                                maxLines: 3,
                              ),
                              buildLabelWithTextfieldWidget(
                                title: "Technician Name",
                                textEditingController: technicianNameController,
                                hintText: "Name",
                                enabelRequiredText: false,
                                enableValidator: false,
                              ),
                              buildSignatureWidget(
                                technicianSignatureController,
                              ),
                              buildLabelWithTextfieldWidget(
                                title: "Client Name",
                                textEditingController: clientNameController,
                                hintText: "Name",
                                enabelRequiredText: false,
                                enableValidator: false,
                              ),
                              buildSignatureWidget(requesteeSignatureController)
                            ],
                          ),
                        ),
                      ),
                      buildElevatedButton(context),
                      SizedBox(
                        height: 5.sp,
                      ),
                    ],
                  );
                }),
          ),
        ));
  }

  Widget buildAdditionalMembers(BuildContext context) {
    if (teamMembers.isNotEmpty) {
      return buildLabelandData(
        title: "Additional Members",
        value: teamMembers.map((e) => e['assignee']?['name'] ?? "").join(', '),
      );
    }

    return GestureDetector(
      onTap: () async {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            // backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(7),
              ),
            ),
            builder: (context) {
              return SizedBox(
                  height: 70.h,
                  child: Builder(builder: (context) {
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            "Additional Members",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const Divider(
                          height: 0,
                        ),
                        Expanded(
                          child: QueryWidget(
                              options: GraphqlServices().getQueryOptions(
                                rereadPolicy: true,
                                query: JobsSchemas.listAllAssigneesUnPaged,
                                variables: {
                                  "domain": userData.domain,
                                  "type": "Mechanic"
                                },
                              ),
                              builder: (result, {fetchMore, refetch}) {
                                if (result.isLoading) {
                                  return BuildShimmerLoadingWidget(
                                    height: 30.sp,
                                  );
                                }

                                if (result.hasException) {
                                  return GraphqlServices()
                                      .handlingGraphqlExceptions(
                                    result: result,
                                    context: context,
                                    refetch: refetch,
                                  );
                                }

                                List list =
                                    result.data?['listAllAssigneesUnPaged']
                                            ?['items'] ??
                                        [];

                                list = list.where((e) {
                                  return e['id'] != assigneeId;
                                }).toList();

                                return ValueListenableBuilder(
                                    valueListenable: additionalMembersNotifier,
                                    builder: (context, values, _) {
                                      return ListView.builder(
                                        itemBuilder: (context, index) {
                                          Map<String, dynamic> map =
                                              list[index];

                                          String emailId = map['emailId'] ?? "";
                                          String contactNumber =
                                              map['contactNumber'] ?? "";

                                          bool check = values.any((element) =>
                                              element['id'] ==
                                              list[index]['id']);

                                          return CheckboxListTile(
                                            value: check,
                                            title: Text(map['name'] ?? ""),
                                            subtitle: Text([
                                              emailId,
                                              contactNumber
                                            ]
                                                .where((element) =>
                                                    element.isNotEmpty)
                                                .join(' - ')),
                                            activeColor:
                                                Theme.of(context).primaryColor,
                                            onChanged: (value) {
                                              try {
                                                if (value == null) {
                                                  return;
                                                }

                                                List newList =
                                                    List.from(values);
                                                if (value) {
                                                  newList.add(list[index]);
                                                } else {
                                                  newList.removeWhere(
                                                    (element) =>
                                                        element["id"] ==
                                                        list[index]['id'],
                                                  );
                                                }

                                                additionalMembersNotifier
                                                    .value = List.from(newList);
                                              } catch (e) {}
                                            },
                                          );
                                        },
                                        itemCount: list.length,
                                      );
                                    });
                              }),
                        )
                      ],
                    );
                  }));
            });
      },
      child: ValueListenableBuilder(
          valueListenable: additionalMembersNotifier,
          builder: (context, value, child) {
            String members = value.map((e) => e['name']).join(', ');

            return buildLabelandData(
              title: "Additional Members",
              textColor: members.isEmpty ? Colors.grey : null,
              value: members.isEmpty
                  ? "Select Additional Members"
                  : value.map((e) => e['name']).join(', '),
            );
          }),
    );
  }

  Column buildSignatureWidget(SignatureController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabelWidget(title: "Signature", enableRequiredText: false),
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Signature(
            controller: controller,
            height: 25.h,
            backgroundColor: Colors.blue.shade50,
            // dynamicPressureSupported: true,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                controller.undo();
              },
              icon: const Icon(
                Icons.undo,
              ),
            ),
            IconButton(
              onPressed: () {
                controller.redo();
              },
              icon: const Icon(
                Icons.redo,
              ),
            ),
            IconButton(
              onPressed: () {
                controller.clear();
              },
              icon: const Icon(
                Icons.clear,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ========================================================================
  // ========================================================================

  Column buildJobEndtimeWidget(
    BuildContext context,
    StateSetter setState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabelWidget(
          title: "Job EndTime",
          enableRequiredText: false,
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
            color: fwhite,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  jobEndTime == 0
                      ? "N/A"
                      : DateFormat("MMMM dd yyyy").add_jm().format(
                            DateTime.fromMillisecondsSinceEpoch(
                              jobEndTime,
                            ),
                          ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.fromMillisecondsSinceEpoch(jobStartTime),
                    firstDate:
                        DateTime.fromMillisecondsSinceEpoch(jobStartTime),
                    lastDate: DateTime(2100),
                  );

                  if (date != null) {
                    // ignore: use_build_context_synchronously
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (time != null) {
                      DateTime selectedDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );

                      bool valid = selectedDateTime.isAfter(
                          DateTime.fromMillisecondsSinceEpoch(jobStartTime));
                      // validateTime(time);

                      if (!valid) {
                        // ignore: use_build_context_synchronously
                        PlatformServices().showPlatformAlertDialog(
                          context,
                          title: "Alert",
                          message:
                              "Invalid End Time. Should be after Start Time",
                        );
                        return;
                      }

                      setState(
                        () {
                          jobEndTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          ).millisecondsSinceEpoch;
                        },
                      );
                    }
                  }
                },
                child: const Icon(
                  Icons.date_range,
                  // size: 10.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 7.sp,
        ),
      ],
    );
  }

  // ===========================================================================
  // Build label and data.

  Widget buildLabelandData({
    required String title,
    required String value,
    Color? textColor,
    bool enableRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabelWidget(
          title: title,
          enableRequiredText: enableRequired,
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
            color: fwhite,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 7.sp,
        ),
      ],
    );
  }

  // =======================================================================
  // Button widget.

  Widget buildElevatedButton(BuildContext context) {
    return MutationWidget(
        options: GrapghQlClientServices().getMutateOptions(
          context: context,
          document: JobsSchemas.jobCompleteMutation,
          onCompleted: (data) async {
            if (data == null) {
              saveButtonLoadingNotifier.value = false;

              return;
            }

            if (data['jobComplete'] == null) {
              saveButtonLoadingNotifier.value = false;

              // ignore: use_build_context_synchronously
              buildSnackBar(
                  context: context, value: "Something went wrong try again");

              return;
            }

            buildSnackBar(
              context: context,
              value: "Job completed successfully",
            );
            
            
            //Refer Jobs Services file. This id is used for cancelling the notification because the same is used for scheduling the notification.
            final completedNotificationId = (jobId) * 10 + 2;

            //==================================================================
            //Cancels the scheduled Job complete Notification for this job
            NotificationService()
                .cancelScheduledNotfication(completedNotificationId);
            if (technicianSignatureController.isNotEmpty) {
              var bytes = await technicianSignatureController.toPngBytes();

              final directory = await getApplicationDocumentsDirectory();

              File file =
                  await File("${directory.path}/technician-signature.png")
                      .writeAsBytes(bytes!);

              // ignore: use_build_context_synchronously
              await JobsServices().attachFiles(
                attachedFile: file,
                filePath: "jobs/$jobDomain/$jobId/hidden/signature/technician",
                context: context,
              );

              await file.delete(recursive: true);
            }

            if (requesteeSignatureController.isNotEmpty) {
              var bytes = await requesteeSignatureController.toPngBytes();

              final directory = await getApplicationDocumentsDirectory();

              File file =
                  await File("${directory.path}/requestee-signature.png")
                      .writeAsBytes(bytes!);

              // ignore: use_build_context_synchronously
              await JobsServices().attachFiles(
                attachedFile: file,
                filePath: "jobs/$jobDomain/$jobId/hidden/signature/requestee",
                context: context,
              );

              await file.delete(recursive: true);
            }

            jobDetailsBloc.add(FetchJobDetailDataEvent(jobId: jobId));

            jobControllerBloc.add(ChangeJobTimeEvent(
              actualEndTime: jobEndTime,
              actualStartTime: jobStartTime,
            ));

            JobsActionService.callTravelTimeSheetApi(
                travelTimeBloc: travelTimeBloc, jobId: jobId);

            saveButtonLoadingNotifier.value = false;

            // ignore: use_build_context_synchronously
            Navigator.of(context).pop(true);
          },
        ),
        builder: (runMutation, result) {
          return ValueListenableBuilder(
              valueListenable: saveButtonLoadingNotifier,
              builder: (context, isLoading, _) {
                // bool isLoading =
                //  result?.isLoading ?? false;

                return BuildElevatedButton(
                  isLoading: isLoading,
                  title: "Save",
                  onPressed: () async {
                    bool isValid = formKey.currentState!.validate();

                    var locationMap = await trackLocation
                        .getCurrentLocationAndLocationName(context);

                    if (isValid) {
                      Map<String, dynamic> variables = {
                        "id": jobId,
                        "data": {
                          "signedTechnician":
                              technicianNameController.text.trim(),
                          "signedClient": clientNameController.text.trim(),
                          "jobRemark": remarkController.text.trim(),
                          "jobStartTime": jobStartTime,
                          "jobEndTime": jobEndTime,
                          "statusLocation": locationMap['location'],
                          "statusLocationName": locationMap['locationName'],
                        }
                      };

                      saveButtonLoadingNotifier.value = true;

                      if (odoMeterController.text.isNotEmpty) {
                        variables['data']['odometer'] =
                            int.parse(odoMeterController.text.trim());
                      }

                      if (runhoursMeterController.text.isNotEmpty) {
                        variables['data']['runhours'] =
                            int.parse(runhoursMeterController.text.trim());
                      }

                      ConnectivityResult connectivityResult =
                          await Connectivity().checkConnectivity();

                      bool noInternet =
                          connectivityResult == ConnectivityResult.none;

                      if (noInternet) {
                        Box<SyncingLocalDb> box = syncdbgetBox();
                        Box<JobDetailsDb> jobBox = jobDetailsDbgetBox();

                        var technicianSignature =
                            await technicianSignatureController.toPngBytes();
                        var requesteeSignature =
                            await requesteeSignatureController.toPngBytes();

                        String technicianFilePath =
                            "jobs/$jobDomain/$jobId/hidden/signature/technician";
                        String requesteeFilePath =
                            "jobs/$jobDomain/$jobId/hidden/signature/requestee";

                        box.add(
                          SyncingLocalDb(
                            payload: {
                              "data": variables,
                              "signatures": {
                                "technician": technicianSignature == null
                                    ? null
                                    : {
                                        "data":
                                            base64Encode(technicianSignature),
                                        "filePath": technicianFilePath,
                                      },
                                "client": requesteeSignature == null
                                    ? null
                                    : {
                                        "data":
                                            base64Encode(requesteeSignature),
                                        "filePath": requesteeFilePath,
                                      },
                              }
                            },
                            generatedTime:
                                DateTime.now().millisecondsSinceEpoch,
                            graphqlMethod: JobsSchemas.jobCompleteMutation,
                          ),
                        );

                        JobDetailsDb? jobDetailsDb = jobBox.values
                            .singleWhereOrNull(
                                (element) => element.id == jobId);

                        if (jobDetailsDb != null) {
                          jobDetailsDb.status = "COMPLETED";

                          jobDetailsDb.signedClient =
                              clientNameController.text.trim();

                          jobDetailsDb.signedTechnician =
                              technicianNameController.text.trim();

                          jobDetailsDb.actualStartTime = jobStartTime;
                          jobDetailsDb.actualEndTime = jobEndTime;

                          int index = jobBox.values.toList().indexWhere(
                                (element) => element.id == jobId,
                              );

                          jobBox.putAt(index, jobDetailsDb);

                          jobDetailsDb.transitions?.add({
                            "time": DateTime.now().millisecondsSinceEpoch,
                            "status": "COMPLETED",
                            "comment": remarkController.text.trim(),
                          });

                          jobControllerBloc.add(ChangeJobTimeEvent(
                            actualEndTime: jobEndTime,
                            actualStartTime: jobStartTime,
                          ));
                        }

                        saveButtonLoadingNotifier.value = false;

                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop(true);

                        return;
                      }

                      if (teamMembers.isEmpty) {
                        List teamMembersIds = additionalMembersNotifier.value
                            .map((e) => e['id'])
                            .toList();

                        if (teamMembersIds.isNotEmpty) {
                          variables['data']['teamMembers'] = teamMembersIds;
                        }
                      }

                      runMutation(variables);
                    }
                  },
                );
              });
        });
  }

  bool validateTime(TimeOfDay time) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(jobStartTime);

    final TimeOfDay minTime = TimeOfDay(hour: time.hour, minute: time.minute);

    return time.hour >= minTime.hour && time.minute >= minTime.minute;
  }
}

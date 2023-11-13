import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/app/modules/pa/navadmin/views/navadmin_view.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../../../presentation/theme.dart';
import '../../../../../../util/empty_screen.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../../../../../routes/app_pages.dart';
import '../controllers/trainingtypecc_controller.dart';


class TrainingtypeccView extends StatefulWidget {
  TrainingtypeccView({Key? key}) : super(key: key);

  @override
  _TrainingtypeccViewState createState() => _TrainingtypeccViewState();
}

class _TrainingtypeccViewState extends State<TrainingtypeccView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final _formPendingKey = GlobalKey<FormState>();
  final _formConfirmationKey = GlobalKey<FormState>();
  final _formDoneKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    TrainingtypeccController controller = Get.find<TrainingtypeccController>();
    var fromPendingC = TextEditingController();
    var toPendingC = TextEditingController();

    var fromConfirmationC = TextEditingController();
    var toConfirmationC = TextEditingController();

    var fromDoneC = TextEditingController();
    var toDoneC = TextEditingController();


    Future<bool> onWillPop() async {
      controller.resetDate();
      return true;
    }

    return WillPopScope( onWillPop: onWillPop , child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.to(()=>NavadminView(initialIndex: 1,));
            controller.resetDate();
          },
        ),
        title: RedTitleText(text: "TRAINING"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 8,
                  child: RedTitleText(text: controller.argumentname.value),
                ),
                Expanded(
                  flex: 1,
                  child: PopupMenuButton(
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                            child: TextButton(
                              onPressed: () async {
                                await Get.toNamed(Routes.ADD_ATTENDANCECC, arguments: {
                                  "id" : controller.argumentid.value,
                                  "name" : controller.argumentname.value
                                });
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.add, size: 16, color: Colors.black,),
                                  SizedBox(width: 5,),
                                  Text("Add Attendance", style: tsOneTextTheme.labelMedium,)
                                ],
                              ),
                            )
                        ),
                        PopupMenuItem(
                          child: TextButton(
                            onPressed: () async {
                              await QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.confirm,
                                  text: 'Do you want to delete training',
                                  confirmBtnText: 'Yes',
                                  cancelBtnText: 'No',
                                  confirmBtnColor: Colors.green,
                                  onConfirmBtnTap: () async {
                                    await controller.deleteTraining();
                                    Navigator.of(context).pop();
                                  }
                              );
                            },
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: Colors.black,),
                                SizedBox(width: 5,),
                                Text("Delete", style: tsOneTextTheme.labelMedium,)
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                    offset: Offset(0, 30),
                    child: GestureDetector(
                      child: Container(
                        child: Icon(Icons.more_vert_outlined),
                      ),
                    ),
                  ),
                ),

              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: TabBar(
                labelPadding: EdgeInsets.symmetric(horizontal: 1.0),
                indicatorColor: TsOneColor.primary,
                indicatorWeight: 3,
                labelColor: TsOneColor.primary,
                unselectedLabelColor: TsOneColor.secondaryContainer,
                controller: _tabController,
                tabs: [
                  Tab(text: "Pending"),
                  Tab(text: "Confirmation"),
                  Tab(text: "Done",)
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Obx(() =>  Column(
                    children: [
                      SizedBox(height: 15),
                      Form(
                        key: _formPendingKey,
                        child: Container(
                          child:   Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: fromPendingC,
                                  obscureText: false,
                                  readOnly: false,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {   // Validation Logic
                                      return 'Please enter the From Date';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                                      prefixIcon: const Icon(Icons.calendar_month, color: TsOneColor.primary,),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: TsOneColor.primary,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(color: TsOneColor.secondaryContainer)
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.green,
                                        ),
                                      ),
                                      labelText: "From Date"
                                  ),
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1945), lastDate: DateTime(2300));
                                    if(pickedDate != null){
                                      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                                      fromPendingC.text = formattedDate;
                                    }
                                  },
                                ),
                              ),
                              Expanded(flex: 1,child: Icon(Icons.compare_arrows_rounded)),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: toPendingC,
                                  obscureText: false,
                                  readOnly: false,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {   // Validation Logic
                                      return 'Please enter the To Date';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                                      prefixIcon: const Icon(Icons.calendar_month, color: TsOneColor.primary,),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: TsOneColor.primary,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(color: TsOneColor.secondaryContainer)
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.green,
                                        ),
                                      ),
                                      labelText: "To Date"
                                  ),
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1945), lastDate: DateTime(2300));
                                    if(pickedDate != null){
                                      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                                      toPendingC.text = formattedDate;
                                    }
                                  },
                                ),
                              ),
                              Expanded(flex: 1,child:
                              InkWell(
                                onTap: (){
                                  DateTime from = DateFormat('dd-MM-yyyy').parse(fromPendingC.text);
                                  DateTime to = DateFormat('dd-MM-yyyy').parse(toPendingC.text);

                                  if (_formPendingKey.currentState != null && _formPendingKey.currentState!.validate()  != 0) {
                                    if (from.isBefore(to)) {
                                      controller.fromPending.value = from;
                                      controller.toPending.value = to;
                                    } else {

                                    }
                                  }
                                },
                                child: Icon(Icons.filter_list, color: TsOneColor.primary,),
                              )
                              ),
                            ],
                          ),
                        ),
                      ),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: controller.getCombinedAttendanceStream(controller.argumentid.value, "pending", from: controller.fromPending.value, to:controller.toPending.value),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return LoadingScreen(); // Placeholder while loading
                          }

                          if (snapshot.hasError) {
                            return ErrorScreen();
                          }

                          var listAttendance= snapshot.data!;
                          if(listAttendance.isEmpty){
                            return EmptyScreen();
                          }

                          return Column(
                            children: [
                              SizedBox(height: 10),
                              ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: listAttendance.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {

                                    Timestamp? timestamp = listAttendance[index]["date"];
                                    DateTime? dateTime = timestamp?.toDate();
                                    String dateC = DateFormat('dd MMMM yyyy').format(dateTime!);
                                    return ListTile(
                                      leading: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.black26,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child : listAttendance[index]["photoURL"] == null ?  Image.asset(
                                            "assets/images/placeholder_person.png",
                                            fit: BoxFit.cover,
                                          ) : Image.network("${listAttendance[index]["photoURL"]}", fit: BoxFit.cover),),
                                      ),
                                      title: Text(listAttendance[index]["name"].toString()),
                                      subtitle: Text(dateC),
                                      trailing: Icon(Icons.navigate_next),
                                      onTap: () => Get.toNamed(Routes.ATTENDANCE_CONFIRCC,  arguments: {
                                        "id" : listAttendance[index]["id"],
                                      }),
                                    );
                                  }
                              )
                            ],
                          );
                        },
                      ),
                    ],
                  )),
                  Obx(() =>  Column(
                    children: [
                      SizedBox(height: 15),
                      Form(
                        key: _formDoneKey,
                        child: Container(
                          child:   Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: fromDoneC,
                                  obscureText: false,
                                  readOnly: false,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {   // Validation Logic
                                      return 'Please enter the From Date';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                                      prefixIcon: const Icon(Icons.calendar_month, color: TsOneColor.primary,),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: TsOneColor.primary,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(color: TsOneColor.secondaryContainer)
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.green,
                                        ),
                                      ),
                                      labelText: "From Date"
                                  ),
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1945), lastDate: DateTime(2300));
                                    if(pickedDate != null){
                                      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                                      fromDoneC.text = formattedDate;
                                    }
                                  },
                                ),
                              ),
                              Expanded(flex: 1,child: Icon(Icons.compare_arrows_rounded)),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: toDoneC,
                                  obscureText: false,
                                  readOnly: false,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {   // Validation Logic
                                      return 'Please enter the To Date';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                                      prefixIcon: const Icon(Icons.calendar_month, color: TsOneColor.primary,),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: TsOneColor.primary,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(color: TsOneColor.secondaryContainer)
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.green,
                                        ),
                                      ),
                                      labelText: "To Date"
                                  ),
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1945), lastDate: DateTime(2300));
                                    if(pickedDate != null){
                                      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                                      toDoneC.text = formattedDate;
                                    }
                                  },
                                ),
                              ),
                              Expanded(flex: 1,child:
                              InkWell(
                                onTap: (){
                                  DateTime from = DateFormat('dd-MM-yyyy').parse(fromDoneC.text);
                                  DateTime to = DateFormat('dd-MM-yyyy').parse(toDoneC.text);

                                  if (_formDoneKey.currentState != null && _formDoneKey.currentState!.validate()  != 0) {
                                    if (from.isBefore(to)) {
                                      controller.fromDone.value = from;
                                      controller.toDone.value = to;
                                    } else {

                                    }
                                  }
                                },
                                child: Icon(Icons.filter_list, color: TsOneColor.primary,),
                              )
                              ),
                            ],
                          ),
                        ),
                      ),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: controller.getCombinedAttendanceStream(controller.argumentid.value, "confirmation", from: controller.fromConfirmation.value, to:controller.toConfirmation.value),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return LoadingScreen(); // Placeholder while loading
                          }

                          if (snapshot.hasError) {
                            return ErrorScreen();
                          }

                          var listAttendance= snapshot.data!;
                          if(listAttendance.isEmpty){
                            return EmptyScreen();
                          }

                          return Column(
                            children: [
                              SizedBox(height: 10),
                              ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: listAttendance.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {

                                    Timestamp? timestamp = listAttendance[index]["date"];
                                    DateTime? dateTime = timestamp?.toDate();
                                    String dateC = DateFormat('dd MMMM yyyy').format(dateTime!);
                                    return ListTile(
                                      leading: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.black26,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child : listAttendance[index]["photoURL"] == null ?  Image.asset(
                                            "assets/images/placeholder_person.png",
                                            fit: BoxFit.cover,
                                          ) : Image.network("${listAttendance[index]["photoURL"]}", fit: BoxFit.cover),),
                                      ),
                                      title: Text(listAttendance[index]["name"].toString()),
                                      subtitle: Text(dateC),
                                      trailing: Icon(Icons.navigate_next),
                                      onTap: () => Get.toNamed(Routes.ATTENDANCE_CONFIRCC,  arguments: {
                                        "id" : listAttendance[index]["id"],
                                      }),
                                    );
                                  }
                              )
                            ],
                          );
                        },
                      ),
                    ],
                  )),
                  Obx(() =>  Column(
                    children: [
                      SizedBox(height: 15),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: controller.getCombinedAttendanceStream(controller.argumentid.value, "done", from: controller.fromDone.value, to:controller.toDone.value),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return LoadingScreen(); // Placeholder while loading
                          }

                          if (snapshot.hasError) {
                            return ErrorScreen();
                          }

                          var listAttendance= snapshot.data!;
                          if(listAttendance.isEmpty){
                            return EmptyScreen();
                          }

                          return Column(
                            children: [
                              SizedBox(height: 10),
                              ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: listAttendance.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {

                                    Timestamp? timestamp = listAttendance[index]["date"];
                                    DateTime? dateTime = timestamp?.toDate();
                                    String dateC = DateFormat('dd MMMM yyyy').format(dateTime!);
                                    return ListTile(
                                      leading: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.black26,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child : listAttendance[index]["photoURL"] == null ?  Image.asset(
                                            "assets/images/placeholder_person.png",
                                            fit: BoxFit.cover,
                                          ) : Image.network("${listAttendance[index]["photoURL"]}", fit: BoxFit.cover),),
                                      ),
                                      title: Text(listAttendance[index]["name"].toString()),
                                      subtitle: Text(dateC),
                                      trailing: Icon(Icons.navigate_next),
                                      onTap: () => Get.toNamed(Routes.ATTENDANCE_CONFIRCC,  arguments: {
                                        "id" : listAttendance[index]["id"],
                                      }),
                                    );
                                  }
                              )
                            ],
                          );
                        },
                      )
                    ],
                  )
                    ,)
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
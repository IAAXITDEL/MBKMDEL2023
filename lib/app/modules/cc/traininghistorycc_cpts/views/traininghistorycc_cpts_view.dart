import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import untuk menggunakan DateFormat
import '../../../../../presentation/theme.dart';
import '../../../../../util/empty_screen.dart';
import '../../../../../util/error_screen.dart';
import '../../../../../util/loading_screen.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/traininghistorycc_cpts_controller.dart';

class TraininghistoryccCptsView
    extends GetView<TraininghistoryccCptsController> {
  TraininghistoryccCptsView({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var fromC = TextEditingController();
    var toC = TextEditingController();

    var nameC = TextEditingController();


    Future<bool> onWillPop() async {
      controller.resetDate();
      return true;
    }

    return WillPopScope( onWillPop: onWillPop, child: Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'TRAINING HISTORY',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex : 8,
                    child: Container(
                      decoration: BoxDecoration(
                          color: TsOneColor.search,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Colors.white54,
                            width: 0.5,
                          )
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.search,
                          color: Colors.blueGrey,
                          size: 20,
                        ),
                        title: TextField(
                          controller: nameC,
                          onChanged: (value){
                            controller.nameS.value = value;
                            print(controller.nameS.value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Type instructor name...',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        trailing: InkWell(
                          onTap: (){
                            controller.nameS.value = "";
                            nameC.clear();
                          },
                          child: Icon(Icons.clear),
                        ),
                      )
                  ),),
                  Expanded(
                      flex : 1,
                      child:  Center(
                        child: IconButton(
                            icon: Icon(Icons.filter_list),
                            onPressed: () {
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusDirectional.only(
                                      topEnd: Radius.circular(25),
                                      topStart: Radius.circular(25),
                                    ),
                                  ),
                                  builder: (context) => SingleChildScrollView(
                                    padding: EdgeInsetsDirectional.only(
                                      start: 20,
                                      end: 20,
                                      bottom: 30,
                                      top: 8,
                                    ),
                                    child: Wrap(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                          child:  Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                'Filter',
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Date',
                                                    style: tsOneTextTheme.labelLarge,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Form(
                                                key: _formKey,
                                                child: Container(
                                                  child:   Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 3,
                                                        child: TextFormField(
                                                          controller: fromC,
                                                          obscureText: false,
                                                          readOnly: true,
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
                                                              fromC.text = formattedDate;
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      Expanded(flex: 1,child: Icon(Icons.compare_arrows_rounded)),
                                                      Expanded(
                                                        flex: 3,
                                                        child: TextFormField(
                                                          controller: toC,
                                                          obscureText: false,
                                                          readOnly: true,
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
                                                              toC.text = formattedDate;
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              Align(
                                                alignment: Alignment.bottomCenter,
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    InkWell(
                                                      onTap:(){
                                                        fromC.clear();
                                                        toC.clear();
                                                        controller.resetDate();
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal: 40, vertical: 10),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius.circular(10.0),
                                                          color: Colors.white,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                              Colors.grey.withOpacity(0.3),
                                                              spreadRadius: 2,
                                                              blurRadius: 3,
                                                              offset: const Offset(0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Text(
                                                          "Reset",
                                                          style: tsOneTextTheme.headlineMedium?.copyWith(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: (){
                                                        DateTime from = DateFormat('dd-MM-yyyy').parse(fromC.text);
                                                        DateTime to = DateFormat('dd-MM-yyyy').parse(toC.text);

                                                        if (_formKey.currentState != null && _formKey.currentState!.validate()  != 0) {
                                                          if (from.isBefore(to)) {
                                                            controller.from.value = from;
                                                            controller.to.value = to;

                                                            print(controller.from.value );
                                                            print(controller.to.value );
                                                            Navigator.of(context).pop();
                                                          } else {

                                                          }
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal: 40, vertical: 10),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius.circular(10.0),
                                                          color: TsOneColor.primary,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                              Colors.grey.withOpacity(0.3),
                                                              spreadRadius: 2,
                                                              blurRadius: 3,
                                                              offset: const Offset(0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Text(
                                                          "Apply",
                                                          style: tsOneTextTheme.headlineMedium?.copyWith(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )

                                      ],
                                    ),
                                  ));
                            }),
                      ) )
                ],
              ),
              SizedBox(height: 10,),
              Obx((){
                print("check");
                print(controller.nameS.value);
                print(controller.from.value);
                print(controller.to.value);
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: controller.historyStream(controller.nameS.value,
                      from: controller.from.value, to: controller.to.value),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingScreen(); // Placeholder while loading
                    }

                    if (snapshot.hasError) {
                      print("test ${snapshot.error}");
                      return ErrorScreen();
                    }

                    var listAttendance = snapshot.data!;
                    if (listAttendance.isEmpty) {
                      return EmptyScreen();
                    }

                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: listAttendance.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          DateTime? dates =
                          listAttendance[index]["date"].toDate();
                          String dateC =
                          DateFormat('dd MMMM yyyy').format(dates!);
                          return InkWell(
                            onTap: () {
                              var idTrainingType =
                                  controller.idTrainingType.value;
                              var idAttendance = listAttendance[index]["id"];

                              if (idTrainingType != null &&
                                  idAttendance != null) {
                                Get.toNamed(Routes.DETAILHISTORYCC_CPTS,
                                    arguments: {
                                      "idTrainingType": idTrainingType,
                                      "idAttendance": idAttendance,
                                    });
                              } else {
                                // Handle the case where either idTrainingType or idAttendance is null
                                // You can show an error message or handle it according to your app logic.
                                print("idTrainingType or idAttendance is null");
                              }
                              /*Get.toNamed(Routes.DETAILHISTORYCC_CPTS, arguments: {
                              "idTrainingType" : controller.idTrainingType.value,
                              "idAttendance" : listAttendance[index]["id"]
                            });*/
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      radius: 15,
                                      child: Text("${index + 1}"),
                                    ),
                                    title: Text(
                                      listAttendance[index]["name"].toString(),
                                      style: tsOneTextTheme.labelMedium,
                                    ),
                                    subtitle: Text(
                                      dateC,
                                      style: tsOneTextTheme.labelMedium,
                                    ),
                                    trailing: const Icon(Icons.navigate_next),
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                );
              })
            ],
          ),
        ),
      ),
    ),);
  }
}
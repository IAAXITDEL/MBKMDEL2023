import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
import '../../../../../presentation/theme.dart';
import '../controllers/analytics_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animations/animations.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({Key? key}) : super(key: key);

  Future<Map<String, int>> countDevicesHub() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot =
        await firestore.collection('Device').get();

    final Map<String, int> deviceCountByHub = {
      'CGK': 0,
      'KNO': 0,
      'DPS': 0,
      'SUB': 0,
    };

    querySnapshot.docs.forEach((doc) {
      final hub = doc['hub'] as String;

      if (deviceCountByHub.containsKey(hub)) {
        deviceCountByHub[hub] = (deviceCountByHub[hub] ?? 0) + 1;
      }
    });

    return deviceCountByHub;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Analytics Device',
          style: tsOneTextTheme.headlineLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [RedTitleText(text: "HUB"), AnalyticsHub()],
          ),
        ),
      ),
    );
  }
}

class AnalyticsHub extends StatefulWidget {
  const AnalyticsHub({Key? key}) : super(key: key);

  @override
  State<AnalyticsHub> createState() => _AnalyticsHubState();
}

class _AnalyticsHubState extends State<AnalyticsHub>
    with TickerProviderStateMixin {
  final List<Tab> tabs = [
    Tab(text: "CGK"),
    Tab(text: "KNO"),
    Tab(text: "DPS"),
    Tab(text: "SUB"),
  ];

  late TabController tabController;
  late Map<String, int> totalDeviceCounts = {};
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
    countDevicesHub('CGK').then((result) {
      setState(() {
        totalDeviceCounts = result;
      });
    });
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          PieChartWidget(totalDeviceCounts, currentTabIndex, tabController),
          TabBar(tabs: tabs, controller: tabController),
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Flexible(
                child: TabBarView(
              controller: tabController,
              children: tabs.map((Tab tab) {
                return Column(
                  children: [
                    count(tab.text), // Menampilkan jumlah total perangkat
                    SizedBox(height: 10),
                    countDevicesInUse(tab
                        .text), // Menampilkan jumlah perangkat yang sedang digunakan
                    SizedBox(height: 10),
                  ],
                );
              }).toList(),
            )),
          ),
        ],
      ),
    );
  }

  Widget count(String? hub) {
    if (hub != null) {
      return FutureBuilder(
        future: Future.wait([countDevicesHub(hub), countDevicesHub_InUse(hub)]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final deviceCounts =
                (snapshot.data as List<Map<String, int>>?)?.first;
            final deviceCounts_InUse =
                (snapshot.data as List? ?? [])[1] as Map<String, int>;
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Flexible(
                    flex: 10,
                    child: Column(
                      children: [
                        Text("Total", style: tsOneTextTheme.bodySmall),
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: tsOneColorScheme.primary,
                                width: 1.0,
                              )),
                          child: Center(
                            child: BlackTitleText(
                                text: "${deviceCounts?[hub] ?? 'N/A'}"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    child: Column(
                      children: [
                        Text("In Use", style: tsOneTextTheme.bodySmall),
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: tsOneColorScheme.primary,
                                width: 1.0,
                              )),
                          child: Center(
                              child: BlackTitleText(
                                  text: "${deviceCounts_InUse[hub]}")),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
    } else {
      return Text('Tab tidak valid');
    }
  }

  Widget countDevicesInUse(String? hub) {
    if (hub != null) {
      return FutureBuilder(
        future: countDevicesHub_InUse_AllHubs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final deviceCounts_InUse_AllHubs = snapshot.data as int;
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Flexible(
                    flex: 10,
                    child: Column(
                      children: [
                        Text("IAA", style: tsOneTextTheme.bodySmall),
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: tsOneColorScheme.primary,
                                width: 1.0,
                              )),
                          child: Center(child: BlackTitleText(text: "Overall")),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    child: Column(
                      children: [
                        Text("Acknowledgment", style: tsOneTextTheme.bodySmall),
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: tsOneColorScheme.primary,
                                width: 1.0,
                              )),
                          child: Center(
                              child: BlackTitleText(
                                  text: "${deviceCounts_InUse_AllHubs}")),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    child: Column(
                      children: [
                        Text("Return", style: tsOneTextTheme.bodySmall),
                        FutureBuilder(
                          future: countDevicesDone(
                              tabs[currentTabIndex]?.text ?? ''),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Container(
                                margin: EdgeInsets.all(16.0),
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(
                                    color: tsOneColorScheme.primary,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child:
                                      BlackTitleText(text: "${snapshot.data}"),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
    } else {
      return Text('Tab tidak valid');
    }
  }

  Future<double> calculatePercentage() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('statusDevice', isEqualTo: 'in-use-pilot')
        .get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;

    int totalRecords = documents.length;
    int recordsWithValues = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['device-name'] != null &&
          data['device-name'] != '-' &&
          (data['device_name2'] != null && data['device_name2'] != '-') &&
          (data['device_name3'] != null && data['device_name3'] != '-')) {
        recordsWithValues++;
      }
    }

    if (totalRecords > 0) {
      return (recordsWithValues / totalRecords) * 100;
    } else {
      return 0.0; // Return 0 jika tidak ada data yang sesuai.
    }
  }

  Future<Map<String, int>> countDevicesHub(String hub) async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot =
        await firestore.collection('Device').get();

    final Map<String, int> deviceCountByHub = {
      'CGK': 0,
      'KNO': 0,
      'DPS': 0,
      'SUB': 0,
    };
    querySnapshot.docs.forEach((doc) {
      final hubValue = doc['hub'] as String;
      if (deviceCountByHub.containsKey(hubValue)) {
        deviceCountByHub[hubValue] = (deviceCountByHub[hubValue] ?? 0) + 1;
      }
    });

    return deviceCountByHub;
  }

  Future<Map<String, int>> countDevicesHub_InUse(String hub) async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('statusDevice', isEqualTo: 'in-use-pilot')
        .where('field_hub', isEqualTo: hub)
        .get();

    final int deviceCount_InUse = querySnapshot.docs.length;

    final Map<String, int> deviceCountByHub_InUse = {
      hub: deviceCount_InUse,
    };

    return deviceCountByHub_InUse;
  }

  Future<int> countDevicesHub_InUse_AllHubs() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('statusDevice', isEqualTo: 'in-use-pilot')
        .get();

    final int deviceCount_InUse_AllHubs = querySnapshot.docs.length;

    return deviceCount_InUse_AllHubs;
  }

  Future<int> countDevicesDone(String hub) async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('statusDevice', isEqualTo: 'Done')
        .where('field_hub', isEqualTo: hub)
        .get();

    final int deviceCountDone = querySnapshot.docs.length;

    return deviceCountDone;
  }

  void _handleTabChange(int newIndex) {
    setState(() {
      currentTabIndex = newIndex;
    });
  }
}

// Pie Chart
class PieChartWidget extends StatefulWidget {
  final Map<String, int> deviceCounts;
  final int currentTabIndex;
  final TabController tabController;

  PieChartWidget(this.deviceCounts, this.currentTabIndex, this.tabController);

  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(() {
      setState(() {
        touchedIndex = widget.tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback:
                (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null) {
                return;
              }
              setState(() {
                if (pieTouchResponse.touchedSection != null) {
                  touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                } else {
                  touchedIndex = -1;
                }
              });

              if (touchedIndex != -1 &&
                  touchedIndex != widget.currentTabIndex) {
                widget.tabController
                    .animateTo(touchedIndex); // Switch to the corresponding tab
              }
            },
          ),
          sectionsSpace: 2,
          centerSpaceRadius: 30,
          sections: _getChartSections(),
          borderData: FlBorderData(show: false),
          startDegreeOffset: 180,
        ),
      ),
    );
  }

  List<PieChartSectionData> _getChartSections() {
    final List<Color> colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
    ];

    final List<String> hubs = widget.deviceCounts.keys.toList();
    return List.generate(widget.deviceCounts.length, (i) {
      final int count = widget.deviceCounts[hubs[i]] ?? 0;
      final double percentage =
          (count / widget.deviceCounts.values.reduce((a, b) => a + b)) * 100;

      final bool isExploded = touchedIndex == i;

      return PieChartSectionData(
        title: '${hubs[i]}\n${percentage.toStringAsFixed(2)}%',
        value: count.toDouble(),
        color: colors[i % colors.length],
        radius: isExploded ? 110 : 90,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontFamily: 'Poppins',
        ),
      );
    });
  }
}

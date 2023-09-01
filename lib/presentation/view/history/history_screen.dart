import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:ts_one/data/assessments/assessment_results.dart';
import 'package:ts_one/data/assessments/assessment_variables.dart';
import 'package:ts_one/data/users/user_preferences.dart';
import 'package:ts_one/data/users/users.dart';
import 'package:ts_one/di/locator.dart';
import 'package:ts_one/presentation/routes.dart';
import 'package:ts_one/presentation/theme.dart';
import 'package:ts_one/presentation/view_model/assessment_results_viewmodel.dart';
import 'package:ts_one/util/util.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late UserPreferences userPreferences;
  late String rankUser;
  late AssessmentResultsViewModel viewModel;

  final int _limit = 10;

  int searchLimit = 10;

  late bool isSearchingAll;
  late List<AssessmentResults> allAssessment;
  late ScrollController _allScrollController;
  late List<AssessmentResults> searchedAssessment;

  late List<AssessmentResults> selfAssessment;

  late bool isSearchingMy;
  late List<AssessmentResults> myAssessment;
  late List<AssessmentResults> myAssessmentSearched;
  late ScrollController _myScrollController;

  int selectedTabHistoryIndex = 0;

  late bool _isCPTS;
  late bool _isInstructor;

  String? _selectedRankFilterAll;
  int? _selectedMarkerFilterAll;
  DateTime? filterDateFromAll;
  DateTime? filterDateToAll;

  String? _selectedRankFilterMy;
  int? _selectedMarkerFilterMy;
  DateTime? filterDateFromMy;
  DateTime? filterDateToMy;

  List<String> rankList = [
    UserModel.keyPositionCaptain,
    UserModel.keyPositionFirstOfficer,
  ];

  List<int> markerList = [
    AssessmentVariables.keyMarkerOne,
    AssessmentVariables.keyMarkerTwo,
    AssessmentVariables.keyMarkerThree,
    AssessmentVariables.keyMarkerFour,
    AssessmentVariables.keyMarkerFive,
  ];



  @override
  void initState() {
    userPreferences = getItLocator<UserPreferences>();
    viewModel = Provider.of<AssessmentResultsViewModel>(context, listen: false);

    switch (userPreferences.getIDNo()) {
      case 1000854:
        rankUser = 'CPTS';
        break;
      default:
        rankUser = 'Pilot';
        break;
    }

    isSearchingAll = false;
    searchedAssessment = [];
    allAssessment = [];
    _allScrollController = ScrollController();
    _allScrollController.addListener(_scrollListener);

    selfAssessment = [];

    isSearchingMy = false;
    myAssessment = [];
    myAssessmentSearched = [];
    _myScrollController = ScrollController();
    _myScrollController.addListener(_scrollListenerMy);

    _isCPTS = false;
    _isInstructor = false;

    checkCPTS();
    checkInstructor();

    super.initState();
  }

  void _scrollListener() {
    if (_allScrollController.position.pixels == _allScrollController.position.maxScrollExtent) {
      getAllAssessments();
    }
  }

  void _scrollListenerMy() {
    if (_myScrollController.position.pixels == _myScrollController.position.maxScrollExtent) {
      getMyAssessments();
    }
  }

  @override
  void dispose() {
    _allScrollController.removeListener(_scrollListener);
    _allScrollController.dispose();
    _myScrollController.removeListener(_scrollListenerMy);
    _myScrollController.dispose();
    super.dispose();
  }

  // ================================================================================================================
  void getAllAssessments() async {
    allAssessment = await viewModel.getAllAssessmentResultsPaginated(
        _limit, _selectedRankFilterAll, _selectedMarkerFilterAll, filterDateFromAll, filterDateToAll);
    log("allAssessment 183: ${allAssessment.length}");
  }

  void searchAssessmentBasedOnName(String searchName) async {
    searchedAssessment = await viewModel.searchAssessmentResultsBasedOnName(searchName, searchLimit, true);
  }

  // ====================================================================================================
  void getSelfAssessment() async {
    selfAssessment = await viewModel.getSelfAssessmentResultsPaginated();
  }

  // ================================================================================================
  void getMyAssessments() async {
    myAssessment = await viewModel.getMyAssessmentResultsPaginated(
        _limit, _selectedRankFilterMy, _selectedMarkerFilterMy, filterDateFromMy, filterDateToMy
    );
    log("myAssessment 163: ${myAssessment.length}");
  }

  void searchMyAssessmentBasedOnName(String searchName) async {
    myAssessmentSearched = await viewModel.searchAssessmentResultsBasedOnName(searchName, searchLimit, false);
  }

  // =====================================================================================================
  void checkCPTS() async {
    if (userPreferences.getPrivileges().contains(UserModel.keyPrivilegeViewAllAssessments) &&
        userPreferences.getInstructor().contains(UserModel.keyCPTS)) {
      _isCPTS = true;
    }
  }

  void checkInstructor() async {
    if (userPreferences.getPrivileges().contains(UserModel.keyPrivilegeCreateAssessment)) {
      _isInstructor = true;
    }
  }

  List<Widget> menuCPTS() {
    return [
      tabViewAll(),
      tabViewSelf(),
    ];
  }

  List<Widget> menuInstructor() {
    return [
      tabMyAssessment(),
      tabViewSelf(),
    ];
  }

  List<Widget> menuGod() {
    return [
      tabViewAll(),
      tabMyAssessment(),
      tabViewSelf(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        if (_isCPTS && _isInstructor) {
          getAllAssessments();
          getMyAssessments();
        } else if (_isInstructor) {
          getMyAssessments();
        } else if (_isCPTS) {
          getAllAssessments();
        }
        getSelfAssessment();
      },
      child: Consumer<AssessmentResultsViewModel>(
        builder: (_, model, child) {
          return SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: DefaultTabController(
                    length: _isCPTS && _isInstructor
                        ? 3
                        : _isCPTS || _isInstructor
                            ? 2
                            : 1,
                    child: Scaffold(
                      appBar: AppBar(
                        systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: TsOneColor.primary),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Assessment History",
                              style: TextStyle(color: TsOneColor.secondary),
                            ),
                            userPreferences.getPrivileges().contains(UserModel.keyPrivilegeManageFormAssessment)
                                ? Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            Navigator.pushNamed(context, NamedRoute.allAssessmentPeriods);
                                          },
                                          icon: const Icon(
                                            Icons.feed,
                                            size: 32.0,
                                            color: TsOneColor.secondary,
                                          )),
                                    ],
                                  )
                                : Container()
                          ],
                        ),
                        backgroundColor: TsOneColor.primary,
                        elevation: 0,
                        bottom: TabBar(
                          labelColor: TsOneColor.primary,
                          unselectedLabelColor: TsOneColor.secondary,
                          indicator: const BoxDecoration(
                            borderRadius:
                                BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                            color: TsOneColor.secondary,
                          ),
                          tabs: [
                            if (_isCPTS)
                              const Tab(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text("All"),
                                ),
                              ),
                            if (_isInstructor)
                              const Tab(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "My Assessment",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            const Tab(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text("Self"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      body: TabBarView(
                        children: _isCPTS && _isInstructor
                            ? menuGod()
                            : _isCPTS
                                ? menuCPTS()
                                : _isInstructor
                                    ? menuInstructor()
                                    : [tabViewSelf()],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================================================ ALL ASSESSMENT ================================================================
  Widget tabViewAll() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: TextField(
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        value = value.toTitleCase();

                        setState(() {
                          isSearchingAll = true;
                        });
                        log("searching for $value");
                        searchAssessmentBasedOnName(value);
                      } else {
                        getAllAssessments();
                        log("EMMTPY");
                        setState(() {
                          isSearchingAll = false;
                        });
                      }
                    },
                    cursorColor: TsOneColor.primary,
                    decoration: InputDecoration(
                        fillColor: TsOneColor.onPrimary,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: TsOneColor.primary),
                        ),
                        hintText: 'Search...',
                        hintStyle: const TextStyle(
                          color: TsOneColor.onSecondary,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(16),
                          width: 32,
                          child: const Icon(Icons.search),
                        )),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.filter_list,
                  size: 32.0,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setModalState) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Filter",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    TextButton(
                                      child: const Text(
                                        "Reset",
                                        style: TextStyle(color: TsOneColor.primary),
                                      ),
                                      onPressed: () {
                                        setModalState(() {
                                          _selectedRankFilterAll = null;
                                          _selectedMarkerFilterAll = null;
                                          filterDateFromAll = null;
                                          filterDateToAll = null;
                                        });
                                      },
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Rank",
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                  ),
                                ),
                                Row(
                                  // FROM ALL VIEW
                                  children: rankChoiceChips(setModalState, true),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Markers",
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                  ),
                                ),
                                Row(
                                  // FROM ALL VIEW
                                  children: markerChoiceChips(setModalState, true),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Date",
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'From',
                                        ),
                                        controller: TextEditingController(
                                          text: filterDateFromAll != null
                                              ? Util.convertDateTimeDisplay(
                                                  filterDateFromAll.toString(),
                                                  "dd MMM yyyy",
                                                )
                                              : "",
                                        ),
                                        textInputAction: TextInputAction.next,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        onTap: () {
                                          // FROM ALL VIEW
                                          _showSelectDatePickerFrom(context, setModalState, true);
                                          FocusScope.of(context).unfocus();
                                        },
                                        readOnly: true,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'To',
                                        ),
                                        controller: TextEditingController(
                                          text: filterDateToAll != null
                                              ? Util.convertDateTimeDisplay(
                                                  filterDateToAll.toString(),
                                                  "dd MMM yyyy",
                                                )
                                              : "",
                                        ),
                                        textInputAction: TextInputAction.next,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        onTap: () {
                                          // FROM ALL VIEW
                                          _showSelectDatePickerTo(context, setModalState, true);
                                          FocusScope.of(context).unfocus();
                                        },
                                        readOnly: true,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    viewModel.allAssessmentResults = [];
                                    viewModel.isAllAssessmentLoaded = false;
                                    viewModel.allLastAssessment = null;

                                    getAllAssessments();
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TsOneColor.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 48,
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: Text("Filter Assessments", style: TextStyle(color: TsOneColor.onPrimary)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              )
            ],
          ),
          !isSearchingAll
              ? Expanded(
                  child: allAssessment.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          controller: _allScrollController,
                          itemCount: allAssessment.length,
                          itemBuilder: (context, index) {
                            if (index == allAssessment.length - 1 && !viewModel.isAllAssessmentLoaded) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            return Card(
                              surfaceTintColor: TsOneColor.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, NamedRoute.resultAssessmentVariables,
                                      arguments: allAssessment[index]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.white,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(50),
                                          child: Image.asset("assets/images/placeholder_person.png"),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                allAssessment[index].examineeName.toString(),
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                allAssessment[index].examineeStaffIDNo.toString(),
                                                style: const TextStyle(fontWeight: FontWeight.normal),
                                              ),
                                              Text(
                                                allAssessment[index].rank.toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(Util.convertDateTimeDisplay(allAssessment[index].date.toString())),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })
                      : viewModel.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : const Center(
                              child: Text('No assessment founded'),
                            ),
                )
              : Expanded(
                  child: !viewModel.isLoading
                      ? searchedAssessment.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: searchedAssessment.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  surfaceTintColor: TsOneColor.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, NamedRoute.resultAssessmentVariables,
                                          arguments: searchedAssessment[index]);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Colors.white,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(50),
                                              child: Image.asset("assets/images/placeholder_person.png"),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    searchedAssessment[index].examineeName.toString(),
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  Text(
                                                    searchedAssessment[index].examineeStaffIDNo.toString(),
                                                    style: const TextStyle(fontWeight: FontWeight.normal),
                                                  ),
                                                  Text(
                                                    searchedAssessment[index].rank.toString(),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.normal,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Text(Util.convertDateTimeDisplay(searchedAssessment[index].date.toString())),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              })
                          : const Center(child: Text("No assessment found"))
                      : const Center(child: CircularProgressIndicator()),
                )
        ],
      ),
    );
  }

  // ================================================ SELF ASSESSMENT ================================================================
  Widget tabViewSelf() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : selfAssessment.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: selfAssessment.length,
                  itemBuilder: (context, index) {
                    return Card(
                      surfaceTintColor: TsOneColor.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, NamedRoute.resultAssessmentVariables,
                              arguments: selfAssessment[index]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.asset("assets/images/placeholder_person.png"),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selfAssessment[index].examineeName.toString(),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        selfAssessment[index].examineeStaffIDNo.toString(),
                                        style: const TextStyle(fontWeight: FontWeight.normal),
                                      ),
                                      Text(
                                        selfAssessment[index].rank.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Text(Util.convertDateTimeDisplay(selfAssessment[index].date.toString())),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const Center(child: Text("No assessment found")),
    );
  }

  // ================================================ MY ASSESSMENT ================================================================
  Widget tabMyAssessment() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: TextField(
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        value = value.toTitleCase();

                        setState(() {
                          isSearchingMy = true;
                        });
                        log("searching for $value");
                        searchMyAssessmentBasedOnName(value);
                      } else {
                        // getAllAssessments();
                        log("EMMTPY");
                        setState(() {
                          isSearchingMy = false;
                        });
                      }
                    },
                    cursorColor: TsOneColor.primary,
                    decoration: InputDecoration(
                        fillColor: TsOneColor.onPrimary,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: TsOneColor.primary),
                        ),
                        hintText: 'Search...',
                        hintStyle: const TextStyle(
                          color: TsOneColor.onSecondary,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(16),
                          width: 32,
                          child: const Icon(Icons.search),
                        )),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter setModalState) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Filter",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        TextButton(
                                          child: const Text(
                                            "Reset",
                                            style: TextStyle(color: TsOneColor.primary),
                                          ),
                                          onPressed: () {
                                            setModalState(() {
                                              _selectedRankFilterMy = null;
                                              _selectedMarkerFilterMy = null;
                                              filterDateFromMy = null;
                                              filterDateToMy = null;
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Rank",
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                      )
                                    ),
                                    Row(
                                      // FROM MY ASSESSMENT VIEW
                                      children: rankChoiceChips(setModalState, false),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Markers",
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                      ),
                                    ),
                                    Row(
                                      // FROM MY ASSESSMENT VIEW
                                      children: markerChoiceChips(setModalState, false),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Date",
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: TextFormField(
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'From',
                                            ),
                                            controller: TextEditingController(
                                              text: filterDateFromMy != null
                                                  ? Util.convertDateTimeDisplay(
                                                filterDateFromMy.toString(),
                                                "dd MMM yyyy",
                                              )
                                                  : "",
                                            ),
                                            textInputAction: TextInputAction.next,
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            onTap: () {
                                              // FROM MY ASSESSMENT VIEW
                                              _showSelectDatePickerFrom(context, setModalState, false);
                                              FocusScope.of(context).unfocus();
                                            },
                                            readOnly: true,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: TextFormField(
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'To',
                                            ),
                                            controller: TextEditingController(
                                              text: filterDateToMy != null
                                                  ? Util.convertDateTimeDisplay(
                                                filterDateToMy.toString(),
                                                "dd MMM yyyy",
                                              )
                                                  : "",
                                            ),
                                            textInputAction: TextInputAction.next,
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            onTap: () {
                                              // FROM MY ASSESSMENT VIEW
                                              _showSelectDatePickerTo(context, setModalState, false);
                                              FocusScope.of(context).unfocus();
                                            },
                                            readOnly: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        viewModel.myAssessmentResults = [];
                                        viewModel.isMyAssessmentLoaded = false;
                                        viewModel.myLastAssessment = null;

                                        getMyAssessments();
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: TsOneColor.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width,
                                        height: 48,
                                        child: const Align(
                                          alignment: Alignment.center,
                                          child: Text("Filter Assessments", style: TextStyle(color: TsOneColor.onPrimary)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        });
                  },
                  icon: const Icon(
                    Icons.filter_alt,
                    size: 32.0,
                  ))
            ],
          ),
          !isSearchingMy
              ? Expanded(
                  child: myAssessment.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          controller: _myScrollController,
                          itemCount: myAssessment.length,
                          itemBuilder: (context, index) {
                            if (index == myAssessment.length - 1 && !viewModel.isMyAssessmentLoaded) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            return Card(
                              surfaceTintColor: TsOneColor.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, NamedRoute.resultAssessmentVariables,
                                      arguments: myAssessment[index]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.white,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(50),
                                          child: Image.asset("assets/images/placeholder_person.png"),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                myAssessment[index].examineeName.toString(),
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                myAssessment[index].examineeStaffIDNo.toString(),
                                                style: const TextStyle(fontWeight: FontWeight.normal),
                                              ),
                                              Text(
                                                myAssessment[index].rank.toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(Util.convertDateTimeDisplay(myAssessment[index].date.toString())),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })
                      : viewModel.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : const Center(
                              child: Text('No assessment found'),
                            ),
                )
              : Expanded(
                  child: !viewModel.isLoading
                      ? myAssessmentSearched.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: myAssessmentSearched.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  surfaceTintColor: TsOneColor.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, NamedRoute.resultAssessmentVariables,
                                          arguments: myAssessmentSearched[index]);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Colors.white,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(50),
                                              child: Image.asset("assets/images/placeholder_person.png"),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    myAssessmentSearched[index].examineeName.toString(),
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  Text(
                                                    myAssessmentSearched[index].examineeStaffIDNo.toString(),
                                                    style: const TextStyle(fontWeight: FontWeight.normal),
                                                  ),
                                                  Text(
                                                    myAssessmentSearched[index].rank.toString(),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.normal,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Text(
                                              Util.convertDateTimeDisplay(myAssessmentSearched[index].date.toString())),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Center(child: Text("No assessment found"))
                      : const Center(child: CircularProgressIndicator()),
                )
        ],
      ),
    );
  }

  List<Widget> rankChoiceChips(StateSetter setModalState, bool isAll) {
    List<Widget> chips = [];

    if (isAll) {
      for (int i = 0; i < rankList.length; i++) {
        Widget item = Padding(
          padding: const EdgeInsets.only(right: 5),
          child: FilterChip(
            label: Text(rankList[i]),
            selected: _selectedRankFilterAll == rankList[i],
            selectedColor: TsOneColor.primary,
            checkmarkColor: _selectedRankFilterAll == rankList[i] ? TsOneColor.secondary : null,
            labelStyle:
            TextStyle(color: _selectedRankFilterAll == rankList[i] ? TsOneColor.secondary : TsOneColor.onSecondary),
            onSelected: (bool value) {
              if (_selectedRankFilterAll != rankList[i]) {
                setModalState(() {
                  _selectedRankFilterAll = rankList[i];
                });
              }
            },
          ),
        );
        chips.add(item);
      }
    } else {
      for (int i = 0; i < rankList.length; i++) {
        Widget item = Padding(
          padding: const EdgeInsets.only(right: 5),
          child: FilterChip(
            label: Text(rankList[i]),
            selected: _selectedRankFilterMy == rankList[i],
            selectedColor: TsOneColor.primary,
            checkmarkColor: _selectedRankFilterMy == rankList[i] ? TsOneColor.secondary : null,
            labelStyle:
            TextStyle(color: _selectedRankFilterMy == rankList[i] ? TsOneColor.secondary : TsOneColor.onSecondary),
            onSelected: (bool value) {
              if (_selectedRankFilterMy != rankList[i]) {
                setModalState(() {
                  _selectedRankFilterMy = rankList[i];
                });
              }
            },
          ),
        );
        chips.add(item);
      }
    }

    return chips;
  }

  List<Widget> markerChoiceChips(StateSetter setModalState, bool isAll) {
    List<Widget> chips = [];

    if (isAll) {
      for (int i = 0; i < markerList.length; i++) {
        Widget item = Padding(
          padding: const EdgeInsets.only(right: 5),
          child: FilterChip(
            label: Text(markerList[i].toString()),
            selected: _selectedMarkerFilterAll == markerList[i],
            selectedColor: TsOneColor.primary,
            checkmarkColor: _selectedMarkerFilterAll == markerList[i] ? TsOneColor.secondary : null,
            labelStyle:
            TextStyle(color: _selectedMarkerFilterAll == markerList[i] ? TsOneColor.secondary : TsOneColor.onSecondary),
            onSelected: (bool value) {
              if (_selectedMarkerFilterAll != markerList[i]) {
                setModalState(() {
                  _selectedMarkerFilterAll = markerList[i];
                });
              }
            },
          ),
        );
        chips.add(item);
      }
    } else {
      for (int i = 0; i < markerList.length; i++) {
        Widget item = Padding(
          padding: const EdgeInsets.only(right: 5),
          child: FilterChip(
            label: Text(markerList[i].toString()),
            selected: _selectedMarkerFilterMy == markerList[i],
            selectedColor: TsOneColor.primary,
            checkmarkColor: _selectedMarkerFilterMy == markerList[i] ? TsOneColor.secondary : null,
            labelStyle:
            TextStyle(color: _selectedMarkerFilterMy == markerList[i] ? TsOneColor.secondary : TsOneColor.onSecondary),
            onSelected: (bool value) {
              if (_selectedMarkerFilterMy != markerList[i]) {
                setModalState(() {
                  _selectedMarkerFilterMy = markerList[i];
                });
              }
            },
          ),
        );
        chips.add(item);
      }
    }

    return chips;
  }

  void _showSelectDatePickerFrom(BuildContext context, StateSetter setModalState, bool isAll) async {
    DateTime now = DateTime.now();

    if (isAll) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: filterDateToAll != null
              ? DateTime(filterDateToAll!.year, filterDateToAll!.month, filterDateToAll!.day)
              : filterDateFromAll == null
              ? DateTime(now.year, now.month, now.day) : filterDateFromAll!,
          firstDate: DateTime(2006),
          lastDate: filterDateToAll == null ? Util.getCurrentDateWithoutTime() : filterDateToAll!,
          helpText: "Select filter date");
      if (picked != null && picked != filterDateFromAll) {
        setModalState(() {
          filterDateFromAll = picked;
        });
      }
    } else {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: filterDateFromMy == null ? DateTime(now.year, now.month, now.day) : filterDateFromMy!,
          firstDate: DateTime(2006),
          lastDate: filterDateFromMy == null ? Util.getCurrentDateWithoutTime() : filterDateFromMy!,
          helpText: "Select filter date");
      if (picked != null && picked != filterDateFromMy) {
        setModalState(() {
          filterDateFromMy = picked;
        });
      }
    }

  }

  void _showSelectDatePickerTo(BuildContext context, StateSetter setModalState, isAll) async {
    DateTime now = DateTime.now();

    if (isAll) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: filterDateToAll == null ? DateTime(now.year, now.month, now.day) : filterDateToAll!,
          firstDate: filterDateFromAll == null ? DateTime(2006) : filterDateFromAll!,
          lastDate: Util.getCurrentDateWithoutTime(),
          helpText: "Select filter date");
      if (picked != null && picked != filterDateToAll) {
        setModalState(() {
          filterDateToAll = picked;
        });
      }
    } else {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: filterDateToMy == null ? DateTime(now.year, now.month, now.day) : filterDateToMy!,
          firstDate: filterDateToMy == null ? DateTime(2006) : filterDateToMy!,
          lastDate: Util.getCurrentDateWithoutTime(),
          helpText: "Select filter date");
      if (picked != null && picked != filterDateToMy) {
        setModalState(() {
          filterDateToMy = picked;
        });
      }
    }
  }
}

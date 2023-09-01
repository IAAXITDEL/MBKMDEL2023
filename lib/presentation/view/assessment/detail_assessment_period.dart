import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:ts_one/data/assessments/assessment_period.dart';
import 'package:ts_one/data/assessments/assessment_variables.dart';
import 'package:ts_one/data/users/user_preferences.dart';
import 'package:ts_one/di/locator.dart';
import 'package:ts_one/presentation/routes.dart';
import 'package:ts_one/presentation/theme.dart';
import 'package:ts_one/presentation/view_model/assessment_viewmodel.dart';
import 'package:ts_one/util/util.dart';

class DetailAssessmentPeriodView extends StatefulWidget {
  const DetailAssessmentPeriodView({Key? key, required this.assessmentPeriodId})
      : super(key: key);

  final String assessmentPeriodId;

  @override
  State<DetailAssessmentPeriodView> createState() =>
      _DetailAssessmentPeriodViewState();
}

class _DetailAssessmentPeriodViewState
    extends State<DetailAssessmentPeriodView> {
  late AssessmentViewModel viewModel;
  late UserPreferences userPreferences;
  late AssessmentPeriod assessmentPeriod;
  late String assessmentPeriodId;
  late List<String> assessmentCategories;

  @override
  void initState() {
    viewModel = Provider.of<AssessmentViewModel>(context, listen: false);
    userPreferences = getItLocator<UserPreferences>();
    assessmentPeriodId = widget.assessmentPeriodId;
    assessmentPeriod = AssessmentPeriod();
    assessmentCategories = [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAssessmentPeriodById();
    });

    super.initState();
  }

  void getAssessmentPeriodById() async {
    assessmentPeriod =
        await viewModel.getAssessmentPeriodById(assessmentPeriodId);

    assessmentCategories.clear();

    for (var assessmentVariable in assessmentPeriod.assessmentVariables) {
      if(!assessmentCategories.contains(assessmentVariable.category)) {
        assessmentCategories.add(assessmentVariable.category);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentViewModel>(builder: (_, model, child) {
      return FocusDetector(
        onFocusGained: () {
          getAssessmentPeriodById();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Form Assessment $assessmentPeriodId"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: assessmentPeriod.id == Util.defaultStringIfNull //if
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : //else
                      SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildExpansionTileForAllAssessmentVariables(assessmentPeriod.assessmentVariables),
                          ),
                        ),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: ExpandableFab.location,
          floatingActionButton: ExpandableFab(
            backgroundColor: TsOneColor.primary,
            children: [
              FloatingActionButton(
                heroTag: "buttonEdit",
                onPressed: () {
                  Navigator.pushNamed(
                      context,
                      NamedRoute.updateAssessmentPeriod,
                      arguments: assessmentPeriodId
                  );
                },
                backgroundColor: TsOneColor.primary,
                child: const Icon(Icons.edit),
              ),
              FloatingActionButton(
                heroTag: "buttonDelete",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Delete Form Assessment ${assessmentPeriod.id}?"),
                        content: const Text(
                            "You will not be able to retrieve this data anymore. "
                                "Are you sure you want to delete this form assessment?"
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("No"),
                          ),
                          TextButton(
                            onPressed: () async {
                              await viewModel.deleteAssessmentPeriodById(
                                  assessmentPeriodId);
                              if (!mounted) return;
                              Navigator.pop(context);
                            },
                            child: const Text("Yes"),
                          ),
                        ],
                      );
                    },
                  );
                },
                backgroundColor: TsOneColor.primary,
                child: const Icon(Icons.delete),
              ),
            ],
          )
        ),
      );
    });
  }

  List<Widget> _buildExpansionTileForAllAssessmentVariables(List<AssessmentVariables> assessmentVariables) {
    List<Widget> expansionTiles = [];
    expansionTiles.add(
      const Text("This form assessment is effective on"),
    );
    expansionTiles.add(
        Text(
          Util.convertDateTimeDisplay(
              assessmentPeriod.period.toString()),
          style: tsOneTextTheme.displaySmall,
        ),
    );

    for (var assessmentCategory in assessmentCategories) {
      List<AssessmentVariables> assessmentVariablesByCategory = [];
      for (var assessmentVariable in assessmentVariables) {
        if(assessmentVariable.category == assessmentCategory) {
          assessmentVariablesByCategory.add(assessmentVariable);
        }
      }
      expansionTiles.add(
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: ExpansionTile(
              backgroundColor: tsOneColorScheme.surface,
              collapsedBackgroundColor: tsOneColorScheme.primary,
              textColor: tsOneColorScheme.primary,
              collapsedTextColor: tsOneColorScheme.onPrimary,
              iconColor: tsOneColorScheme.primary,
              collapsedIconColor: tsOneColorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Text(assessmentCategory),
              childrenPadding: const EdgeInsets.only(left: 16.0, right: 16.0),
              children: [
                for (var assessmentVariable in assessmentVariablesByCategory)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Row(
                      children: [
                        Text(
                          assessmentVariable.name,
                          style: tsOneTextTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          )
      );
    }

    return expansionTiles;
  }
}

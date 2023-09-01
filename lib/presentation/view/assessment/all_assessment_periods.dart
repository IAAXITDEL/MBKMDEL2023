import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ts_one/data/assessments/assessment_period.dart';
import 'package:ts_one/data/users/user_preferences.dart';
import 'package:ts_one/di/locator.dart';
import 'package:ts_one/presentation/routes.dart';
import 'package:ts_one/presentation/theme.dart';
import 'package:ts_one/presentation/view_model/assessment_viewmodel.dart';
import 'package:ts_one/util/util.dart';

class AllAssessmentPeriodsView extends StatefulWidget {
  const AllAssessmentPeriodsView({Key? key}) : super(key: key);

  @override
  State<AllAssessmentPeriodsView> createState() =>
      _AllAssessmentPeriodsViewState();
}

class _AllAssessmentPeriodsViewState extends State<AllAssessmentPeriodsView> {
  late AssessmentViewModel viewModel;
  late UserPreferences userPreferences;
  late List<AssessmentPeriod> assessmentPeriods;

  @override
  void initState() {
    viewModel = Provider.of<AssessmentViewModel>(context, listen: false);
    userPreferences = getItLocator<UserPreferences>();
    assessmentPeriods = [];

    super.initState();
  }

  Stream<List<AssessmentPeriod>> _getAssessmentPeriods() async* {
    yield await viewModel.getAllAssessmentPeriod();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentViewModel>(
        builder: (_, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Form Assessment"),
            ),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<AssessmentPeriod>>(
                          stream: _getAssessmentPeriods(),
                          builder: (context, snapshot) {
                            if(snapshot.hasData) {
                              return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      surfaceTintColor: TsOneColor.surface,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            NamedRoute.detailAssessmentPeriod,
                                            arguments: snapshot.data![index].id,
                                          );
                                        },
                                        child: ListTile(
                                          title: Text("Form Assessment ${snapshot.data![index].id}"),
                                          subtitle: Text("Effective on ${Util.convertDateTimeDisplay(snapshot.data![index].period.toString())}"),
                                        ),
                                      ),
                                    );
                                  }
                              );
                            }
                            else if (snapshot.hasError) {
                              return Text(("${snapshot.error}"));
                            }
                            else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          }
                      ),
                    ),
                  ],
                ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  NamedRoute.addAssessmentPeriod,
                );
              },
              backgroundColor: TsOneColor.primary,
              child: const Icon(Icons.add),
            )
          );
        });
  }
}

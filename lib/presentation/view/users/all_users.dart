import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:ts_one/data/users/users.dart';
import 'package:ts_one/presentation/routes.dart';
import 'package:ts_one/presentation/theme.dart';
import 'package:ts_one/presentation/view_model/user_viewmodel.dart';
import 'package:ts_one/util/util.dart';

class AllUsersView extends StatefulWidget {
  const AllUsersView({Key? key}) : super(key: key);

  @override
  State<AllUsersView> createState() => _AllUsersViewState();
}

class _AllUsersViewState extends State<AllUsersView> {
  late UserViewModel viewModel;
  late List<UserModel> users;
  late List<UserModel> searchedUsers;
  late ScrollController _scrollController;
  late bool isSearching;
  int limit = 30;
  int searchLimit = 5;

  @override
  void initState() {
    viewModel = Provider.of<UserViewModel>(context, listen: false);
    users = [];
    searchedUsers = [];
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    isSearching = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUsers();
    });

    super.initState();
  }

  void getUsers () async {
    users = await viewModel.getAllUsers(limit);
  }

  void searchUser(String searchName) async {
    searchedUsers = await viewModel.getUsersBySearchName(searchName, searchLimit);
  }

  void _scrollListener() {
    if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // viewModel.getAllUsers(limit);
      getUsers();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        getUsers();
      },
      child: Consumer<UserViewModel>(
        builder: (_, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Users"),
            ),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 0,
                      child: TextField(
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          onChanged: (value) {
                            if(value.isNotEmpty) {
                              // capitalize the first letter
                              value = value.toTitleCase();

                              // set isSearching to true
                              setState(() {
                                isSearching = true;
                              });

                              // search user
                              searchUser(value);
                            } else {
                              setState(() {
                                isSearching = false;
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
                            hintText: 'Search',
                            hintStyle: const TextStyle(
                              color: TsOneColor.onSecondary,
                            ),
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(16),
                              width: 32,
                              child: const Icon(Icons.search),
                            ),
                          ),
                        )
                    ),
                    !isSearching
                    ? Expanded(
                      child: users.isNotEmpty
                          ? ListView.builder(
                          shrinkWrap: true,
                          controller: _scrollController,
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            if (index == users.length - 1 && !viewModel.isAllUsersLoaded) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            return Card(
                              surfaceTintColor: TsOneColor.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context,
                                      NamedRoute.detailUser,
                                      arguments: users[index].idNo.toString()
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
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
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                users[index].name,
                                                style: tsOneTextTheme.titleMedium,
                                              ),
                                              Text(
                                                users[index].rank,
                                                style: tsOneTextTheme.bodySmall,
                                              ),
                                              Text(
                                                users[index].idNo.toString(),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            );
                          }
                      )
                          : const Center(child: CircularProgressIndicator())
                    )
                    : Expanded(
                        child: !viewModel.isLoading
                            ? searchedUsers.isNotEmpty
                              ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: searchedUsers.length,
                            itemBuilder: (context, index) {
                              return Card(
                                  surfaceTintColor: TsOneColor.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context,
                                          NamedRoute.detailUser,
                                          arguments: searchedUsers[index].idNo.toString()
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
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
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    searchedUsers[index].name,
                                                    style: tsOneTextTheme.titleMedium,
                                                  ),
                                                  Text(
                                                    searchedUsers[index].rank,
                                                    style: tsOneTextTheme.bodySmall,
                                                  ),
                                                  Text(
                                                    searchedUsers[index].idNo.toString(),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                              );
                            }
                        )
                              : const Center(child: Text("No user found"))
                            : const Center(child: CircularProgressIndicator())
                    )
                  ],
                )
            ),
            /**
             * THIS IS FOR ADD BUTTON.
             * IF YOU WANT TO USE IT, UNCOMMENT THE CODE BELOW.
             * MAKE SURE TO UPDATE THE CODE FOR ADDING USER DATA IN add_user.dart
             */
            /*
            floatingActionButton: FloatingActionButton(
              backgroundColor: TsOneColor.primary,
              onPressed: () {
                Navigator.pushNamed(context, NamedRoute.addUser);
              },
              child: const Icon(Icons.add),
            ),
             */
          );
        },
      ),
    );
  }
}
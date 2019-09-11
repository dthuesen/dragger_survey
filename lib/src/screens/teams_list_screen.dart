import 'dart:developer';

import 'package:dragger_survey/src/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dragger_survey/src/styles.dart';
import 'package:dragger_survey/src/blocs/blocs.dart';
import 'package:dragger_survey/src/screens/splash_screen.dart';

class TeamsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TeamBloc teamBloc = Provider.of<TeamBloc>(context);
    final SignInBloc signInBloc = Provider.of<SignInBloc>(context);

    return FutureBuilder<FirebaseUser>(
      future: signInBloc.currentUser,
      builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
        if (snapshot.connectionState == ConnectionState.none ||
            snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          log("In SurveySetListsScreen _buildSurveySetsListView - ${snapshot.connectionState}");
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.uid == null) {
              log("In teams_list_screen - User is not signed in! - forward to SplashScreen()");
              return SplashScreen();
            }
            return Scaffold(
              backgroundColor: Styles.drg_colorAppBackground,
              endDrawer: UserDrawer(),
              appBar: AppBar(
                actions: <Widget>[
                  SigendInUserCircleAvatar(),
                ],
                title: Text("Your Teams"),
              ),
              body: buildTeamsListView(
                context: context,
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Styles.drg_colorSecondary,
                child: Icon(
                  Icons.people,
                  color: Styles.drg_colorDarkerGreen,
                ),
                tooltip: "Create new Team",
                onPressed: () {
                  print("Add new Team button pressed");
                  teamBloc.updatingTeamData = false;
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Create new Team"),
                          content: TeamForm(),
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(3),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          backgroundColor: Styles.drg_colorSecondary,
                          contentTextStyle:
                              TextStyle(color: Styles.drg_colorText),
                        );
                      });
                },
              ),
            );
          }
          return Container();
        }
        return Container();
      },
    );
  }
}

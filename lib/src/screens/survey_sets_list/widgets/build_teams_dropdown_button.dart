import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dragger_survey/src/blocs/blocs.dart';
import 'package:dragger_survey/src/screens/survey_sets_list/widgets/widgets.dart';
import 'package:dragger_survey/src/shared/shared.dart';
import 'package:dragger_survey/src/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_letter/rounded_letter.dart';
import 'package:rounded_letter/shape_type.dart';

class BuildTeamsDropdownButtonRow extends StatefulWidget {
  final AsyncSnapshot<QuerySnapshot> teamsSnapshot;

  BuildTeamsDropdownButtonRow({this.teamsSnapshot}) : super();
  @override
  _BuildTeamsDropdownButtonRowState createState() =>
      _BuildTeamsDropdownButtonRowState();
}

class _BuildTeamsDropdownButtonRowState
    extends State<BuildTeamsDropdownButtonRow> {
  String _selectedTeamId;
  // DocumentSnapshot _selectedTeam;

  @override
  Widget build(BuildContext context) {
    final TeamBloc teamBloc = Provider.of<TeamBloc>(context);
    FirebaseUser _user = Provider.of<FirebaseUser>(context);
    MediaQueryData mq = MediaQuery.of(context);
    double mqWidth = mq.size.width;

    //// Check if there's a current selected team in the bloc (selected via dropdown or teams list)
    // if (teamBloc?.currentSelectedTeamId != null) {
    //   setState(() {
    //     _selectedTeamId = teamBloc.currentSelectedTeamId;
    //   });
    // }

    if (teamBloc.currentSelectedTeamId == null &&
        widget.teamsSnapshot?.data != null) {
      teamBloc.currentSelectedTeamId =
          widget.teamsSnapshot?.data?.documents[0]?.documentID;
      teamBloc.currentSelectedTeam = widget.teamsSnapshot?.data?.documents[0];
    }
    // if (_selectedTeamId == null && widget.teamsSnapshot?.data != null) {
    //   setState(() {
    //     _selectedTeamId = widget.teamsSnapshot?.data?.documents[0]?.documentID;
    //     _selectedTeam = widget.teamsSnapshot?.data?.documents[0];
    //   });
    //   teamBloc.currentSelectedTeamId = _selectedTeamId;
    //   teamBloc.currentSelectedTeam = _selectedTeam;
    // }

    Stream<QuerySnapshot> streamTeamsQuery = teamBloc
        .streamTeamsQueryByArray(
          fieldName: 'users',
          arrayValue: _user?.uid,
        )
        .handleError((err) => log(
            "ERROR in BuildTeamsDropdownButton getTeamsQueryByArray: $err"));

    if (streamTeamsQuery == null) {
      return Text("No Team Snapshot");
    }

    return Column(
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
          child: SizedBox(
            height: 66,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  /// DROPDOWN BUTTON
                  child: Flexible(
                    flex: 1,
                    // Check if more than 2 teams in db for this user build dropdown button to select a team
                    child: widget.teamsSnapshot.data.documents.length < 2
                        ? buildTeamText(teamsListSnapshot: widget.teamsSnapshot)
                        : DropdownButton(
                            underline: Container(),
                            isExpanded: true,
                            isDense: false,
                            // value: _selectedTeamId,
                            value: teamBloc.currentSelectedTeamId,
                            onChanged: (value) {
                              // setState(() {
                              //   _selectedTeamId = value;
                              // });
                              teamBloc.currentSelectedTeamId = value;

                              showDialog(
                                  context: context,
                                  child: AlertDialog(
                                    title: Text("Current Team: $value"),
                                    content: Text(
                                        "...in bloc: ${teamBloc.currentSelectedTeamId}"),
                                  ));
                              // teamBloc.setCurrentSelectedTeamId(value);

                              // teamBloc
                              //     .streamTeamById(id: value)
                              //     .listen((team) {
                              //   teamBloc.currentSelectedTeam = team;
                              //   teamBloc.currentSelectedTeamId =
                              //       team.documentID;
                              //   if (this.mounted) {
                              //     return;
                              //   } else {
                              //     setState(() {
                              //       _selectedTeam = team;
                              //     });
                              //   }
                              // });
                            },
                            iconSize: 28,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Styles.color_Secondary,
                            ),
                            elevation: 12,
                            hint: Text(
                              "Please Select a Team",
                              style: TextStyle(
                                  color: Styles.color_Text.withOpacity(.8),
                                  fontFamily: 'Bitter',
                                  fontWeight: FontWeight.w700,
                                  height: 2.4),
                              maxLines: 1,
                            ),
                            items: <DropdownMenuItem<dynamic>>[
                              ...widget.teamsSnapshot.data.documents
                                  .map<DropdownMenuItem>(
                                (team) {
                                  return DropdownMenuItem(
                                    key: ValueKey(team.documentID),
                                    value: team.documentID,
                                    child: SingleChildScrollView(
                                      child: Container(
                                        height: 54,
                                        padding:
                                            const EdgeInsets.only(bottom: 0),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Styles.color_AppBackground
                                                  .withOpacity(.6),
                                              width: .5,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 12.0, bottom: 4),
                                              child: RoundedLetter(
                                                text: buildInitials(
                                                    name: team['name']),
                                                fontColor:
                                                    Styles.color_Secondary,
                                                shapeType: ShapeType.circle,
                                                shapeColor:
                                                    Styles.color_Primary,
                                                borderColor:
                                                    Styles.color_Secondary,
                                                shapeSize: 34,
                                                fontSize: 15,
                                                borderWidth: 2,
                                              ),
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: EdgeInsetsDirectional
                                                      .only(top: 6, bottom: 0),
                                                  child: Text(
                                                    "${team['name']}",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      color: Styles.color_Text
                                                          .withOpacity(0.8),
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontFamily: 'Bitter',
                                                      height: .7,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: mqWidth * .55,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 4),
                                                    child: Text(
                                                      team['description'] != ''
                                                          ? "${team['description']}"
                                                          : 'Team has no description',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color: Styles
                                                              .color_SecondaryDeepDark
                                                              .withOpacity(.8),
                                                          fontFamily: 'Bitter',
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 14,
                                                          height: 1.6),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ).toList()
                            ],
                          ),
                  ),
                ),
                BuildFilterSort(),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: Styles.color_Secondary.withOpacity(.2),
        ),
      ],
    );
  }

  Widget buildTeamText({AsyncSnapshot<QuerySnapshot> teamsListSnapshot}) {
    DocumentSnapshot teamDoc;

    if (teamsListSnapshot.connectionState != ConnectionState.active) {
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 50),
          child: AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
              strokeWidth: 10,
            ),
          ),
        ),
      );
    }

    if (!teamsListSnapshot.hasData) {
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 50),
          child: AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
              strokeWidth: 10,
            ),
          ),
        ),
      );
    }

    teamDoc = teamsListSnapshot?.data?.documents[0];

    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: RichText(
        overflow: TextOverflow.clip,
        maxLines: 2,
        text: TextSpan(
          text: "Your Team: ",
          style: TextStyle(color: Styles.color_Text, fontSize: 20),
          children: [
            TextSpan(
              text: "${teamDoc['name']}",
              style: TextStyle(
                  color: Styles.color_Text,
                  fontSize: 22,
                  fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: teamDoc['description'] != ''
                  ? "\n${teamDoc['description']}"
                  : "\nTeam has no description",
              style: TextStyle(
                color: Styles.color_Text,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
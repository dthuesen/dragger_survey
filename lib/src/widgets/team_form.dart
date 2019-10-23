import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dragger_survey/src/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dragger_survey/src/blocs/blocs.dart';

class TeamForm extends StatefulWidget {
  final String id;
  TeamForm({this.id}) : super();

  @override
  _TeamFormState createState() => _TeamFormState();
}

class _TeamFormState extends State<TeamForm> {
  // autogenerated

  final _formKey = GlobalKey<FormState>();
  bool _formHasChanged = false;

  // required
  DateTime _created = DateTime.now().toUtc();
  String _name;

  // Optional
  String _description = "";
  dynamic _users = [];
  dynamic _prismSurveySets = [];

  // When edited
  DateTime _edited = DateTime.now().toUtc();

  // Meta information
  String _createdByUser;
  String _lastEditedByUser;

  FocusNode firstFocus;
  FocusNode secondFocus;
  FocusNode thirdFocus;
  FocusNode fourthFocus;
  FocusNode fifthFocus;
  FocusNode sixthFocus;

  // loaded from db by id
  DocumentSnapshot _selectedTeam;

  @override
  void initState() {
    super.initState();
    firstFocus = FocusNode();
    secondFocus = FocusNode();
    thirdFocus = FocusNode();
    fourthFocus = FocusNode();
    fifthFocus = FocusNode();
    sixthFocus = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    firstFocus.dispose();
    secondFocus.dispose();
    thirdFocus.dispose();
    fourthFocus.dispose();
    fifthFocus.dispose();
    sixthFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: () {
        if (_formKey.currentState.validate()) {
          setState(() {
            _formHasChanged = true;
          });
        }
      },
      child: _buildForm(
          context: context, formKey: _formKey, documentId: widget.id),
    );
  }

  Widget _buildForm({@required context, @required formKey, String documentId}) {
    final TeamBloc teamBloc = Provider.of<TeamBloc>(context);

    log("---------> In TeamForm _buildForm - documentId: $documentId");

    if (documentId == null) {
      teamBloc.updatingTeamData = false;
    } else {
      teamBloc.updatingTeamData = true;
    }

    return FutureBuilder(
      future: teamBloc.getTeamById(id: documentId),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> teamSnapshot) {
        if (!teamSnapshot.hasData) {
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 200),
              child: AspectRatio(
                aspectRatio: 1,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  initialValue:
                      documentId != null ? teamSnapshot?.data['name'] : '',
                  autofocus: true,
                  focusNode: firstFocus,
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(secondFocus),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  // style: Styles.drg_textFieldContent,
                  decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor:
                          Styles.drg_colorAppBackgroundLight.withOpacity(.5),
                      labelStyle: TextStyle(
                        color: Styles.drg_colorAppBackground,
                      ),
                      labelText: "Team Name",
                      hintStyle: TextStyle(
                        fontSize: Styles.drg_fontSizeHintText,
                      ),
                      hintText: "Please provide a team name",
                      errorStyle: TextStyle(
                        fontSize: 14,
                        color: Styles.drg_colorAppBackgroundShiny,
                        backgroundColor: Styles.drg_colorAttention,
                      )),
                  validator: (value) {
                    if (value.isEmpty) {
                      return '  Please enter a team name  ';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  minLines: 2,
                  maxLines: 9,
                  maxLength: 200,
                  initialValue: documentId != null
                      ? teamSnapshot?.data['description']
                      : '',
                  focusNode: secondFocus,
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(thirdFocus),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  style: Styles.drg_textFieldContent,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      // borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          style: BorderStyle.solid,
                          color: Styles.drg_colorAppBackground),
                    ),
                    filled: true,
                    fillColor:
                        Styles.drg_colorAppBackgroundLight.withOpacity(.5),
                    labelStyle: TextStyle(
                      color: Styles.drg_colorText,
                    ),
                    labelText: "Team description",
                    hintText: "How would you like to describe your team",
                  ),
                  onSaved: (value) => _description = value,
                ),
              ),
              _buildFormButton(
                bloc: teamBloc,
                context: context,
                formKey: formKey,
              ),
            ],
          ),
        );
      },
    );
  }

  String getInitialValue(TeamBloc bloc, AsyncSnapshot snapshot) {
    print("----------========>>> snapshot ::: $snapshot");
    print("----------========>>> snapshot?.data ::: ${snapshot?.data}");
    // print("----------========>>> snapshot?.data['name'] ::: ${snapshot?.data['name']}");
    // print("----------========>>> snapshot?.data['description'] ::: ${snapshot?.data['description']}");
    if (!bloc.updatingTeamData) {
      return '';
    }
    return snapshot?.data['name'];
    // print("----------========>>> snapshot?.data['desciption'] ::: ${snapshot?.data['name']}");
    // if(bloc.updatingTeamData == null) {
    //   return '';
    // } else if (snapshot?.data['name'] == null) {
    //   return '';
    // }
    // return '${snapshot?.data['name']}';
  }

  Widget _buildFormButton(
      {@required bloc, @required context, @required formKey}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: <Widget>[
          _buildSubmitButton(formKey, context),
          _buildCancelButton(context)
        ],
      ),
    );
  }

  SizedBox _buildSubmitButton(formKey, context) {
    final TeamBloc teamBloc = Provider.of<TeamBloc>(context);

    return SizedBox(
      width: double.infinity,
      child: FlatButton(
        disabledColor: Colors.orange.shade50.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Styles.drg_colorPrimary,
        textColor: Colors.white,
        onPressed: _formHasChanged
            ? () {
                _buttonOnPressed(context: context, formKey: formKey);
                log("In TeamForm Submit button presssed - form has changed");
                Navigator.of(context).pop();
              }
            : () {
                log("In TeamForm Submit button presssed - form has NOT changed");
              },
        child: teamBloc.updatingTeamData ? Text('Update') : Text('Submit'),
      ),
    );
  }

  SizedBox _buildCancelButton(context) {
    return SizedBox(
      width: double.infinity,
      child: FlatButton(
        textColor: Styles.drg_colorPrimary,
        onPressed: () {
          print("Cancel button presssed");
          Navigator.of(context).pop();
        },
        child: Text('Cancel'),
      ),
    );
  }

  void _sendFormValuesToBloc({@required BuildContext context}) {
    final TeamBloc teamBloc = Provider.of<TeamBloc>(context);

    Map<String, dynamic> team;
    if (teamBloc.updatingTeamData) {
      team = {
        "edited": _edited,
        "name": _name,
        "description": _description,
        "lastEditedByUser": _lastEditedByUser,
      };
    } else {
      team = {
        "created": _created,
        "name": _name,
        "description": _description,
        "createdByUser": _createdByUser,
        "lastEditedByUser": _lastEditedByUser,
        "users": _users,
      };
    }
    print("===============================");
    print("Values sent to bloc:");
    print("_created: $_created");
    print("_edited: $_edited");
    print("_name: $_name");
    print("_description: $_description");
    print("_createdByUser: $_createdByUser");
    print("_lastEditedByUser: $_lastEditedByUser");
    print("_users: $_users");
    print("================================");

    if (teamBloc.updatingTeamData) {
      teamBloc.updateTeamById(object: team, id: teamBloc.currentSelectedTeamId);
    } else {
      teamBloc.addTeamToDb(team: team);
    }
    print("2 team) ----> Form values have been sent to bloc");
  }

  void _buttonOnPressed({formKey, @required BuildContext context}) {
    final TeamBloc teamBloc = Provider.of<TeamBloc>(context);
    FirebaseUser user = Provider.of<FirebaseUser>(context);

    log("----> In TeamForm _buttonOnPressed");

    if (formKey.currentState.validate()) {
      print("1a TeamForm) ----> Form has been validated.");
      if (!(teamBloc.updatingTeamData)) {
        _createdByUser = user.uid;
        _users.add(user.uid);
      } else {
        _lastEditedByUser = user.uid;
      }
      formKey.currentState.save();

      _sendFormValuesToBloc(context: context);
      print("1b TeamForm) ----> Sending form values to bloc.");

      print("1c TeamForm) ----> Sent data:");
      print("_created: $_created");
      print("_name: $_name");
      print("_description: $_description");
      print("_createdByUser: $_createdByUser");
      print("_lastEditedByUser: $_lastEditedByUser");
      print("_users: $_users");
    }
  }
}

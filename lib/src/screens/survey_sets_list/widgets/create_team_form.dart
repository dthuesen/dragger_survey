import 'dart:developer';

import 'package:dragger_survey/src/screens/survey_sets_list/widgets/widgets.dart';
import 'package:dragger_survey/src/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dragger_survey/src/blocs/blocs.dart';

class CreateTeamForm extends StatefulWidget {
  final String id;
  CreateTeamForm({this.id}) : super();

  @override
  _CreateTeamFormState createState() => _CreateTeamFormState();
}

class _CreateTeamFormState extends State<CreateTeamForm> {
  // autogenerated

  final _formKey = GlobalKey<FormState>();

  // required
  DateTime _created = DateTime.now().toUtc();
  String _name;

  // Optional
  String _description = "";
  dynamic _users = [];

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
      child: _buildForm(context: context, formKey: _formKey),
    );
  }

  Widget _buildForm({@required context, @required formKey}) {
    final TeamBloc teamBloc = Provider.of<TeamBloc>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: TextFormField(
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
                    fillColor: Styles.color_AppBackgroundLight.withOpacity(.5),
                    labelStyle: TextStyle(
                      color: Styles.color_AppBackground,
                    ),
                    labelText: "Team Name",
                    hintStyle: TextStyle(
                      fontSize: Styles.fontSize_HintText,
                    ),
                    hintText: "Please provide a team name",
                    errorStyle: TextStyle(
                      fontSize: 14,
                      color: Styles.color_AppBackgroundShiny,
                      backgroundColor: Styles.color_Attention,
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
                focusNode: secondFocus,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(thirdFocus),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                style: TextStyle(
                  fontSize: Styles.fontSize_FieldContentText,
                  fontWeight: FontWeight.w400,
                  color: Styles.color_SecondaryDeepDark,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        style: BorderStyle.solid,
                        color: Styles.color_AppBackground),
                  ),
                  filled: true,
                  fillColor: Styles.color_AppBackgroundLight.withOpacity(.5),
                  labelStyle: TextStyle(
                    color: Styles.color_Text,
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
      ),
    );
  }

  String getInitialValue(TeamBloc bloc, AsyncSnapshot snapshot) {
    if (!bloc.updatingTeamData) {
      return '';
    }
    return snapshot?.data['name'];
  }

  Widget _buildFormButton(
      {@required bloc, @required context, @required formKey}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: <Widget>[
          _buildSubmitButton(formKey, context),
          new BuildCancelButton(context: context),
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
        color: Styles.color_Primary,
        textColor: Colors.white,
        onPressed: () {
          _submitButtonOnPressed(context: context, formKey: formKey);
          log("In TeamForm Submit button presssed - form has changed");
          Navigator.of(context).pop();
        },
        child: teamBloc.updatingTeamData ? Text('Update') : Text('Submit'),
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
  }

  void _submitButtonOnPressed({formKey, @required BuildContext context}) {
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

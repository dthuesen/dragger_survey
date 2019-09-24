import 'dart:developer';

import 'package:dragger_survey/src/blocs/blocs.dart';
import 'package:dragger_survey/src/screens/screens.dart';
import 'package:dragger_survey/src/styles.dart';
import 'package:dragger_survey/src/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DraggerScreen extends StatefulWidget {
  DraggerScreen({Key key}) : super(key: key);
  @override
  _DraggerScreenState createState() => _DraggerScreenState();
}

class _DraggerScreenState extends State<DraggerScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _xName = '';
  String _yName = '';

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final PrismSurveySetBloc prismSurveySetBloc =
        Provider.of<PrismSurveySetBloc>(context);
    var surveySet = await prismSurveySetBloc?.currentPrismSurveySet;
    setState(() {
      _xName = surveySet?.data['xName'];
      _yName = surveySet?.data['yName'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final MatrixGranularityBloc matrixGranularityBloc =
        Provider.of<MatrixGranularityBloc>(context);
    final PrismSurveyBloc prismSurveyBloc =
        Provider.of<PrismSurveyBloc>(context);
    final PrismSurveySetBloc prismSurveySetBloc =
        Provider.of<PrismSurveySetBloc>(context);
    final SignInBloc signInBloc = Provider.of<SignInBloc>(context);

    if (signInBloc.currentUser == null) {
      print("User is not signed in!");
      return SplashScreen();
    } else {}

    if (prismSurveySetBloc.currentPrismSurveySet == null) {
      log("In Dragger Screen prismSurveySetBloc.currentPrismSurveySet == null: ${prismSurveySetBloc.currentPrismSurveySet == null}");
    }


    // return FutureBuilder<DocumentSnapshot>(
    //     future: prismSurveySetBloc?.currentPrismSurveySet,
    //     builder: (context, surveySetSnapshot) {
    //       if (surveySetSnapshot.connectionState == ConnectionState.done) {
    //         try {
    //           setState(() {
    //             _xName = surveySetSnapshot?.data['xName'];
    //             _yName = surveySetSnapshot?.data['yName'];
    //           });
    //         } catch(e) {
    //           log("ERROR IN MatrixBoard: $e");
    //         }
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      BuildAskedRoleForm(
                        formKey: _formKey,
                      ),
                      BuildBoard(xLabel: _xName, yLabel: _yName,),
                      Text(
                          "Granularity: ${matrixGranularityBloc.matrixGranularity} \nStone is dragged to \n$_xName: ${prismSurveyBloc.rowIndex} \n$_yName: ${prismSurveyBloc.colIndex}"),
                      DraggerBoardButtonRow(
                        formKey: _formKey,
                      ),
                    ],
                  ),
                ),
              );
          // }
          // return Container();
        // }
        // );
  }
}

class BuildAskedRoleForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  BuildAskedRoleForm({this.formKey});

  @override
  _BuildAskedRoleFormState createState() => _BuildAskedRoleFormState();
}

class _BuildAskedRoleFormState extends State<BuildAskedRoleForm> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = '';
  }

  @override
  Widget build(BuildContext context) {
    final PrismSurveyBloc prismSurveyBloc =
        Provider.of<PrismSurveyBloc>(context);

    return Form(
        key: widget.formKey,
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Name or role",
                  textAlign: TextAlign.left,
                ),
              ),
              TextFormField(
                onChanged: (val) {
                  setState(() {
                    _controller.text = val;
                  });
                  prismSurveyBloc.currentAskedPerson = _controller.text;
                },
                validator: (val) {
                  if (val.trim().length < 2) {
                    return '  At least 2 characters  ';
                  }
                  if (val.trim().length > 30) {
                    return '  Max 30 characters  ';
                  }
                  return null;
                },
                autovalidate: false,
                maxLines: 1,
                maxLength: 30,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: Colors.white60,
                    // labelText: "Role or name",
                    hintText: "Name or Role of asked person.",
                    labelStyle: TextStyle(color: Styles.drg_colorAppBackground),
                    // focusColor: Colors.white,
                    errorStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                        backgroundColor: Styles.drg_colorAttention,
                        fontWeight: FontWeight.w700),
                    counterStyle: TextStyle(
                      color: Styles.drg_colorText,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 3,
                        style: BorderStyle.solid,
                      ),
                    )),
              ),
            ],
          ),
        ));
  }
}

class BuildBoard extends StatelessWidget {
  final String xLabel;
  final String yLabel;
  BuildBoard({this.xLabel, this.yLabel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        MatrixBoard(xLabel: xLabel, yLabel: yLabel,),
        // MatrixBoard(xLabel: xLabel, yLabel: yLabel,),
      ],
    );
  }
}

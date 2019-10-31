import 'dart:developer';

import 'package:dragger_survey/src/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dragger_survey/src/blocs/blocs.dart';

class SelectGranularity extends StatelessWidget {
  final GlobalKey<FormState> formkey;
  SelectGranularity({this.formkey}) : super();
  @override
  Widget build(BuildContext context) {
    final MatrixGranularityBloc granularityBloc =
        Provider.of<MatrixGranularityBloc>(context);

    final _textStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Styles.drg_colorText,
    );
    final _granularityArray = MatrixGranularityBloc.GRANULARITY;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "Select granularity ",
          style: Styles.drg_selectButton,
        ),
        Spacer(),
        DropdownButton(
          isDense: true,
          key: this.formkey,
          style: _textStyle,
          value: granularityBloc.matrixGranularity,
          onChanged: (int newValue) {
            log("In SelectGranularity DropdownButton onChanged newValue: $newValue");
            granularityBloc.setNewGranularity(granularity: newValue);
          },
          items: _granularityArray.map<DropdownMenuItem<int>>((int value) {
            log("--->In selectGranularity value: $value");
            return DropdownMenuItem<int>(
              key: formkey,
              value: value,
              child: Text("$value"),
            );
          }).toList(),
        )
      ],
    );
  }
}

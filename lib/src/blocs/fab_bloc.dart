import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FabBloc extends ChangeNotifier {
  bool _fabVisible = true;

  set fabToVisible(_) {
    _fabVisible = true;
    notifyListeners();
  }

  set fabToInVisible(_) {
    _fabVisible = false;
    notifyListeners();
  }

  get fabVisibilty {
    return _fabVisible;
  }

  setFabToInvisible() {
    _fabVisible = false;
    notifyListeners();
  }

  setFabToVisible() {
    _fabVisible = false;
    notifyListeners();
  }
}

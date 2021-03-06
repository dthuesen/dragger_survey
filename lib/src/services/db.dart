import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import './globals.dart';

class Document<T> {
  final Firestore _db = Firestore.instance;
  final String path;
  DocumentReference ref;

  Document({this.path}) {
    ref = _db.document(path);
  }

  Future<T> getData() {
    return ref.get().then((value) => Global.models[T](value.data) as T);
  }

  Stream<T> streamData() {
    return ref.snapshots().map((value) => Global.models[T](value.data) as T);
  }

  Future<void> upsert(Map data) {
    return ref.setData(Map<String, dynamic>.from(data), merge: true);
  }
}

class Collection<T> {
  final Firestore _db = Firestore.instance;
  final String path;
  CollectionReference ref;

  Collection({this.path}) {
    _db.settings(persistenceEnabled: true);
    ref = _db.collection(path);
  }

  Future<List<T>> getData() async {
    var snapshots = await ref.getDocuments();
    return snapshots.documents
        .map((doc) => Global.models[T].fromFirestore(doc.data) as T)
        .toList();
  }

  Future<List<T>> getDocuments() async {
    var snapshots = await ref.getDocuments();
    return snapshots.documents
        .map((doc) => Global.models[T].fromFirestore(doc.data) as T);
  }

  Future<QuerySnapshot> getDocumentsByQuery(
      {String fieldName, String fieldValue}) async {
    return ref.where(fieldName, isEqualTo: fieldValue).getDocuments();
  }

  Future<QuerySnapshot> getDocumentsByQueryOrderByField(
      {@required String fieldName,
      @required String fieldValue,
      @required String orderField,
      bool descending}) async {
    return ref
        .where(fieldName, isEqualTo: fieldValue)
        .orderBy(orderField, descending: descending)
        .getDocuments()
        .catchError(
            (e) => log("ERROR in db.dart getDocumentsByQueryOrderByField: $e"));
  }

  Future<QuerySnapshot> getDocumentsByQuerySortByCreatedAsc(
      {String fieldName, String fieldValue}) async {
    return ref
        .where(fieldName, isEqualTo: fieldValue)
        .orderBy('created', descending: false)
        .getDocuments()
        .catchError((e) =>
            log("ERROR in db.dart getDocumentsByQuerySortByCreatedDesc: $e"));
  }

  Future<QuerySnapshot> getDocumentsByQuerySortByCreatedDesc(
      {String fieldName, String fieldValue}) async {
    return ref
        .where(fieldName, isEqualTo: fieldValue)
        .orderBy('created', descending: true)
        .getDocuments()
        .catchError((e) =>
            print("ERROR in db.dart getDocumentsByQuerySortByCreatedDesc: $e"));
  }

  Stream<QuerySnapshot> streamDocumentsByQueryOrderByField(
      {@required String fieldName,
      @required String fieldValue,
      @required String orderField,
      bool descending}) {
    return ref
        .where(fieldName, isEqualTo: fieldValue)
        .orderBy(orderField, descending: descending)
        .snapshots()
        .handleError((e) => log("ERROR in db.dart getDocumentsByQueryOrderByField: $e"));
  }

  Stream<QuerySnapshot> streamDocumentsByQuerySortByCreatedAsc(
      {String fieldName, String fieldValue}) {
    return ref
        .where(fieldName, isEqualTo: fieldValue)
        .orderBy('created', descending: false)
        .snapshots()
        .handleError((e) =>
            log("ERROR in db.dart getDocumentsByQuerySortByCreatedDesc: $e"));
  }

  Stream<QuerySnapshot> streamDocumentsByQuerySortByCreatedDesc(
      {String fieldName, String fieldValue}) {
    return ref
        .where(fieldName, isEqualTo: fieldValue)
        .orderBy('created', descending: true)
        .snapshots()
        .handleError((e) =>
            print("ERROR in db.dart getDocumentsByQuerySortByCreatedDesc: $e"));
  }

  Future<QuerySnapshot> getDocumentsByQueryArray(
      {String fieldName, String arrayValue}) {
    return ref.where(fieldName, arrayContains: arrayValue).getDocuments();
  }

  Future deleteItemsFromDocumentsArrayById(
      {String fieldName, String id}) async {
    // 1) Find all documents where 'fieldname' array contains id
    QuerySnapshot documentsSnapshot =
        await ref.where(fieldName, arrayContains: id).getDocuments();

    // 2) For each document of documentsSnapshot...
    documentsSnapshot.documents.forEach((DocumentSnapshot document) async {
      // 3) ...extract the document ID
      String _documentID = document.documentID;
      // 4) ...get the document by ID...
      DocumentSnapshot _documentSnapshot =
          await ref.document('$_documentID').get();
      // DocumentSnapshot _doc = await docRef.get();
      List<dynamic> _usersList;

      try {
        // 5) extract the user array...
        _usersList = _documentSnapshot.data[fieldName].toList();
        // List<dynamic> _usersList = _doc.data[fieldName].toList();
      } catch (err) {
        log("ERROR in DB deleteItemsFromDocumentsArrayById - _doc[fieldName].toList(), error: $err");
      }

      // 6) ...remove desired items from array...
      _usersList.removeWhere((arrayItem) => arrayItem.toString() == id);

      // 7) ...replace array in snapshot...
      _documentSnapshot.data[fieldName] = _usersList;

      try {
        log("--> 1)   In DB - deleted arrayValue: $id from doc id: $_documentID");
        // ...replace document data with snapshot data
        return ref.document('$_documentID').setData(_documentSnapshot.data);
      } catch (error) {
        print('Error occured while updating data: $error');
      }
    });
  }

  Stream<QuerySnapshot> streamDocumentsByQueryArray(
      {String fieldName, String arrayValue}) {
    return ref.where(fieldName, arrayContains: arrayValue).snapshots();
  }

  Future<DocumentSnapshot> getDocument(id) async {
    try {
      DocumentSnapshot _doc = await ref.document('$id').get();
      if (!_doc.exists) {
        print(
            "NO SUCCESS!!! In DB getDocument - document found: ${_doc.documentID}");
        return null;
      }
      print("SUCCESS! In DB getDocument - document found: ${_doc.exists}");
      return _doc;
    } catch (e) {
      log("ERROR in DB.dart - getDocument(id) - error: $e");
      return null;
    }
  }

  Future<bool> checkIfDocumentExists(id) async {
    bool _exists = await ref.document(id).get().then((doc) => doc.exists);
    return _exists;
  }

  createDocumentWithValues({
    @required name,
    description = "",
    resolution = 5,
    @required xName,
    xDescription = "",
    @required yName,
    yDescription = "",
  }) async {
    return _db.collection(path).add({
      "created": DateTime.now(),
      "name": name,
      "description": description,
      "resolution": resolution,
      "xName": xName,
      "xDescription": xDescription,
      "yName": yName,
      "yDescription": yDescription,
    });
  }

  Future createDocumentWithObject({object}) async {
    print("In DB.dart createDocumentWithObject - value of object: $object");
    DocumentReference retunedValue = await ref.add(object);

    log("In DB.dart createDocumentWithObject retunedValue doc.documentID ${retunedValue.documentID}");
    return retunedValue;
  }

  updateDocumentWithObject({object, id}) async {
    try {
      ref.document('$id').updateData(object);
    } catch (error) {
      print('Error occured while updating data: $error');
    } finally {
      print("End of updateDocumentWithObject()");
    }
  }

  updateDocumentByIdWithFieldAndValue({id, field, value}) async {
    try {
      ref.document('$id').updateData({'$field': value});
    } catch (error) {
      print('Error occured while updating data: $error');
    } finally {
      print("End of updateDocumentByIdWithFieldAndValue()");
    }
  }

  updateArrayInDocumentByIdWithFieldAndValue({id, field, value}) async {
    try {
      ref.document('$id').updateData({
        '$field': FieldValue.arrayUnion(['$value'])
      });
    } catch (error) {
      print('Error occured while updating data: $error');
    } finally {
      print("End of updateArrayInDocumentByIdWithFieldAndValue()");
    }
  }

  Stream<QuerySnapshot> streamDocuments() {
    return ref.snapshots();
  }

  Stream<DocumentSnapshot> streamDocumentById(id) {
    return ref.document('$id').snapshots();
  }

  Stream<List<T>> streamData() {
    return ref
        .snapshots()
        .map((list) => list.documents.map((doc) => Global.models[T] as T));
  }

  deleteQueryById({fieldName, id}) {
    ref.where(fieldName, arrayContains: id).getDocuments().then((documents) {
      documents.documents.forEach((doc) {
        deleteById(doc.documentID);
      });
    });
  }

  deleteById(id) {
    print(">>>>>>>-------------------> Delete document by ID: $id");
    ref.document('$id').delete().catchError(
          (err) => debugPrint("ERROR in DB - Method deleteById(): $err"),
        );
  }

  Future<QuerySnapshot> deleteDocumentsChildrenByQuery(
      {String fieldName, String fieldValue}) async {
    QuerySnapshot returnedDocuments =
        // 1) find all documents where the fieldnames value is equal to field value
        await ref.where(fieldName, isEqualTo: fieldValue).getDocuments().then(
      (documents) {
        documents.documents.forEach(
          (document) async {
            // 2) For each returned documents Id find and delete a document
            await deleteById(document.documentID);
          },
        );
        log(">>>>>>>-------------------> Delete document by ID: $fieldValue");
        return documents;
      },
    ).catchError(
      (err) => debugPrint(
        "ERROR in DB - Method deleteDocumentsChildrenByQuery(): $err",
      ),
    );
    return returnedDocuments;
  }
}

class UserData<T> {
  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String collection;

  UserData({this.collection});

  Stream<T> get documentStream {
    return Observable(_auth.onAuthStateChanged).switchMap((user) {
      if (user != null) {
        Document<T> doc = Document<T>(path: '$collection/${user.uid}');
        return doc.streamData();
      } else {
        return Observable<T>.just(null);
      }
    });
  }

  Future<T> getDocument() async {
    FirebaseUser user = await _auth.currentUser();

    if (user != null) {
      Document doc = Document<T>(path: '$collection/${user.uid}');
      return doc.getData();
    } else {
      return null;
    }
  }

  Future<void> upsert(Map data) async {
    FirebaseUser user = await _auth.currentUser();
    Document<T> ref = Document(path: '$collection/${user.uid}');
    return ref.upsert(data);
  }
}

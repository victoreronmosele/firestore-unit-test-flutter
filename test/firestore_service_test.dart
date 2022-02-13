import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firestore_unit_test_flutter/firestore_service.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';

void main() {
  group('FirestoreService', () {
    FakeFirebaseFirestore? fakeFirebaseFirestore;
    const Map<String, dynamic> data = {'data': '42'};

    setUp(() {
      fakeFirebaseFirestore = FakeFirebaseFirestore();
    });

    group(
      'Collection Operations',
      () {
        test('addToCollection adds data to given collection', () async {
          final FirestoreService firestoreService =
              FirestoreService(firestore: fakeFirebaseFirestore!);
          const String collectionPath = 'collectionPath';

          await firestoreService.addToCollection(
              data: data, collectionPath: collectionPath);

          final List<Map<String, dynamic>> actualDataList =
              (await fakeFirebaseFirestore!.collection('collectionPath').get())
                  .docs
                  .map((e) => e.data())
                  .toList();

          expect(actualDataList, const MapListContains(data));
        });

        test('getFromCollection gets data from a given collection', () async {
          final FirestoreService firestoreService =
              FirestoreService(firestore: fakeFirebaseFirestore!);
          const String collectionPath = 'collectionPath';

          await fakeFirebaseFirestore!.collection(collectionPath).add(data);

          final List<Map<String, dynamic>> dataList = (await firestoreService
                  .getFromCollection(collectionPath: collectionPath))
              .docs
              .map((e) => e.data())
              .toList();

          expect(dataList, const MapListContains(data));
        });

        test(
            'getSnapshotStreamFromCollection returns a stream of QuerySnaphot containing the data added',
            () async {
          final FirestoreService firestoreService =
              FirestoreService(firestore: fakeFirebaseFirestore!);
          const String collectionPath = 'collectionPath';

          final CollectionReference<Map<String, dynamic>> collectionReference =
              fakeFirebaseFirestore!.collection(collectionPath);
          await collectionReference.add(data);

          final Stream<QuerySnapshot<Map<String, dynamic>>>
              expectedSnapshotStream = collectionReference.snapshots();

          final actualSnapshotStream = firestoreService
              .getSnapshotStreamFromCollection(collectionPath: collectionPath);

          final QuerySnapshot<Map<String, dynamic>> expectedQuerySnapshot =
              await expectedSnapshotStream.first;
          final QuerySnapshot<Map<String, dynamic>> actualQuerySnapshot =
              await actualSnapshotStream.first;

          final List<Map<String, dynamic>> expectedDataList =
              expectedQuerySnapshot.docs.map((e) => e.data()).toList();
          final List<Map<String, dynamic>> actualDataList =
              actualQuerySnapshot.docs.map((e) => e.data()).toList();

          expect(actualDataList, expectedDataList);
        });
      },
    );

    group('Document Operations', () {
      test(
          'deleteDocumentFromCollection deletes a document from a given collection',
          () async {
        final FirestoreService firestoreService =
            FirestoreService(firestore: fakeFirebaseFirestore!);
        const String collectionPath = 'collectionPath';

        final CollectionReference<Map<String, dynamic>> collectionReference =
            fakeFirebaseFirestore!.collection(collectionPath);

        final DocumentReference<Map<String, dynamic>> documentReference =
            await collectionReference.add(data);

        final String documentPath = documentReference.path;

        await firestoreService.deleteDocumentFromCollection(
            collectionPath: collectionPath, documentPath: documentPath);

        final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            await collectionReference.doc(documentPath).get();

        expect(documentSnapshot.exists, false);
      });

      test('getFromDocument gets data from a given document', () async {
        final FirestoreService firestoreService =
            FirestoreService(firestore: fakeFirebaseFirestore!);

        const String collectionPath = 'collectionPath';
        const String documentPath = 'documentPath';

        final DocumentReference<Map<String, dynamic>> documentReference =
            fakeFirebaseFirestore!.collection(collectionPath).doc(documentPath);

        await documentReference.set(data);

        final DocumentSnapshot<Map<String, dynamic>> expectedDocumentSnapshot =
            await documentReference.get();

        final DocumentSnapshot<Map<String, dynamic>> actualDocumentSnapshot =
            await firestoreService.getFromDocument(
                collectionPath: collectionPath, documentPath: documentPath);

        final Map<String, dynamic>? expectedData =
            expectedDocumentSnapshot.data();
        final Map<String, dynamic>? actualData = actualDocumentSnapshot.data();

        expect(actualData, expectedData);
      });

      test('setDataOnDocument sets data on a given document', () async {
        final FirestoreService firestoreService =
            FirestoreService(firestore: fakeFirebaseFirestore!);

        const String collectionPath = 'collectionPath';
        const String documentPath = 'documentPath';

        await firestoreService.setDataOnDocument(
            data: data,
            collectionPath: collectionPath,
            documentPath: documentPath);

        final DocumentReference<Map<String, dynamic>> documentReference =
            fakeFirebaseFirestore!.collection(collectionPath).doc(documentPath);

        final DocumentSnapshot<Map<String, dynamic>> actualDocumentSnapshot =
            await documentReference.get();
        final Map<String, dynamic>? actualData = actualDocumentSnapshot.data();

        const Map<String, dynamic> expectedData = data;

        expect(actualData, expectedData);
      });

      test(
          'getSnapshotStreamFromDocument returns a stream of DocumentSnapshot containing the data set',
          () async {
        final FirestoreService firestoreService =
            FirestoreService(firestore: fakeFirebaseFirestore!);

        const String collectionPath = 'collectionPath';
        const String documentPath = 'documentPath';

        final DocumentReference<Map<String, dynamic>> documentReference =
            fakeFirebaseFirestore!.collection(collectionPath).doc(documentPath);

        await documentReference.set(data);

        final Stream<DocumentSnapshot<Map<String, dynamic>>>
            expectedSnapshotStream = documentReference.snapshots();

        final Stream<DocumentSnapshot<Map<String, dynamic>>>
            actualSnapshotStream =
            firestoreService.getSnapshotStreamFromDocument(
                collectionPath: collectionPath, documentPath: documentPath);

        final DocumentSnapshot<Map<String, dynamic>> expectedDocumentSnapshot =
            await expectedSnapshotStream.first;
        final DocumentSnapshot<Map<String, dynamic>> actualDocumentSnapshot =
            await actualSnapshotStream.first;

        final Map<String, dynamic>? expectedData =
            expectedDocumentSnapshot.data();
        final Map<String, dynamic>? actualData = actualDocumentSnapshot.data();

        expect(actualData, expectedData);
      });

      test('updateDataOnDocument updates a given document\'s data', () async {
        final FirestoreService firestoreService =
            FirestoreService(firestore: fakeFirebaseFirestore!);

        const String collectionPath = 'collectionPath';
        const String documentPath = 'documentPath';

        final DocumentReference<Map<String, dynamic>> documentReference =
            fakeFirebaseFirestore!.collection(collectionPath).doc(documentPath);

        await documentReference.set(data);

        final Map<String, dynamic> dataUpdate = {'data': '43'};

        await firestoreService.updateDataOnDocument(
            data: dataUpdate,
            collectionPath: collectionPath,
            documentPath: documentPath);

        final DocumentSnapshot<Map<String, dynamic>> actualDocumentSnapshot =
            await documentReference.get();

        final Map<String, dynamic>? actualData = actualDocumentSnapshot.data();

        final Map<String, dynamic> expectedData = dataUpdate;

        expect(actualData, expectedData);
      });
    });
  });
}

class MapListContains extends Matcher {
  final Map<dynamic, dynamic> _expected;

  const MapListContains(this._expected);

  @override
  Description describe(Description description) {
    return description.add('contains ').addDescriptionOf(_expected);
  }

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is List<Map>) {
      return item.any((element) => mapEquals(element, _expected));
    }
    return false;
  }
}

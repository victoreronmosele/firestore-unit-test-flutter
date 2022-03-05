import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  const FirestoreService({required this.firestore});

  final FirebaseFirestore firestore;

  /// Collection Operations

  Future<DocumentReference<Map<String, dynamic>>> addToCollection(
      {required Map<String, dynamic> data,
      required String collectionPath}) async {
    return firestore.collection(collectionPath).add(data);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getFromCollection(
      {required String collectionPath}) async {
    return firestore.collection(collectionPath).get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getSnapshotStreamFromCollection(
      {required String collectionPath}) {
    return firestore.collection(collectionPath).snapshots();
  }

  /// Document Operations

  Future<void> deleteDocumentFromCollection(
      {required String collectionPath, required String documentPath}) async {
    return firestore.collection(collectionPath).doc(documentPath).delete();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getFromDocument(
      {required String collectionPath, required String documentPath}) async {
    return firestore.collection(collectionPath).doc(documentPath).get();
  }

  Future<void> setDataOnDocument(
      {required Map<String, dynamic> data,
      required String collectionPath,
      required String documentPath}) async {
    return firestore.collection(collectionPath).doc(documentPath).set(data);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getSnapshotStreamFromDocument(
      {required String collectionPath, required String documentPath}) {
    return firestore.collection(collectionPath).doc(documentPath).snapshots();
  }

  Future<void> updateDataOnDocument(
      {required Map<String, dynamic> data,
      required String collectionPath,
      required String documentPath}) async {
    return firestore.collection(collectionPath).doc(documentPath).update(data);
  }

  Future<void> runTransaction({
    required Map<String, dynamic> dataToUpdate,
    required Map<String, dynamic> dataToSet,
    required String collectionPath,
    required String documentPathToUpdate,
    required String documentPathToSetTo,
    required String documentPathToDelete,
  }) async {
    return firestore.runTransaction<void>((transaction) async {
      final DocumentReference documentReferenceToUpdate =
          firestore.collection(collectionPath).doc(documentPathToUpdate);
      final DocumentReference documentReferenceToSetTo =
          firestore.collection(collectionPath).doc(documentPathToSetTo);
      final DocumentReference documentReferenceToDelete =
          firestore.collection(collectionPath).doc(documentPathToDelete);

      final DocumentSnapshot documentSnapshotForUpdate =
          await transaction.get(documentReferenceToUpdate);

      final Map<String, dynamic> dataInDocumentPathToUpdate =
          documentSnapshotForUpdate.data() as Map<String, dynamic>;

      final Map<String, dynamic> updatedData = {
        ...dataInDocumentPathToUpdate,
        ...dataToUpdate
      };

      transaction.update(documentReferenceToUpdate, updatedData);

      transaction.set(documentReferenceToSetTo, dataToSet);

      transaction.delete(documentReferenceToDelete);
    });
  }

  Future<void> runBatchedWrite({
    required Map<String, dynamic> dataToSet,
    required Map<String, dynamic> dataToUpdate,
    required String collectionPath,
    required String documentPathToSetTo,
    required String documentPathToUpdate,
    required String documentPathToDelete,
  }) async {
    final WriteBatch writeBatch = firestore.batch();

    final CollectionReference collectionReference =
        firestore.collection(collectionPath);

    final DocumentReference documentReferenceToSetTo =
        collectionReference.doc(documentPathToSetTo);
    final DocumentReference documentReferenceToUpdate =
        collectionReference.doc(documentPathToUpdate);
    final DocumentReference documentReferenceToDelete =
        collectionReference.doc(documentPathToDelete);

    writeBatch.set(documentReferenceToSetTo, dataToSet);

    writeBatch.update(documentReferenceToUpdate, dataToUpdate);

    writeBatch.delete(documentReferenceToDelete);

    await writeBatch.commit();
  }
}

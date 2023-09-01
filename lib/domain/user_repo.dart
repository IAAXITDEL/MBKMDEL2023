import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ts_one/data/users/user_signatures.dart';
import 'package:ts_one/data/users/users.dart';
import 'package:ts_one/util/util.dart';

abstract class UserRepo {
  Future<UserAuth> login(String email, String password);

  Future<UserAuth> loginWithGoogle();

  Future<void> logout();

  Future<List<UserModel>> getUsersPaginated(int limit, UserModel? lastUser);

  Future<int> getLengthOfAllUsers();

  Future<UserModel> getUserByIDNo(String idNo);

  Future<List<UserModel>> getUsersBySearchName(
      String searchName, int searchLimit);

  Future<List<UserModel>> getUserBySearchIdNo(String searchId, int searchLimit);

  Future<UserModel> addUser(UserModel userModel);

  Future<UserModel> updateUser(String userEmail, UserModel userModel);

  Future<void> deleteUserByEmail(String email);

  Future<String> uploadSignature(int idUser, DateTime assessmentDate, Uint8List? signatureBytes);

  Future<UserSignatures> addSignature(UserSignatures userSignatures);

  Future<UserSignatures> getSignature(int id);

  Future<bool> getPDFTemplate();
}

class UserRepoImpl implements UserRepo {
  UserRepoImpl({FirebaseFirestore? db, FirebaseAuth? auth, FirebaseStorage? storage})
      : _db = db,
        _auth = auth,
        _storage = storage;

  final FirebaseFirestore? _db;
  final FirebaseAuth? _auth;
  final FirebaseStorage? _storage;

  @override
  Future<UserAuth> login(String email, String password) async {
    UserAuth userAuth = UserAuth();

    try {
      // try to login with firebase auth
      UserCredential userCredential = await _auth!
          .signInWithEmailAndPassword(email: email, password: password);

      // if current user is not null and user credential is not null, it means login is successful
      if (_auth!.currentUser != null && userCredential.user != null) {
        // get user data from firestore database by finding the uid of the current user
        final userData = await _db!
            .collection(UserModel.firebaseCollection)
            .where(UserModel.keyEmail, isEqualTo: email)
            .get();

        log(userData.docs.first.data().toString());

        // create user model from firebase user and user data from firestore
        UserModel userModel = UserModel.fromFirebaseUser(userData.docs.first.data());

        // return user auth with user model and message
        userAuth.userModel = userModel;
        userAuth.userCredential = userCredential;
      }
    } catch (e) {
      log("Exception un UserRepo: $e");
    }
    return userAuth;
  }

  @override
  Future<UserAuth> loginWithGoogle() async {
    UserAuth userAuth = UserAuth();

    GoogleSignIn googleSignIn = GoogleSignIn(
        // scopes: [
        //   'email',
        //   'https://www.googleapis.com/auth/contacts.readonly',
        // ],
        );

    GoogleSignInAccount? googleSignInAccount;

    try {
      googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        // get google auth credential from google sign in account
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        // get firebase auth credential from google auth credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // try to login with firebase auth credential
        UserCredential userCredential =
            await _auth!.signInWithCredential(credential);

        // if current user is not null and user credential is not null, it means login is successful
        if (_auth!.currentUser != null && userCredential.user != null) {
          // get user data from firestore database by finding the uid of the current user
          final userData = await _db!
              .collection(UserModel.firebaseCollection)
              // .doc(userCredential.user!.email)
              .where(UserModel.keyEmail, isEqualTo: userCredential.user!.email)
              .get();

          // create user model from firebase user and user data from firestore
          UserModel userModel = UserModel.fromFirebaseUser(userData.docs[0].data());

          // return user auth with user model and message
          userAuth.userModel = userModel;
          userAuth.userCredential = userCredential;
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        userAuth.errorMessage =
            'The account already exists with a different credential.';
        log("Exception in UserRepo on loginWithGoogle - account-exists-with-different-credential: $e");
      } else if (e.code == 'invalid-credential') {
        userAuth.errorMessage =
            'Error occurred while accessing credentials. Try again.';
        log("Exception in UserRepo on loginWithGoogle - invalid-credential: $e");
      }
    } catch (e) {
      userAuth.errorMessage = 'Error occurred using Google Sign-In. Try again.';
      log("Exception in UserRepo on loginWithGoogle: $e");
    }

    return userAuth;
  }

  @override
  Future<void> logout() async {
    try {
      return await _auth!.signOut();
    } catch (e) {
      log("Exception in UserRepo on logout: $e");
    }
  }

  @override
  Future<int> getLengthOfAllUsers() async {
    return await _db!
        .collection(UserModel.firebaseCollection)
        .snapshots()
        .length;
  }

  @override
  Future<List<UserModel>> getUsersPaginated(
      int limit, UserModel? lastUser) async {
    List<UserModel> users = [];

    try {
      // get all users from firestore database
      Query query = _db!
          .collection(UserModel.firebaseCollection)
          .orderBy(UserModel.keyName)
          .limit(limit);

      if (lastUser != null) {
        final lastDocument = await _db!
            .collection(UserModel.firebaseCollection)
            .doc(lastUser.idNo.toString())
            .get();

        query = query.startAfterDocument(lastDocument);
      }

      final usersData = await query.get();

      // create user model from firebase user and user data from firestore
      users = usersData.docs
          .map((e) =>
              UserModel.fromFirebaseUser(e.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log("Exception in UserRepo on getUsersPaginated: $e");
    }

    return users;
  }

  @override
  Future<UserModel> getUserByIDNo(String idNo) async {
    UserModel user = UserModel();

    try {
      // get user data from firestore database by finding the email of the current user
      final userData =
          await _db!.collection(UserModel.firebaseCollection).doc(idNo).get();

      // create user model from firebase user and user data from firestore
      user = UserModel.fromFirebaseUser(userData.data()!);
    } catch (e) {
      log("Exception in UserRepo on getUserByIDNo: $e");
    }

    return user;
  }

  @override
  Future<List<UserModel>> getUsersBySearchName(
      String searchName, int searchLimit) async {
    List<UserModel> users = [];

    try {
      Query query = _db!
          .collection(UserModel.firebaseCollection)
          .orderBy(UserModel.keyName)
          .limit(searchLimit)
          // .where(UserModel.keyName, isGreaterThanOrEqualTo: searchName)
          // .where(UserModel.keyName, isLessThanOrEqualTo: searchName + '\uf8ff');
          .startAt([searchName])
          .endAt(['$searchName\uf8ff']);

      final usersData = await query.get();

      // create user model from firebase user and user data from firestore
      users = usersData.docs
          .map((e) =>
              UserModel.fromFirebaseUser(e.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log("Exception in UserRepo on getUsersBySearchName: $e");
    }

    return users;
  }

  @override
  Future<List<UserModel>> getUserBySearchIdNo(String searchId, int searchLimit) {
    // TODO: implement getUserBySearchIdNo
    throw UnimplementedError();
  }

  @override
  Future<UserModel> addUser(UserModel userModel) async {
    UserModel newUserModel = UserModel();

    try {
      // add new user to firestore database
      await _db!
          .collection(UserModel.firebaseCollection)
          .doc(userModel.email)
          .set(userModel.toFirebase());

      // get user data from firestore database by finding the email of the current user
      final userData = await _db!
          .collection(UserModel.firebaseCollection)
          .doc(userModel.email)
          .get();

      // create user model from firebase user and user data from firestore
      newUserModel = UserModel.fromFirebaseUser(userData.data()!);
    } catch (e) {
      log("Exception in UserRepo on addUser: $e");
    }

    return newUserModel;
  }

  @override
  Future<UserModel> updateUser(String userEmail, UserModel user) async {
    UserModel updatedUser = UserModel();

    UserModel currentUser = await getUserByIDNo(userEmail);
    try {
      /** if the user changes their email, delete the old user */
      if (user.email != currentUser.email) {
        await deleteUserByEmail(currentUser.email);

        /** insert the new user */
        await _db!
            .collection(UserModel.firebaseCollection)
            .doc(user.email)
            .set(user.toFirebase());

        /** get thew newly updated user */
        final userData = await _db!
            .collection(UserModel.firebaseCollection)
            .doc(user.email)
            .get();

        /** assign the newly updated user */
        updatedUser = UserModel.fromFirebaseUser(userData.data()!);
      }
      else {
        /** update the user */
        await _db!
            .collection(UserModel.firebaseCollection)
            .doc(currentUser.email)
            .update(user.toFirebase());

        /** get thew newly updated user */
        final userData = await _db!
            .collection(UserModel.firebaseCollection)
            .doc(currentUser.email)
            .get();

        /** assign the newly updated user */
        updatedUser = UserModel.fromFirebaseUser(userData.data()!);
      }
    } catch (e) {
      log("Exception in UserRepo on updateUser: $e");
    }

    return updatedUser;
  }

  @override
  Future<void> deleteUserByEmail(String email) async {
    /** delete the user */
    await _db!.collection(UserModel.firebaseCollection).doc(email).delete();
  }

  @override
  Future<String> uploadSignature(int idUser, DateTime assessmentDate, Uint8List? signatureBytes) async {
    String downloadURL = "";
    try {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      String fileName = "Signature-$idUser"
          "-${Util.convertDateTimeDisplay(assessmentDate.toString())}"
          "-${DateTime.now().millisecondsSinceEpoch.toString()}.png";
      String filePath = "$tempPath/$fileName";

      // File fileToUpload = await File(filePath).writeAsBytes(newAssessment.signatureBytes!);
      File fileToUpload = await File(filePath).writeAsBytes(signatureBytes!);

      final ref = _storage!.ref().child('signatures/$fileName');
      final uploadTask = ref.putFile(fileToUpload);

      final snapshot = await uploadTask.whenComplete(() {});
      downloadURL = await snapshot.ref.getDownloadURL();
    }
    catch (e) {
      log("Exception in UserRepo on uploadSignature: $e");
    }
    log("Message from UserRepo: $downloadURL");
    return downloadURL;
  }

  @override
  Future<UserSignatures> addSignature(UserSignatures userSignatures) async {
    UserSignatures newUserSignatures = UserSignatures();
    try {
      await _db!
          .collection(UserSignatures.firebaseCollection)
          .doc()
          .set(userSignatures.toFirebase());

      newUserSignatures = userSignatures;
    }
    catch (e) {
      log("Exception in UserRepo on addSignature: $e");
    }

    return newUserSignatures;
  }

  @override
  Future<UserSignatures> getSignature(int staffIDNo) async {
    UserSignatures userSignatures = UserSignatures();
    try {
      final snapshot = await _db!
          .collection(UserSignatures.firebaseCollection)
          .where(UserSignatures.keyStaffId, isEqualTo: staffIDNo)
          .orderBy(UserSignatures.keyDateUploaded, descending: true)
          .get();

      // get the first signature
      userSignatures = UserSignatures.fromFirebase(snapshot.docs.first.data());
    }
    catch (e) {
      log("Exception in UserRepo on getSignature: $e");
    }
    return userSignatures;
  }

  @override
  Future<bool> getPDFTemplate() async {

    try {
      Directory? tempDir = await getExternalStorageDirectory();

      File downloadedFile = File('${tempDir!.path}/QZ_TS1_SIM_04JUL2020_rev02.pdf');

      await _storage!
          .ref('template-assessments/QZ_TS1_SIM_04JUL2020_rev02.pdf')
          .writeToFile(downloadedFile);

    } catch (e) {
      log("Exception in UserRepo on getPDFTemplate: $e");
    }

    return true;
  }
}

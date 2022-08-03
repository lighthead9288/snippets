import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  static AuthProvider instance = AuthProvider();
  User user;
  AuthStatus status;
  FirebaseAuth _auth;

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    _checkCurrentUserAuthentication();
  }

  void registerUserWithEmailAndPassword(String email, String password, Future<void> onSuccess(String userId), Future<void> onError()) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      user = result.user;
      status = AuthStatus.Authenticated;
      await onSuccess(user.uid);
    } catch(e) {
      status = AuthStatus.Error;
      user = null;
      await onError();
    }
    notifyListeners();
  }

  void loginUserWithEmailAndPassword(String email, String password, Future<void> onSuccess(String userId), Future<void> onError()) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      user = result.user;
      status = AuthStatus.Authenticated;
      await onSuccess(user.uid);
    } catch(e) {
        status = AuthStatus.Error;
        user = null;
        await onError();
    }
    notifyListeners();
  }



  Future<void> logout(Future<void> onSuccess(String userId)) async {
    try {
      var id = user.uid;
      await _auth.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess(id);
    } catch(e) {
      print(e);
    }
    notifyListeners();
  }
  
  Future<PasswordResetStatus> resetPassword(String email) async {
    var status = PasswordResetStatus.Success;
    await _auth.sendPasswordResetEmail(email: email)
      .onError((error, stackTrace) => status = PasswordResetStatus.Error)
      .timeout(Duration(seconds: 60), onTimeout: () => status = PasswordResetStatus.TimeoutExpired);
    return status;
  }

  Future<EmailChangeStatus> changeEmail(String email) async {   
    var status = EmailChangeStatus.Success;
    await user.updateEmail(email)
      .onError((error, stackTrace) => status = EmailChangeStatus.Error)
      .timeout(Duration(seconds: 60), onTimeout: () => status = EmailChangeStatus.TimeoutExpired);
    return status;
  }

  Future<bool> isCurrentPasswordValid(String email, String password) async {
    var credentials = EmailAuthProvider.credential(email: email, password: password);
    try {
      var result = await user.reauthenticateWithCredential(credentials);
      return (result.user!=null);
    } catch(e) {
      return false;
    }    
  }

  Future<PasswordChangeStatus> changeUserPassword(String password) async {
    var status = PasswordChangeStatus.Success;
    await user.updatePassword(password)
      .onError((error, stackTrace) => status = PasswordChangeStatus.Error)
      .timeout(Duration(seconds: 60), onTimeout: () => status = PasswordChangeStatus.TimeoutExpired);
    return status;
  }

  void _checkCurrentUserAuthentication() async {
    user = _auth.currentUser;
    if (user!=null) {
      notifyListeners();
    }
  }
}

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error
}

enum PasswordResetStatus {
  Success,
  Error,
  TimeoutExpired
}

enum EmailChangeStatus {
  Success,
  Error,
  TimeoutExpired
}

enum PasswordChangeStatus {
  Success,
  Error,
  TimeoutExpired
}

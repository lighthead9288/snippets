import 'package:chromatec_service/features/requests/presentation/dialog/pages/dialog_page.dart';
import 'package:core/core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class MessagingService {
  static MessagingService instance = MessagingService();
  static String currentRequestId; 
  static String _currentBackgroundMessageId;

  MessagingService() {
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        try {
          var data = message.data;
          var requestId = data['requestId'];
          var requestTitle = data['title'];
          var messageId = message.messageId;
          print("Message id: $messageId");

          if (_currentBackgroundMessageId != messageId) {
            _currentBackgroundMessageId = messageId;
            NavigationService.instance.navigateToRoute(
              MaterialPageRoute(
                builder: (BuildContext _context) => DialogPage(requestId: requestId, requestTitle: requestTitle) 
              )
            );
          }           
        } catch(e) {

        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;

      if (notification != null && android != null) {
        var data = message.data;
        var requestId = data['requestId'];
        var requestTitle = data['title'];
        var messageText = message.notification.body;

        if (requestId != currentRequestId) {
          showSimpleNotification(
            GestureDetector(
              child: Text(requestTitle, style: TextStyle(color: Colors.black)),
              onTap: () {
                NavigationService.instance.navigateToRoute(
                  MaterialPageRoute(
                    builder: (BuildContext _context) => DialogPage(requestId: requestId, requestTitle: requestTitle) 
                  )
                );
              }
            ),
            leading: Image.asset('assets/notification.png'),
            subtitle: GestureDetector(
              child: Text(messageText, style: TextStyle(color: Colors.black)),
              onTap: () {
                NavigationService.instance.navigateToRoute(
                  MaterialPageRoute(
                    builder: (BuildContext _context) => DialogPage(requestId: requestId, requestTitle: requestTitle) 
                  )
                );
              },
            ),
            background: Colors.white,
            duration: Duration(seconds: 3),
            slideDismissDirection: DismissDirection.none      
          );
        }        
      }
    });      
  }  

  Future<String> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}
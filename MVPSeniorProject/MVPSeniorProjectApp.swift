//
//  MVPSeniorProjectApp.swift
//  MVPSeniorProject
//
//  Created by Family on 10/13/24.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import FirebaseFirestore
import FirebaseAuth
import FirebaseCrashlytics
import GoogleSignIn

// Custom AppDelegate to handle Firebase and notifications
//class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate {
//    
//    static let shared = AppDelegate()
//    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
//        // Initialize Firebase
//        FirebaseApp.configure()
//        print("Firebase initialized successfully")
//        
//        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
//        
//        // Request notification permissions
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
//            if let error = error {
//                print("Notification authorization error: \(error.localizedDescription)")
//            } else {
//                print("Notification permission granted: \(granted)")
//            }
//        }
//        
//        // Register for remote notifications
//        application.registerForRemoteNotifications()
//        
//        // Set the FCM messaging delegate
//        Messaging.messaging().delegate = self
//        
//        return true
//    }
//    
//    // Called when the device successfully registers for remote notifications (APNs)
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        // Pass device token to Firebase for FCM registration
//        Messaging.messaging().apnsToken = deviceToken
//    }
//    
//    // Called when FCM token is updated or created
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        guard let fcmToken = fcmToken else {
//            print("Error: FCM token is nil.")
//            return
//        }
//        print("FCM Token: \(fcmToken)")
//        
//        // You can save the token to your Firestore database for sending notifications later
//        saveFcmTokenToFirestore(fcmToken)
//    }
//    
//    // Function to save FCM token to Firestore (or your server)
//    func saveFcmTokenToFirestore(_ fcmToken: String) {
//        // Ensure the user is authenticated
//        guard let userUID = Auth.auth().currentUser?.uid else {
//            print("Error: No authenticated user found.")
//            return
//        }
//        
//        let db = Firestore.firestore()
//        db.collection("users").document(userUID).setData([
//            "fcmToken": fcmToken
//        ], merge: true) { error in
//            if let error = error {
//                print("Error saving FCM token: \(error.localizedDescription)")
//            } else {
//                print("FCM token saved to Firestore.")
//            }
//        }
//    }
//}
//
//@main
//struct MVPSeniorProjectApp: App {
//    
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    static let shared = AppDelegate()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()
        print("Firebase initialized successfully")
        
        // Enable Crashlytics
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        
        // Request notification permissions
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }

        // Register for remote notifications
        application.registerForRemoteNotifications()
        
        // Set Firebase Messaging delegate
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // Handle URL redirects from Google Sign-In
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // Handle APNs token registration
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    // FCM token received or updated
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("Error: FCM token is nil.")
            return
        }
        print("FCM Token: \(fcmToken)")
        saveFcmTokenToFirestore(fcmToken)
    }

    // Save FCM token to Firestore
    func saveFcmTokenToFirestore(_ fcmToken: String) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("Error: No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userUID).setData([
            "fcmToken": fcmToken
        ], merge: true) { error in
            if let error = error {
                print("Error saving FCM token: \(error.localizedDescription)")
            } else {
                print("FCM token saved to Firestore.")
            }
        }
    }
}

@main
struct MVPSeniorProjectApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

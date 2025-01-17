//
//  AppDelegate.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/17/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseMessaging
import GoogleSignIn
import UserNotifications
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        print("user defaults location:", NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        
        configureNotifications()
        
        configureFirebase()
        
        Messaging.messaging().delegate = self
        
        deleteSavedVoiceMemos()
        
        configureSVProgressHUD()
        
        let gidConfiguration = GIDConfiguration(clientID: FirebaseApp.app()?.options.clientID ?? "")
        GIDSignIn.sharedInstance.configuration = gidConfiguration
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

        print("failed to register for remote notfications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        debugPrint("Received: \(userInfo)")
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    //Only gets called if application is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if UIApplication.shared.applicationState != .active {
            
            completionHandler([.alert, .badge, .sound])
        }
        
        else {
            
            let tabBarController = self.window?.rootViewController as! UITabBarController
            
            if tabBarController.selectedIndex == 0 {
                
                
            }
            
            else if tabBarController.selectedIndex != 2 {
                
                completionHandler([.alert, .badge, .sound])
            }
        }
    }
    
    private func configureNotifications () {
        
        let notifOptions: UNAuthorizationOptions = [.alert, .badge, .sound, .carPlay]
        
        UNUserNotificationCenter.current().requestAuthorization(options: notifOptions) { (granted, error) in
            
            if granted == true {
                
                print ("granted")
            }
            
            else {
                
                print ("denied")
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func configureFirebase () {
        
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        let settings = FirestoreSettings()
        
        settings.isPersistenceEnabled = false
        db.settings = settings
    }
    
    private func deleteSavedVoiceMemos () {
        
        //Deleting any voice memos that may have been saved
        let url = documentsDirectory.appendingPathComponent("VoiceMemos", isDirectory: true)
        
        do {
            
            try FileManager.default.removeItem(at: url)
            
        } catch {
            
            print(error.localizedDescription)
        }
    }
    
    private func configureSVProgressHUD () {
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(3)
        
        if let image = UIImage(systemName: "xmark.circle.fill") {
            
            SVProgressHUD.setErrorImage(image)
        }
    }
}

extension AppDelegate: MessagingDelegate {
    
    //Subscribe to topics here
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        guard let fcmToken else { return }
        
        let currentUser = CurrentUser.sharedInstance
        
        if currentUser.userSignedIn, currentUser.fcmToken != fcmToken {
            
            let firebaseAuth = FirebaseAuthentication()
            firebaseAuth.setNewFCMToken(fcmToken: fcmToken)
        }
        
        //Will be called whenever the token is updated for any reason, posts the following notification
        let dataDict: [String : String] = ["token" : fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}

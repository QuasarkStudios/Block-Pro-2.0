//
//  AppDelegate.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/17/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        print ("realm location:", Realm.Configuration.defaultConfiguration.fileURL!) //Used to locate where our Realm database is
        print("user defaults location:", NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        
        //Sets the intial view of the tabBar to be the TimeBlock view
        let tabBarController = self.window?.rootViewController as! UITabBarController
        tabBarController.selectedIndex = 2

        UINavigationBar.appearance().tintColor = UIColor(hexString: "#e35d5b")
        UITabBar.appearance().tintColor = UIColor(hexString: "#e35d5b")

//        do {
//            let realm = try Realm() //Creation of a new object from the Realm class
//        } catch {
//            print ("Error initializing new realm, \(error)")
//        }
        
        UNUserNotificationCenter.current().delegate = self
        let notifOptions: UNAuthorizationOptions = [.badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: notifOptions) { (granted, error) in
            
            if granted == true {
                print ("aye dope")
            }
            
            else {
                print ("awhhh")
            }
        }
        
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        let settings = FirestoreSettings()
        
        settings.isPersistenceEnabled = false
        db.settings = settings
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
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
        
        do {
            try Auth.auth().signOut()
            print("user signed out")
        } catch let signOutError as NSError {
            print("Error signing out", signOutError.localizedDescription)
        }
    }


}


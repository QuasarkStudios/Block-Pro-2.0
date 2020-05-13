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
        
        //let realm = try! Realm()//
        
        migrateRealmModel()
        
        
        
        //Sets the intial view of the tabBar to be the TimeBlock view
//        let tabBarController = self.window?.rootViewController as! UITabBarController
//        tabBarController.selectedIndex = 2
        
//        UINavigationBar.appearance().tintColor = UIColor(hexString: "#e35d5b")
        UINavigationBar.appearance().tintColor = .black
        
        UITabBar.appearance().tintColor = UIColor(hexString: "#e35d5b")
        
        UNUserNotificationCenter.current().delegate = self
        let notifOptions: UNAuthorizationOptions = [.badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: notifOptions) { (granted, error) in
            
            if granted == true {
                print ("granted")
            }
            
            else {
                print ("denied")
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let tabBarController = self.window?.rootViewController as! UITabBarController
        
        let defaults = UserDefaults.standard
        
        //If the selected notification is a Pomodoro notification
        if defaults.value(forKey: "pomodoroNotificationID") as? String ?? "" == response.notification.request.identifier {
            
            let application = UIApplication.shared
            
            //If BlockPro is active
            if application.applicationState == .active {
                
                tabBarController.delegate = nil
                tabBarController.selectedIndex = 1
            }
            
            //If BlockPro isn't active
            else if application.applicationState == .inactive {
                
                //If the loading splashView has already been presented
                if defaults.value(forKey: "splashViewPresented") as? Bool ?? false == true {
                    
                    tabBarController.delegate = nil
                    tabBarController.selectedIndex = 1
                }
                
                //If it hasn't been presented
                else {
                    
                    //Move to the Pomodoro view after a small delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.25) {
                        
                        tabBarController.delegate = nil
                        tabBarController.selectedIndex = 1
                    }
                }
            }
        }
        
        else {
            
            tabBarController.delegate = nil
            tabBarController.selectedIndex = 2
        }
    }

    func migrateRealmModel () {
        
        print("helloooooo")
        
        let configuration = Realm.Configuration(
            
            schemaVersion: 1,
            
            migrationBlock: { (migration, oldSchemaVersion) in
                
                if oldSchemaVersion < 1 {
                    
                    migration.enumerateObjects(ofType: Block.className()) { (oldObject, newObject) in
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "h:mm a"
                        #warning("change the format of the date because it should include the actual date the block was created BAKA")
                        
                        let startHour = oldObject!["startHour"] as! String
                        let startMinute = oldObject!["startMinute"] as! String
                        let startPeriod = oldObject!["startPeriod"] as! String
                        let startTime = "\(startHour):\(startMinute) \(startPeriod)"
                            //startHour + ":" + startMinute + " " + startPeriod
                        
                        
                        let endHour = oldObject!["endHour"] as! String
                        let endMinute = oldObject!["endMinute"] as! String
                        let endPeriod = oldObject!["endPeriod"] as! String
                        let endTime = "\(endHour):\(endMinute) \(endPeriod)"
                            //endHour + ":" + endMinute + " " + endPeriod
                        
                        let blockCategory = oldObject!["blockCategory"] as! String
                        
                        newObject!["begins"] = formatter.date(from: startTime)
                        newObject!["ends"] = formatter.date(from: endTime)
                        newObject!["category"] = blockCategory
                    }
                }
        })
        
        Realm.Configuration.defaultConfiguration = configuration
        
        _ = try! Realm()
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
        
        let defaults = UserDefaults.standard
        defaults.setValue(false, forKey: "splashViewPresented")
        
        if defaults.value(forKey: "keepUserSignedIn") as? Bool ?? false == false {
            
            do {
                try Auth.auth().signOut()
                print("user signed out")
            } catch let signOutError as NSError {
                print("Error signing out", signOutError.localizedDescription)
            }
        }
    }


}


//
//  AppDelegate.swift
//  testing
//
//  Created by Vadim on 04/03/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        registerForPushNotifications()
        scheduleNotification()
        return true
    }
    
    func registerForPushNotifications() {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {[weak self] granted, error in
            
          print("Permission granted: \(granted)")
          guard granted else { return }
          self?.getNotificationSettings()
      }
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        if settings.authorizationStatus != .authorized {
          // Notifications not allowed
        }
      }
    }
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink){
        guard let url = dynamicLink.url else{
            print("Dynaimc link object has no url")
            return
        }
        print("Your incoming link parameter is \(url.absoluteString)")
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryitems = components.queryItems else {return}
        print(url.path)
        
        if(Auth.auth().currentUser == nil) {return}
        
        if(url.path == "/invite"){
            print("new invite")
            var teacherId: String? = nil, classId: String? = nil
            for i in queryitems{
                if(i.name == "teacherId"){
                    teacherId = i.value
                }else if(i.name == "classId"){
                    classId = i.value
                }
            }
            if(teacherId == nil || classId == nil) {return}
            guard let v_controller = self.window?.rootViewController else {return}
            handleClassroomLink(teacherId: teacherId!, classId: classId!, v_controller: v_controller)
        }else{
            print("new category")
            var user_shared_id: String? = nil, category_shared: String? = nil
            for i in queryitems{
                if(i.name == "user"){
                    user_shared_id = i.value
                }else if(i.name == "category"){
                    category_shared = i.value
                }
            }
            guard let user_id = user_shared_id, let category = category_shared else { return }
            guard let v_controller = self.window?.rootViewController else {return}
            handleCategoryLink(user_shared_id: user_id, category_shared: category, v_controller: v_controller)
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL{
            print("Incoming URL is \(incomingURL)")
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                guard error == nil else{
                    print("Dynamic links error: \(error!.localizedDescription)")
                    return
                }
                if let dynamicLink = dynamicLink{
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
            if(linkHandled){
                return true
            }else{
                //Do something?
                return false
            }
        }
        return false
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromUniversalLink: url){
            self.handleIncomingDynamicLink(dynamicLink)
            return true
        }else{
            return GIDSignIn.sharedInstance().handle(url)
        }
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
        UIApplication.shared.applicationIconBadgeNumber = 0
        guard let current = window?.rootViewController else {return}
        if(!UserDefaults.isFirstLaunch() && Auth.auth().currentUser != nil && current.isKind(of: MainViewController.self)){
            print("Running view did appear")
            current.viewDidAppear(false)
        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}


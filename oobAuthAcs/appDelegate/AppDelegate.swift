//
//  AppDelegate.swift
//  oobAuthAcs
//
//  Created by LOB4 on 16/10/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import SwiftyJSON


@UIApplicationMain
class AppDelegate:UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    var model: String?
    var deviceID : String?
    var FireBaseTokenID : String?;
    
    var givenURL : String?;
    var tranID: String?;
    var custID: String?;
    var gPin: String?;
    var authTypeValue: String?
    var merchant_name: String?
    var currency_symbol: String?
    var txn_amt: String?

        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // Override point for customization after application launch.
            
            model = UIDevice.modelName
            deviceID = UIDevice.current.identifierForVendor!.uuidString
            
            loadViewController()
            
            if #available(iOS 10.0, *) {
                // For iOS 10 display notification (sent via APNS)
                UNUserNotificationCenter.current().delegate = self
                let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                UNUserNotificationCenter.current().requestAuthorization(
                    options: authOptions,
                    completionHandler: {_, _ in })
            }
            else {
                let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                application.registerUserNotificationSettings(settings)
            }
            application.registerForRemoteNotifications()
            FirebaseApp.configure()
            Messaging.messaging().shouldEstablishDirectChannel = true
            Messaging.messaging().delegate = self
            
            //retreiving the token
            InstanceID.instanceID().instanceID { (result, error) in
                if let error = error {
                    print("Error fetching remote instange ID: \(error)")
                } else if let result = result {
                    print("Remote instance ID token: \(result.token)")
                }
            }
            return true
        }
        
        func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
            print("Firebase registration token: \(fcmToken)")
            FireBaseTokenID = fcmToken;
            let dataDict:[String: String] = ["token": fcmToken]
            NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
            // TODO: If necessary send token to application server.
            // Note: This callback is fired at each app startup and whenever a new token is generated.
        }
        
        private func application(application: UIApplication,
                                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
            print("APNs token retrieved: \(deviceToken)")
            Messaging.messaging().apnsToken = deviceToken as Data
        }
        
        func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
            print(remoteMessage.appData)
        }
        
        //RECEIVING IN IOS APP
        func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
            // If you are receiving a notification message while your app is in the background,
            // this callback will not be fired till the user taps on the notification launching the application.
            // TODO: Handle data of notification
            
            // With swizzling disabled you must let Messaging know about the message, for Analytics
            Messaging.messaging().appDidReceiveMessage(userInfo)
            
            // Print message ID.
            if let messageID = userInfo[gcmMessageIDKey] {
                print("Message ID: \(messageID)")
            }
            
            // Print full message.
            print(userInfo)
        }
        
        func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                         fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            // If you are receiving a notification message while your app is in the background,
            // this callback will not be fired till the user taps on the notification launching the application.
            // TODO: Handle data of notification
            
            // With swizzling disabled you must let Messaging know about the message, for Analytics
            Messaging.messaging().appDidReceiveMessage(userInfo)
            
            // Print message ID.
            if let messageID = userInfo[gcmMessageIDKey] {
                print("Message ID: \(messageID)")
            }
            
            // Print full message.
            print(userInfo)
            
            completionHandler(UIBackgroundFetchResult.newData)
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
            
//            let userDefaults = UserDefaults.standard
//            let flagValue = userDefaults.string(forKey: "totpFlag")
//            print("totpFlag value is \(String(describing: flagValue)) from viewcontroller appdelegate")
//            
//            if (flagValue == "yes"){
//                print("restart timer")
//                print("foreground entered")
//                
//                let viewController = self.window?.rootViewController as! softTokenViewController
//                viewController.generateCode()
//            }
//            
//            else{
//                print("do nothing")
//            }
        }
        
        func applicationDidBecomeActive(_ application: UIApplication) {
            // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        }
        
        func applicationWillTerminate(_ application: UIApplication) {
            // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        }
        
        
    }
    
    @available(iOS 10, *)
    extension AppDelegate : UNUserNotificationCenterDelegate {
        
        // Receive displayed notifications for iOS 10 devices.
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            let userInfo = notification.request.content.userInfo
            
            // With swizzling disabled you must let Messaging know about the message, for Analytics
            Messaging.messaging().appDidReceiveMessage(userInfo)
            
            // Print message ID.
            if let messageID = userInfo[gcmMessageIDKey] {
                print("Message ID: \(messageID)")
            }
            
            
            // Print full message.
            print(userInfo)
            // Print full message-and Naviagting to Auth-Page
            //AuthPage()
            
            
            
            // Change this to your preferred presentation option
            completionHandler([.alert, .sound])
        }
        
        
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {
            let userInfo = response.notification.request.content.userInfo
            // Print message ID.
            if let messageID = userInfo[gcmMessageIDKey] {
                print("Message ID: \(messageID)")
            }
            //print("user info values \(userInfo)")
            
            let fulArray = JSON(userInfo)
            print("My Response Array \(fulArray)")

            //getting_GPin
            gPin = fulArray["gen_pin"].stringValue
            print("Gpin received-----\(String(describing: gPin))")

            //getting_Tran_ID
            tranID = fulArray["tranid"].stringValue

            //getting_URL
            givenURL = fulArray["url"].stringValue

            //getting_cust_ID
            custID = fulArray["custid"].stringValue
            print("given url ----\(String(describing: givenURL))")

            //getting_Auth_Type
            authTypeValue =  fulArray["auth_type"].stringValue

            //gettingTransactionDetails
            merchant_name = fulArray["merchant_name"].stringValue
            txn_amt = fulArray["txn_amt"].stringValue
            currency_symbol = fulArray["currency_symbol"].stringValue
            
            //Approve-Page
            //if authTypeValue == "0" {
                //ApprovePage()
            //}
                
            //else if authTypeValue == "3" {
                //softToken
            //}
            //5577882000000011
            
            //else if authTypeValue == "4" {
                //gpin
            //}
//
//            if authTypeValue == "0" {
//            chooseAuthPage()
//            }
//
//            else if authTypeValue == "3" {
//            chooseTOTP()
//            }
//
//            else if authTypeValue == "4" {
//            choosePinPage()
//            }
//
//            else if authTypeValue == "5" {
//                //chooseTestPage()
//            }
            ApprovePage()
            completionHandler()
        }
        
        
        func ApprovePage(){
            window = UIWindow()
            let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle(for: ApproveViewController.self))
            let homeVC = storyboard.instantiateViewController(withIdentifier: "approve")
            window?.rootViewController = homeVC
            window?.makeKeyAndVisible()
        }
        
        func chooseAuthPage(){
            window = UIWindow()
            let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle(for: chooseAuthViewController.self))
            let homeVC = storyboard.instantiateViewController(withIdentifier: "chooseAuth") as! chooseAuthViewController
            homeVC.receiveCustID = custID
            homeVC.receiveUrl = givenURL
            homeVC.receiveTranId = tranID
            window?.rootViewController = homeVC
            window?.makeKeyAndVisible()
        }
        
        func choosePinPage(){
            window = UIWindow()
            let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle(for: pinViewController.self))
            let homeVC = storyboard.instantiateViewController(withIdentifier: "pin") as! pinViewController
            homeVC.receiveCustId = custID
            homeVC.toUrl = givenURL
            homeVC.receiveTranId = tranID
            window?.rootViewController = homeVC
            window?.makeKeyAndVisible()
        }
        
        func chooseTOTP(){
            window = UIWindow()
            let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle(for: totpViewController.self))
            let homeVC = storyboard.instantiateViewController(withIdentifier: "totp") as! totpViewController
            homeVC.receivedCid = custID
            window?.rootViewController = homeVC
            window?.makeKeyAndVisible()
        }
        
        //Load_viewController_based_on_condition
        func loadViewController(){
            let userDefaults = UserDefaults.standard
            let a = userDefaults.string(forKey: "loginFlag")
            print("loginFlag is \(String(describing: a))")
            
            if a == nil{
                print("no loginFlag----redirecting to registration page")
                window = UIWindow()
                let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle(for: signUpViewController.self))
                let homeVC = storyboard.instantiateViewController(withIdentifier: "signup")
                window?.rootViewController = homeVC
                window?.makeKeyAndVisible()
            }
                
            else{
                print("loginFlag present \(String(describing: a))")
                print("So navigating to main page of the app")
              
                window = UIWindow()
                let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle(for: homeViewController.self))
                let homeVC = storyboard.instantiateViewController(withIdentifier: "navHome")
                window?.rootViewController = homeVC
                window?.makeKeyAndVisible()
            }
        }
        
}



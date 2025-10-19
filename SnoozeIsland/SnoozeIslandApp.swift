//
//  SnoozeIslandApp.swift
//  SnoozeIsland
//
//  Created by jose Yun on 1/31/25.
//

import SwiftUI
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func application(_application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }

}


@main
struct SnoozeIslandApp: App {
    @StateObject private var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appdelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(snoozeViewModel)
    }
}



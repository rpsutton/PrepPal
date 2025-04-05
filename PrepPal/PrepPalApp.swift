//
//  PrepPalApp.swift
//  PrepPal
//
//  Created by Paul Sutton on 2/1/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct PrepPalApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // Add shared instance of UserProfileManager
    @StateObject private var userProfileManager = UserProfileManager()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userProfileManager)
        }
    }
}

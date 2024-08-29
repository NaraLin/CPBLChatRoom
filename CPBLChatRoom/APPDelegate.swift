//
//  APPDelegate.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/8.
//
import UIKit
import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

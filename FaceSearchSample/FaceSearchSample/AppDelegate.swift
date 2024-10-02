//
//  AppDelegate.swift
//  FaceSearchSample
//
//  Created by Serge Rylko on 19.06.24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      if #available(iOS 13.0, *) {
          // Handled by the SceneDelegate on >= iOS 13.
      } else {
          let window = UIWindow(frame: UIScreen.main.bounds)
          self.window = window

          let container = UINavigationController()
          container.viewControllers = [DatabaseGroupsViewController()]
          window.rootViewController = container

          window.makeKeyAndVisible()
      }
      return true
  }

  // MARK: UISceneSession Lifecycle
  @available(iOS 13.0, *)
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
      let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
      configuration.sceneClass = UIWindowScene.self
      configuration.delegateClass = SceneDelegate.self
      return configuration
  }

  @available(iOS 13.0, *)
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
      // Called when the user discards a scene session.
      // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
      // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
}


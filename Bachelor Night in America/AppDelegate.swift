//
//  AppDelegate.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 6/23/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FirebaseUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FUIAuthDelegate {

    var window: UIWindow?
    var authUI: FUIAuth?
    var currentUser: BNIAUser?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
        authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self
        let providers: [FUIAuthProvider] = [FUIGoogleAuth(), FUIFacebookAuth()]
        self.authUI?.providers = providers
        self.authUI?.shouldHideCancelButton = true
        let authViewController = authUI?.authViewController()
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let survivorVC = storyboard.instantiateViewController(identifier: "survivor") as! SurvivorPoolViewController
        if Defaults.all().bool(forKey: Defaults.signedInKey) == true {
            print("USER SIGNED IN")
//            self.window?.rootViewController = survivorVC
//            window?.makeKeyAndVisible()
        } else {
            print("USER NOT FOUND")
            self.window?.rootViewController = authViewController
            window?.makeKeyAndVisible()
        }
        return true
    }

    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
          return true
        }
        return false
//        ApplicationDelegate.shared.application(app, open: url,sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation]
//        )

    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if error != nil {
            print("ERROR LOGGING IN: \(error.debugDescription)")
        } else {
            print("USER LOGGED IN")
            let user = authDataResult!.user
            Defaults.add(value: true, for: Defaults.signedInKey)
            TimerManager().setUpTimer()
            if Defaults.all().string(forKey: Defaults.userIDKey) == nil {
                FirebaseClient.createUser(user: user)
                Defaults.add(value: user.uid, for: Defaults.userIDKey)
            }
            
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let survivorVC = storyboard.instantiateViewController(identifier: "survivor") as! SurvivorPoolViewController
            window?.rootViewController = survivorVC
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return SignInViewController(authUI: authUI)
    }


}


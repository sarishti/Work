//
//  AppDelegate.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/10/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.

		QuoteManager().setIsQuoteDisplayed(false)
		self.setColorOfNavigationBar()
		// Fabric for crash reporting
		Fabric.with([Crashlytics.self])
		// Move this to where you establish a user session
		self.logUser()
        // Google Analytics
        self.setGoogleAnalytics()
        /**
         *  If there is no value in key chain then set the value of uuid in keychain
         */
        setUniqueIdentifier()

		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
		NSNotificationCenter.defaultCenter().postNotificationName(Constants.articleReloadNotification, object: nil)
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	// MARK: Fabric crash Reporter
	func logUser() {
		// Use the current user's information
		// You can call any combination of these three methods
		Crashlytics.sharedInstance().setUserEmail("sarishti.batta@netsolutions.in")
		Crashlytics.sharedInstance().setUserIdentifier("991")
		Crashlytics.sharedInstance().setUserName("Sarishti")
	}

	// MARK: Navigation Bar Color
	/**
	 Set the navigation bar Item and status color white along with font
	 */
	func setColorOfNavigationBar() {

		let font = FontFamily.OpenSans.Bold.font(18)

		UINavigationBar.appearance().tintColor = UIColor.whiteColor()
		UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font]
		UIApplication.sharedApplication().statusBarStyle = .LightContent
	}
    //MARK:- Google Anaylytic
    func setGoogleAnalytics() {
        // Configure tracker from GoogleService-Info.plist.
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")

    }

}

//
//  Extensions.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/11/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import UIKit
import MBProgressHUD
//import SDWebImage

extension UIViewController {

	/**
     Set the navigation Bar transparency
     */

	func setNavigationBarTransparent() {
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		self.navigationController?.navigationBar.translucent = true
	}

	// MARK: Memory Release of SDWebImage
	/**
     If the memory of application increates this function to clean cache of SDWebImage
     */
	func memoryReleaseSDWebImage() {
		SDImageCache.sharedImageCache().clearDisk()
		SDImageCache.sharedImageCache().cleanDisk()
		SDImageCache.sharedImageCache().clearMemory()
		SDImageCache.sharedImageCache().setValue(nil, forKey: "memCache")
	}

	func setGoogleAnalyticsEvent(eventName: String, action: String, label: String, value: NSNumber?) {
		let tracker = GAI.sharedInstance().defaultTracker
		let event = GAIDictionaryBuilder.createEventWithCategory(
			eventName,
			action: action,
			label: label,
			value: value).build()
		tracker.send(event as [NSObject: AnyObject])
	}

	// MARK: - Share

	/**
     Represent the sharing Time sheet

     - parameter shareContent: content to share
     */

	func displayShareSheet(shareContent: String) {
		let textToShare = L10n.ShareContent + "\n" + shareContent
		let objectsToShare = [textToShare]
		DLog("objectsToShare: \(objectsToShare)")
		let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
		/**
         *  make the status bar color default for activity controller
         */
		UIApplication.sharedApplication().statusBarStyle = .Default

		activityViewController.completionWithItemsHandler = { (activityType, completed: Bool, returnedItems: [AnyObject]?, error: NSError?) in
			/// Reset the color of navigation bar in application
			if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
				appDelegate.setColorOfNavigationBar()
			}

		}
		self.presentViewController(activityViewController, animated: true, completion: { })
	}
}
//MARK : -  String extensions

extension String {

	// MARK : - Localization

	var localized: String {
		"MainFeedTitle"
		return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: self, comment: "")
	}

}

//MARK: -  UI View Extension

extension UIView {

	/**
     Set the View Corner radius

     - parameter corners: corner to set radius [left/right/top/bottom]
     - parameter radius:  value of radius
     */

	func roundCorners(corners: UIRectCorner, radius: CGFloat) {
		let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
		mask.frame = self.bounds
		mask.path = path.CGPath
		self.layer.mask = mask
	}

	/**
     Add loader on view
     */

	func addLoaderOnView() {

		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			MBProgressHUD.showHUDAddedTo(self, animated: true)

		})
	}

	func removeLoaderFromView() {
		MBProgressHUD.hideHUDForView(self, animated: true)

	}
}
//MARK: -  Date Extension
extension NSDate {
	func yearsFrom(date: NSDate) -> Int {
		return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
	}
	func monthsFrom(date: NSDate) -> Int {
		return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
	}
	func weeksFrom(date: NSDate) -> Int {
		return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
	}
	func daysFrom(date: NSDate) -> Int {
		return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
	}
	func hoursFrom(date: NSDate) -> Int {
		return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
	}
	func minutesFrom(date: NSDate) -> Int {
		return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
	}
	func secondsFrom(date: NSDate) -> Int {
		return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
	}

	func offsetFrom(date: NSDate) -> String {
		if yearsFrom(date) > 0 {
			return "\(yearsFrom(date))Y"
		} else if monthsFrom(date) > 0 {
			return "\(monthsFrom(date))M"
		} else if weeksFrom(date) > 0 {
			return "\(weeksFrom(date))W"
		} else if daysFrom(date) > 0 {
			return "\(daysFrom(date))D"
		} else if hoursFrom(date) > 0 {
			return "\(hoursFrom(date))h"
		} else if minutesFrom(date) > 0 {
			return "\(minutesFrom(date))m"
		} else if secondsFrom(date) > 0 {
			return "\(secondsFrom(date))s"
		}
		return "0S"
	}
}

extension Array {
	func isIndexWithinBound(index: Int) -> Bool {
		if index >= 0 && self.count > index {
			return true
		}

		return false
	}
}
extension UITableView {
	func loaderStopAnimating() {
		self.pullToRefreshView?.stopAnimating()
		self.infiniteScrollingView?.stopAnimating()

	}
	func removeLoader(by isResponseFromCache: Bool) {
		if !(isResponseFromCache) {
			self.loaderStopAnimating()
		}
	}
}
extension UICollectionView {
	func loaderStopAnimating() {
		self.pullToRefreshView?.stopAnimating()
		self.infiniteScrollingView?.stopAnimating()

	}
	func removeLoader(by isResponseFromCache: Bool) {
		if !(isResponseFromCache) {
			self.loaderStopAnimating()
		}
	}
}

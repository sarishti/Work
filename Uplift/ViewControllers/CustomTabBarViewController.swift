//
//  CustomTabBarViewController.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/10/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import UIKit

class CustomTabBarViewController: UITabBarController, ScrollPagerDelegate {

	var scrollPager: ScrollPager!

	override func viewDidLoad() {
		super.viewDidLoad()

		addCustomTabBar()
		setViewBackgroundColor((HappinessRating(rawValue: 1)?.getRatingColor)!)
		// Do any additional setup after loading the view.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - BottomTabbar

	/**
     Add custome tab bar
     */
	func addCustomTabBar() {
		scrollPager = ScrollPager(frame: CGRect(x: 0, y: 0, width: 0, height: 49))
		scrollPager.delegate = self
		scrollPager.font = FontFamily.OpenSans.Regular.font(10)
		scrollPager.selectedFont = FontFamily.OpenSans.Bold.font(10)
        scrollPager.textColor = UIColor.whiteColor()
		scrollPager.selectedTextColor = UIColor.whiteColor()

	//	scrollPager.addSegmentsWithTitlesAndImages([("NEWS FEED", UIImage(asset: .News_feed)!), ("CATEGORY", UIImage(asset: .Source_tab)!), ("YOUR UPS", UIImage(asset: .YourUps)!)])

		scrollPager.addSegmentsWithTitlesAndImages([("FEED", UIImage(named: "news_feed")!), ("CATEGORY", UIImage(named: "source_tab")!), ("YOUR UPS", UIImage(named: "yourUps")!)])

		scrollPager.indicatorColor = UIColor.whiteColor()
		self.view.addSubview(scrollPager)

		addConstraintsToScrollPager()
	}

	/**
     Add constraints on scrollpager
     */
	func addConstraintsToScrollPager() {

		scrollPager.translatesAutoresizingMaskIntoConstraints = false
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[scrollPager(49)]-0-|",
			options: NSLayoutFormatOptions.AlignmentMask,
			metrics: nil,
			views: ["scrollPager": scrollPager]))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[scrollPager]-0-|",
			options: NSLayoutFormatOptions.AlignmentMask,
			metrics: nil,
			views: ["scrollPager": scrollPager]))
	}

	/**
     Hide bottom bar

     - parameter hide: bool value
     */
	func hideBottomBar(hide: Bool) {
		scrollPager.hidden = hide
	}

	// MARK: - ScrollPager delegate

	func scrollPager(scrollPager: ScrollPager, changedIndex: Int) {

		if changedIndex == 0 {
			NSNotificationCenter.defaultCenter().postNotificationName(Constants.articleReloadNotification, object: nil)
		}
		selectedIndex = changedIndex
	}

	// MARK: - BackgroundColor

	/**
     Set background color on background view of tab bar

     - parameter color: UICOlor object
     */
	func setViewBackgroundColor(color: UIColor) {

		UIView.animateWithDuration(0.2) {
			self.view.backgroundColor = color
		}
	}

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */

}

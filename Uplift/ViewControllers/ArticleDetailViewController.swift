//
//  ArticleDetailViewController.swift
//  Uplift
//
//  Created by Sarishti on 8/11/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import UIKit

class ArticleDetailViewController: UIViewController, UIScrollViewDelegate, ArticleWebserviceProtocol, UIWebViewDelegate {

	// MARK: - Outlet Properties

	@IBOutlet weak var lblArticleTitle: UILabel!
	@IBOutlet weak var vwArticleInfo: UIView!
	@IBOutlet weak var webVwArticleDetail: UIWebView!
	@IBOutlet weak var btnIsUped: UIButton!
	@IBOutlet weak var constraintBottomVwArticleInfo: NSLayoutConstraint!
	@IBOutlet weak var btnUpCount: UIButton!
	@IBOutlet weak var btnTime: UIButton!
	@IBOutlet weak var btnSource: UIButton!
	@IBOutlet weak var btnCategory: UIButton!

	// MARK: -  Properties

	/// Bool values
	var shouldCacheResponse = false
	var increaseBottonHeight = true
	var isUped = false
	/// Model object
	var objYourUpsArticle: Article?
	/// Constant values
	let vwArticleInfoDefaultBottom: CGFloat = -52
	let vwArticleInfoHeight: CGFloat = 52

	// MARK: - View Controller Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()
		webVwArticleDetail.scrollView.delegate = self
		setNavigationBarTransparent()
		self.initializeView()
		self.setContentOnBottonView()
		(self.navigationController?.tabBarController as? CustomTabBarViewController)!.hideBottomBar(true)
	}

	override func viewWillDisappear(animated: Bool) {

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewDidAppear(animated: Bool) {

		self.loadWebView()
		/**
         article info the corner round

         - parameter radius: value of radius to round the corner

         - returns: rounded view
         */
		vwArticleInfo.roundCorners([.BottomRight, .BottomLeft], radius: 4.0)
		(self.navigationController?.tabBarController as? CustomTabBarViewController)!.hideBottomBar(true)

	}

	// MARK: - Intialize View

	/**
     Initialize the view

     */
	func initializeView() {

		self.view.addLoaderOnView()
		self.constraintBottomVwArticleInfo.constant = 0

		self.view.layoutIfNeeded()

	}

	// MARK: - Set Content of bottom (Article Info)View

	func setContentOnBottonView() {

		guard let article = objYourUpsArticle else {
			self.view.removeLoaderFromView()
			return
		}

		lblArticleTitle.text = article.title
		btnSource.setTitle(article.source, forState: .Normal)
		btnCategory.setTitle(article.category, forState: .Normal)
		if article.isUped {
			btnIsUped.selected = true
		} else {
			btnIsUped.selected = false
		}

		if article.numberOfUps.isEmpty || Int(article.numberOfUps) == 0 {
			btnUpCount.hidden = true
		} else {
			btnUpCount.setTitle(article.numberOfUps, forState: .Normal)
		}

		setDateIntervalOnButtonSinceData(article)
	}

	/**
     Find the time interval between two dates

     - parameter article: object of article which conatin article detail
     */

	func setDateIntervalOnButtonSinceData(article: Article) {

		let timeInterval = NSDate().offsetFrom(article.createdDate)
		btnTime.setTitle(timeInterval, forState: .Normal)

	}

	// MARK: - Outlet Methods

	/**
     Article up for particular device

     - parameter sender: tapped button
     */

	@IBAction func btnArticleUpTapped(sender: UIButton) {

		if sender.selected {
			isUped = false
		} else {
			isUped = true
		}
		sender.selected = !sender.selected
		self.upAnArticleService()

	}

	// MARK: Web Service Call

	/**
     Up an article web service call
     */

	func upAnArticleService() {

		guard let article = objYourUpsArticle else {
			return
		}

		let dict = [
			ServerKeys.ArticleId: article.articleId,
			ServerKeys.IsUp: "\(isUped)",
			ServerKeys.DeviceId: getUniqueIdentifier()
		]

		upArticle(true, withData: dict as [NSObject: AnyObject], withHandler: { (obj, success) in
			guard success == true else {
				self.btnUpCount.hidden = true
				assert(success == false, "Error in response")
				return
			}

			guard let upCountValue = obj as? String where !upCountValue.isEmpty else {
				self.btnUpCount.hidden = true
				self.notifyHomeToUpdateArticle(by: Int(0))
				return
			}

			if Int(upCountValue) != nil {
				self.notifyHomeToUpdateArticle(by: Int(upCountValue)!)
			}
			if Int(upCountValue) > 0 {
				self.btnUpCount.hidden = false
			} else {
				self.btnUpCount.hidden = true
			}
			self.btnUpCount.setTitle(obj as? String, forState: .Normal)

		}) { (error) in
			DLog("Error")
		}
	}
	/**
     On update the article notify the news feed screen to update value

     - parameter upCountValue: value up or empty
     */

	func notifyHomeToUpdateArticle(by upCountValue: Int) {
		if self.objYourUpsArticle != nil {
			let numberOfUps = Int(self.objYourUpsArticle!.numberOfUps)
			self.objYourUpsArticle?.isUped = numberOfUps < Int(upCountValue)

			self.objYourUpsArticle?.numberOfUps = "\(upCountValue)"
			NSNotificationCenter.defaultCenter().postNotificationName("ArticleUpOrDownNotification", object: Wrapper(theValue: self.objYourUpsArticle!))
		}
	}

	// MARK: - Scrolling of Web View

	func scrollViewDidScroll(scrollView: UIScrollView) {

		self.vwArticleInfo.clipsToBounds = true
		if scrollView.panGestureRecognizer.translationInView(scrollView.superview).y > 0 {

			// Present the article info View
			self.constraintBottomVwArticleInfo.constant = 0

		} else if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {

			if increaseBottonHeight {

				increaseBottonHeight = false
				scrollView.contentSize.height = scrollView.contentSize.height + vwArticleInfoHeight
			}
			self.constraintBottomVwArticleInfo.constant = 0
		} else {

			// Disable the article info View

			self.constraintBottomVwArticleInfo.constant = vwArticleInfoDefaultBottom

		}
		// Animation of article info View

		AppUtility.setAnimation(0.1, view: self.vwArticleInfo)

	}

	// MARK: - Web View Methods

	/**
     Load the Web View with Url
     */
	func loadWebView() {

		guard let article = objYourUpsArticle else {
			self.view.removeLoaderFromView()
			return
		}

		let url = NSURL(string: article.webUrl)

		if url == nil {
			self.view.removeLoaderFromView()
			return
		}
		// URL Request Object
		let requestObj: NSURLRequest = NSURLRequest(URL: url!)
		// Load the request in the UIWebView.
		webVwArticleDetail.loadRequest(requestObj)
	}
	/**
     In case of faliture user can't scroll the web page
     */
	func disableScrollingWebView() {
		webVwArticleDetail.scrollView.scrollEnabled = false
		webVwArticleDetail.scrollView.bounces = false
		webVwArticleDetail.scrollView.delegate = nil
	}

	// MARK: - Web View Delegate

	func webViewDidFinishLoad(webView: UIWebView) {
		self.view.removeLoaderFromView()
	}

	func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
		self.view.removeLoaderFromView()
		self.disableScrollingWebView()
	}

	func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {

		if navigationType == .LinkClicked {

			/**
             *  Selected Link from web view open on safari
             */
			if request.URL != nil {
				UIApplication.sharedApplication().openURL(request.URL!)
			}

			return false
		}

		return true
	}

	// MARK: - Bar button Actions

	/**
     On tap back button from navigation bar

     - parameter sender: tapped button
     */
	@IBAction func btnBackTapped(sender: AnyObject) {
		self.navigationController?.popViewControllerAnimated(true)
	}

	/**
     On tap share button from navigation bar

     - parameter sender: tapped button
     */

	@IBAction func btnShareTapped(sender: AnyObject) {
		guard let article = objYourUpsArticle else {
			return
		}

		displayShareSheet(article.webUrl)
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

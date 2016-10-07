//
//  YourUpsViewController.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/10/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import UIKit

class YourUpsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ArticleWebserviceProtocol, UIGestureRecognizerDelegate {

	// MARK: - Properties

	let yourUpsTableCellIdentifier = "YourUpsTableViewCell"

	/// Array and model Object
	var arrayYourUpsArticles: [Article]?
	var objYourUpsArticle: Article?

	/// Paggination Limit
	let articlesLimit = 20

	/// Bool Values

	var shouldCacheResponse = true

	/// Global Offset value
	var articleOffSet = 0

	// MARK: - Outlet Properties

	@IBOutlet weak var tblVwYourUps: UITableView!
	@IBOutlet weak var lblNoRecord: UILabel!

	// MARK: - View Controller Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		AppUtility.setTabBarColor(with: UIColor(named: .YourUpsTabBarColor), viewController: self)
		self.navigationController?.interactivePopGestureRecognizer?.delegate = self
		self.lblNoRecord.hidden = true
		setNavigationBarTransparent()
		// set the table view scrollable
		self.setPullToRefreshOnTable()
		self.setInfiniteScrollOnTable()

	}

	override func viewWillAppear(animated: Bool) {

		self.tblVwYourUps.infiniteScrollingView?.hasMoreData = true
		fetchHappiness3Articles(0)
		(self.navigationController?.tabBarController as? CustomTabBarViewController)!.hideBottomBar(false)

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		memoryReleaseSDWebImage()
	}

	// MARK: Pull to refresh
	/**
     Set the Reuseable component Pull to refresh handler
     */
	func setPullToRefreshOnTable() {
		tblVwYourUps.addPullToRefreshHandler {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
				self.tblVwYourUps.infiniteScrollingView?.hasMoreData = true
				self.tblVwYourUps.setShowsInfiniteScrolling(true)
				self.fetchHappiness3Articles(0)

			})
		}
	}
	// MARK: - Infinite scrolling
	/**
     Set reuseable component Infinite scroller handler
     */
	func setInfiniteScrollOnTable() {
		let fontForInfiniteScrolling = FontFamily.OpenSans.Bold.font(15)

		self.tblVwYourUps
			.addInfiniteScrollingWithHandler(fontForInfiniteScrolling, fontColor: UIColor(named: .YourUpsTabBarColor), actionHandler: {

				if self.tblVwYourUps.infiniteScrollingView!.hasMoreData {
					dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
						self.loadMoreArticles(with: self.articleOffSet)

					})
				}

		})
	}

	// MARK: - UITableView DataSource methods

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let arrYourUpsArticle = self.arrayYourUpsArticles else {
			return 0
		}
		return arrYourUpsArticle.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		guard let cell: YourUpsTableViewCell = tableView.dequeueReusableCellWithIdentifier(yourUpsTableCellIdentifier, forIndexPath: indexPath) as? YourUpsTableViewCell else {
			return UITableViewCell()
		}
		guard let arrYourUpsArticle = self.arrayYourUpsArticles else {
			return UITableViewCell()
		}

		let objYourUpsArticle = arrYourUpsArticle[indexPath.row]

		cell.setContentOnCell(objYourUpsArticle)

		if arrYourUpsArticle.count - 1 == indexPath.row {
			self.articleOffSet = arrYourUpsArticle.count

		}

		return cell
	}

	// MARK: - Table View Delegate methods

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		guard let arrYourUpsArticle = self.arrayYourUpsArticles where self.arrayYourUpsArticles!.isIndexWithinBound(indexPath.row) else {

			assert((arrayYourUpsArticles != nil) && (arrayYourUpsArticles!.isIndexWithinBound(indexPath.row)), "arrArticles is nil or index is out of bound")

			return
		}

		self.objYourUpsArticle = arrYourUpsArticle[indexPath.row]
        let articleName = self.objYourUpsArticle?.title
        self.setGoogleAnalyticsEvent(articleName!, action: "Select Article", label: "SomeLabel", value: nil)

		self.performSegueWithIdentifier(StoryboardSegue.Main.ShowArticleDetailVC.rawValue, sender: self)
	}

	func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		guard let cell: YourUpsTableViewCell = tableView.dequeueReusableCellWithIdentifier(yourUpsTableCellIdentifier, forIndexPath: indexPath) as? YourUpsTableViewCell else {
			return
		}

		cell.imgVwArticle.sd_cancelCurrentImageLoad()
	}

	// MARK: - Load more
	/**
     Load more articles

     - parameter offset: starting index of articles
     */

	func loadMoreArticles(with offset: Int) {
		fetchHappiness3Articles(offset)
	}

	// MARK: - Webservice Calls

	/**
     Fetch the articles from particular index

     - parameter offset: starting index of articles
     */

	func fetchHappiness3Articles(offset: Int) {

		fetchYourUpArticles(true, withData: [ServerKeys.HappinessLevel: "3", ServerKeys.ArticlesOffset: offset, ServerKeys.ArticlesLimit: articlesLimit, ServerKeys.DeviceId:  getUniqueIdentifier()], withHandler: { (arrArticles, success, isResponseFromCache) in
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.tblVwYourUps.removeLoader(by: isResponseFromCache!)
				guard let articleArray = arrArticles as? [Article] else {
					self.tblVwYourUps.infiniteScrollingView?.hasMoreData = false
					return
				}
				if articleArray.count == 0 && offset == 0 {
					self.lblNoRecord.hidden = false
					self.tblVwYourUps.setShowsInfiniteScrolling(false)
				} else if articleArray.count == 0 && offset > 0 {
					// Infinite scroll View to represent no more records
					if !(isResponseFromCache!) {
						self.lblNoRecord.hidden = true
						self.tblVwYourUps.infiniteScrollingView?.hasMoreData = false
					}
				}

				if articleArray.count < self.articlesLimit && articleArray.count > 0 {
					self.lblNoRecord.hidden = true
					self.tblVwYourUps.infiniteScrollingView?.hasMoreData = false
				}

				if offset == 0 {
					self.arrayYourUpsArticles = articleArray
				} else {
					self.arrayYourUpsArticles?.appendContentsOf(articleArray)
				}
				self.tblVwYourUps.reloadData()

			})

		}) { (error) in
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.tblVwYourUps.loaderStopAnimating()
			})
		}
	}

	// MARK: - Navigation

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let objArticle = objYourUpsArticle else {
			return
		}
		/**
         *  Navigate on article detail view controller with selected object
         */
		if segue.identifier == StoryboardSegue.Main.ShowArticleDetailVC.rawValue {

			if let nextScene = segue.destinationViewController as? ArticleDetailViewController {
				nextScene.objYourUpsArticle = objArticle
				self.navigationController?.interactivePopGestureRecognizer?.enabled = true
			}
		}
	}

}

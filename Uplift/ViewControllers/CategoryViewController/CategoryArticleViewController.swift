//
//  CategoryArticleViewController.swift
//  Uplift
//
//  Created by Sarishti on 9/2/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import UIKit

class CategoryArticleViewController: UIViewController, ArticleWebserviceProtocol, UIGestureRecognizerDelegate {

	// MARK: - Properties

	let homeArticleTableViewCellIdentifier = "HomeArticleTableViewCell"

	/// Array and model Object
	var arrayArticlesByCategory: [Article]?
	var objCategory: Category?
	var objArticleByCategory: Article?

	/// Global Offset value
	var articleOffSet = 0

	/// Paggination Limit
	let articlesLimit = 20

	/// Bool Values
	var shouldCacheResponse = true

	// MARK: - Outlet Properties

	@IBOutlet weak var tblVwArticleByCategory: UITableView!
	@IBOutlet weak var lblNoRecord: UILabel!

	// MARK: View LifeCycle

	override func viewDidLoad() {
		super.viewDidLoad()

		AppUtility.setTabBarColor(with: UIColor(named: .YourUpsTabBarColor), viewController: self)
		self.setTitleOfNavBar()
		self.navigationController?.interactivePopGestureRecognizer?.delegate = self
		self.lblNoRecord.hidden = true

		self.setPullToRefreshOnTable()
		self.setInfiniteScrollOnTable()
		fetchArticlesByCategory(0)
		addObservers()

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		memoryReleaseSDWebImage()
	}

	override func viewWillAppear(animated: Bool) {

		(self.navigationController?.tabBarController as? CustomTabBarViewController)!.hideBottomBar(true)

	}
	// MARK: Pull to refresh
	/**
     Set the Reuseable component Pull to refresh handler
     */
	func setPullToRefreshOnTable() {
		tblVwArticleByCategory.addPullToRefreshHandler {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
				self.tblVwArticleByCategory.infiniteScrollingView?.hasMoreData = true
				self.tblVwArticleByCategory.setShowsInfiniteScrolling(true)
				self.fetchArticlesByCategory(0)

			})
		}
	}
	// MARK: - Infinite scrolling
	/**
     Set reuseable component Infinite scroller handler
     */
	func setInfiniteScrollOnTable() {
		let fontForInfiniteScrolling = FontFamily.OpenSans.Bold.font(15)

		self.tblVwArticleByCategory
			.addInfiniteScrollingWithHandler(fontForInfiniteScrolling, fontColor: UIColor(named: .YourUpsTabBarColor), actionHandler: {

				if self.tblVwArticleByCategory.infiniteScrollingView!.hasMoreData {
					dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
						self.loadMoreArticles(with: self.articleOffSet)

					})
				}

		})
	}
	// MARK: Title Of Navigation bar
	/**
     Set the title bar text based upon category user have selected
     */
	func setTitleOfNavBar() {
		if let object = objCategory {
			self.navigationItem.title = object.categoryName.uppercaseString
		}
	}

	// MARK: - NSNotification

	func addObservers() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onArticleUpOrDownNotification), name: Constants.articleUpOrDownNotification, object: nil)
	}
	func onArticleUpOrDownNotification(notification: NSNotification) {
		guard let wrapper = notification.object as? Wrapper<Article>else { return }

		let changedArticle = wrapper.wrappedValue

		if arrayArticlesByCategory == nil { return }

		let index = arrayArticlesByCategory!.indexOf { (article) -> Bool in
			return article.articleId == changedArticle.articleId
		}
		if index != nil {
			arrayArticlesByCategory![index!] = changedArticle
			self.tblVwArticleByCategory.reloadData()
		}
	}

	// MARK: - UITableView DataSource methods

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let arrYourUpsArticle = self.arrayArticlesByCategory else {
			return 0
		}
		return arrYourUpsArticle.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		guard let cell: HomeArticleTableViewCell = tableView.dequeueReusableCellWithIdentifier(homeArticleTableViewCellIdentifier, forIndexPath: indexPath) as? HomeArticleTableViewCell else {
			return UITableViewCell()
		}
		guard let arrArticlesByCategory = self.arrayArticlesByCategory else {
			return UITableViewCell()
		}

		let objArticlesByCategory = arrArticlesByCategory[indexPath.row]

		cell.setContentOnCell(objArticlesByCategory)

		if arrArticlesByCategory.count - 1 == indexPath.row {
			self.articleOffSet = arrArticlesByCategory.count

		}

		return cell
	}

	// MARK: - Table View Delegate methods

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		guard let arrArticlesByCategory = self.arrayArticlesByCategory where self.arrayArticlesByCategory!.isIndexWithinBound(indexPath.row) else {

			assert((arrayArticlesByCategory != nil) && (arrayArticlesByCategory!.isIndexWithinBound(indexPath.row)), "arrArticles is nil or index is out of bound")

			return
		}

		self.objArticleByCategory = arrArticlesByCategory[indexPath.row]
        let articleName = self.objArticleByCategory?.title
        self.setGoogleAnalyticsEvent(articleName!, action: "Select Article", label: "SomeLabel", value: nil)

		self.performSegueWithIdentifier(StoryboardSegue.Main.ShowArticleDetailVC.rawValue, sender: self)
	}

	func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

		guard let cell: HomeArticleTableViewCell = tableView.dequeueReusableCellWithIdentifier("HomeArticleTableViewCell") as? HomeArticleTableViewCell else {
			return
		}

		cell.imageViewthumbnail.sd_cancelCurrentImageLoad()
	}

	// MARK: - Bar button Actions

	/**
     On tap back button from navigation bar

     - parameter sender: tapped button
     */
	@IBAction func btnBackTapped(sender: AnyObject) {
		self.navigationController?.popViewControllerAnimated(true)
	}

	// MARK: - Load more
	/**
     Load more articles depending on happiness level
     - parameter offset: starting index of articles
     */

	func loadMoreArticles(with offset: Int) {
		fetchArticlesByCategory(offset)
	}

	// MARK: - Webservice Calls

	/**
     Fetch the articles from particular index

     - parameter offset: starting index of articles
     */

	func fetchArticlesByCategory(offset: Int) {

		guard let object = objCategory else {
			return
		}

		fetchArticlesByCategory(true, withData: [ServerKeys.categoryId: object.categoryId, ServerKeys.ArticlesOffset: offset, ServerKeys.ArticlesLimit: articlesLimit, ServerKeys.DeviceId:  getUniqueIdentifier()], withHandler: { (arrArticles, success, isResponseFromCache) in

			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.tblVwArticleByCategory.removeLoader(by: isResponseFromCache!)
				guard let articleArray = arrArticles as? [Article] else {
					self.tblVwArticleByCategory.infiniteScrollingView?.hasMoreData = false
					return
				}
				if articleArray.count == 0 && offset == 0 {
					self.lblNoRecord.hidden = false
					self.tblVwArticleByCategory.setShowsInfiniteScrolling(false)
				} else if articleArray.count == 0 && offset > 0 {
					// Infinite scroll View to represent no more records
					if !(isResponseFromCache!) {
						self.lblNoRecord.hidden = true
						self.tblVwArticleByCategory.infiniteScrollingView?.hasMoreData = false
					}
				}

				if articleArray.count < self.articlesLimit && articleArray.count > 0 {
					self.lblNoRecord.hidden = true
					self.tblVwArticleByCategory.infiniteScrollingView?.hasMoreData = false
				}

				if offset == 0 {
					self.arrayArticlesByCategory = articleArray
				} else {
					self.arrayArticlesByCategory?.appendContentsOf(articleArray)
				}
				self.tblVwArticleByCategory.reloadData()

			})
		}) { (error) in
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.tblVwArticleByCategory.removeLoader(by: false)

			})
		}
	}

	// MARK: - Navigation

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let objArticle = objArticleByCategory else {
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

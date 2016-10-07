//
//  CategoryViewController.swift
//  Uplift
//
//  Created by Sarishti on 8/30/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UICollectionViewDataSource, CategoryWebserviceProtocol, UICollectionViewDelegateFlowLayout {

	static let numberOfItemsHorizontally: CGFloat = 2
	static let numberOfItemsVertically: CGFloat = 3
	static let cellsSpacing: CGFloat = 6

	// MARK: Properties

	let categoryCollectionViewIdentifier = "CategoryCollectionViewCell"

	/// Array and model Object
	var arrayCategories: [Category]?
	var objCategory: Category?

	/// Paggination Limit
	let categoryLimit = 20

	/// Global Offset value
	var articleOffSet = 0

	/// Bool Values
	var shouldCacheResponse = true

	/// Outlet
	@IBOutlet weak var lblNoRecord: UILabel!
	@IBOutlet weak var collectionViewCategory: UICollectionView!

	// MARK: View LifeCycle

	override func viewDidLoad() {
		super.viewDidLoad()

		AppUtility.setTabBarColor(with: UIColor(named: .YourUpsTabBarColor), viewController: self)
		setNavigationBarTransparent()
		self.lblNoRecord.hidden = true
		self.setPullToRefreshOnCollectionVw()
		self.setInfiniteScrollOnCollectionVw()
	}

	override func viewWillAppear(animated: Bool) {
		self.collectionViewCategory.infiniteScrollingView?.hasMoreData = true
		fetchAllCategories(0)
		(self.navigationController?.tabBarController as? CustomTabBarViewController)!.hideBottomBar(false)

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		memoryReleaseSDWebImage()
		// Dispose of any resources that can be recreated.
	}

	// MARK: Pull to refresh
	/**
     Set the Reuseable component Pull to refresh handler
     */
	func setPullToRefreshOnCollectionVw() {
		collectionViewCategory.addPullToRefreshHandler {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
				self.collectionViewCategory.setShowsInfiniteScrolling(true)
				self.collectionViewCategory.infiniteScrollingView?.hasMoreData = true
				self.fetchAllCategories(0)

			})
		}
	}
	// MARK: - Infinite scrolling
	/**
     Set reuseable component Infinite scroller handler
     */
	func setInfiniteScrollOnCollectionVw() {
		let fontForInfiniteScrolling = UIFont(name: "HelveticaNeue-Bold", size: 15) ?? UIFont.boldSystemFontOfSize(17)

		self.collectionViewCategory
			.addInfiniteScrollingWithHandler(fontForInfiniteScrolling, fontColor: UIColor(named: .CategoryNoMoreRecordColor), actionHandler: {

				if self.collectionViewCategory.infiniteScrollingView!.hasMoreData {
					dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
						self.loadMoreCategories(with: self.articleOffSet)

					})
				}

		})
	}

	// MARK:  CollectionView delegate & data source

	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let arrCategory = self.arrayCategories else {
			return 0
		}
		return arrCategory.count

	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		guard let cell: CategoryCollectionViewCell = (collectionView.dequeueReusableCellWithReuseIdentifier(categoryCollectionViewIdentifier, forIndexPath: indexPath) as? CategoryCollectionViewCell), arrCategories = self.arrayCategories else {
			return UICollectionViewCell()
		}

		let objCategory = arrCategories[indexPath.row]

		cell.setContentOnCell(objCategory)

		if arrCategories.count - 1 == indexPath.row {
			self.articleOffSet = arrCategories.count

		}
		return cell
	}

	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

		let size = CGSize(width: (self.collectionViewCategory.frame.size.width / CategoryViewController.numberOfItemsHorizontally) - CategoryViewController.cellsSpacing, height: (self.collectionViewCategory.frame.size.height / CategoryViewController.numberOfItemsVertically) - CategoryViewController.cellsSpacing)
		return size
	}

	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		guard let arrCategories = self.arrayCategories where self.arrayCategories!.isIndexWithinBound(indexPath.row) else {

			assert((arrayCategories != nil) && (arrayCategories!.isIndexWithinBound(indexPath.row)), "arrArticles is nil or index is out of bound")

			return
		}

		self.objCategory = arrCategories[indexPath.row]
		let CategoryName = self.objCategory?.categoryName

		self.setGoogleAnalyticsEvent(CategoryName!, action: "Select Category", label: "SomeLabel", value: nil)

		self.performSegueWithIdentifier(StoryboardSegue.Main.ShowCategoryArticleVC.rawValue, sender: self)
	}
	func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
		guard let cell: CategoryCollectionViewCell = (collectionView.dequeueReusableCellWithReuseIdentifier(categoryCollectionViewIdentifier, forIndexPath: indexPath) as? CategoryCollectionViewCell) else {
			return
		}

		cell.imgCategory.sd_cancelCurrentImageLoad()
	}

	// MARK: - Load more
	/**
     Load more articles

     - parameter offset: starting index of articles
     */

	func loadMoreCategories(with offset: Int) {
		fetchAllCategories(offset)
	}

	// MARK: - Webservice Calls

	/**
     Fetch the categories from particular index

     - parameter offset: starting index of categories
     */

	func fetchAllCategories(offset: Int) {

		fetchCategories(true, withData: [ServerKeys.CategoryOffset: offset, ServerKeys.CategoryLimit: categoryLimit, ServerKeys.DeviceId: getUniqueIdentifier()], withHandler: { (arrCategories, success, isResponseFromCache) in
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.collectionViewCategory.removeLoader(by: isResponseFromCache!)
				guard let categoryArray = arrCategories as? [Category] else {
					self.collectionViewCategory.infiniteScrollingView?.hasMoreData = false
					return
				}
				if categoryArray.count == 0 && offset == 0 {
					self.lblNoRecord.hidden = false
					self.collectionViewCategory.setShowsInfiniteScrolling(false)
				} else if categoryArray.count == 0 && offset > 0 {
					// Infinite scroll View to represent no more records
					if !(isResponseFromCache!) {
						self.lblNoRecord.hidden = true
						self.collectionViewCategory.infiniteScrollingView?.hasMoreData = false
					}
				}

				if categoryArray.count < self.categoryLimit && categoryArray.count > 0 {
					self.lblNoRecord.hidden = true
					self.collectionViewCategory.infiniteScrollingView?.hasMoreData = false
				}

				if offset == 0 {
					self.arrayCategories = categoryArray
				} else {
					self.arrayCategories?.appendContentsOf(categoryArray)
				}
				self.collectionViewCategory.reloadData()

			})
		}) { (error) in
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.collectionViewCategory.removeLoader(by: false)
			})
		}
	}

	// MARK: - Navigation

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let objectCategory = objCategory else {
			return
		}
		/**
         *  Navigate on article detail view controller with selected object
         */
		if segue.identifier == StoryboardSegue.Main.ShowCategoryArticleVC.rawValue {

			if let nextScene = segue.destinationViewController as? CategoryArticleViewController {
				nextScene.objCategory = objectCategory
				self.navigationController?.interactivePopGestureRecognizer?.enabled = true

			}
		}
	}

}

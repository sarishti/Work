//
//  MainFeedViewController.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/10/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import UIKit
import Foundation

class MainFeedViewController: UIViewController, ArticleWebserviceProtocol, QuoteWebserviceProtocol, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {

	/// Dictionary keys for article array
	let happiness3Key = "Happiness3", happiness2Key = "Happiness2", happiness1Key = "Happiness1"

	/// Limit used for pagination
	let articlesLimit = 20

	/// Bool values

	var isCollectionViewScrolling = false, shouldTableScrollToTop = false
	var shouldCacheResponse = true
	var isQuoteDisplayedOnStartup = true
	var currentlyDisplayedHappinnessPage = 0

	/// Array & Models
	var arrayArticles: [String: [Article]] = ["Happiness3": [], "Happiness2": [], "Happiness1": []]
	var dailyQuote: Quote?
	var selectedArticle: Article?

	// Table view
	var tblViewOfCollection: UITableView?

	/// IBActions
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var scrollPager: ScrollPager!

	// MARK: - View lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		setNavigationBarTransparent()
		initializeView()
		self.navigationController?.interactivePopGestureRecognizer?.delegate = self
		fetchArticlesBasedOnDisplayedHappiness(0)
		showQuoteIfNotDisplayedEarlier()
		addObservers()
		// Do any additional setup after loading the view.
	}

	override func viewDidAppear(animated: Bool) {
		setViewBackgroundColorBasedOnHappiness()

	}
	override func viewWillAppear(animated: Bool) {
		(self.navigationController?.tabBarController as? CustomTabBarViewController)!.hideBottomBar(false)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		memoryReleaseSDWebImage()
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	// MARK: - View setup

	/**
     Setup defaults of the view and set default values in variables
     */
	func initializeView() {
		isQuoteDisplayedOnStartup = QuoteManager().isQuoteDisplayedOnStartUp()
        title = L10n.MainFeedTitle
		scrollPager.addSegmentsWithTitles(["", "", ""])
	}

	func removeLoader(by isResponseFromCache: Bool) {
		if !(isResponseFromCache) {
			if let tableView = self.tblViewOfCollection {
				tableView.loaderStopAnimating()
			}
		}
	}

	/**
     In infinite scroll show "No more data" by set its bool value false
     */
	func setValueOfHasMoreDataFalse() {
		if let tableView = self.tblViewOfCollection {
			tableView.infiniteScrollingView?.hasMoreData = false
		}
	}

	// MARK: - Webservice Calls

	/**
     Fetch articles based on happiness rating
     - parameter happinessRating: HappinessRating(3,2,1)
     - parameter offset:          starting index of articles
     */
	func fetchHappinessArticles(by happinessRating: HappinessRating, offset: Int) {

		var happinessLevel = HappinessLevel.Happiness3
		var happinessKey = happiness3Key

		switch happinessRating {
		case .Happiness3:
			happinessLevel = HappinessLevel.Happiness3
			happinessKey = happiness3Key
		case .Happiness2:
			happinessLevel = HappinessLevel.Happiness2
			happinessKey = happiness2Key
		case .Happiness1:
			happinessLevel = HappinessLevel.Happiness1
			happinessKey = happiness1Key
		default: assert((happinessRating.rawValue < 0) || (happinessRating.rawValue > 3), "HappinessRating is incorrect")
		}

		fetchArticles(false, withData: [ServerKeys.HappinessLevel: happinessLevel.rawValue, ServerKeys.ArticlesOffset: offset, ServerKeys.ArticlesLimit: articlesLimit, ServerKeys.DeviceId:  getUniqueIdentifier()], withHandler: { (arrArticles, success, isResponseFromCache) in
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.removeLoader(by: isResponseFromCache!)
				guard let articleArray = arrArticles as? [Article] else {
					self.setValueOfHasMoreDataFalse()
					return
				}

				if articleArray.count < self.articlesLimit && articleArray.count > 0 {
					self.setValueOfHasMoreDataFalse()
				} else if articleArray.count == 0 && offset > 0 {
					// Infinite scroll View to represent no more records
					if !(isResponseFromCache!) {
						self.setValueOfHasMoreDataFalse()
					}
				}

				if offset == 0 {
					self.shouldTableScrollToTop = true
					self.arrayArticles[happinessKey] = articleArray
				} else {
					self.shouldTableScrollToTop = false
					self.arrayArticles[happinessKey]?.appendContentsOf(articleArray)
				}
				self.reloadCollectionView()

			})

		}) { (error) in
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.removeLoader(by: false)
			})
		}

	}

	/**
     Fetch articles based on current displayed happiness

     - parameter displayedHappiness: page index of current displayed happiness(0,1,2)
     */
	func fetchArticlesBasedOnDisplayedHappiness(displayedHappiness: Int) {

		shouldCacheResponse = true
		// resetBoolValues()

		switch displayedHappiness {
		case 0: fetchHappinessArticles(by: .Happiness3, offset: 0)
		case 1: fetchHappinessArticles(by: .Happiness2, offset: 0)
		case 2: fetchHappinessArticles(by: .Happiness1, offset: 0)
		default: assert((displayedHappiness < 0) && (displayedHappiness > 3), "displayedHappiness incorrect")
		}
	}

	/**
     Fetch latest quote
     */
	func fetchLatestQuote() {
		shouldCacheResponse = true
		fetchDailyQuote(false, withData: nil, withHandler: { (arrQuotes, success) in
			guard success else {
				self.hideQuote()
				return
			}
			guard let quoteArray = arrQuotes as? [Quote] where quoteArray.count > 0 else {
				self.hideQuote()
				return
			}
			self.dailyQuote = quoteArray[0]
			self.shouldTableScrollToTop = false
			self.reloadCollectionView()
		}) { (error) in
			DLog("Error")
		}
	}

	// MARK: - CollectionView delegate & data source

	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return arrayArticles.keys.count
	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell: ArticlesCollectionViewCell = (collectionView.dequeueReusableCellWithReuseIdentifier("ArticlesCollectionViewCell", forIndexPath: indexPath) as? ArticlesCollectionViewCell)!
		cell.isQuoteDisplayedOnStartup = true
		cell.dailyQuote = nil
		/// Set array of articles in cell & reload table
		let displayedHappiness = indexPath.item
		switch displayedHappiness {
		case 0:
			cell.isQuoteDisplayedOnStartup = isQuoteDisplayedOnStartup
			cell.dailyQuote = dailyQuote
			cell.arrArticles = arrayArticles[happiness3Key]
		case 1:
			cell.arrArticles = arrayArticles[happiness2Key]
		case 2:
			cell.arrArticles = arrayArticles[happiness1Key]
		default: assert((displayedHappiness < 0) && (displayedHappiness > 3), "displayedHappiness incorrect")
		}
		cell.reloadTableView(shouldTableScrollToTop)

		/**
         *  Handle events from  cell
         */
		cell.didRowSelected = { (article) in
			self.selectedArticle = article
            let articleName = self.selectedArticle!.title
            self.setGoogleAnalyticsEvent(articleName, action: "Select Article", label: "SomeLabel", value: nil)
			self.performSegueWithIdentifier(StoryboardSegue.Main.ShowArticleDetailVC.rawValue, sender: self)
		}
		cell.loadMoreArticlesHandler = { (offset, tableView) in
			self.tblViewOfCollection = tableView
			self.loadMoreArticles(indexPath.item, offset: offset)
		}
		cell.quoteDidHideHandler = { () in
			self.hideQuote()
		}
		return cell
	}

	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
	}

	func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
		setViewBackgroundColorBasedOnHappiness()
	}

	/**
     Reload collection view cell on main thread
     */
	func reloadCollectionView() {
		dispatch_async(dispatch_get_main_queue()) { () -> Void in
			self.collectionView.reloadData()
		}
	}

	// MARK: - ScrollView delegates

	func scrollViewDidScroll(scrollView: UIScrollView) {
		isCollectionViewScrolling = true
		scrollPager.scrollViewDidScroll(scrollView)
	}

	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		isCollectionViewScrolling = false
		let displayedHappiness = Int(collectionView.contentOffset.x / collectionView.frame.size.width)

		if displayedHappiness != currentlyDisplayedHappinnessPage {
			currentlyDisplayedHappinnessPage = displayedHappiness
			hideQuote()
			fetchArticlesBasedOnDisplayedHappiness(displayedHappiness)
		}
	}

	// MARK: - Navigation

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard selectedArticle != nil else { return }
		if segue.identifier == StoryboardSegue.Main.ShowArticleDetailVC.rawValue {
			if let nextScene = segue.destinationViewController as? ArticleDetailViewController {
				nextScene.objYourUpsArticle = selectedArticle
				self.navigationController?.interactivePopGestureRecognizer?.enabled = true
			}
		}
	}

	// MARK: View background color

	/**
     Change background color of window based on current displayed happiness
     */
	func setViewBackgroundColorBasedOnHappiness() {
		let displayedHappiness = Int(collectionView.contentOffset.x / collectionView.frame.size.width)

		var hapinnessRating: HappinessRating

		switch displayedHappiness {
		case 0: hapinnessRating = .Happiness3
		case 1: hapinnessRating = .Happiness2
		case 2: hapinnessRating = .Happiness1
		default: hapinnessRating = .None
		}

		(self.navigationController?.tabBarController as? CustomTabBarViewController)!.setViewBackgroundColor(hapinnessRating.getRatingColor)
	}

	// MARK: - Load more articles

	/**
     Handler to load more articles
     - parameter displayedHappiness: currently displayed page of happiness(0,1,2)
     - parameter offset:             start index of articles
     */
	func loadMoreArticles(displayedHappiness: Int, offset: Int) {
		if isCollectionViewScrolling { return }

		shouldCacheResponse = false

		switch displayedHappiness {
		case 0: fetchHappinessArticles(by: .Happiness3, offset: offset)
		case 1: fetchHappinessArticles(by: .Happiness2, offset: offset)
		case 2: fetchHappinessArticles(by: .Happiness1, offset: offset)
		default:
			assert((displayedHappiness < 0) && (displayedHappiness > 3), "displayedHappiness incorrect")
		}
	}

	// MARK: - Quote functionality

	/**
     Fetch latest quote & display if not displayed earlier
     */
	func showQuoteIfNotDisplayedEarlier() {
		if isQuoteDisplayedOnStartup { return }
		fetchLatestQuote()
	}

	/**
     Hide quote
     */
	func hideQuote() {
		if isQuoteDisplayedOnStartup { return }
		isQuoteDisplayedOnStartup = true
		QuoteManager().setIsQuoteDisplayed(true)
		shouldTableScrollToTop = false
		reloadCollectionView()
	}

	// MARK: - NSNotification

	func addObservers() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onArticleUpOrDownNotification), name: Constants.articleUpOrDownNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onArticleReloadNotification), name: Constants.articleReloadNotification, object: nil)
	}

	func onArticleUpOrDownNotification(notification: NSNotification) {
		guard let wrapper = notification.object as? Wrapper<Article> else { return }

		let article = wrapper.wrappedValue
		let displayedHappiness = Int(collectionView.contentOffset.x / collectionView.frame.size.width)
		switch displayedHappiness {
		case 0: updateArticleObjectFromCurrentHappinessPage(happiness3Key, changedArticle: article)
		case 1: updateArticleObjectFromCurrentHappinessPage(happiness2Key, changedArticle: article)
		case 2: updateArticleObjectFromCurrentHappinessPage(happiness1Key, changedArticle: article)
		default:
			assert((displayedHappiness < 0) && (displayedHappiness > 3), "displayedHappiness incorrect")
		}
	}

	func updateArticleObjectFromCurrentHappinessPage(happinessKey: String, changedArticle: Article) {
		if arrayArticles[happinessKey] == nil { return }

		let index = arrayArticles[happinessKey]!.indexOf { (article) -> Bool in
			return article.articleId == changedArticle.articleId
		}
		if index != nil {
			arrayArticles[happinessKey]![index!] = changedArticle
			shouldTableScrollToTop = false
			reloadCollectionView()
		}
	}

	func onArticleReloadNotification(notification: NSNotification) {
		shouldTableScrollToTop = true
		let displayedHappiness = Int(collectionView.contentOffset.x / collectionView.frame.size.width)
		fetchArticlesBasedOnDisplayedHappiness(displayedHappiness)
	}
}

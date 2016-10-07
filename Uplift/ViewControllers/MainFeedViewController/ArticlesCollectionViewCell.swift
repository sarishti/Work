//
//  ArticlesCollectionViewCell.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/17/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import UIKit

class ArticlesCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {

	/// IBOutlets
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var lblNoArticles: UILabel!

	/// Array & models
	var arrArticles: [Article]?
	var dailyQuote: Quote?

	/// Handlers
	var didRowSelected: ((Article?) -> ())?
	var loadMoreArticlesHandler: ((offset: Int, tableView: UITableView) -> ())?
	var quoteDidHideHandler: (() -> ())?

	/// Bool & int values
	var isQuoteDisplayedOnStartup = true
	let cellHeight = 130

	/// Custom views
	var quoteView: DailyQuoteView?

	override func awakeFromNib() {
		super.awakeFromNib()
		setupUI()

		// set the table view scrollable
		self.setPullToRefreshOnTable()
		setInfiniteScrollOnTable()

	}
	// MARK: Pull to refresh
	/**
     Set the Reuseable component Pull to refresh handler
     */
	func setPullToRefreshOnTable() {
		tableView.addPullToRefreshHandler {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
				self.tableView.infiniteScrollingView?.hasMoreData = true
				self.tableView.setShowsInfiniteScrolling(true)
				self.loadMoreArticles(0)

			})
		}
	}

	// MARK: - Infinite scrolling
	/**
     Set reuseable component Infinite scroller handler
     */

	func setInfiniteScrollOnTable() {
		// Initialization code
		let fontForInfiniteScrolling = FontFamily.OpenSans.Bold.font(15)

		tableView
			.addInfiniteScrollingWithHandler(fontForInfiniteScrolling, fontColor: UIColor(named: .YourUpsTabBarColor), actionHandler: {

				if self.tableView.infiniteScrollingView!.hasMoreData {
					dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in

						self.loadMoreArticles(self.arrArticles!.count)

					})
				}

		})
	}

	// MARK: - UI setup

	/**
     Set the UI of Cell
     */

	func setupUI() {
		/// Cell initial setup
		self.layer.cornerRadius = 3.0
	}

	// MARK: - UITableView methods

	/**
     Reload table view and add quote view if needed
     - parameter shouldTableScrollToTop: Bool to decide whether table view should scroll to top or not
     */
	func reloadTableView(shouldTableScrollToTop: Bool) {

		if shouldTableScrollToTop {
			tableView.contentOffset = CGPoint(x: 0, y: 0)
			self.tableView.infiniteScrollingView?.hasMoreData = true
		}

		quoteView?.removeFromSuperview()

		if !isQuoteDisplayedOnStartup {
			addQuoteView()
		}

		if arrArticles?.count == 0 {
			lblNoArticles.hidden = false
			self.tableView.setShowsInfiniteScrolling(false)
		} else {
			lblNoArticles.hidden = true
			self.tableView.setShowsInfiniteScrolling(true)
		}

		tableView.reloadData()
	}

	// MARK- UITableView delegate & data source

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		let totalCount = arrArticles?.count ?? 0
		return isQuoteDisplayedOnStartup ? totalCount : totalCount + 1
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		var cell: UITableViewCell

		if !isQuoteDisplayedOnStartup && indexPath.row == 0 {
			cell = tableView.dequeueReusableCellWithIdentifier("EmptyCell")!
		} else {
			cell = getHomeArticleTableViewCell(indexPath)
		}

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

		let index = isQuoteDisplayedOnStartup ? indexPath.row : indexPath.row - 1

		guard arrArticles != nil && arrArticles!.isIndexWithinBound(index) else {
			assert((arrArticles != nil) && (arrArticles!.isIndexWithinBound(index)), "arrArticles is nil or index is out of bound")

			return
		}

		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		didRowSelected?(arrArticles![index])
	}

	func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if let homeCell = cell as? HomeArticleTableViewCell {
            homeCell.imageViewthumbnail?.sd_cancelCurrentImageLoad()
        }
	}

	// MARK: - ScrollView delegate

	func scrollViewDidScroll(scrollView: UIScrollView) {

		if !isQuoteDisplayedOnStartup {
			setAlphaAndScaleOfQuote()
		}
	}

	// MARK: - HomeArticleTableViewCell

	/**
     Helper method to get HomeArticleTableViewCell

     - parameter indexPath: current indexpath

     - returns: Object of HomeArticleTableViewCell
     */
	func getHomeArticleTableViewCell(indexPath: NSIndexPath) -> HomeArticleTableViewCell {

		let cell = (tableView.dequeueReusableCellWithIdentifier("HomeArticleTableViewCell") as? HomeArticleTableViewCell)!
		cell.layer.cornerRadius = 3.0

		let index = isQuoteDisplayedOnStartup ? indexPath.row : indexPath.row - 1

		guard arrArticles != nil && arrArticles!.isIndexWithinBound(index) else {
			assert((arrArticles != nil) && (arrArticles!.isIndexWithinBound(index)), "arrArticles is nil or index is out of bound")
			return cell
		}

		cell.setContentOnCell(arrArticles![index])

		return cell
	}

	// MARK: - Load more

	/**
     Handler to fetch more articles

     - parameter offset: new cell index
     */
	private func loadMoreArticles(offset: Int) {
		loadMoreArticlesHandler?(offset: offset, tableView: self.tableView)
	}

	// MARK: - Quote functionality

	/**
     Create quote view and subview
     */
	func addQuoteView() {

		guard dailyQuote != nil else {
			return
		}

		quoteView = DailyQuoteView(frame: CGRect(x: 0, y: 0, width: 200, height: 120))
		self.contentView.addSubview(quoteView!)
		self.contentView.sendSubviewToBack(quoteView!)
		addConstraintsToQuoteView()
		quoteView?.setContentOnView(dailyQuote!)
		setAlphaAndScaleOfQuote()
	}

	/**
     Set alpha & scale of quote view based on tabe view scroll
     */
	func setAlphaAndScaleOfQuote() {
		var alpha = 1 - (tableView.contentOffset.y / CGFloat(cellHeight))

		if alpha < 0 {
			quoteDidHideHandler?()
			return
		}

		if alpha > 1 {
			alpha = 1
		}

		quoteView?.alpha = alpha
		quoteView?.transform = CGAffineTransformScale(CGAffineTransformIdentity, alpha, alpha)
	}

	/**
     Add constraints on quote view
     */
	func addConstraintsToQuoteView() {

		quoteView!.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-4-[quoteView(129)]",
			options: NSLayoutFormatOptions.AlignmentMask,
			metrics: nil,
			views: ["quoteView": quoteView!]))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-8-[quoteView]-8-|",
			options: NSLayoutFormatOptions.AlignmentMask,
			metrics: nil,
			views: ["quoteView": quoteView!]))
	}
}

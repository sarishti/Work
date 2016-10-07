//
//  HomeArticleTableViewCell.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/17/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import UIKit
import SDWebImage

class HomeArticleTableViewCell: UITableViewCell {

	/// IBOutlets
	@IBOutlet weak var imageViewthumbnail: UIImageView!
	@IBOutlet weak var viewHappinessRating: UIView!
	@IBOutlet weak var labelTitle: UILabel!
	@IBOutlet weak var btnCategory: UIButton!
	@IBOutlet weak var btnSource: UIButton!
	@IBOutlet weak var btnSinceDate: UIButton!
	@IBOutlet weak var btnNumberOfUps: UIButton!
	@IBOutlet weak var viewBackgroundShadow: UIView!

	override func awakeFromNib() {
		super.awakeFromNib()
		setupUI()
		// Initialization code
	}

	// MARK: - UI setup

	/**
     Set the UI of Cell
     */

	func setupUI() {
		imageViewthumbnail?.layer.cornerRadius = 5.0
		viewBackgroundShadow?.layer.cornerRadius = 3.0
		viewHappinessRating?.layer.cornerRadius = 1.5
		viewBackgroundShadow?.layer.shadowOffset = CGSize(width: 0, height: 0)
		viewBackgroundShadow?.layer.shadowColor = UIColor.darkGrayColor().CGColor
		viewBackgroundShadow?.layer.shadowOpacity = 0.4
		viewBackgroundShadow?.layer.shadowRadius = 2.0
	}

	/**
     Set the content of cell

     - parameter article: object of article from which we get data to fill
     */

	func setContentOnCell(article: Article) {
		setupUI()
		labelTitle.text = article.title
		btnCategory.setTitle(article.category.uppercaseString, forState: .Normal)
		btnSource.setTitle(article.source.uppercaseString, forState: .Normal)
		setDateIntervalOnButtonSinceData(article)
		viewHappinessRating.backgroundColor = article.happinessRating.getRatingColor

		if Int(article.numberOfUps) > 0 {
			btnNumberOfUps.hidden = false
			btnNumberOfUps.setTitle(article.numberOfUps, forState: .Normal)
		} else {
			btnNumberOfUps.hidden = true
		}

		imageViewthumbnail.sd_setImageWithURL(NSURL(string: article.thumbnailImageUrl), placeholderImage: UIImage(asset: .Article_default), options: .RefreshCached, completed: { (image: UIImage!, error: NSError!, cachetype: SDImageCacheType, url: NSURL!) -> Void in
		})
	}

	/**
     Find the time interval between two dates

     - parameter article: object of article which conatin article detail
     */

	func setDateIntervalOnButtonSinceData(article: Article) {

		let timeInterval = NSDate().offsetFrom(article.createdDate)
		btnSinceDate.setTitle(timeInterval, forState: .Normal)
	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}

}

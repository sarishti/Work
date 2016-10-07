//
//  YourUpsTableViewCell.swift
//  Uplift
//
//  Created by Sarishti on 8/12/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import UIKit
import SDWebImage

class YourUpsTableViewCell: UITableViewCell {

	// MARK: - Outlet properties

	@IBOutlet weak var imgVwArticleRating: UIImageView!
	@IBOutlet weak var imgVwArticle: UIImageView!
	@IBOutlet weak var lblArticleTitle: UILabel!
	@IBOutlet weak var btnUpCount: UIButton!
	@IBOutlet weak var btnCreatedDate: UIButton!
	@IBOutlet weak var btnCategoryName: UIButton!
	@IBOutlet weak var btnSourceName: UIButton!

	// MARK: - Cell Initializer

	override func awakeFromNib() {
		super.awakeFromNib()
		setUpUI()
		// Initialization code
	}

	// MARK: UI setup

	/**
     Set the UI of Cell
     */

	func setUpUI() {
		imgVwArticleRating.layer.borderColor = UIColor.whiteColor().CGColor
		imgVwArticleRating.layer.borderWidth = 1.5
	}

	/**
     Set the content of cell

     - parameter article: object of article from which we get data to fill
     */

	func setContentOnCell(article: Article) {

		lblArticleTitle.text = article.title
		btnSourceName.setTitle(article.source.uppercaseString, forState: .Normal)
		btnCategoryName.setTitle(article.category.uppercaseString, forState: .Normal)

		setDateIntervalOnButtonSinceData(article)
		imgVwArticleRating.backgroundColor = article.happinessRating.getRatingColor

		if Int(article.numberOfUps) > 0 {
			btnUpCount.hidden = false
			btnUpCount.setTitle(article.numberOfUps, forState: .Normal)
		} else {
			btnUpCount.hidden = true
		}

		self.imgVwArticle.sd_setImageWithURL(NSURL(string: article.thumbnailImageUrl), placeholderImage: UIImage(asset: .Article_default), completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
		})
	}

	/**
     Find the time interval between two dates

     - parameter article: object of article which conatin article detail
     */

	func setDateIntervalOnButtonSinceData(article: Article) {

		let timeInterval = NSDate().offsetFrom(article.createdDate)
		btnCreatedDate.setTitle(timeInterval, forState: .Normal)

	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}

}

//
//  CategoryCollectionViewCell.swift
//  Uplift
//
//  Created by Sarishti on 8/30/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import UIKit
import SDWebImage

class CategoryCollectionViewCell: UICollectionViewCell {

	// MARK: Properties

	/// Outlet
	@IBOutlet weak var lblCategoryName: UILabel!
	@IBOutlet weak var imgCategory: UIImageView!

	// MARK: Nib Methods

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
		/// Cell initial setup

	}

	/**
     Set the content of cell

     - parameter category: object of category from which we get data to fill
     */

	func setContentOnCell(category: Category) {

		lblCategoryName.text = category.categoryName.uppercaseString

		imgCategory.sd_setImageWithURL(NSURL(string: category.categoryImageUrl), placeholderImage: UIImage(asset: .Article_default), options: .RefreshCached, completed: { (image: UIImage!, error: NSError!, cachetype: SDImageCacheType, url: NSURL!) -> Void in
		})
	}

}

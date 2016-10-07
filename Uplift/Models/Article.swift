//
//  Article.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/11/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation

struct Article {

	/// Article model properties

	var articleId: String = ""
	var thumbnailImageUrl: String = ""
	var title: String = ""
	var happinessRating: HappinessRating
	var source: String = ""
	var category: String = ""
	var createdDate: NSDate = NSDate()
	var numberOfUps: String = ""
	var webUrl: String = ""
	var isUped: Bool
}

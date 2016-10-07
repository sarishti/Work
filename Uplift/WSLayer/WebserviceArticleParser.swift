//
//  WebserviceArticleParser.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/18/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation

protocol WebserviceArticleParser {

	// declaration of Functions defined in  protocol
	func fillModelArticleWithDict(dictArticle: NSDictionary) -> Article

}

extension WebserviceArticleParser {

	/**
	 Fill the model of article with response data

	 - parameter dictArticle: dictionary conatins articles

	 - returns: article model object
	 */

	func fillModelArticleWithDict(dictArticle: NSDictionary) -> Article {

		let articleId = AppUtility.getIntForKey(ServerKeys.keyServerArticleId, dictResponse: dictArticle)
		let strArticleId = "\(articleId)"

		let thumbnailImageUrl = AppUtility.getStringForKey(ServerKeys.keyServerLogoUrl, dictResponse: dictArticle)
		let title = AppUtility.getStringForKey(ServerKeys.keyServerArticleTitle, dictResponse: dictArticle)
		let source = AppUtility.getStringForKey(ServerKeys.keyServerSourceName, dictResponse: dictArticle)
		let category = AppUtility.getStringForKey(ServerKeys.keyServerCategoryName, dictResponse: dictArticle)
		let webUrl = AppUtility.getStringForKey(ServerKeys.keyServerArticleUrl, dictResponse: dictArticle)
		let isUped = AppUtility.getBoolForKey(ServerKeys.keyServerIsUps, dictResponse: dictArticle)
		let yourUpCount = AppUtility.getStringForKey(ServerKeys.keyServerUpCount, dictResponse: dictArticle)
		let createdOn = AppUtility.getStringForKey(ServerKeys.keyServerCreatedOn, dictResponse: dictArticle)
		// Save the date in GMT Time zone
		let formatter = NSDateFormatter()
		formatter.timeZone = NSTimeZone(name: "GMT")
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		var createdDate = NSDate()
		if let articleDate = formatter.dateFromString(createdOn) {
			createdDate = articleDate
		}

		var happinessRating = HappinessRating.None

		let articleHappinessRating = AppUtility.getStringForKey(ServerKeys.keyServerHappinessRating, dictResponse: dictArticle)
		if let intHappinessRating = Int(articleHappinessRating) {
			switch intHappinessRating {
			case 1:
				happinessRating = .Happiness1
			case 2:
				happinessRating = .Happiness2
			case 3:
				happinessRating = .Happiness3
			default:
				happinessRating = .None
			}
		}
		let article = Article(articleId: strArticleId, thumbnailImageUrl: thumbnailImageUrl, title: title, happinessRating: happinessRating, source: source, category: category, createdDate: createdDate, numberOfUps: yourUpCount, webUrl: webUrl, isUped: isUped)
		return article

	}

}

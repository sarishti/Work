//
//  Serverkeys.swift
//  Uplift
//
//  Created by Sarishti on 8/12/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation

struct ServerKeys {
	static let keyServerError = "error"
	static let keyServerResponse = "response"
    static let keyServerDetail = "detail"
    static let keyServerMessage = "message"
    static let keyServerStatus = "status"
    static let keyServerCode = "code"

	// Article keys

	static let keyServerArticleId = "articleId"
	static let keyServerArticleTitle = "articleTitle"
	static let keyServerLogoUrl = "logoUrl"
	static let keyServerSourceName = "sourceName"
	static let keyServerCategoryName = "categoryName"
	static let keyServerCreatedOn = "createdOn"
	static let keyServerArticleUrl = "articleUrl"
	static let keyServerHappinessRating = "happinesRating"
	static let keyServerUpCount = "count"
	static let keyServerIsUps = "isUp"

    //MARK: - Article request keys

    static let HappinessLevel = "hpLevel"
    static let ArticlesLimit = "limit"
    static let ArticlesOffset = "offset"

    //MARK: - category request keys

    static let CategoryLimit = "limit"
    static let CategoryOffset = "offset"
    static let categoryId = "categoryId"

    // Up request keys
    static let DeviceId = "deviceId"
    static let IsUp = "isUps"
    static let ArticleId = "articleId"

    //MARK: - Daily Quote

    static let keyQuoteId = "quoteId"
    static let keyQuoteText = "quoteText"
    static let keyQuoteCreatedOn = "createdOn"
    static let keyQuoteAuthor = "author"

    //MARK: Category keys

    static let keyCategoryId = "categoryId"
    static let keyCategoryImage = "categoryImage"
    static let keyCategoryCreatedOn = "createdOn"
    static let keyCategoryName = "categoryName"
    static let keyCategoryStatus = "status"
}

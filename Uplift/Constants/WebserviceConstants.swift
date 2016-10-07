//
//  WebserviceConstants.swift
//  Uplift
//
//  Created by Sarishti on 8/16/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation
struct WebserviceConstants {

	// MARK: Your Ups get service Module

	static let wsYourUps = "getUpsArticles/"
    //deviceId=f123&hpLevel=3&limit=20&offset=0

    // up/down the particular article
    /// up/down the particular article with article id = 1?deviceId=f123&isUps=false"
    static let wsUpAnArticle =  "makeUpsOnArticle/"

    // MARK:  Main Field Articles
	static let wsArticles = "getArticles/"

	///  Daily quote

	static let wsDailyQuote = "getLatestQuote/"

    // MARK:  All Categories

    static let wsCategories = "getAllCategory/"
    /// Get article based on particular category id
    static let wsArticlesByCategory = "getArticlesByCategory/"

}

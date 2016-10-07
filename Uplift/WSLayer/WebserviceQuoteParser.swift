//
//  WebserviceQuoteParser.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/23/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation

protocol WebserviceQuoteParser {

	// declaration of Functions defined in  protocol
	func fillModelQuoteWithDict(dictQuote: NSDictionary) -> Quote
}

extension WebserviceQuoteParser {
	/**
	 Fill the quote model as per response

	 - parameter dictQuote: dictionary of quote

	 - returns: quote with model
	 */
	func fillModelQuoteWithDict(dictQuote: NSDictionary) -> Quote {

		let quoteId = AppUtility.getIntForKey(ServerKeys.keyQuoteId, dictResponse: dictQuote)
		let quoteText = AppUtility.getStringForKey(ServerKeys.keyQuoteText, dictResponse: dictQuote)
		let quoteAuthor = AppUtility.getStringForKey(ServerKeys.keyQuoteAuthor, dictResponse: dictQuote)
		let createdOn = AppUtility.getStringForKey(ServerKeys.keyQuoteCreatedOn, dictResponse: dictQuote)

		let formatter = NSDateFormatter()
		formatter.timeZone = NSTimeZone(name: "GMT")
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		var createdDate = NSDate()
		if let articleDate = formatter.dateFromString(createdOn) {
			createdDate = articleDate
		}

		let quote = Quote(quoteId: quoteId, quoteText: quoteText, quoteAuthor: quoteAuthor, createdOn: createdDate)
		return quote
	}
}

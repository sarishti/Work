//
//  QuoteManager.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/19/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation

struct QuoteManager {

    let quoteDisplayedKey = "IsQuoteDiplayed"

    func isQuoteDisplayedOnStartUp() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(quoteDisplayedKey)
    }

    func setIsQuoteDisplayed(isQuoteDisplayed: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(isQuoteDisplayed, forKey: quoteDisplayedKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

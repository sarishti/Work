//
//  QuoteWebserviceProtocol.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/19/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation

protocol QuoteWebserviceProtocol: WebserviceProtocol, WebserviceQuoteParser {

}

extension QuoteWebserviceProtocol {

    /**
     Fetch the daily quote for happiness level 3

     - parameter showLoader: show loader true/ false
     - parameter dic:        data to send in dictionary
     - parameter handler:    response handler
     - parameter falitureHandler:  faliture case handle
     */

    func fetchDailyQuote(showLoader: Bool, withData dic: [NSObject: AnyObject]?, withHandler handler: (arrQuotes: Any?, success: Bool) -> Void, falitureHandler: (error: Any?) -> Void) {

        self.requestToGet(url: WebserviceConstants.wsDailyQuote, params: nil, showLoader: showLoader, withCompletionHandler: { (obj, success, isResponseFromCache) in

            guard success else { handler(arrQuotes: nil, success: false); return }

            guard let dictResp = obj as? [String: AnyObject] else { handler(arrQuotes: nil, success: false); return }
            guard let arrQuotesResp = AppUtility.getValueForKey(ServerKeys.keyServerResponse, dictResponse: dictResp) as? NSArray where arrQuotesResp.count > 0 else {
                handler(arrQuotes: nil, success: false); return
            }

            var arrQuotes = [Quote]()
            for dictQuote in arrQuotesResp {
                if let dict = dictQuote as? NSDictionary {
                    let article = self.fillModelQuoteWithDict(dict)
                    arrQuotes.append(article)
                    break // Only one quote needed
                }
            }

            handler(arrQuotes: arrQuotes, success: true)
            }, falitureHandler: {(error) in
                falitureHandler(error: error)
        })
    }
}

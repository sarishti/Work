//
//  ArticleWebserviceProtocol.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/18/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation

protocol ArticleWebserviceProtocol: WebserviceProtocol, WebserviceArticleParser {

	associatedtype CompletionHandler = (obj: Any?, success: Bool?, isResponseFromCache:Bool?) -> Void

	 func fetchYourUpArticles(showLoader: Bool, withData params: [NSObject: AnyObject]?, withHandler handler: (arrArticles: Any?, success: Bool?, isResponseFromCache: Bool?) -> Void, falitureHandler: (error: Any?) -> Void)

}

extension ArticleWebserviceProtocol {

    /**

     Get the articles which are uped by particular device id

     - parameter showLoader: display loader true/ false
     - parameter params:        parameters to send in request
     - parameter handler:    response handler
     - parameter falitureHandler:  faliture case handle
     */

    func fetchYourUpArticles(showLoader: Bool, withData params: [NSObject: AnyObject]?, withHandler handler: (arrArticles: Any?, success: Bool?, isResponseFromCache: Bool?) -> Void, falitureHandler: (error: Any?) -> Void) {

		self.requestToGet(url: WebserviceConstants.wsYourUps, params: params, showLoader: showLoader, withCompletionHandler: { (obj, success, isResponseFromCache) in

			guard success else { handler(arrArticles: nil, success: false, isResponseFromCache:isResponseFromCache); return }
            guard let dictResp = obj as? [String: AnyObject] else { handler(arrArticles: nil, success: false, isResponseFromCache:isResponseFromCache); return }

			guard let arrArticlesResp = AppUtility.getValueForKey(ServerKeys.keyServerResponse, dictResponse: dictResp) as? NSArray else {
				return
			}

			var arrArticles = [Article]()
			for dictArticle in arrArticlesResp {
				if let dict = dictArticle as? NSDictionary {
					let article = self.fillModelArticleWithDict(dict)
					arrArticles.append(article)
				}
			}

			handler(arrArticles: arrArticles, success: true, isResponseFromCache:isResponseFromCache)
            }, falitureHandler: {(error) in
               falitureHandler(error: error)
        })
	}


	/**
	 Make the article Up and down

	 - parameter showLoader: display loader true/ false
	 - parameter dic:        dictionary of article id,deviceid,up state
	 - parameter handler:    response handler
      - parameter falitureHandler:  faliture case handle
	 */

    func upArticle(showLoader: Bool, withData dic: [NSObject: AnyObject]?, withHandler handler: (obj: Any?, success: Bool?) -> Void, falitureHandler: (error: Any?) -> Void) {

        var dict = [:]
        if let dictValue = dic {
            dict = dictValue
        }

        let url = WebserviceConstants.wsUpAnArticle

        self.requestforPOST(url: url, params: dict as [NSObject: AnyObject], withCompletionHandler: { (obj, success, isResponseFromCache) in

            guard success else { handler(obj: nil, success: false); return }

            guard let dictResp = obj as? [String: AnyObject] else { handler(obj: nil, success: false); return }
            guard let responseArr = AppUtility.getValueForKey(ServerKeys.keyServerResponse, dictResponse: dictResp) as? NSArray else {
                return
            }

            guard let countDict = (responseArr[0]) as? NSDictionary where ((AppUtility.getValueForKey(ServerKeys.keyServerResponse, dictResponse: dictResp) as? NSArray) != nil) else {
                return
            }
            let count = AppUtility.getValueForKey(ServerKeys.keyServerUpCount, dictResponse: countDict) as? String
            handler(obj: count, success: true)
            }, falitureHandler: {(error) in
                falitureHandler(error: error)
        })
    }

	/**
	 get the list of articles from service

	 - parameter showLoader: display loader true/ false
	 - parameter params:     parameters to send in request
	 - parameter handler:    response handler
      - parameter falitureHandler:  faliture case handle
	 */

    func fetchArticles(showLoader: Bool, withData params: [NSObject: AnyObject]?, withHandler handler: (arrArticles: Any?, success: Bool?, isResponseFromCache: Bool?) -> Void, falitureHandler: (error: Any?) -> Void) {

		self.requestToGet(url: WebserviceConstants.wsArticles, params: params, showLoader: showLoader, withCompletionHandler: { (obj, success, isResponseFromCache) in

			guard success else { handler(arrArticles: nil, success: false, isResponseFromCache: isResponseFromCache); return }
			guard let dictResp = obj as? [String: AnyObject] else { handler(arrArticles: nil, success: false, isResponseFromCache: isResponseFromCache); return }

			guard let arrArticlesResp = AppUtility.getValueForKey(ServerKeys.keyServerResponse, dictResponse: dictResp) as? NSArray else {
				return
			}

			var arrArticles = [Article]()
			for dictArticle in arrArticlesResp {
				if let dict = dictArticle as? NSDictionary {
					let article = self.fillModelArticleWithDict(dict)
					arrArticles.append(article)
				}

			}

			handler(arrArticles: arrArticles, success: true, isResponseFromCache: isResponseFromCache)
            }, falitureHandler: {(error) in
                falitureHandler(error: error)
            })
	}

    /**
     Get the articles based Upon The particular category

     - parameter showLoader: display loader true/ false
     - parameter params:        parameters to send in request
     - parameter handler:    response handler
     - parameter falitureHandler: faliture case handle
     */

    func fetchArticlesByCategory(showLoader: Bool, withData params: [NSObject: AnyObject]?, withHandler handler: (arrArticles: Any?, success: Bool?, isResponseFromCache: Bool?) -> Void, falitureHandler: (error: Any?) -> Void) {

        self.requestToGet(url: WebserviceConstants.wsArticlesByCategory, params: params, showLoader: showLoader, withCompletionHandler: { (obj, success, isResponseFromCache) in

            guard success else { handler(arrArticles: nil, success: false, isResponseFromCache: isResponseFromCache); return }
            guard let dictResp = obj as? [String: AnyObject] else { handler(arrArticles: nil, success: false, isResponseFromCache: isResponseFromCache); return }

            guard let arrArticlesResp = AppUtility.getValueForKey(ServerKeys.keyServerResponse, dictResponse: dictResp) as? NSArray else {
                return
            }

            var arrArticles = [Article]()
            for dictArticle in arrArticlesResp {
                if let dict = dictArticle as? NSDictionary {
                    let article = self.fillModelArticleWithDict(dict)
                    arrArticles.append(article)
                }
            }

            handler(arrArticles: arrArticles, success: true, isResponseFromCache: isResponseFromCache)
            }, falitureHandler: {(error) in
                falitureHandler(error: error)
        })
    }
}

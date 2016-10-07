//
//  WebserviceProtocol.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/11/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation
import CMLibrary

protocol WebserviceProtocol {

	/// set and get the value of cache enable or disable
    var shouldCacheResponse: Bool { get set }

    func requestToGet(url serviceURL: String, params: [NSObject: AnyObject]?, showLoader: Bool, withCompletionHandler successHandler: SuccessCompletionHandler, falitureHandler: FalitureCompletionHandler)
    func requestforPOST(url serviceURL: String, params: [NSObject: AnyObject], withCompletionHandler successHandler: SuccessCompletionHandler, falitureHandler: FalitureCompletionHandler)
}

extension WebserviceProtocol {
    typealias SuccessCompletionHandler = (obj: AnyObject?, success: Bool, isResponseFromCache: Bool) -> Void
    typealias FalitureCompletionHandler = (error: NSError?) -> Void

	/**
	 Handle the faliure of service response

	 - parameter response: response from service

	 - returns: true or false
	 */

	private func handleFailureWithOperation(response: WebserviceResponse) -> Bool {

		guard let dic = response.webserviceResponse as? NSDictionary else {
			AppUtility.showAlert("Error".localized, message: "Nil Response".localized, delegate: nil)
			return true
		}

		guard let status = AppUtility.getObjectForKey(ServerKeys.keyServerStatus, dictResponse: dic) as? NSNumber where status.intValue == 1 else {

			guard let errorMessage = AppUtility.getObjectForKey(ServerKeys.keyServerMessage, dictResponse: dic) as? String else {

				AppUtility.showAlert("Error".localized, message: "Nil Response".localized, delegate: nil)
				return true
			}

			AppUtility.showAlert("Error".localized, message: errorMessage, delegate: nil)

			return true
		}

		return false
	}
	/**
	 Request to get data

     - parameter serviceURL: url to hit service
     - parameter params:     parameters of service
     - parameter showLoader: loader hide/show
     - parameter successHandler:    response handler
      - parameter falitureHandler:  faliture case handle
     */

	func requestToGet(url serviceURL: String, params: [NSObject: AnyObject]?, showLoader: Bool, withCompletionHandler successHandler: SuccessCompletionHandler, falitureHandler: FalitureCompletionHandler) {

		var webserviceCachePolicy = WebserviceCallCachePolicyRequestFromUrlNoCache

		if shouldCacheResponse {
			webserviceCachePolicy = WebserviceCallCachePolicyRequestFromCacheFirstAndThenFromUrlAndUpdateInCache
		}

		let webservice = WebserviceCall(responseType: WebserviceCallResponseJSON, requestType: WebserviceCallRequestTypeJson, cachePolicy: webserviceCachePolicy)
		webservice.isShowLoader = showLoader
		webservice.shouldDisableInteraction = true

		let urlStr = Configuration.BaseURL() + "\(serviceURL)"

		guard let url = NSURL(string: urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!) else {
			return
		}

		webservice.GET(url, parameters: params as [NSObject: AnyObject]!, withSuccessHandler: { (response: WebserviceResponse!) -> Void in

			if self.handleFailureWithOperation(response) {
                successHandler(obj: response?.webserviceResponse, success: false, isResponseFromCache:response.isResponseFromCache)
			} else {
                DLog("response cache: \(response.isResponseFromCache)")
                successHandler(obj: response?.webserviceResponse, success: true, isResponseFromCache:response.isResponseFromCache)
			}

			}, withFailureHandler: { (error: NSError?) -> Void in
                falitureHandler(error:error)
			DLog("Service failure, \(error?.description), \(error)")
		})
	}


    /**
     Request for post data

     - parameter serviceURL:       webservice url
     - parameter params:           dict to post
     - parameter handler:          completion handler
      - parameter falitureHandler:  faliture case handle
     */

    func requestforPOST(url serviceURL: String, params: [NSObject: AnyObject], withCompletionHandler handler: SuccessCompletionHandler, falitureHandler: FalitureCompletionHandler) {

        var webserviceCachePolicy = WebserviceCallCachePolicyRequestFromUrlNoCache

        if shouldCacheResponse {
            webserviceCachePolicy = WebserviceCallCachePolicyRequestFromCacheFirstAndThenFromUrlAndUpdateInCache
        }

        let webservice = WebserviceCall(responseType: WebserviceCallResponseJSON, requestType: WebserviceCallRequestTypeJson, cachePolicy: webserviceCachePolicy)
        webservice.isShowLoader = true
        webservice.shouldDisableInteraction = true


        let urlStr = Configuration.BaseURL() + "\(serviceURL)"

        guard let url = NSURL(string: urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!) else {
            return
        }


        webservice?.POST(url, parameters: params, withSuccessHandler: { (response: WebserviceResponse?) -> Void in

            if self.handleFailureWithOperation(response!) {
                handler(obj: response?.webserviceResponse, success: false, isResponseFromCache: response!.isResponseFromCache)
            } else {
                handler(obj: response?.webserviceResponse, success: true, isResponseFromCache: response!.isResponseFromCache)
            }

            }, withFailureHandler: { (error: NSError?) -> Void in
        })
    }
}

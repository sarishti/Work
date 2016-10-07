//
//  CategoryWebserviceProtocol.swift
//  Uplift
//
//  Created by Sarishti on 9/1/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation
protocol CategoryWebserviceProtocol: WebserviceProtocol, WebserviceCategoryParser {

}
extension CategoryWebserviceProtocol {

	/**
	 Get all categories with device id

	 - parameter showLoader: display loader true/ false
	 - parameter params:        parameters to send in request
	 - parameter handler:    response handler
      - parameter falitureHandler:  faliture case handle
	 */

	func fetchCategories(showLoader: Bool, withData params: [NSObject: AnyObject]?, withHandler handler: (arrCategories: Any?, success: Bool?, isResponseFromCache: Bool?) -> Void, falitureHandler: (error: Any?) -> Void) {
  

		self.requestToGet(url: WebserviceConstants.wsCategories, params: params, showLoader: showLoader, withCompletionHandler: { (obj, success, isResponseFromCache) in

            guard success else { handler(arrCategories: nil, success: false, isResponseFromCache:isResponseFromCache); return }
			guard let dictResp = obj as? [String: AnyObject] else { handler(arrCategories: nil, success: false, isResponseFromCache:isResponseFromCache); return }

			guard let arrCategoriesResp = AppUtility.getValueForKey(ServerKeys.keyServerResponse, dictResponse: dictResp) as? NSArray else {
				return
			}

			var arrCategory = [Category]()
			for dictCategory in arrCategoriesResp {
				if let dict = dictCategory as? NSDictionary {
					let category = self.fillModelCategoryWithDict(dict)
					arrCategory.append(category)
				}
			}

            handler(arrCategories: arrCategory, success: true, isResponseFromCache:isResponseFromCache)
            }, falitureHandler: {(error) in
                falitureHandler(error: error)
		})
	}
}

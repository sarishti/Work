//
//  WebserviceCategoryParser.swift
//  Uplift
//
//  Created by Sarishti on 9/1/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation

protocol WebserviceCategoryParser {

    // declaration of Functions defined in  protocol
    func fillModelCategoryWithDict(dictQuote: NSDictionary) -> Category
}

extension WebserviceCategoryParser {
    /**
     Fill the category model as per response

     - parameter dictCategory: dictionary of category

     - returns: category with model
     */
    func fillModelCategoryWithDict(dictCategory: NSDictionary) -> Category {

        let categoryId = AppUtility.getIntForKey(ServerKeys.keyCategoryId, dictResponse: dictCategory)
        let categoryName = AppUtility.getStringForKey(ServerKeys.keyCategoryName, dictResponse: dictCategory)
        let categoryImage = AppUtility.getStringForKey(ServerKeys.keyCategoryImage, dictResponse: dictCategory)
        let createdOn = AppUtility.getStringForKey(ServerKeys.keyCategoryCreatedOn, dictResponse: dictCategory)

        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(name: "GMT")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var createdDate = NSDate()
        if let categoryDate = formatter.dateFromString(createdOn) {
            createdDate = categoryDate
        }

        let status = AppUtility.getStringForKey(ServerKeys.keyCategoryStatus, dictResponse: dictCategory)


        let category = Category(categoryId: categoryId, categoryName: categoryName, categoryImageUrl: categoryImage, createdOn: createdDate, status:status)
        return category
    }
}

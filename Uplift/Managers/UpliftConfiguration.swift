//
//  UpliftConfiguration.swift
//  Uplift
//
//  Created by Sarishti on 8/23/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation
import UIKit

struct Configuration {

	static var config: String?
	static var variables: NSDictionary?

    /**
     Set the configuartion variables from plist
     */

	static func setConfiguaration() {
		if let configuration = NSBundle.mainBundle().objectForInfoDictionaryKey("Configuration") as? String {
			self.config = configuration.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
			if let path = NSBundle.mainBundle().pathForResource("Configurations", ofType: "plist") {
				// use swift dictionary as normal
				let dict = NSDictionary(contentsOfFile: path)
				self.variables = dict!.objectForKey(self.config!) as? NSDictionary
			}
		}
	}

    /**
     Get the base Url according to  configuration

     - returns: base url in string
     */

	static func BaseURL() -> String! {
		 self.setConfiguaration()
		if (self.variables) != nil {
			if let url = self.variables!.objectForKey("BaseUrl") as? String {
				return url
			}
		}
		return ""
	}

}

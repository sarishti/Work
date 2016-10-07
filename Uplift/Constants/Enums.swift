//
//  Enums.swift
//  Uplift
//
//  Created by Sarishti on 8/12/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation
import UIKit


enum HappinessLevel: String {
	case None = "0", Happiness1 = "1", Happiness2 = "2", Happiness3 = "3"
}

enum HappinessRating: Int {
	case None = 0, Happiness3, Happiness2, Happiness1
	var getRatingColor: UIColor {
		switch self {
		case None:
			return UIColor.whiteColor()
		case Happiness3:
            return UIColor(red: 251.0 / 255.0, green: 117.0 / 255.0, blue: 69.0 / 255.0, alpha: 1.0)
        case Happiness2:
            return UIColor(red: 250.0 / 255.0, green: 148.0 / 255.0, blue: 1.0 / 255.0, alpha: 1.0)
        case Happiness1:
            return UIColor(red: 238.0 / 255.0, green: 187.0 / 255.0, blue: 107.0 / 255.0, alpha: 1.0)
		}

	}
}

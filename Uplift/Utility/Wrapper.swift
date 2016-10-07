//
//  Wrapper.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/24/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation

class Wrapper<T> {
    var wrappedValue: T
    init(theValue: T) {
        wrappedValue = theValue
    }
}

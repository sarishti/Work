//
//  Macros.swift
//  Uplift
//
//  Created by Sarishti on 8/23/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation

// DLog and aLog macros to abbreviate NSLog.
// Use like this:
//
//   dLog("Log this!")
//

func DLog(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
	#if DEBUG
		let splitFilename = filename.componentsSeparatedByString("/")
		let classGuess = splitFilename[splitFilename.endIndex - 1]
		print("\(classGuess) : \(function) : \(line) - \(message)")
	#endif
}

func aLog(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
	let splitFilename = filename.componentsSeparatedByString("/")
	let classGuess = splitFilename[splitFilename.endIndex - 1]
	print("\(classGuess) : \(function) : \(line) - \(message)")
}

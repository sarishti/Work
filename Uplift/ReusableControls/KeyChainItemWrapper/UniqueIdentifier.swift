//
//  UniqueIdentifier.swift
//  UniqueIdentifierLibrary
//
//  Created by Sarishti on 9/14/16.
//  Copyright © 2016 sarishti. All rights reserved.
//

import Foundation

extension NSObject {

	/**
     Set the unique identifier in keychain
     */
	func setUniqueIdentifier() {
		let keyChain = KeychainItemWrapper.init(identifier: "Test", accessGroup: nil)
		guard let strUUIDKeyChain = keyChain.objectForKey(kSecAttrAccount) as? String else {
			return
		}
		if strUUIDKeyChain.isEmpty {
			keyChain.setObject(getUniversalUniqueDeviceIdentifier(), forKey: kSecAttrAccount)
			print("value of identifier is set")
		} else {
			print("value Already set ")
		}

	}

	/**
     // Get the unique identifier from keychain

     - returns: value of UUID from keychain
     */

	func getUniqueIdentifier() -> String {
		let keyChain = KeychainItemWrapper.init(identifier: "Test", accessGroup: nil)

		print("(keyChain.objectForKey(kSecAttrAccount) : \(keyChain.objectForKey(kSecAttrAccount))")

		guard let strUUIDKeyChain = keyChain.objectForKey(kSecAttrAccount) as? String else {
			return ""
		}
		return strUUIDKeyChain
	}

	/**
     Function to get the UUID

     - returns: UUID in string
     */

	func getUniversalUniqueDeviceIdentifier() -> String {

		#if (arch(i386) || arch(x86_64))
			return "Simulator"
		#else
			return UIDevice.currentDevice().identifierForVendor!.UUIDString

		#endif

	}
}

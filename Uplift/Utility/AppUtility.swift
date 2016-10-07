//
//  AppUtility.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/10/16.
//  Copyright © 2016 Aditya Aggarwal. All rights reserved.
//

import Foundation
import UIKit

struct AppUtility {

	// MARK: - Get String from dictionary

	static func getStringForKey(key: String!, dictResponse: NSDictionary!) -> String! {

		guard let key = key else {
			return ""
		}
		guard let dict = dictResponse else {
			return ""
		}
		guard let value = dict.valueForKey(key) as? String else {
			return ""
		}

		return value
	}

	static func getDoubleForKey(key: String!, dictResponse: NSDictionary!) -> Double! {

		guard let key = key else {
			return 0.0
		}
		guard let dict = dictResponse else {
			return 0.0
		}
		guard let value = dict.valueForKey(key) as? Double else {
			return 0.0
		}
		return value

	}

	// MARK: - Get Int from dictionary

	static func getIntForKey(key: String!, dictResponse: NSDictionary!) -> Int {
		if key != nil {
			if let dict = dictResponse {
				if let value = dict.valueForKey(key) as? Int {
					return value
				} else {
					return -1
				}

			} else {
				return -1
			}
		} else {
			return -1
		}
	}

	static func getBoolForKey(key: String!, dictResponse: NSDictionary!) -> Bool {
		if key != nil {
			if let dict = dictResponse {
				if let value = dict.valueForKey(key) as? Bool {
					return value
				} else {
					return false
				}

			} else {
				return false
			}
		} else {
			return false
		}
	}

	// MARK: - Get value from dictionary

	static func getObjectForKey(key: String!, dictResponse: NSDictionary!) -> AnyObject! {
		if key != nil {
			if let dict = dictResponse {
				if let value: AnyObject = dict.valueForKey(key) {
					return value
				} else {
					return nil
				}

			} else {
				return nil
			}
		} else {
			return nil
		}
	}

	static func getArrayForKey(key: String!, dictResponse: NSDictionary!) -> AnyObject! {
		let arrTemp = []
		if key != nil {
			if let dict = dictResponse {
				if let value: AnyObject = dict.valueForKey(key) {
					return value
				} else {
					return arrTemp
				}

			} else {
				return arrTemp
			}
		} else {
			return arrTemp
		}
	}

	static func getValueForKey(key: String!, dictResponse: NSDictionary!) -> AnyObject! {
		if key != nil {
			if let dict = dictResponse {
				if let value: AnyObject = dict.valueForKey(key) {
					return value
				} else {
					return nil
				}

			} else {
				return nil
			}
		} else {
			return nil
		}
	}

	// MARK:  Check Url validation

	static func isValidUrl(urlStr: String) -> Bool {
		let urlRegex: String = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
		let predicateForEmail: NSPredicate = NSPredicate(format: "SELF MATCHES %@", urlRegex)
		return predicateForEmail.evaluateWithObject(urlStr)
	}

	// MARK: - Show AlertView

	static func showAlert(title: String, message: String, delegate: AnyObject?) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		let okAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in

		}
		alertController.addAction(okAction)

		UIApplication.sharedApplication().delegate?.window!?.rootViewController?.presentViewController(alertController, animated: true, completion: {

		})
	}

	// Used to fetch the controller via StoryBoard
	static func fetchViewControllerWithName(vcName: String, storyBoardName: String) -> UIViewController {
		let storyboard = UIStoryboard(name: storyBoardName, bundle: nil)
		let controller: UIViewController = storyboard.instantiateViewControllerWithIdentifier(vcName)
		return controller
	}

	static func addBasicConstraints(onSubview subview: UIView, onSuperview superview: UIView) {
		subview.translatesAutoresizingMaskIntoConstraints = false

		superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(subview.frame.origin.y)-[subview]-0-|",
			options: NSLayoutFormatOptions.AlignmentMask,
			metrics: nil,
			views: ["subview": subview]))
		superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-\(subview.frame.origin.x)-[subview]-\(subview.frame.origin.x)-|",
			options: NSLayoutFormatOptions.AlignmentMask,
			metrics: nil,
			views: ["subview": subview]))
	}

	// MARK: - Animation

	static func setAnimation(animationDuration: Double, view: UIView) {

		UIView.animateWithDuration(animationDuration, animations: { () -> Void in
			view.layoutIfNeeded()
			for viewInside: UIView in view.subviews {
				viewInside.layoutIfNeeded()
			}

		})
	}
	// MARK: Set TabBarColor
	static func setTabBarColor(with color: UIColor, viewController: UIViewController) {
		(viewController.navigationController?.tabBarController as? CustomTabBarViewController)!.setViewBackgroundColor(color)
	}

}

//
//  DailyQuoteView.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/23/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import UIKit

class DailyQuoteView: UIView {

	/*
	 // Only override drawRect: if you perform custom drawing.
	 // An empty implementation adversely affects performance during animation.
	 override func drawRect(rect: CGRect) {
	 // Drawing code
	 }
	 */

	/// IBOulets
	@IBOutlet weak var lblQuote: UILabel!
	@IBOutlet weak var lblAuthor: UILabel!

	override init(frame: CGRect) {
		super.init(frame: frame)

		let nibArray = NSBundle.mainBundle().loadNibNamed("DailyQuoteView", owner: self, options: nil)
		let subView = (nibArray.first as? UIView)!
		self.addSubview(subView)
		AppUtility.addBasicConstraints(onSubview: subView, onSuperview: self)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/**
     Set content on view based on Quote object

     - parameter quote: object of Quote
     */
	func setContentOnView(quote: Quote) {
		let quoteAttributedString = NSMutableAttributedString(string: "“\(quote.quoteText)”", attributes: nil)
		quoteAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 250.0 / 255.0, green: 169.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0), range: NSRange(location: 0, length: 1))
		quoteAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 250.0 / 255.0, green: 169.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0), range: NSRange(location: quoteAttributedString.length - 1, length: 1))

		lblQuote.attributedText = quoteAttributedString
		lblAuthor.text = quote.quoteAuthor.uppercaseString
	}
}

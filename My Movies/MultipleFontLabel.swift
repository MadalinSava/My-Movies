//
//  MultipleFontLabel.swift
//  My Movies
//
//  Created by Madalin Sava on 27/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

@IBDesignable
class MultipleFontLabel: UILabel {
	@IBInspectable var secondFontSize: CGFloat = 0 {
		didSet {
			updateAttributes()
		}
	}
	
	@IBInspectable var charsDifferent: Int = 0 {
		didSet {
			updateAttributes()
		}
	}
	
	override var text: String? {
		didSet {
			updateAttributes()
		}
	}
	
	func updateAttributes() {
		guard text?.lenght >= charsDifferent else {
			return
		}
		
		let attrText = NSMutableAttributedString(string: text!, attributes: [NSFontAttributeName : font])
		attrText.addAttributes([NSFontAttributeName: font.fontWithSize(secondFontSize), NSForegroundColorAttributeName: UIColor.grayColor()], range: NSRange(location: text!.lenght - charsDifferent, length: charsDifferent))
		
		attributedText = attrText
	}
}

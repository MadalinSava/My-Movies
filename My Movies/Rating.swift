//
//  Rating.swift
//  My Movies
//
//  Created by Madalin Sava on 01/12/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

@IBDesignable
public class Rating: UIView {
	
	@IBInspectable var score: Double = 0.0 {
		didSet {
			updateText()
		}
	}
	@IBInspectable var starImage: UIImage! {
		didSet {
			star.image = starImage.imageWithRenderingMode(.AlwaysTemplate)
			star.tintColor = UIColor.yellowColor()
		}
	}
	
	private let text = UILabel()
	private let star = UIImageView()
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		
		addStars()
	}
	
	public override func prepareForInterfaceBuilder() {
		addStars()
	}
	
	public override func intrinsicContentSize() -> CGSize {
		var contentSize = CGSize()
		contentSize.width = text.frame.maxX
		contentSize.height = max(star.frame.maxY, text.frame.maxY)
		return contentSize
	}
	
	private func addStars() {
		addSubview(star)
		star.sizeToFit()
		
		text.font = UIFont.systemFontOfSize(14)
		text.textColor = UIColor.yellowColor()
		text.sizeToFit()
		text.frame.origin.x = star.frame.width
		addSubview(text)
	}
	
	private func updateText() {
		guard score > 0 else {
			hidden = true
			return
		}
		hidden = false
		text.text = String(format: "%.1lf", score)
		text.sizeToFit()
		invalidateIntrinsicContentSize()
	}
}

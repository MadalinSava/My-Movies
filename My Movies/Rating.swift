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
	
	@IBInspectable var score: CGFloat = 3.4 {
		didSet {
			updateText()
		}
	}
	@IBInspectable var starImage: UIImage! {
		didSet {
			star.image = starImage
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
		text.textColor = UIColor.blackColor()
		text.sizeToFit()
		text.frame.origin.x = star.frame.width
		addSubview(text)
	}
	
	private func updateText() {
		text.text = String(score)
	}
}

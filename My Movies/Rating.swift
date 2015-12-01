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
	
	private var goodFrame = CGSize()
	private let text = UILabel()
	private let star = UIImageView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		
		//addStars()
	}

	required public init?(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
		
		addStars()
	}
	
	private func addStars() {
		//translatesAutoresizingMaskIntoConstraints = false
		
		//let star = UIImageView(image: UIImage(named: "second"))
		//star.image = UIImage(named: "second")
		//star.sizeToFit()
		//star.frame.size = CGSize(width: 30, height: 30)
		
		//star.image = starImage
		//star.sizeToFit()
		addSubview(star)
		
		text.font = UIFont(name: "System", size: 14)
		text.textColor = UIColor.blackColor()
		addSubview(text)
	}
	
	public override func layoutSubviews() {
		star.sizeToFit()
		star.frame.size.height = 15
		
		//text.sizeToFit()
		text.frame.origin.x = star.frame.width
		
		goodFrame.width = star.frame.width + text.frame.width
		goodFrame.height = star.frame.height
		
		frame.size = goodFrame
		//text.text = "layoutSubviews"
		//text.sizeToFit()
	}
	
	public override func prepareForInterfaceBuilder() {
		addStars()
	}
	
	private func updateText() {
		text.text = String(score)
		//text.text = String(star.frame.size)
	}
}

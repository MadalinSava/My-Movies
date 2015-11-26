//
//  Graphics.swift
//  My Movies
//
//  Created by Madalin Sava on 21/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

func pointsToPixels(pixels: CGFloat) -> CGFloat {
	return pixels * UIScreen.mainScreen().scale
}

extension UIImage {
	var aspectRatio: CGFloat {
		return size.width / size.height
	}
}

extension UIImageView {
	var aspectRatio: CGFloat? {
		return image?.aspectRatio
	}
}
/*
extension UIScrollView {
	var lastScrollPosition: Float!
}
*/
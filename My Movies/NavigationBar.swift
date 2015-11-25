//
//  NavigationBar.swift
//  My Movies
//
//  Created by Madalin Sava on 24/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class NavigationBar: UINavigationBar {
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func sizeThatFits(size: CGSize) -> CGSize {
		let newSize = super.sizeThatFits(size)
		//print(size)
		//print(newSize)
		if backItem != nil {
			//print(backItem!)
			//print(backItem!.backBarButtonItem)
			//print(subviews)
		}
		
		return newSize
	}
	
	override func addSubview(view: UIView) {
		/*if view != nil {
			
		}
		print(view)*/
		super.addSubview(view)
	}
}

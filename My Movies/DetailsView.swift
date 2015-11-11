//
//  DetailsView.swift
//  My Movies
//
//  Created by Madalin Sava on 11/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class DetailsView: UIView {
	
	var metadata: JSON! = nil {
		didSet {
			setup()
		}
	}
	
	func setup() {
		assertionFailure("please override")
	}
}

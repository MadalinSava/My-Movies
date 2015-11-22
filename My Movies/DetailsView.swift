//
//  DetailsView.swift
//  My Movies
//
//  Created by Madalin Sava on 11/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class DetailsView: UIView {
	
	class var nibName: String {
		assertionFailure("please override")
		return ""
	}
	
	func setupWithEntity(entity: Entity) {
		assertionFailure("please override")
	}
	
	func getTitle() -> String {
		assertionFailure("please override")
		return ""
	}
}

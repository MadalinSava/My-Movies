//
//  SeriesView.swift
//  My Movies
//
//  Created by Madalin Sava on 11/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class SeriesView: DetailsView {
	
	override class var nibName: String {
		return "SeriesDetails"
	}
	
	@IBOutlet var titleLabel: UILabel!
	
	override func setupWithEntity(entity: Entity) {
		//titleLabel.text = metadata["name"].stringValue
	}
}

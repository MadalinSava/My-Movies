//
//  PersonView.swift
//  My Movies
//
//  Created by Madalin Sava on 11/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class PersonView: DetailsView {
	
	@IBOutlet var nameLabel: UILabel!
	
	override func setup() {
		nameLabel.text = metadata["name"].stringValue
	}
}

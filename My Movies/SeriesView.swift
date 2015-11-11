//
//  SeriesView.swift
//  My Movies
//
//  Created by Madalin Sava on 11/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class SeriesView: DetailsView {
	
	@IBOutlet var titleLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func setup() {
		titleLabel.text = metadata["name"].stringValue
	}
}

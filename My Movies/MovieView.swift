//
//  MovieView.swift
//  My Movies
//
//  Created by Madalin Sava on 11/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class MovieView: DetailsView {
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var title: UINavigationItem!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func setup() {
		let movieTitle = metadata["title"].stringValue
		titleLabel.text = movieTitle
		title.title = movieTitle
	}
}

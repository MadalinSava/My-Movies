//
//  SearchCell.swift
//  My Movies
//
//  Created by Madalin Sava on 10/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {
	static let reuseIdentifier = "searchCell"
	
	@IBOutlet var thumbnail: UIImageView!
	@IBOutlet var name: UILabel!
	
	func setupWithImage(path: String?, andText text: String) {
		print("setup for \(self)")
		
		thumbnail.image = UIImage(named: "default")
		
		//ImageSetter.instance.setImage(path, ofType: .Poster, andWidth: thumbnail.frame.width, forView: thumbnail, defaultImage: "default")
		ImageSetter.instance.setImage(path, ofType: .Poster, andWidth: 1000, forView: thumbnail)
		
		name.text = text
	}
}

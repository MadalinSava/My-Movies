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
	
	private var imageSetTask: AsyncTask? = nil
	
	func setupWithImage(path: String?, andText text: String) {
		//print("setup for \(self)")
		
		imageSetTask?.cancel()
		thumbnail.image = nil//UIImage(named: "default")
		
		//ImageSetter.instance.setImage(path, ofType: .Poster, andWidth: thumbnail.frame.width, forView: thumbnail, defaultImage: "default")
		imageSetTask = ImageSetter.instance.setImage(path, ofType: .Poster, andWidth: 1000, forView: thumbnail)
		
		name.text = text
	}
}

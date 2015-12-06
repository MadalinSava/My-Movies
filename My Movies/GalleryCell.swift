//
//  GalleryCell.swift
//  My Movies
//
//  Created by Madalin Sava on 26/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {
	
	static let reuseIdentifier = "galleryCell"
	
	@IBOutlet var image: UIImageView!
	
	func setImage(image: String, ofType imageType: ImageType, success: SimpleBlock) {
		self.image.image = nil
		ImageSetter.instance.setImage(image, ofType: imageType, andWidth: self.image.frame.width, forView: self.image, defaultImage: nil, success: success)
	}
}

//
//  GalleryCell.swift
//  My Movies
//
//  Created by Madalin Sava on 26/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit
import RxSwift

class GalleryCell: UICollectionViewCell {
	
	static let reuseIdentifier = "galleryCell"
	
	@IBOutlet var image: UIImageView!
	
	private var bag: DisposeBag!
	
	func setImage(image: String, ofType imageType: ImageType) -> Observable<Void> {
		self.image.image = nil
		
		bag = DisposeBag()
		let observable = ImageSetter.instance.setImageRx(image, ofType: imageType, andWidth: self.image.frame.width, forView: self.image, defaultImage: nil)
			.shareReplay(1)
		observable.subscribe().addDisposableTo(bag)
		
		return observable
	}
}

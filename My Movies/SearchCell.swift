//
//  SearchCell.swift
//  My Movies
//
//  Created by Madalin Sava on 10/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

import RxSwift

final class SearchCell: UITableViewCell {
	static let reuseIdentifier = "searchCell"
	
	@IBOutlet var thumbnail: UIImageView!
	@IBOutlet var name: UILabel!
	
	private var bag: DisposeBag!
	
	func setupWithImage(path: String?, andText text: String) {
		thumbnail.image = nil
		
		bag = DisposeBag()
		ImageSetter.instance.setImageRx(path, ofType: .Poster, andWidth: thumbnail.frame.width, forView: thumbnail, defaultImage: "default")
			.subscribe()
			.addDisposableTo(bag)
		
		name.text = text
	}
}

//
//  ImageSetter.swift
//  My Movies
//
//  Created by Madalin Sava on 21/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

enum ImageType {
	case Poster
	case Still
	case Logo
	case Profile
	case Backdrop
}

typealias ImageSetSuccess = () -> Void

class ImageSetter {
	
	static let instance = ImageSetter()
	
	private var baseURL: String! = nil
	private let queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
	private var configurationComplete = false
	
	private var sizes = [ImageType: [(width: Int, name: String)]]()
	//private var widths = [(width: Int, type: ImageType): String]()
	/*
	func setImage (path: String, ofType type: ImageType, andWidth width: CGFloat, forView: UIImageView, success: ImageSetSuccess? = nil) {
	}*/
	
	func setImage (path: String?, ofType type: ImageType, andWidth width: CGFloat, forView: UIImageView, defaultImage: String? = nil, success: ImageSetSuccess? = nil) {
		guard configurationComplete else {
			// TODO: do something? like queueing
			print("configuration not ready")
			return
		}
		
		guard let path = path else {
			if defaultImage != nil {
				forView.image = UIImage(named: defaultImage!)
			}
			return
		}
		
		let pixels = Int(ceil(pointsToPixels(width)))
		let sizeComponent = getSizeComponentForWidth(pixels, ofImageType: type)
		//print("setting image " + sizeComponent)
		
		let imageId = sizeComponent + "-" + path[1, 0]
		let tmpDirURL = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true)
		let fileURL = tmpDirURL.URLByAppendingPathComponent(imageId)
		
		dispatch_async(queue) { [unowned self] in
			var image: UIImage?
			if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
				image = UIImage(contentsOfFile: fileURL.path!)
			} else {
				let fullURL = self.baseURL + sizeComponent + path
				if let data = NSData(contentsOfURL: NSURL(string: fullURL)!) {
					NSFileManager.defaultManager().createFileAtPath(fileURL.path!, contents: data, attributes: nil)
					image = UIImage(data: data)
				}
			}
			dispatch_async(dispatch_get_main_queue()) {
				if image != nil {
					forView.image = image
					//print("success")
					success?()
				} else if defaultImage != nil { // TODO: test this
					forView.image = UIImage(named: defaultImage!)
					success?()
				}
			}
		}
	}
	
	private init() {
		Api.instance.getConfiguration(gotConfiguration)
	}
	
	private func gotConfiguration(config: JSON) {
		let images = config["images"]
		baseURL = images["secure_base_url"].stringValue
		
		sizes[.Poster] = getSizesFromJSON(images["poster_sizes"])
		sizes[.Still] = getSizesFromJSON(images["still_sizes"])
		sizes[.Logo] = getSizesFromJSON(images["logo_sizes"])
		sizes[.Profile] = getSizesFromJSON(images["profile_sizes"])
		sizes[.Backdrop] = getSizesFromJSON(images["backdrop_sizes"])
		
		configurationComplete = true
	}
	
	private func getSizesFromJSON(json: JSON) -> [(width: Int, name: String)] {
		var list = [(width: Int, name: String)]()
		
		for size in json.arrayValue {
			let sizeStr = size.stringValue
			var width: Int
			if sizeStr.characters.first == "w" {
				width = Int(sizeStr[1, 0])!
			} else if sizeStr == "original" {
				width = 1000
			} else {
				continue
			}
			list.append((width, sizeStr))
		}
		
		return list
	}
	
	private func getSizeComponentForWidth(width: Int, ofImageType type: ImageType) -> String {
		let minWidth = sizes[type]!.reduce(nil, combine: { (minWidth: (width: Int, name: String)?, size: (width: Int, name: String)) -> (width: Int, name: String)? in
			guard let minWidth = minWidth else {
				return size
			}
			if minWidth.width < width {
				if minWidth.width > size.width {
					return minWidth
				}
				return size
			}
			if size.width >= width && size.width < minWidth.width {
				return size
			}
			return minWidth
		})
		return minWidth!.name
	}
}

//
//  ImageSetter.swift
//  My Movies
//
//  Created by Madalin Sava on 21/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation
import UIKit

import RxSwift
import Alamofire
import RxAlamofire
import SwiftyJSON

enum ImageType {
	case Poster
	case Still
	case Logo
	case Profile
	case Backdrop
}

class ImageSetter {
	
	static let instance = ImageSetter()
	
	private var basePath: String! = nil
	private let queue = NSOperationQueue()
	
	private typealias ImageSize = (width: Int, name: String)
	
	private var sizes = [ImageType: [ImageSize]]()
	
	func setImageRx(path: String?, ofType type: ImageType, andWidth width: CGFloat, forView: UIImageView, defaultImage: String? = nil) -> Observable<Void> {
		
		return ensureConfig
			.observeOn(OperationQueueScheduler(operationQueue: queue))
			.map { Void throws -> UIImage? in
				let imageFromDefault = { () -> UIImage? in
					if let def = defaultImage {
						return UIImage(named: def)
					} else {
						throw NSError(domain: "Image or default not found", code: 1, userInfo: nil)
					}
				}
				guard let path = path else {
					return try imageFromDefault()
				}
				let pixels = Int(ceil(pointsToPixels(width)))
				let sizeComponent = self.getSizeComponentForWidth(pixels, ofImageType: type)
				let onlinePath = self.basePath + sizeComponent + path
				guard let data = NSData(contentsOfURL: NSURL(string: onlinePath)!) else {
					return try imageFromDefault()
				}
				return UIImage(data: data)
			}
			.observeOn(MainScheduler.instance)
			.map { image throws in
				guard let image = image else {
					throw NSError(domain: "Image set error", code: 1, userInfo: nil)
				}
				forView.image = image
//				print("image was set")
			}
	}
	
	private init() {
		
		queue.qualityOfService = .UserInitiated
		
		//NSLog("image setter init")
		print(NSOperationQueueDefaultMaxConcurrentOperationCount)
		//#if DEBUG
		// TESTING - delete cache
		if false {
			let manager = NSFileManager.defaultManager()
			let tempDir = NSTemporaryDirectory()
			let contents = try! manager.contentsOfDirectoryAtPath(tempDir)
			for item in contents {
				try! manager.removeItemAtPath(tempDir + item)
			}
		}
		//#endif
		
		_ = ensureConfig.subscribe()
	}
	
	private lazy var ensureConfig: Observable<Void> = {
		return Api.instance.config
			.map { self.gotConfiguration($0) }
			.shareReplay(1)
	}()
	
	private func gotConfiguration(config: JSON) {
		let images = config["images"]
		basePath = images["secure_base_url"].stringValue
		
		sizes[.Poster] = getSizesFromJSON(images["poster_sizes"])
		sizes[.Still] = getSizesFromJSON(images["still_sizes"])
		sizes[.Logo] = getSizesFromJSON(images["logo_sizes"])
		sizes[.Profile] = getSizesFromJSON(images["profile_sizes"])
		sizes[.Backdrop] = getSizesFromJSON(images["backdrop_sizes"])
	}
	
	private func getSizesFromJSON(json: JSON) -> [ImageSize] {
		var list = [ImageSize]()
		
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
		let minSize = sizes[type]!.reduce(nil) { (minSize: ImageSize?, size: ImageSize) -> ImageSize? in
			guard let minSize = minSize else {
				return size
			}
			if minSize.width < width {
				if minSize.width > size.width {
					return minSize
				}
				return size
			}
			if size.width >= width && size.width < minSize.width {
				return size
			}
			return minSize
		}!
		return minSize.name
	}
}

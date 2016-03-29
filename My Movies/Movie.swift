//
//  Movie.swift
//  My Movies
//
//  Created by Madalin Sava on 16/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

class ManagedMovie: NSManagedObject, NamedManagedObject {
	static let entityName = "Movie"
	
	@NSManaged var id: Int32
	@NSManaged var title: String
	@NSManaged var releaseDate: String?
	@NSManaged var posterPath: String?
	@NSManaged var isInWatchList: Bool
}

class Movie: Entity {
	
	let title: String
	let id: Int
	let releaseDate: String?
	
	private(set) var minBackdropAspectRatio: Float?
	
	private(set) var posterPath: String? = nil
	private(set) var backdropPaths = [String]()
	private(set) var overview: String? = nil
	private(set) var youtubeTrailer: String? = nil
	private(set) var runTime: Int? = nil
	private(set) var genreList: [String] = [String]()
	private(set) var isInWatchList = false
	private(set) var rating = 0.0
	
	var releaseYear: String? {
		guard let date = releaseDate else {
			return nil
		}
		return date[0, 4]
	}
	
	init(data: JSON) {
		title = data["title"].stringValue
		id = data["id"].intValue
		releaseDate = data["release_date"].string~?
		
		super.init()
		
		// get the managed movie if exists and set stored data
		if let movie = getExistingManagedMovie() {
			setupSavedProperties(fromManagedMovie: movie)
		}
		
		addData(data)
	}
	
	init(withManagedMovie movie: ManagedMovie) {
		id = Int(movie.id)
		title = movie.title
		releaseDate = movie.releaseDate
		posterPath = movie.posterPath
		
		super.init()
		
		setupSavedProperties(fromManagedMovie: movie)
	}
	
	func requestDetails(completion: SimpleBlock) {
		Api.instance.requestMovieDetails(id, success: { [unowned self] (data) in
			//print(data)
			self.addData(data)
			completion()
		})
	}
	
	private func addData(data: JSON) {
		//print(data)
		
		posterPath ?=~? data["poster_path"].string
		overview ?=~? data["overview"].string
		runTime ?=~? data["runtime"].int
		
		backdropPaths = data["images"]["backdrops"].arrayValue.map { (backdrop) in
			return backdrop["file_path"].stringValue
		}
		minBackdropAspectRatio = data["images"]["backdrops"].arrayValue.reduce(nil) { (currentMin, backdrop) -> Float? in
			return min(currentMin ?? Float.infinity, backdrop["aspect_ratio"].floatValue)
		}
		
		genreList = data["genres"].arrayValue.map { (genre) in
			return genre["name"].stringValue
		}
		
		youtubeTrailer ?=~? data["trailers"]["youtube"][0]["source"].string
		
		rating =? data["vote_average"].double
	}
	
	func toggleWatchList() -> Bool {
		let movie = getExistingOrNewManagedMovie()
		!!movie.isInWatchList
		
		guard CoreDataManager.instance.save() else {
			return false
		}
		
		!!isInWatchList
		return true
	}
	
	private func setupSavedProperties(fromManagedMovie movie: ManagedMovie) {
		isInWatchList = movie.isInWatchList
	}
	
	private func getExistingManagedMovie() -> ManagedMovie? {
		let predicate = NSPredicate(format: "id == %d", id)
		guard let managedMovies = CoreDataManager.instance.getObjects(ofType: ManagedMovie.self, withPredicate: predicate) else {
			return nil
		}
		
		if managedMovies.count > 0 {
			return managedMovies[0]
		}
		
		return nil
	}
	
	private func getExistingOrNewManagedMovie() -> ManagedMovie {
		return getExistingManagedMovie() ?? getNewManagedMovie()
	}
	
	private func getNewManagedMovie() -> ManagedMovie {
		let movieEntity = CoreDataManager.instance.createEntity(ofType: ManagedMovie.self)
		
		movieEntity.id = Int32(id)
		movieEntity.title = title
		movieEntity.posterPath = posterPath
		movieEntity.isInWatchList = isInWatchList
		
		return movieEntity
	}
}

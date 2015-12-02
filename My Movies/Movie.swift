//
//  Movie.swift
//  My Movies
//
//  Created by Madalin Sava on 16/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit
import CoreData

class ManagedMovie: NSManagedObject {
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
	
	func requestDetails(completion: () -> Void) {
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
		minBackdropAspectRatio = data["images"]["backdrops"].arrayValue.reduce(nil, combine: { (currentMin, backdrop) -> Float? in
			return min(currentMin ?? Float.infinity, backdrop["aspect_ratio"].floatValue)
		})
		
		genreList = data["genres"].arrayValue.map { (genre) in
			return genre["name"].stringValue
		}
		
		youtubeTrailer ?=~? data["trailers"]["youtube"][0]["source"].string
	}
	
	func toggleWatchList() -> Bool {
		if let movie = getExistingOrNewManagedMovie() {
			!!movie.isInWatchList
			do {
				try AppDelegate.instance.managedObjectContext.save()
				!!isInWatchList
			} catch let error as NSError {
				print("nope - " + error.localizedDescription)
				return false
			}
			
			return true
		}
		
		return false
	}
	
	private func setupSavedProperties(fromManagedMovie movie: ManagedMovie) {
		isInWatchList = movie.isInWatchList
	}
	
	private func getExistingManagedMovie() -> ManagedMovie? {
		let context = AppDelegate.instance.managedObjectContext
		let fetchRequest = NSFetchRequest(entityName: "Movie")
		fetchRequest.predicate = NSPredicate(format: "id == %d", id)
		do {
			let managedMovies = try context.executeFetchRequest(fetchRequest) as! [ManagedMovie]
			if managedMovies.count > 0 {
				return managedMovies[0]
			}
		} catch let error as NSError {
			print(error.localizedDescription)
		}
		return nil
	}
	
	private func getExistingOrNewManagedMovie() -> ManagedMovie? {
		return getExistingManagedMovie() ?? getNewManagedMovie()
	}
	
	private func getNewManagedMovie() -> ManagedMovie? {
		let context = AppDelegate.instance.managedObjectContext
		let entityDescription = NSEntityDescription.entityForName("Movie", inManagedObjectContext: context)!
		
		let movieEntity = ManagedMovie(entity: entityDescription, insertIntoManagedObjectContext: context)
		movieEntity.id = Int32(id)
		movieEntity.title = title
		movieEntity.posterPath = posterPath
		movieEntity.isInWatchList = isInWatchList
		
		return movieEntity
	}
}

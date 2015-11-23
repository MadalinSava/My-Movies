//
//  WatchListTableViewController.swift
//  My Movies
//
//  Created by Madalin Sava on 21/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit
import CoreData

class WatchListTableViewController: UITableViewController, TabbedViewController {
	
	static var tabIndex = -1
	
	var movies = [ManagedMovie]()
	// TODO: add another section for series!!!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
		tableView.registerNib(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: SearchCell.reuseIdentifier)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		do {
			let context = AppDelegate.instance.managedObjectContext
			let fetchRequest = NSFetchRequest(entityName: "Movie")
			movies = try context.executeFetchRequest(fetchRequest) as! [ManagedMovie]
			movies = movies.filter { (movie) in
				return movie.isInWatchList
			}
			tableView.reloadData()
		} catch let error as NSError {
			print(error.localizedDescription)
		}
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return movies.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier(SearchCell.reuseIdentifier) as! SearchCell
		
		let movie = movies[indexPath.row]
		
		ImageSetter.instance.setImage(movie.posterPath, ofType: .Poster, andWidth: cell.thumbnail.frame.width, forView: cell.thumbnail, defaultImage: "default")
		
		cell.name.text = movie.title
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let vc = (parentViewController as! TabBarController).goToDetails()
		let entity = Movie(withManagedMovie: movies[indexPath.row])
		let image = (tableView.cellForRowAtIndexPath(indexPath) as! SearchCell).thumbnail.image!
		vc.setupWithEntity(entity, andImage: image)
	}
}

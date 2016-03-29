//
//  WatchListTableViewController.swift
//  My Movies
//
//  Created by Madalin Sava on 21/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit
import CoreData

class WatchListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet var tableView: UITableView!
	
	private var movies = [ManagedMovie]()
	// TODO: add another section for series!!!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.registerNib(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: SearchCell.reuseIdentifier)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		let predicate = NSPredicate(format: "isInWatchList == true")
		movies =? CoreDataManager.instance.getObjects(ofType: ManagedMovie.self, withPredicate: predicate)
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return movies.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier(SearchCell.reuseIdentifier) as! SearchCell
		
		let movie = movies[indexPath.row]
		
		_ = ImageSetter.instance.setImageRx(movie.posterPath, ofType: .Poster, andWidth: cell.thumbnail.frame.width, forView: cell.thumbnail, defaultImage: "default")
			.subscribe()
		
		cell.name.text = movie.title
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		/*let vc = (parentViewController as! TabBarController).goToDetails()
		let entity = Movie(withManagedMovie: movies[indexPath.row])
		vc.setupWithEntity(entity)*/
	}
}

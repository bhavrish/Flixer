//
//  NowPlayingViewController.swift
//  flixer
//
//  Created by Bhavesh Shah on 9/28/18.
//  Copyright © 2018 Bhavesh Shah. All rights reserved.
//

import UIKit
import AlamofireImage

class NowPlayingViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    
    var movies: [[String: Any]] = []
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NowPlayingViewController.didPullToRefresh(_:)), for: .valueChanged)
        tableview.insertSubview(refreshControl, at: 0)
        
        tableview.dataSource=self
        fetchMovies()
        
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        fetchMovies()
    }
    
    func fetchMovies() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")! // connect to specific link
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10) // even if info is in cache, connect to api to get movies
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main) // put info in main thread
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] // puts data from json file into a dictionary
                let movies = dataDictionary["results"] as! [[String: Any]]
                self.movies=movies
                self.tableview.reloadData() // table is created before network request is processed, so this function continues to refresh data before finalizing table
                self.refreshControl.endRefreshing()
            }
        }
        task.resume()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    } // Method for how many rows in tableview.
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell // Find MovieCell which is of type MovieCell
        let movie=movies[indexPath.row]
        let title=movie["title"] as! String
        let overview=movie["overview"] as! String
        let posterPathString = movie["poster_path"] as! String
        let baseURLString="https://image.tmdb.org/t/p/w500"
        
        cell.titleLabel.text = title
        cell.descriptionLabel.text = overview
        let posterURL = URL(string: baseURLString + posterPathString)!
        cell.posterImageView.af_setImage(withURL: posterURL)
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}

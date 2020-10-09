//
//  MovieListViewController.swift
//  MovieDatabase
//
//  Created by Emir Zecevic on 10/7/20.
//

import UIKit


class MovieListViewController: UIViewController {
    
    @IBOutlet weak var querryLabel: UILabel!
    
    @IBOutlet weak var movieTableView: UITableView!
    
    
    @IBAction func onClick(_ sender: Any) {
        //Clear movies array so it is emtpy for the next search
        movies.removeAll()
        //Set page and totalPages back to 1 (default values)
        page = 1
        totalPages = 1
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        querryLabel.text = "Search results for " + querry
        movieTableView.dataSource = self
        movieTableView.delegate = self
    }
    
    //Loads new data into the tableView
    @objc func loadList(){
        DispatchQueue.main.async {
            self.movieTableView.reloadData()
        }
    }
}

extension MovieListViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieTableViewCell

        if (movies[indexPath.row].posterImage == "") {
            //If no image is available from the API call, set image to a placeholder
            let imageLink = "https://cdn2.iconfinder.com/data/icons/documents-7/100/kden-document-broken-512.png"
            let url = URL(string: imageLink)
            let data = try? Data(contentsOf: url!)
            cell.movieImage.image = UIImage(data: data!)
        }
        else{
            let imageLink = "https://image.tmdb.org/t/p/w185/" + movies[indexPath.row].posterImage
            let url = URL(string: imageLink)
            let data = try? Data(contentsOf: url!)
            cell.movieImage.image = UIImage(data: data!)
        }
        cell.movieName.text = "Name: " + movies[indexPath.row].title
        cell.movieRelease.text = "Release date: " +  movies[indexPath.row].releaseDate
        cell.movieOverview.text = movies[indexPath.row].overview
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = movies.count-1
        
        if (!loadData && indexPath.row == lastElement) {
            loadData = true
            search(q: querry)
            tableView.reloadData()
        }
    }
}

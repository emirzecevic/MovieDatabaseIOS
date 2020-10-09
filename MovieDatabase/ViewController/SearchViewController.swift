//
//  ViewController.swift
//  MovieDatabase
//
//  Created by Emir Zecevic on 10/7/20.
//

import UIKit
import CoreData

//Global variables shared between SearchViewController and MovieListViewController
var querry = ""
var page = 1
var totalPages = 1
var loadData = false

var movies: [Movie] = []

enum CustomError: String, Error {
    case invalidResponse = "The response from the server was invalid"
    case invalidData = "The data recieved from the server was invalid"
}

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var suggestions: [String] = []

    @IBOutlet weak var searchQuerry: UITextField!
    
    @IBOutlet weak var suggestionTableView: UITableView!
    
    @IBAction func onClick(_ sender: UIButton) {
        if(checkQuerry()){
            suggestionTableView.resignFirstResponder()
            suggestionTableView.isHidden = true
            self.performSegue(withIdentifier: "showMovieList", sender: self)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        suggestionTableView.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        suggestionTableView.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(checkQuerry()){
            textField.resignFirstResponder()
            self.performSegue(withIdentifier: "showMovieList", sender: self)
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        suggestionTableView.dataSource = self
        suggestionTableView.delegate = self
        searchQuerry.delegate = self
        
        fetchSuggestions()
    }
    
    //Adds the 10 last querries saved in the database
    func fetchSuggestions(){
        var tempSuggestions: [Suggestion]
        
        do {
            tempSuggestions = try context.fetch(Suggestion.fetchRequest())
            //If there is 10 or less saved querries, fetch them all
            if (tempSuggestions.count<11) {
                for sugg in tempSuggestions {
                    suggestions.insert(sugg.suggestion!, at: 0)
                }
            }
            //Else fetch the last 10 in reverse order
            else {
                for i in (tempSuggestions.count-10)...(tempSuggestions.count-1) {
                    suggestions.insert(tempSuggestions[i].suggestion!, at: 0)
                }
            }
        }
        catch {
            print("Failed")
        }
    }
    
    //Checking if the querry is empty and calling the API if it's not
    func checkQuerry() -> Bool {
        querry = searchQuerry.text!
        
        if(querry == ""){
            return false
        }
        else{
            search(q: querry)
            //Check if the querry is already listed in the current suggestion array
            var alreadyExists = false
            for suggestion in suggestions {
                //If the querry is already in the last 10 suggestions, skip everything
                if (suggestion == querry) {
                    alreadyExists = true
                    break
                }
            }
            //Check if there are less than 10 suggestions
            //If less than 10, just add to the suggestion list and the database
            if (!alreadyExists && suggestions.count<10) {
                let newSuggestion = Suggestion(context: self.context)
                newSuggestion.suggestion = querry
                try! self.context.save()
                
                suggestions.insert(querry, at: 0)
                self.suggestionTableView.reloadData()
            }
            //If more than 10, add the latest querry as the first element of the suggestion array
            //and remove the last element of that array (oldest querry) and add to the database
            else if(!alreadyExists){
                let newSuggestion = Suggestion(context: self.context)
                newSuggestion.suggestion = querry
                try! self.context.save()
                
                suggestions.insert(querry, at: 0)
                suggestions.remove(at: suggestions.count-1)
                self.suggestionTableView.reloadData()
            }
        }
        return true
    }
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath) as! SuggestionTableViewCell
        
        cell.suggestionLabel.text = suggestions[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        search(q: suggestions[indexPath.row])
        querry = suggestions[indexPath.row]
        suggestionTableView.resignFirstResponder()
        suggestionTableView.isHidden = true
        
        self.performSegue(withIdentifier: "showMovieList", sender: self)
    }
}

//Calling the API and storing the new data into the movies array
func search(q: String){
    if (page <= totalPages){
        if let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=2696829a81b1b5827d515ff121700838&query=" + q + "&page=" + String(page)) {
           URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let res = try JSONDecoder().decode(Response.self, from: data)
                    var tempMovie: Movie
                    totalPages = res.total_pages
                    //Append all movies from the current page to the movies array
                    for movie in res.results {
                        tempMovie = Movie(t: movie.title, rd: movie.release_date ?? "", ov: movie.overview, i: movie.poster_path ?? "")
                        movies.append(tempMovie)
                    }
                    //Allow tableView to reload data before being able to call this function again
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        loadData = false
                    }
                    //Increment current page to be ready for next API call
                    page += 1
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                } catch let error {
                    print(error)
                }
            }
           }.resume()
        }
    }
}


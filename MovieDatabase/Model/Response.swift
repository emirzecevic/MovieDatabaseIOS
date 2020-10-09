//
//  File.swift
//  MovieDatabase
//
//  Created by Emir Zecevic on 10/8/20.
//

import UIKit

class Response: Codable{
    var page: Int
    var total_results: Int
    var total_pages: Int
    var results: [MovieResponse]
    
}

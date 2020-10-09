//
//  Movie.swift
//  MovieDatabase
//
//  Created by Emir Zecevic on 10/8/20.
//

import UIKit

class MovieResponse: Codable{
    var popularity: Float
    var id: Int
    var video: Bool
    var vote_count: Int
    var vote_average: Float
    var title: String
    var release_date: String?
    var original_language: String
    var original_title: String
    var genre_ids: [Int]
    var backdrop_path: String?
    var adult: Bool
    var overview: String
    var poster_path: String?
}

class Movie{
    var title: String
    var releaseDate: String
    var overview: String
    var posterImage: String
    
    init(t: String, rd: String, ov: String, i: String) {
        self.title = t
        self.releaseDate = rd
        self.overview = ov
        self.posterImage = i
    }
}

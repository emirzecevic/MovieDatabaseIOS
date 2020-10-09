//
//  Suggestion+CoreDataProperties.swift
//  MovieDatabase
//
//  Created by Emir Zecevic on 10/9/20.
//
//

import Foundation
import CoreData


extension Suggestion {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Suggestion> {
        return NSFetchRequest<Suggestion>(entityName: "Suggestion")
    }

    @NSManaged public var suggestion: String?

}

extension Suggestion : Identifiable {

}

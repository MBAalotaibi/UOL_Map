//
//  Murals+CoreDataProperties.swift
//  UserLocation
//
//  Created by Mohammed Abdullah Alotaibi on 13/12/2022.
//
//

import Foundation
import CoreData


extension Murals {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Murals> {
        return NSFetchRequest<Murals>(entityName: "Murals")
    }

    @NSManaged public var artist: String?
    @NSManaged public var enabled: Int16
    @NSManaged public var id: String?
    @NSManaged public var images: [String]?
    @NSManaged public var info: String?
    @NSManaged public var lastModified: String?
    @NSManaged public var lat: String?
    @NSManaged public var lon: String?
    @NSManaged public var thumbnail: String?
    @NSManaged public var title: String?
    @NSManaged public var favorite: Bool

}

extension Murals : Identifiable {

}

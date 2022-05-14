//
//  Rehearsal+CoreDataProperties.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 14/05/22.
//
//

import Foundation
import CoreData


extension Rehearsal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rehearsal> {
        return NSFetchRequest<Rehearsal>(entityName: "Rehearsal")
    }

    @NSManaged public var rehearsalID: Int64
    @NSManaged public var name: String?
    @NSManaged public var filePath: String?
    @NSManaged public var duration: String?

}

extension Rehearsal : Identifiable {

}

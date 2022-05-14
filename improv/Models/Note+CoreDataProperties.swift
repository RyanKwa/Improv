//
//  Note+CoreDataProperties.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 14/05/22.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var noteID: Int64
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var isFlipped: Bool
    @NSManaged public var folder: Folder?

}

extension Note : Identifiable {

}

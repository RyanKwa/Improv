//
//  Folder+CoreDataProperties.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 14/05/22.
//
//

import Foundation
import CoreData


extension Folder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Folder> {
        return NSFetchRequest<Folder>(entityName: "Folder")
    }

    @NSManaged public var folderID: Int64
    @NSManaged public var name: String?
    @NSManaged public var notes: NSSet?

    public var notesArray: [Note]{
        let set = notes as? Set<Note> ?? []
        return set.sorted(by: {
            $0.noteID < $1.noteID
        })
    }
}

// MARK: Generated accessors for notes
extension Folder {

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: Note)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: Note)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)

}

extension Folder : Identifiable {

}

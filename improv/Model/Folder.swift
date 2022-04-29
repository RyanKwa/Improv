//
//  Folder.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 26/04/22.
//

import Foundation

class Folder: Codable{
    
    var name: String?
    var notes: [Note]

    init(name: String? = nil, notes: [Note]) {
        self.name = name
        self.notes = notes
    }

}

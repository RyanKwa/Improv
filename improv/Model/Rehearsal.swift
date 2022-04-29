//
//  Rehearsal.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 27/04/22.
//

import Foundation

class Rehearsal: Codable{
    var name: String?
    var duration: String?
    var filePath: String?
    init(name: String, duration: String, filePath: String) {
        self.name = name
        self.duration = duration
        self.filePath = filePath
    }

}

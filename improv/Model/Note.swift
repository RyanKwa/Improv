//
//  Note.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 26/04/22.
//

import Foundation

class Note: Codable{
    
    var title: String?
    var content: String?
    var isFlipped: Bool?
    
    init(title: String? = nil, content: String? = nil) {
        self.title = title
        self.content = content
        self.isFlipped = false
    }

}

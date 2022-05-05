//
//  Helper.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 05/05/22.
//

import Foundation
import UIKit


class Helper{
    static let defaults = UserDefaults.standard
    static let decoder = JSONDecoder()
    static let encoder = JSONEncoder()

    static func getFoldersFromUserDefault() -> [Folder]{
        var folders = [Folder]()
        if let folderData = defaults.data(forKey: UserDefaultKeys.folderKey){
            do{
                folders = try decoder.decode([Folder].self, from: folderData)
            }
            catch{
                print("ERROR")
            }
        }
        return folders
    }
    
    static func getRehearsalsFromUserDefault() -> [Rehearsal] {
        var rehearsals = [Rehearsal]()
        if let rehearsalData = defaults.data(forKey: UserDefaultKeys.rehearsalKey){
            do{
                rehearsals = try decoder.decode([Rehearsal].self, from: rehearsalData)
            }
            catch{
                print("ERROR")
            }
        }
        return rehearsals
    }
    
    static func saveRehearsalToUserDefault(content: Array<Rehearsal>){
        if let encodedData = try? encoder.encode(content) {
            defaults.set(encodedData, forKey: UserDefaultKeys.rehearsalKey)
        }
    }
    
    static func saveFolderToUserDefault(content: Array<Folder>){
        if let encodedData = try? encoder.encode(content) {
            defaults.set(encodedData, forKey: UserDefaultKeys.folderKey)
        }
    }
}

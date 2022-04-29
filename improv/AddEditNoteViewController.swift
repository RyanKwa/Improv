//
//  AddEditNoteViewController.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 27/04/22.
//

import UIKit

// MARK: - Protocol untuk delegate
protocol AddEdtNoteViewControllerDelegate: AnyObject{
    func reloadData()
}

class AddEditNoteViewController: UIViewController {

    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    var note: Note?
    var foldersArr = [Folder]()
    var isEditingNote = false
    var folderIndex = -1
    var noteIndex = -1
    
    let defaults = UserDefaults.standard
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    // MARK: - delegate object initialization
    weak var delegate: AddEdtNoteViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if folderIndex == -1{
            return
        }
        getFolders()
        if isEditingNote {
            
            if noteIndex == -1{
                return
            }
            navTitle.title = "Edit Note"

            titleTextField.text = foldersArr[folderIndex].notes[noteIndex].title
            contentTextView.text = foldersArr[folderIndex].notes[noteIndex].content
        }
        else{
            navTitle.title = "Add Note"
        }
    }
    func getFolders(){
        if let folderData = defaults.data(forKey: "Folder"){
            do{
                let folder = try decoder.decode([Folder].self, from: folderData)
                self.foldersArr = folder
            }
            catch{
                print("ERROR")
            }
        }
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        //validation
        if titleTextField.text == "" {
            let alert = UIAlertController(title: "Uh-oh", message: "The title field cannot be empty", preferredStyle: .alert)
            let okBtn = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okBtn)
            self.present(alert, animated: true)
            return
        }
        if contentTextView.text == "" {
            let alert = UIAlertController(title: "Uh-oh", message: "The content field cannot be empty", preferredStyle: .alert)
            let okBtn = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okBtn)
            self.present(alert, animated: true)
            return
        }
        //edit note
        if isEditingNote{
            foldersArr[folderIndex].notes[noteIndex].title = titleTextField.text
            foldersArr[folderIndex].notes[noteIndex].content = contentTextView.text
        }
        //new Note
        else{
            foldersArr[folderIndex].notes.append(Note(title: titleTextField.text, content: contentTextView.text))
        }
        if let encodedNote = try? encoder.encode(foldersArr) {
            defaults.set(encodedNote, forKey: "Folder")
        }
        self.dismiss(animated: true, completion: self.delegate?.reloadData)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

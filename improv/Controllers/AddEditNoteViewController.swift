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
    var folder: Folder?
    
    var isEditingNote = false
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    // MARK: - delegate object initialization
    weak var delegate: AddEdtNoteViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isEditingNote {
            navTitle.title = "Edit Note"
            titleTextField.text = note?.title
            contentTextView.text = note?.content
        }
        else{
            navTitle.title = "Add Note"
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
            note?.title = titleTextField.text
            note?.content = contentTextView.text
        }
        //new Note
        else{
            let newNote = Note(context: context)
            if let notes = folder?.notesArray{
                if notes.isEmpty {
                    newNote.noteID = 1
                }
                else{
                    newNote.noteID = notes.last!.noteID + 1
                }
            }
            newNote.title = titleTextField.text
            newNote.content = contentTextView.text
            folder?.addToNotes(newNote)
        }
        //save data
        do {
            try self.context.save()
            try self.context.parent?.save()
        }
        catch let error as NSError{
            print("ERROR: \(error.localizedDescription)")
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

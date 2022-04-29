//
//  ManageCardViewController.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 27/04/22.
//

import UIKit

class ManageNoteViewController: UIViewController, AddEdtNoteViewControllerDelegate {
    

    var folder: Folder?
    var folderIndex = -1
    var noteIndex = -1
    var foldersArr = [Folder]()
    var addAlert: UIAlertController?

    var indexChosen = -1
    let defaults = UserDefaults.standard
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    @IBOutlet weak var noteTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if folderIndex == -1 {
            return
        }
        // Do any additional setup after loading the view.
        reloadData()
        noteTableView.dataSource = self
        noteTableView.delegate = self
    }
    func reloadData() {
        getFolders()
        noteTableView.reloadData()
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

    @IBAction func addButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "addNoteSegue", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNoteSegue" {
            let dest = segue.destination as! AddEditNoteViewController
            dest.isEditingNote = false
            dest.delegate = self
            dest.folderIndex = folderIndex
        }
        else if segue.identifier == "editNoteSegue"{
            let dest = segue.destination as! AddEditNoteViewController
            dest.isEditingNote = true
            dest.delegate = self
            dest.folderIndex = folderIndex
            dest.noteIndex = noteIndex
        }
    
    }
}

extension ManageNoteViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foldersArr[folderIndex].notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell") as! NotesTableViewCell
        cell.noteTitleLabel.text = foldersArr[folderIndex].notes[indexPath.row].title
        cell.noteContentLabel.text = foldersArr[folderIndex].notes[indexPath.row].content
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 114
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexChosen = indexPath.row
    }
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil"), identifier: nil){_ in
            self.noteIndex = indexPath.row
            self.performSegue(withIdentifier: "editNoteSegue", sender: self)

        }
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive) { _ in
            let cancelAction = UIAlertAction(title: "Cancel", style: .default)

            self.addAlert = UIAlertController(title: "Delete Note", message: "This note will be deleted permanently", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.foldersArr[self.folderIndex].notes.remove(at: indexPath.row)
                //save to userdefault
                if let encodedFolders = try? self.encoder.encode(self.foldersArr){
                    self.defaults.set(encodedFolders, forKey: "Folder")
                }
                self.noteTableView.reloadData()
            }

            self.addAlert!.addAction(cancelAction)
            self.addAlert!.addAction(deleteAction)
            
            self.present(self.addAlert!, animated: true)
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [editAction, deleteAction])
        }
    }
}

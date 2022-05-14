//
//  ViewController.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 25/04/22.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var folderTableView: UITableView!
    var foldersArr = [Folder]()
    var clicked = false
    var addAlert: UIAlertController?
    var indexSelected = -1
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        folderTableView.delegate = self
        folderTableView.dataSource = self
        fetchFolders()
        folderTableView.backgroundColor = .none
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchFolders()
    }
    
    func fetchFolders(){
        do{
            let request = Folder.fetchRequest() as NSFetchRequest<Folder>
            
            let sort = NSSortDescriptor(key: "folderID", ascending: true)
            request.sortDescriptors = [sort]
            
            self.foldersArr = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.folderTableView.reloadData()
            }
        }
        catch let error as NSError{
            print("Error : \(error.localizedDescription)")
        }
        print("COREDATA: WORKING FOLDER")
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAlert = UIAlertController(title: "New Folder", message: "Enter a name for your new folder", preferredStyle: .alert)
        addAlert!.addTextField { (textField) in
            textField.addTarget(self, action: #selector(self.textFieldDidChangeSelection(_:)), for: .editingChanged)
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [self, unowned addAlert] _ in
            let folderName = addAlert?.textFields![0].text
            //create folder object
            let newFolder = Folder(context: self.context)
            if self.foldersArr.isEmpty {
                newFolder.folderID = 1
            }
            else{
                newFolder.folderID = self.foldersArr.last!.folderID + 1
            }
            newFolder.name = folderName
            newFolder.notes = []
            //save data
            do {
                try self.context.save()
            }
            catch let error as NSError{
                print("ERROR: \(error.localizedDescription)")
            }
            //refetch data
            self.fetchFolders()
        }
        saveAction.isEnabled = false
        addAlert!.addAction(cancelAction)
        addAlert!.addAction(saveAction)

        present(addAlert!, animated: true)
    }
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        if !textField.hasText {
            self.addAlert!.actions[1].isEnabled = false
        }
        else{
            self.addAlert!.actions[1].isEnabled = true
        }

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if indexSelected == -1 {
            return
        }
        let destination = segue.destination as? NoteViewController
        destination?.titleNavBar = foldersArr[indexSelected].name ?? ""
        destination?.folderIndex = indexSelected
        destination?.folder = foldersArr[indexSelected]
        let backButton = UIBarButtonItem()
        backButton.title = "Folders"
        navigationItem.backBarButtonItem = backButton
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foldersArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "folderCell") as! FolderTableViewCell
        cell.folderName.text = foldersArr[indexPath.row].name
        cell.totalNumberOfCard.text = "\(foldersArr[indexPath.row].notes!.count) notes"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexSelected = indexPath.row
        performSegue(withIdentifier: "cardSegue", sender: self)
    }
    //MARK: Context Menu
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let folder = foldersArr[indexPath.row]
        let renameAction = UIAction(title: "Rename", image: UIImage(systemName: "pencil"), identifier: nil) { _ in
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

            self.addAlert = UIAlertController(title: "Rename Folder", message: "Enter a new name for this folder", preferredStyle: .alert)
            self.addAlert!.addTextField { (textField) in
                textField.addTarget(self, action: #selector(self.textFieldDidChangeSelection(_:)), for: .allEditingEvents)
            }
            self.addAlert?.textFields![0].text = folder.name
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                let folderName = self.addAlert?.textFields![0].text
                
                //edit name
                folder.name = folderName
                //save data
                do {
                    try self.context.save()
                }
                catch let error as NSError{
                    print("ERROR: \(error.localizedDescription)")
                }
                //fetch
                self.fetchFolders()
            }
            saveAction.isEnabled = false
            self.addAlert!.addAction(cancelAction)
            self.addAlert!.addAction(saveAction)
            
            self.present(self.addAlert!, animated: true)
        }
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive) { _ in
            let cancelAction = UIAlertAction(title: "Cancel", style: .default)

            self.addAlert = UIAlertController(title: "Delete Folder", message: "This folder and all the notes inside will be deleted permanently", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                
                //get folder to remove
                let folderToRemove = self.foldersArr[indexPath.row]
                
                //remove the folder
                self.context.delete(folderToRemove)
                
                //save data
                do {
                    try self.context.save()
                }
                catch let error as NSError{
                    print("ERROR: \(error.localizedDescription)")
                }

                //fetch
                self.fetchFolders()
            }

            self.addAlert!.addAction(cancelAction)
            self.addAlert!.addAction(deleteAction)
            
            self.present(self.addAlert!, animated: true)
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [renameAction, deleteAction])
        }
    }

}

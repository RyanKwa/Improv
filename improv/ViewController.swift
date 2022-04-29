//
//  ViewController.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 25/04/22.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var folderTableView: UITableView!
    var folderArr = [Folder]()
    var clicked = false
    var addAlert: UIAlertController?
    var indexSelected = -1
    let defaults = UserDefaults.standard
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        folderTableView.delegate = self
        folderTableView.dataSource = self
        getFolders()
        folderTableView.backgroundColor = .none
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getFolders()
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAlert = UIAlertController(title: "New Folder", message: "Enter a name for your new folder", preferredStyle: .alert)
        addAlert!.addTextField { (textField) in
            textField.delegate = self
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned addAlert] _ in
            let folderName = addAlert?.textFields![0].text
            self.folderArr.append(Folder(name: folderName, notes: []))
            self.saveToUserDefaultAndRefreshData()
        }
        saveAction.isEnabled = false
        addAlert!.addAction(cancelAction)
        addAlert!.addAction(saveAction)

        present(addAlert!, animated: true)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length == 0 {
            self.addAlert!.actions[1].isEnabled = true
        }
        else{
            self.addAlert!.actions[1].isEnabled = false
        }
        return true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if indexSelected == -1 {
            return
        }
        let destination = segue.destination as? NoteViewController
        destination?.titleNavBar = folderArr[indexSelected].name ?? ""
        destination?.folderIndex = indexSelected
        let backButton = UIBarButtonItem()
        backButton.title = "Folders"
        navigationItem.backBarButtonItem = backButton
    }
    func getFolders(){
        if let folderData = defaults.data(forKey: "Folder"){
            do{
                let folder = try decoder.decode([Folder].self, from: folderData)
                self.folderArr = folder
                folderTableView.reloadData()
            }
            catch{
                print("ERROR")
            }
        }
    }
    
    func removeAllFolder(){
        let temp = [Folder]()
        if let encodedFolders = try? encoder.encode(temp){
            defaults.set(encodedFolders, forKey: "Folder")
        }
    }
    func saveToUserDefaultAndRefreshData(){
        if let encodedFolders = try? encoder.encode(folderArr){
            defaults.set(encodedFolders, forKey: "Folder")
        }
        folderTableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "folderCell") as! FolderTableViewCell
        cell.folderName.text = folderArr[indexPath.row].name
        cell.totalNumberOfCard.text = "\(folderArr[indexPath.row].notes.count) notes"
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
        let folder = folderArr[indexPath.row]
        let renameAction = UIAction(title: "Rename", image: UIImage(systemName: "pencil"), identifier: nil) { _ in
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

            self.addAlert = UIAlertController(title: "Rename Folder", message: "Enter a new name for this folder", preferredStyle: .alert)
            self.addAlert!.addTextField { (textField) in
                textField.delegate = self
            }
            self.addAlert?.textFields![0].text = folder.name
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                let folderName = self.addAlert?.textFields![0].text
                self.folderArr[indexPath.row].name = folderName
                self.saveToUserDefaultAndRefreshData()
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
                self.folderArr.remove(at: indexPath.row)
                self.saveToUserDefaultAndRefreshData()
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

//
//  RehearsalViewController.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 28/04/22.
//

import UIKit
import CoreData
import AVFoundation

class RehearsalViewController: UIViewController, AVAudioPlayerDelegate, UITextFieldDelegate {

    @IBOutlet weak var rehearsalCollectionView: UICollectionView!
    var indexPlay = -1
    var audioPlayer: AVAudioPlayer!

    var selectedCell: RehearsalCollectionViewCell?
    var rehearsalsArr = [Rehearsal]()
    var userDataRehearsal = [Rehearsal]()
    var addAlert: UIAlertController?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext


    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRehearsals()
        rehearsalCollectionView.delegate = self
        rehearsalCollectionView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchRehearsals()
    }
    func fetchRehearsals(){
        do{
            let request = Rehearsal.fetchRequest() as NSFetchRequest<Rehearsal>
            
            let sort = NSSortDescriptor(key: "rehearsalID", ascending: false)
            request.sortDescriptors = [sort]
            
            self.rehearsalsArr = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.rehearsalCollectionView.reloadData()
            }
        }
        catch let error as NSError{
            print("Error : \(error.localizedDescription)")
        }

    }

    func updateRehearseFileName(rehearsal: Rehearsal, newName: String) -> String {
        guard let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            return ""
        }
        let newFileName = "\(newName).m4a"

        do{
            let oldAudioFileURL = directoryURL.appendingPathComponent(rehearsal.filePath!)
            //new
            let newAudioFileURL = directoryURL.appendingPathComponent(newFileName)
            try FileManager.default.moveItem(at: oldAudioFileURL, to: newAudioFileURL)
        }
        catch{
            print("ERROR Getting File")
        }

        return newFileName
    }
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        if !textField.hasText {
            self.addAlert!.actions[1].isEnabled = false
        }
        else{
            self.addAlert!.actions[1].isEnabled = true
        }

    }

    func deleteRehearsal(filePath: String){
        guard let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            return
        }

        let urlString = directoryURL.appendingPathComponent(filePath).absoluteString
        let url = URL(string: urlString)
//        let url = URL(string: filePath)
        if FileManager.default.fileExists(atPath: url!.path){
            do{
                try FileManager.default.removeItem(at: url!)
            }
            catch{
                print("Rehearsal: ERROR Deleting file")
            }
        }

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

extension RehearsalViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rehearsalsArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rehearsalCell", for: indexPath) as! RehearsalCollectionViewCell
        cell.rehearsalTitle.text = rehearsalsArr[indexPath.row].name
        cell.durationLabel.text = rehearsalsArr[indexPath.row].duration
        cell.rehearsalTitle.numberOfLines = 0
        cell.rehearsalTitle.lineBreakMode = .byWordWrapping
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            return
        }

        if(audioPlayer?.isPlaying == true && indexPlay == indexPath.row){
            audioPlayer?.stop()
            selectedCell?.controlButton.setImage(UIImage(systemName:"waveform"), for: .normal)
            return
        }
        else if (audioPlayer?.isPlaying == true && indexPlay != indexPath.row){
            audioPlayer?.stop()
            selectedCell?.controlButton.setImage(UIImage(systemName:"waveform"), for: .normal)
        }
        let urlString = directoryURL.appendingPathComponent(rehearsalsArr[indexPath.row].filePath!).absoluteString
        let url = URL(string: urlString)
        audioPlayer = try? AVAudioPlayer(contentsOf: url!)
        do{
            selectedCell = collectionView.cellForItem(at: indexPath) as? RehearsalCollectionViewCell
            
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            indexPlay = indexPath.row
            selectedCell!.controlButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        }
        catch{
            print("AudioPlayer: ERROR")
        }
    }
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let rehearsal = rehearsalsArr[indexPath.row]
        let renameAction = UIAction(title: "Rename", image: UIImage(systemName: "pencil"), identifier: nil){_ in
            //alert input
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

            self.addAlert = UIAlertController(title: "Rename Rehearsal", message: "Enter a new name for this rehearsal", preferredStyle: .alert)
            self.addAlert!.addTextField { (textField) in
                textField.addTarget(self, action: #selector(self.textFieldDidChangeSelection(_:)), for: .allEditingEvents)
            }
            self.addAlert?.textFields![0].text = rehearsal.name
            let saveAction = UIAlertAction(title: "Save", style: .default) { [self] _ in
                let rehearseName = self.addAlert?.textFields![0].text
                let newRehearsalFileName = self.updateRehearseFileName(rehearsal: rehearsal, newName: rehearseName!)
                //edit name
                rehearsal.name = rehearseName
                rehearsal.filePath = newRehearsalFileName
                //save data
                do {
                    try self.context.save()
                }
                catch let error as NSError{
                    print("ERROR: \(error.localizedDescription)")
                }
                //fetch
                self.fetchRehearsals()
                
            }
            saveAction.isEnabled = false
            self.addAlert!.addAction(cancelAction)
            self.addAlert!.addAction(saveAction)
            
            self.present(self.addAlert!, animated: true)
        }
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive) { _ in
            let cancelAction = UIAlertAction(title: "Cancel", style: .default)

            self.addAlert = UIAlertController(title: "Delete Rehearsal", message: "This rehearsal will be deleted permanently", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.deleteRehearsal(filePath: self.rehearsalsArr[indexPath.row].filePath!)

                let rehearsalToBeRemoved = self.rehearsalsArr[indexPath.row]
                
                //remove the folder
                self.context.delete(rehearsalToBeRemoved)
                
                //save data
                do {
                    try self.context.save()
                }
                catch let error as NSError{
                    print("ERROR: \(error.localizedDescription)")
                }

                //fetch
                self.fetchRehearsals()

            }

            self.addAlert!.addAction(cancelAction)
            self.addAlert!.addAction(deleteAction)
            
            self.present(self.addAlert!, animated: true)
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [renameAction, deleteAction])
        }
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer?.stop()
        selectedCell?.controlButton.setImage(UIImage(systemName:"waveform"), for: .normal)
        do{
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        catch{
            
        }
    }
}



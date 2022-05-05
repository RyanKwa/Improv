//
//  CardViewController.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 26/04/22.
//

import UIKit
import AVFoundation

class NoteViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var noteCollectionView: UICollectionView!
    
    @IBOutlet weak var rehearsalDurationLabel: UILabel!
    @IBOutlet weak var noteProgressLabel: UILabel!
    @IBOutlet weak var rehearseButton: UIButton!
    var audioFileURL: URL!
    var audioFileName = ""
    var audioFileNamewithExtension = ""
    var timer: Timer?
    var foldersArr = [Folder]()
    var rehearsalsArr = [Rehearsal]()
    var folderIndex = -1
    
    var rehearseDuration = "00:00"
    var duration = 0
    var titleNavBar = ""
    var currentSelectedIndex = 0
    var isRehearsal = false
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?

    let defaults = UserDefaults.standard
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        if folderIndex == -1 {
            return
        }
        getRehearsals()
        setup()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setup()
    }
    func setup(){
        title = titleNavBar

        noteCollectionView.backgroundColor = .none
        noteCollectionView.collectionViewLayout = NoteCollectionFlowLayout()
        noteCollectionView.delegate = self
        noteCollectionView.dataSource = self
        getFolders()
        noteCollectionView.reloadData()
        rehearsalDurationLabel.isHidden = true
        noteProgressLabel.text = foldersArr[folderIndex].notes.count == 0 ?"0 / \(foldersArr[folderIndex].notes.count)" : "\(currentSelectedIndex + 1) / \(foldersArr[folderIndex].notes.count)"
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
    func getRehearsals(){
        if let rehearsalData = defaults.data(forKey: "Rehearsal"){
            do{
                let rehearsal = try decoder.decode([Rehearsal].self, from: rehearsalData)
                self.rehearsalsArr = rehearsal
            }
            catch{
                print("ERROR")
            }
        }
    }
    
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "manageNoteSegue", sender: self)
    }
    
    @IBAction func rehearseButtonPressed(_ sender: Any) {
        guard let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            return
        }
        checkMicrophoneAccess()
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(AVAudioSession.Category(rawValue: AVAudioSession.Category.playAndRecord.rawValue), mode: .default)
        }
        catch{
            print("Audio: ERROR")
        }
        if AVAudioSession.sharedInstance().recordPermission == AVAudioSession.RecordPermission.granted {
            if isRehearsal == false{
                rehearsalDurationLabel.text = rehearseDuration
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyymmddHHmmss"
                let dateStr = dateFormatter.string(from: date)
                audioFileName = "\(foldersArr[folderIndex].name!) Rehearsal \(dateStr)"
                audioFileNamewithExtension = "\(audioFileName).m4a"
                

                rehearseButton.setTitle("Stop", for: .normal)
                isRehearsal = true
                
                audioFileURL = directoryURL.appendingPathComponent(audioFileNamewithExtension)

                let recorderSetting = [AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC as UInt32),
                                     AVSampleRateKey: 44100.0,
                               AVNumberOfChannelsKey: 2,
                                 AVEncoderBitRateKey: 320000,
                            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue] as [String : Any]
                audioRecorder = try? AVAudioRecorder(url: audioFileURL, settings: recorderSetting)
                audioRecorder?.delegate = self
                audioRecorder?.isMeteringEnabled = true
                if !audioRecorder!.isRecording {
                    do{
                        try audioSession.setActive(true)
                    } catch _ {
                        print("Audio: ERROR")
                    }
                    audioRecorder!.record()
                    rehearsalDurationLabel.isHidden = false
                     timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ [self]
                        timer in
                        
                        self.duration += 1
                        self.rehearseDuration = self.convertSecondToMinutes(seconds: duration)
                        self.rehearsalDurationLabel.text = rehearseDuration
                    }
                    isRehearsal = true
                }
            }
            else{
                rehearseButton.setTitle("Rehearse", for: .normal)
                isRehearsal = false
                
                if audioRecorder!.isRecording {
                    audioRecorder!.stop()
                    timer?.invalidate()
                    do{
                        try audioSession.setActive(false)
                    }
                    catch _ {
                        print("Audio: ERROR")
                    }
                }
    //            if somehow mau pakai userdefault, untuk filepathnya append audio filename ->  /audioFileName
    //            let fileLocation = "\(directoryURL.path)/\(audioFileNamewithExtension)"
                rehearsalsArr.append(Rehearsal(name: audioFileName, duration: rehearseDuration, filePath: audioFileNamewithExtension))
                if let encodedRehearsals = try? encoder.encode(rehearsalsArr){
                    defaults.set(encodedRehearsals, forKey: "Rehearsal")
                }
            }

        }
    }
    func checkMicrophoneAccess() {
        // Check Microphone Authorization
        let recordPermission = AVAudioSession.sharedInstance().recordPermission
        if recordPermission == AVAudioSession.RecordPermission.granted{
            print("Permission: Microphone granted")
        }
        else if recordPermission == AVAudioSession.RecordPermission.denied {
            let alert = UIAlertController(title: "Microphone Permission Required", message: "Improv is Not Authorized to Access the Microphone!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            //open settings
            let settingAction = UIAlertAction(title: "Settings", style: .default) { (_) in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else{
                    return
                }
                if UIApplication.shared.canOpenURL(settingsURL){
                    UIApplication.shared.open(settingsURL, completionHandler: nil)
                }
            }
            alert.addAction(cancelAction)
            alert.addAction(settingAction)
            present(alert,animated: true)
            return
        }
        else if recordPermission == AVAudioSession.RecordPermission.undetermined{
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    print("Permission granted")
                } else {
                    print("Pemission not granted")
                }
            })
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! ManageNoteViewController
        dest.folderIndex = folderIndex
        let backButton = UIBarButtonItem()
        backButton.title = "Notes"
        navigationItem.backBarButtonItem = backButton
    }
    private func convertSecondToMinutes (seconds:Int) -> String{
        let minute = seconds / 60
        let second = seconds % 60
        let songMinute = minute >= 10 ? String(minute) : String("0\(minute)")
        let songSeconds = second >= 10 ? String(second) : String("0\(second)")
        return "\(songMinute):\(songSeconds)"
    }
    

}

//MARK: Scrolling behaviour
extension NoteViewController{
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        /*
         Ketika selesai drag, current snap and center current note
         */

        guard scrollView == noteCollectionView else{
            return
        }
        targetContentOffset.pointee = scrollView.contentOffset
        let flowLayout = noteCollectionView.collectionViewLayout as! NoteCollectionFlowLayout

        //untuk set current cell width dan spacing
        let cellWidthAndSpacing = flowLayout.itemSize.width + flowLayout.minimumLineSpacing
        
        //posisi dari content relatif terhadap origin coordinates
        let offset = targetContentOffset.pointee
        //scroll speed
        let horizontalSwipeVelocity = velocity.x

        var selectedIndex = currentSelectedIndex

        // swipe kanan
        if horizontalSwipeVelocity > CGFloat(0) {
            selectedIndex = currentSelectedIndex + 1
        }
        //swipe kiri
        else if horizontalSwipeVelocity < CGFloat(0) {
            selectedIndex = currentSelectedIndex - 1
        }
        //drag
        else if horizontalSwipeVelocity == CGFloat(0) {
            let idx = (offset.x + scrollView.contentInset.left) / cellWidthAndSpacing
            let roundedIndex = round(idx)
            selectedIndex = Int(roundedIndex)
        }
        else{
            print("Scroll: Error")
        }
//        case: kalau ngescroll dia bisa out of index kalau mentok jadi pastiin si index jgn sampe out of index (> size array or < 0)
        if selectedIndex > foldersArr[folderIndex].notes.count - 1 {
            selectedIndex = foldersArr[folderIndex].notes.count - 1
        }
        else if selectedIndex < 0 {
            selectedIndex = 0
        }
        
        //untuk nge fokus content ketika lagi di drag
        let selectedIndexPath = IndexPath(row: selectedIndex, section: 0)
        flowLayout.collectionView?.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)

//        on swipe, the prev card will be transformed back to the normal size, sedangkan yang current card will be enlarged
        let previousSelectedIndex = IndexPath(row: Int(currentSelectedIndex), section: 0)
        let previousSelectedCard = noteCollectionView.cellForItem(at: previousSelectedIndex) as! NoteCollectionView
        let nextSelectedCard = noteCollectionView.cellForItem(at: selectedIndexPath) as! NoteCollectionView

        currentSelectedIndex = selectedIndexPath.row

        previousSelectedCard.shrinkCard()
        nextSelectedCard.enlargeCard()
        noteProgressLabel.text = "\(currentSelectedIndex + 1) / \(foldersArr[folderIndex].notes.count)"
        
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        /*
         Ketika nge drag, current note dishrink
         */
        let currentCell = noteCollectionView.cellForItem(at: IndexPath(row: currentSelectedIndex, section: 0)) as! NoteCollectionView
        currentCell.shrinkCard()
    }
    
}

//MARK: Collection views
extension NoteViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foldersArr[folderIndex].notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noteCell", for: indexPath) as! NoteCollectionView
        
        cell.cardTitleLabel.text = foldersArr[folderIndex].notes[indexPath.row].title
        cell.cardContentLabel.text = foldersArr[folderIndex].notes[indexPath.row].content
        cell.cardContentLabel.adjustsFontSizeToFitWidth = true
        cell.notes = foldersArr[folderIndex].notes
        cell.currentIndex = indexPath.row
        
        if currentSelectedIndex == indexPath.row {
            cell.enlargeCard()
        }
        
        return cell
    }
    
    
}

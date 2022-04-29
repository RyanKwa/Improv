//
//  FolderTableViewCell.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 26/04/22.
//

import UIKit

class FolderTableViewCell: UITableViewCell {

    @IBOutlet weak var totalCardScroll: UILabel!
    @IBOutlet weak var folderNameScroll: UILabel!
    @IBOutlet weak var folderName: UILabel!
    @IBOutlet weak var totalNumberOfCard: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

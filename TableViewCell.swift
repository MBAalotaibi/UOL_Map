//
//  TableViewCell.swift
//  UserLocation
//
//  Created by Mohammed Abdullah Alotaibi on 12/12/2022.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
   

    @IBOutlet weak var subtitle: UILabel!
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var starButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

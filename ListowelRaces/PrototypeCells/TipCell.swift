//
//  TipCell.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 31/03/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit

class TipCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var tip : Tip? {
        didSet {
            self.nameLabel.text = tip?.name
            self.scoreLabel.text = String(describing: tip?.tipsterScore)
            self.correctLabel.text = "0"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

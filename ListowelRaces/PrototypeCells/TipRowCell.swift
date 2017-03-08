//
//  TipRowCell.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 3/6/17.
//  Copyright © 2017 Jack McAuliffe. All rights reserved.
//

import UIKit

class TipRowCell: UITableViewCell {

    @IBOutlet weak var columnView: TipXibView!
    
    var tip : Tip? {
        didSet {
            if let myTip = tip {
                self.columnView.nameLabel.text = myTip.name
                self.columnView.scoreLabel.text = String(myTip.tipsterScore)
                self.columnView.typeLabel.text = "Win"
            }
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

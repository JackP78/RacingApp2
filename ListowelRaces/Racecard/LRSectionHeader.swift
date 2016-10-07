//
//  LRSectionHeader.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 29/08/2015.
//  Copyright (c) 2015 Jack McAuliffe. All rights reserved.
//

import UIKit

class LRSectionHeader: UITableViewCell {

   
    @IBOutlet weak var raceNumber: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var raceName: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var prizeMoney: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  RaceSummaryCellTableViewCell.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 22/11/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit

class RaceSummaryCellTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    
    
    @IBOutlet weak var raceTitle: UILabel!
    
    
    @IBOutlet weak var distanceLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var race: Race? {
        didSet {
            if let currentRace = race {
                self.timeLabel.text = currentRace.scheduledTime.replacingOccurrences(of: ":00", with: "")
                self.raceTitle.text = currentRace.raceTitle
                self.distanceLable.text = currentRace.distanceYards.distanceString()
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

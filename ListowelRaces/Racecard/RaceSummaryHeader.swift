//
//  RaceSummaryHeader.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 30/11/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit

class RaceSummaryHeader: UITableViewHeaderFooterView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var timeLabel: UILabel!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var race: Race? {
        didSet {
            if let currentRace = race {
                self.timeLabel.text = currentRace.scheduledTime.replacingOccurrences(of: ":00", with: "")
                self.titleLabel.text = currentRace.raceTitle
                //self.distanceLable.text = currentRace.distanceYards.distanceString()
            }
        }
    }

}

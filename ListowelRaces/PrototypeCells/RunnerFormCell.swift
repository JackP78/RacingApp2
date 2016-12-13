//
//  RunnerFormCell.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 08/09/2015.
//  Copyright © 2015 Jack McAuliffe. All rights reserved.
//

import UIKit

class RunnerFormCell: UITableViewCell {
    @IBOutlet weak var raceDate: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var startingPrice: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    var form : Form? {
        didSet {
            if let myForm = form {
                self.raceDate.text = myForm.meetingdateString()
                self.courseName.text = myForm.course!.substring(to: myForm.course!.characters.index(myForm.course!.startIndex, offsetBy: 3))
                self.distance.text = myForm.distanceYards?.distanceString()
                self.startingPrice.text = myForm.startingPrice!
                self.positionLabel.text = myForm.finishpositionString()
                self.comment.text = myForm.briefcommentString()
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

//
//  FormRowCell.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 3/7/17.
//  Copyright © 2017 Jack McAuliffe. All rights reserved.
//

import UIKit

class FormRowCell: UITableViewCell {

    @IBOutlet weak var columnView: FormXibView!
    
    var form : Form? {
        didSet {
            if let myForm = form {
                self.columnView.dateLabel.text = myForm.meetingdateString()
                self.columnView.courseLabel.text = myForm.course!.substring(to: myForm.course!.characters.index(myForm.course!.startIndex, offsetBy: 3))
                self.columnView.distanceLabel.text = myForm.distanceYards?.distanceString()
                self.columnView.spLabel.text = myForm.startingPrice!
                self.columnView.positionLabel.text = myForm.finishpositionString()
                self.columnView.commentLabel.text = myForm.briefcommentString()
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

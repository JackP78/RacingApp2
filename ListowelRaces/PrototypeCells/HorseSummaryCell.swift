//
//  HorseSummaryCell.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 31/03/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import SDWebImage

class HorseSummaryCell: UITableViewCell {

    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var clothLabel: UILabel!
    @IBOutlet weak var silksImage: UIImageView!
    
    var runner: Runner? {
        didSet {
            if let currentRunner = runner {
                self.clothLabel.text = currentRunner.clothNumber?.stringValue
                self.nameLabel.text = currentRunner.name!
                if let tips = currentRunner.numberTips?.integerValue {
                    if tips > 0 {
                        tipsLabel.text = "\(tips) tips"
                    }
                }
                self.silksImage.sd_setImageWithURL(NSURL(string: currentRunner.silksUrl!), placeholderImage: UIImage(named:"defaultSilk"))
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

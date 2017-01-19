//
//  ColumnarView.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 19/01/2017.
//  Copyright © 2017 Jack McAuliffe. All rights reserved.
//

import UIKit

@IBDesignable class ColumnarView: UIView {

    @IBInspectable var columnList: String = ""
    
    var columns = [UILabel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (columns.count > 0) {
            let numColumns = columns.count
            let multiplier = CGFloat(1.0/Double(numColumns))
            
            let vertical = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[column1]-0-|",
                options: .directionLeadingToTrailing,
                metrics: nil,
                views: ["column1" : columns[0]]
            )
            let horizontal = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[column1][columnN]-0-|",
                options: .directionLeadingToTrailing,
                metrics: nil,
                views: ["column1" : columns[0], "columnN" : columns[numColumns - 1]]
            )
            
            self.addConstraints(vertical);
            self.addConstraints(horizontal);
            
            var lastColumn = columns[0];
            for i in 0..<numColumns {
                let thisColumn = columns[i];
                let width = NSLayoutConstraint.init(
                    item: thisColumn,
                    attribute: .width,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .width,
                    multiplier: multiplier,
                    constant: 0
                )
                lastColumn = thisColumn;
            }
        }
    }

}

//
//  ColumnarView.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 19/01/2017.
//  Copyright © 2017 Jack McAuliffe. All rights reserved.
//

import UIKit

class ColumnarView: UIView {

    var columnList: String = ""
    
    var columns = [UILabel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
    }
    
    func addSubviews() {
        NSLog("adding headers")
        let headers = ["Date","CRS","SP","Pos","Comment"];
        for headerText in headers {
            let columnHeader = UILabel();
            columnHeader.text = headerText;
            columns.append(columnHeader);
        }
    }
    
    
    override func layoutSubviews() {
        for columnHeader in columns {
            columnHeader.translatesAutoresizingMaskIntoConstraints = false
            columnHeader.textAlignment = .center
            self.addSubview(columnHeader)
        }
        if (columns.count > 0) {
            var lastColumn = columns[0];
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
            
            for i in 0..<numColumns {
                let thisColumn = columns[i];
                let proportionalWidth = NSLayoutConstraint.init(
                    item: thisColumn,
                    attribute: .width,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .width,
                    multiplier: multiplier,
                    constant: 0
                )
                let hAlign = NSLayoutConstraint.init(
                    item: thisColumn,
                    attribute: .centerY,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .centerY,
                    multiplier: 1,
                    constant: 0
                )
                let equalHeight = NSLayoutConstraint.init(
                    item: thisColumn,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .height,
                    multiplier: 1,
                    constant: 0
                )
                self.addConstraints([proportionalWidth, hAlign, equalHeight]);
                if (i > 0) {
                    let horizontalSpace = NSLayoutConstraint.init(
                        item: thisColumn,
                        attribute: .leading,
                        relatedBy: .equal,
                        toItem: lastColumn,
                        attribute: .trailing,
                        multiplier: 1,
                        constant: 0
                    )
                    self.addConstraint(horizontalSpace)
                }
                lastColumn = thisColumn;
            }
        }
        super.layoutSubviews()
    }

}

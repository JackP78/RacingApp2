//
//  ColumnarTableViewHeader.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 14/12/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit

class ColumnarTableViewHeader: UITableViewHeaderFooterView {

    let sectionLabel = UILabel()
    var columnHeaders = [UILabel]()
    
    required init(reuseIdentifier: String?, headers: [String]) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(sectionLabel)
        for headerText in headers {
            let columnHeader = UILabel();
            columnHeader.text = headerText;
            columnHeader.translatesAutoresizingMaskIntoConstraints = false
            columnHeader.textAlignment = .center
            columnHeaders.append(columnHeader);
            contentView.addSubview(columnHeader)
        }
        
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        // layout the form header first
        let centerHorizontally = NSLayoutConstraint(
            item: sectionLabel,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .centerX,
            multiplier: 1,
            constant: 0
        )
        
        let vertical = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[sectionLabel(==30)]",
            options: .directionLeadingToTrailing,
            metrics: nil,
            views: ["sectionLabel" : sectionLabel]
        )
        
        contentView.addConstraint(centerHorizontally);
        contentView.addConstraints(vertical);
        
        if (columnHeaders.count > 0) {
            NSLog("laying out the column headers")
            let firstColumn = columnHeaders[0]
            
            let multiplier = CGFloat(1.0/Double(columnHeaders.count))
            let width = NSLayoutConstraint.init(
                item: firstColumn,
                attribute: .width,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .width,
                multiplier: multiplier,
                constant: 0
            )
            let vertical2 = NSLayoutConstraint.constraints(
                withVisualFormat: "V:[firstColumn(==30)]-0-|",
                options: .directionLeadingToTrailing,
                metrics: nil,
                views: ["firstColumn" : firstColumn]
            )
            let horizontal = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[firstColumn]",
                options: .directionLeadingToTrailing,
                metrics: nil,
                views: ["firstColumn" : firstColumn]
            )
            contentView.addConstraint(width);
            contentView.addConstraints(vertical2);
            contentView.addConstraints(horizontal);
            var lastColumn = firstColumn
            
            for i in 1..<columnHeaders.count {
                let thisColumn = columnHeaders[i];
                let align = NSLayoutConstraint.init(
                    item: thisColumn,
                    attribute: .centerY,
                    relatedBy: .equal,
                    toItem: lastColumn,
                    attribute: .centerY,
                    multiplier: 1,
                    constant: 0
                )
                let equalHeight = NSLayoutConstraint.init(
                    item: thisColumn,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: lastColumn,
                    attribute: .height,
                    multiplier: 1,
                    constant: 0
                )
                let equalWidth = NSLayoutConstraint.init(
                    item: thisColumn,
                    attribute: .width,
                    relatedBy: .equal,
                    toItem: lastColumn,
                    attribute: .width,
                    multiplier: 1,
                    constant: 0
                )
                let horizontalSpace = NSLayoutConstraint.init(
                    item: thisColumn,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: lastColumn,
                    attribute: .trailing,
                    multiplier: 1,
                    constant: 0
                )
                contentView.addConstraints([align, equalHeight, equalWidth, horizontalSpace]);
                lastColumn = thisColumn;
            }
        }
    
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

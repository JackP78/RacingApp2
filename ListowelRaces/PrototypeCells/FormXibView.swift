//
//  FormXibView.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 2/28/17.
//  Copyright © 2017 Jack McAuliffe. All rights reserved.
//

import UIKit

@IBDesignable
class FormXibView: UIView {

    var contentView : UIView?
    
    var font: UIFont? {
        didSet {
            if let currentFont = font {
                dateLabel.font = currentFont
                courseLabel.font = currentFont
                positionLabel.font = currentFont
                distanceLabel.font = currentFont
                spLabel.font = currentFont
                commentLabel.font = currentFont
            }
        }
    }
    
    @IBInspectable var textColor: UIColor? {
        didSet {
            if let currentColor = textColor {
                dateLabel.textColor = currentColor
                courseLabel.textColor = currentColor
                positionLabel.textColor = currentColor
                distanceLabel.textColor = currentColor
                spLabel.textColor = currentColor
                commentLabel.textColor = currentColor
            }
        }
    }
    
    @IBInspectable var headerCsv: String? {
        didSet {
            if let notNull = headerCsv {
                let headers = notNull.characters.split{$0 == ","}.map(String.init)
                for i in 0..<headers.count {
                    switch (i) {
                    case 0:
                        dateLabel.text = headers[i];
                        break;
                    case 1:
                        courseLabel.text = headers[i];
                        break;
                    case 2:
                        positionLabel.text = headers[i];
                        break;
                    case 3:
                        distanceLabel.text = headers[i];
                        break;
                    case 4:
                        spLabel.text = headers[i];
                        break;
                    default:
                        commentLabel.text = headers[i];
                    }
                }
            }
        }
    }
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var spLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        contentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        contentView!.frame = bounds
        
        // Make the view stretch with containing view
        contentView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView!)
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

}

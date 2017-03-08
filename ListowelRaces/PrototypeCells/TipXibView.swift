//
//  FormXibView.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 2/28/17.
//  Copyright © 2017 Jack McAuliffe. All rights reserved.
//

import UIKit

@IBDesignable
class TipXibView: UIView {

    var contentView : UIView?
    
    var font: UIFont? {
        didSet {
            if let currentFont = font {
                nameLabel.font = currentFont
                scoreLabel.font = currentFont
                typeLabel.font = currentFont
            }
        }
    }
    
    @IBInspectable var textColor: UIColor = UIColor.black {
        didSet {
            nameLabel.textColor = textColor
            scoreLabel.textColor = textColor
            typeLabel.textColor = textColor
        }
    }
    
    @IBInspectable var headerCsv: String? {
        didSet {
            if let notNull = headerCsv {
                let headers = notNull.characters.split{$0 == ","}.map(String.init)
                for i in 0..<headers.count {
                    switch (i) {
                    case 0:
                        nameLabel.text = headers[i];
                        break;
                    case 1:
                        scoreLabel.text = headers[i];
                        break;
                    default:
                        typeLabel.text = headers[i];
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
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

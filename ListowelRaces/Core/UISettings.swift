//
//  UISettings.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 29/09/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import Foundation

open class UISettings {
    static func getFontName() -> String {
        return "AromaNo2LTW01-ExtraBold";
    }
    
    static func getPrimaryFont() -> UIFont {
        return UIFont(name: "AromaNo2LTW01-ExtraBold", size: 20) ?? UIFont.systemFont(ofSize: 17)
    }
    
    static func getPrimaryBackGroundColour() -> UIColor {
        return UIColor(red: 0.0, green: 0.259, blue: 0.145, alpha: 1.0)
    }
}

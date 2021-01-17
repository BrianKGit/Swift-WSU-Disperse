//
//  CardView.swift
//  Disperse
//
//  Created by Tim Gegg-Harrison, Nicole Anderson on 12/20/13.
//  Copyright © 2013 TiNi Apps. All rights reserved.
//

import UIKit

class CardView: UIImageView {

    var suit: Int
    var value: Int
    var highlightColor: String = "\0"
    var index: Int = 0
    var removed: Bool = false
    
    init(frame: CGRect, suit: Int, value: Int) {
        self.suit = suit
        self.value = value
        super.init(frame: frame)
        highlight()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func highlight() {
        image = UIImage(named: suit == 0 ? "AC\(highlightColor).png" : suit == 1 ? "AD\(highlightColor).png" : suit == 2 ? "AH\(highlightColor).png" : "AS\(highlightColor).png")
    }
    
    func highlight(_ color: String) {
        highlightColor = color
        highlight()
    }
    
    func highlighted() -> Bool {
        return highlightColor != "\0"
    }
    
}

//
//  PreviewController.swift
//  Disperse
//
//  Created by Klein, Brian K on 10/28/19.
//  Copyright © 2019 Tim Gegg-Harrison. All rights reserved.
//

import Foundation
import UIKit

class PreviewController: UIViewController {
    
    private var previewCards = [CardView]()
    private var startButton: UIButton = UIButton(type: UIButton.ButtonType.custom)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set the background color to purple
        view.backgroundColor = UIColor.purple
        //display 4 aces here
        createPreviewCards()
        displayPreviewCards()
        //a button that displays the string "Start Game"
        startButton.setTitle("Start", for: UIControl.State.normal)
        startButton.frame = CGRect(x: view.center.x-(0.5*view.frame.width*1/4), y: view.center.y, width: view.frame.width*1/4, height: view.frame.width*1/8)
        startButton.backgroundColor = UIColor.black
        startButton.addTarget(self, action: #selector(PreviewController.startButtonPressed), for: UIControl.Event.touchUpInside)
        view.addSubview(startButton)
    }
    
    //create card objects and populate the board with them.
    private func createPreviewCards() {
        var cardSuit: Int = 0
        var card: CardView
        
        //let w = 0.25*view.frame.width
        //let h = ((351.0/230.0)*0.25*view.frame.width)
        //var x: CGFloat = view.center.x - 40
        for _ in 0 ... 3 {
            //let card = previewCards[i]
            card = CardView(frame: CGRect(x: view.center.x, y: view.center.x, width: 0, height: 0), suit: cardSuit, value: 0)
            card.suit = cardSuit
            previewCards.append(card)
            cardSuit += 1
            //x += 20
            //view.addSubview(card)
       }
   }
       
   //display the card objects created in createCards()
   private func displayPreviewCards() {
        var x: CGFloat = view.center.x - (100 + (0.065*view.frame.width))
        var rotate: CGFloat = -45
        for i in 0 ..< previewCards.count {
            let card = previewCards[i]
            let w = 0.25*view.frame.width
            let h = ((351.0/230.0)*0.25*view.frame.width)
            var y = view.center.x
            if i==0 || i==3 {
                y = view.center.x + 35
            }
            card.frame = CGRect(x: x, y: y, width: w, height: h)
            x += 50
            //card.index = i
            card.transform = CGAffineTransform(rotationAngle: rotate*CGFloat.pi/180.0)
            rotate += 30
            view.addSubview(card)
            //card.removed = false
       }
   }
    
    @objc func startButtonPressed() {
        let vc: ViewController = ViewController()
        vc.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        present(vc, animated: true, completion: {
            () -> Void in
            vc.enterNewGame()
        })
    }
}

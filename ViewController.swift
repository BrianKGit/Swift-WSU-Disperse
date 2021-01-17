//
//  ViewController.swift
//  Disperse
//
//  Created by Tim Gegg-Harrison, Nicole Anderson on 12/20/13.
//  Copyright © 2013 TiNi Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //global constants and variables
    private let MAXCARDS: Int = 10
    private let BLUE: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.609375, alpha: 1.0)
    private let RED: UIColor = UIColor(red: 0.733333, green: 0.0, blue: 0.0, alpha: 1.0)
    private let game: GameState = GameState()
    private var suits: Array<UIImageView> = Array()
    private var buttons: Array<UIButton> = Array()
    private var previousTurn: [(Int, CGPoint)] = []
    private var startingPoint: CGPoint = CGPoint(x: 0, y: 0)
    private var playButton: UIButton = UIButton(type: UIButton.ButtonType.custom)
    private var quitButton: UIButton = UIButton(type: UIButton.ButtonType.custom)
    private var replayButton: UIButton = UIButton(type: UIButton.ButtonType.custom)
    private var replayCount: Int = 0
    private let increment: CGFloat = 500
    private var winner: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        //create UIImageView for each suit and add UIImage for each individually
        //create UIImageView object and define dimensions (x, y) makes up the origin and is the top right corner
        //create club object
        let myClub = UIImageView()
        //attach UIImage club.png to myClub
        myClub.image = UIImage(named: "club")
        
        //create spade object
        let mySpade = UIImageView()
        //attach UIImage spade.png to mySpade
        mySpade.image = UIImage(named: "spade")
        
        //create heart object
        let myHeart = UIImageView()
        //attach UIImage heart.png to myHeart
        myHeart.image = UIImage(named: "heart")
        
        //create diamond object
        let myDiamond = UIImageView()
        //attach UIImage diamond.png to myDiamond
        myDiamond.image = UIImage(named: "diamond")
        
        //configure a play button to change player turns
        playButton.setImage(UIImage(named: "play"), for: UIControl.State.normal)
        playButton.setImage(UIImage(named: "playH"), for: UIControl.State.highlighted)
        playButton.addTarget(self, action: #selector(ViewController.playButtonPressed), for: UIControl.Event.touchUpInside)
        
        //configure a quit button to end the game
        quitButton.setImage(UIImage(named: "quit"), for: UIControl.State.normal)
        quitButton.setImage(UIImage(named: "quitH"), for: UIControl.State.highlighted)
        quitButton.addTarget(self, action: #selector(ViewController.quitButtonPressed), for: UIControl.Event.touchUpInside)
        
        //configure a replay button to show the moves made during the previous turn
        replayButton.setImage(UIImage(named: "replay"), for: UIControl.State.normal)
        replayButton.setImage(UIImage(named: "replayH"), for: UIControl.State.highlighted)
        replayButton.addTarget(self, action: #selector(ViewController.replayButtonPressed), for: UIControl.Event.touchUpInside)
        
        //add UIButton to an Array
        buttons.append(replayButton)
        buttons.append(playButton)
        buttons.append(quitButton)
        
        //add the UIImageView's to an array
        suits.append(myClub)
        suits.append(myDiamond)
        suits.append(myHeart)
        suits.append(mySpade)
        
        //add constraints to the buttons and add them to the subview
        for i in 0 ..< buttons.count {
            buttons[i].translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(buttons[i])
            NSLayoutConstraint(item: buttons[i],
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .width,
                               multiplier: 1.0/(2.0*CGFloat(buttons.count)+1.0),
                               constant: 0.0).isActive = true
            NSLayoutConstraint(item: buttons[i],
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: buttons[i],
                               attribute: .width,
                               multiplier: 1.0,
                               constant: 0.0).isActive = true
            NSLayoutConstraint(item: buttons[i],
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .centerX,
                               multiplier: CGFloat(2*i+1)/CGFloat(buttons.count),
                               constant: 0.0).isActive = true
            NSLayoutConstraint(item: buttons[i],
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .bottom,
                               multiplier: 1.0,
                               constant: -40.0).isActive = true
        }
        
        //add constraints to the suit images and add them to the subview
        for i in 0 ..< suits.count {
            suits[i].translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(suits[i])
            NSLayoutConstraint(item: suits[i],
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .width,
                               multiplier: 1.0/(2.0*CGFloat(suits.count)+1.0),
                               constant: 0.0).isActive = true
            NSLayoutConstraint(item: suits[i],
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: suits[i],
                               attribute: .width,
                               multiplier: 1.0,
                               constant: 0.0).isActive = true
            NSLayoutConstraint(item: suits[i],
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .centerX,
                               multiplier: CGFloat(2*i+1)/CGFloat(suits.count),
                               constant: 0.0).isActive = true
            NSLayoutConstraint(item: suits[i],
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .top,
                               multiplier: 1.0,
                               constant: 80.0).isActive = true
        }
    }
    
    // The following 3 methods were "borrowed" from http://stackoverflow.com/questions/15710853/objective-c-check-if-subviews-of-rotated-uiviews-intersect and converted to Swift
    private func projectionOfPolygon(poly: [CGPoint], onto: CGPoint) ->  (min: CGFloat, max: CGFloat) {
        var minproj: CGFloat = CGFloat.greatestFiniteMagnitude
        var maxproj: CGFloat = -CGFloat.greatestFiniteMagnitude
        for point in poly {
            let proj: CGFloat = point.x * onto.x + point.y * onto.y
            if proj > maxproj {
                maxproj = proj
            }
            if proj < minproj {
                minproj = proj
            }
        }
        return (minproj, maxproj)
    }
    
    private func convexPolygon(poly1: [CGPoint], poly2: [CGPoint]) -> Bool {
        for i in 0..<poly1.count {
            // Perpendicular vector for one edge of poly1:
            let p1: CGPoint = poly1[i];
            let p2: CGPoint = poly1[(i+1) % poly1.count];
            let perp: CGPoint = CGPoint(x: p1.y - p2.y, y: p2.x - p1.x)
            // Projection intervals of poly1, poly2 onto perpendicular vector:
            let (minp1,maxp1): (CGFloat,CGFloat) = projectionOfPolygon(poly: poly1, onto: perp)
            let (minp2,maxp2): (CGFloat,CGFloat) = projectionOfPolygon(poly: poly2, onto: perp)
            // If projections do not overlap then we have a "separating axis" which means that the polygons do not intersect:
            if maxp1 < minp2 || maxp2 < minp1 {
                return false
            }
        }
        // And now the other way around with edges from poly2:
        for i in 0..<poly2.count {
            // Perpendicular vector for one edge of poly2:
            let p1: CGPoint = poly2[i];
            let p2: CGPoint = poly2[(i+1) % poly2.count];
            let perp: CGPoint = CGPoint(x: p1.y - p2.y, y:
                p2.x - p1.x)
            // Projection intervals of poly1, poly2 onto perpendicular vector:
            let (minp1,maxp1): (CGFloat,CGFloat) = projectionOfPolygon(poly: poly1, onto: perp)
            let (minp2,maxp2): (CGFloat,CGFloat) = projectionOfPolygon(poly: poly2, onto: perp)
            // If projections do not overlap then we have a "separating axis" which means that the polygons do not intersect:
            if maxp1 < minp2 || maxp2 < minp1 {
                return false
            }
        }
        return true
    }

    private func viewsIntersect(view1: UIView, view2: UIView) -> Bool {
        return convexPolygon(poly1: [view1.convert(view1.bounds.origin, to: nil), view1.convert(CGPoint(x: view1.bounds.origin.x + view1.bounds.size.width, y: view1.bounds.origin.y), to: nil), view1.convert(CGPoint(x: view1.bounds.origin.x + view1.bounds.size.width, y: view1.bounds.origin.y + view1.bounds.height), to: nil), view1.convert(CGPoint(x: view1.bounds.origin.x, y: view1.bounds.origin.y + view1.bounds.height), to: nil)], poly2: [view2.convert(view1.bounds.origin, to: nil), view2.convert(CGPoint(x: view2.bounds.origin.x + view2.bounds.size.width, y: view2.bounds.origin.y), to: nil), view2.convert(CGPoint(x: view2.bounds.origin.x + view2.bounds.size.width, y: view2.bounds.origin.y + view2.bounds.height), to: nil), view2.convert(CGPoint(x: view2.bounds.origin.x, y: view2.bounds.origin.y + view2.bounds.height), to: nil)])
    }
    
    private func cardIsOpenAtIndex(i: Int) -> Bool {
        var j: Int = i+1
        while j < game.board.count && (game.board[j].removed || !viewsIntersect(view1: game.board[i], view2: game.board[j])) {
            j += 1
        }
        return (j >= game.board.count)
    }
    
    //highlight cards on top and allow them to recognize a Pan gesture; enable interaction
    private func highlightOpenCards() {
        //for loop to iterate through all card objects on the board
        for i in 0 ..< game.board.count {
            let card: CardView = game.board[i]
            card.highlight("\0")
            //If: the card is not removed, the card's suit is not hidden, and the card is not covered by another card object.
            //Then: highlight the card, add the pan gesture recognizer to the card, and enable user interaction with the card.
            //Else: ensure the card cannot be interacted with by the user
            if !card.removed && !suits[card.suit].isHidden && cardIsOpenAtIndex(i: i) {
                    card.highlight("H")
                card.isUserInteractionEnabled = true
            } else {
                card.isUserInteractionEnabled = false
            }
        }
    }
    
    //function to set the background color of the app depending on which turn it is. Blue turn gets a blue background. Not blue turn gets a red background.
    private func setBackground() {
        if game.blueTurn {
            view.backgroundColor = BLUE
            winner = "Red Wins!"
        }
        else {
            view.backgroundColor = RED
            winner = "Blue Wins!"
        }
    }
    
    //create card objects and populate the board with them.
    private func createCards() {
        var cardSuit: Int = 0
        var card: CardView
        game.board = [CardView]()
        game.cardsRemaining = MAXCARDS + Int.random(in: 0...MAXCARDS/2)
        for _ in 0 ..< game.cardsRemaining {
            card = CardView(frame: CGRect(x: view.center.x, y: view.center.x, width: 0.0, height: 0.0), suit: cardSuit, value: 0)
            game.board.append(card)
            cardSuit = (cardSuit + 1) % 4
            card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(ViewController.handlePan(_:))))
        }
    }
    
    //display the card objects created in createCards()
    private func displayCards() {
        for i in 0 ..< game.board.count {
            let card = game.board[i]
            let w = 0.25*view.frame.width
            let h = ((351.0/230.0)*0.25*view.frame.width)
            let x = CGFloat.random(in: 0.35...0.85)*view.frame.width - w
            let y = CGFloat.random(in: 0.40...0.80)*view.frame.height - h
            card.frame = CGRect(x: x, y: y, width: w, height: h)
            card.index = i
            card.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: 0.0...45.0)*CGFloat.pi/180.0)
            view.addSubview(card)
            card.removed = false
        }
    }
    
    // Method to handle a pan gesture
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        //bring selected card to the front when the user begins a pan gesture. This will ensure that the card's image doesn't hide behind other card's images while the user moves the image around.
        if recognizer.state == UIGestureRecognizer.State.began {
            //keep track of the starting point so you have somewhere to put the card in the case of gesture cancellation
            startingPoint = recognizer.view!.center
            //bring selected card to the front of the view so the user doesn't pan the card behind other cards on the board
            recognizer.view?.superview?.bringSubviewToFront(recognizer.view!)
            //if replay button is active and the card is done being moved you will remove all cards from the replay array and disable the replay button
            if(replayButton.isHighlighted) {
                for i in 0 ..< previousTurn.count {
                    let card: CardView = game.board[previousTurn[i].0]
                     card.removed = true
                     card.removeFromSuperview()
                }
                previousTurn.removeAll()
                disableReplayButton()
            }
        }
        //update the center of the card to reflect the panning movement
        let translation: CGPoint = recognizer.translation(in: view)
        recognizer.view?.center = CGPoint(x: recognizer.view!.center.x + translation.x, y: recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
        //if gesture is cancelled move card back to starting point
        if recognizer.state == UIGestureRecognizer.State.cancelled {
            recognizer.view?.center = startingPoint
        }
        
        /*
         if gesture is ended:
         -->mark card as removed
         -->remove selected card from superview
         -->decrement remaining cards count
         -->invoke highlightOpenCards()
         -->change the play image to be the green play button by highlighting it and making it accept user interactions.
        */
        if recognizer.state == UIGestureRecognizer.State.ended {
            
            //cast recognizer.view to CardView with optional binding
            if let card: CardView = recognizer.view as? CardView {
                //hide the image of the suit of the card that is removed here
                suits[card.suit].isHidden = true
                //if replay button is active and the card is done being moved you will remove all cards from the replay array and disable the replay button
                //add the card to an array for later replay
                previousTurn.append((card.index, startingPoint))
                //hide card from view
                card.isHidden = true
                //mark the card as removed
                card.removed = true
            }
            //decrement card count
            game.cardsRemaining -= 1
            //check if the game is over
            if game.cardsRemaining == 0 {
                //if there are no more cards to play issue an alert and dismiss the ViewController
                let alert: UIAlertController = UIAlertController(title: "\(winner)", message: "", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style:
                    UIAlertAction.Style.default, handler:
                    {(action: UIAlertAction!) -> Void in
                        self.presentingViewController?.dismiss(animated: true, completion: {() -> Void in
                            
                        })
                }))
                present(alert, animated: true, completion:
                    {() -> Void in

                })
                
            }
            //highlight cards that are now available
            highlightOpenCards()
            //call function to display a green play button
            highlightPlayButton()
        }
    }
    
    //action method for when a user presses the play button
    @objc func playButtonPressed() {
        //switch turns
        if game.blueTurn {
            game.blueTurn = false
        }
        else {
            game.blueTurn = true
            //highlight the quit button after both players have had a turn. Since the game always begins on Blue's turn we don't highlight the quit button until we switch from red's turn back to blue's turn.
            highlightQuitButton()
        }
        //call method to reveal the hidden suit images at the top of the screen
        showSuitImages()
        //call method to change the background to reflect the correct turn
        setBackground()
        //call method to disable the play button
        disablePlayButton()
        //call method to highlight cards that are open as the turn changes
        highlightOpenCards()
        //highlight and enable the replay button when you switch turns
        highlightReplayButton()
    }
    
    //action method for when a user presses the quit button
    @objc func quitButtonPressed() {
        let alert: UIAlertController = UIAlertController(title: "Quit?", message: "Would you like to end your game now?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler:
            {(action: UIAlertAction!) -> Void in
                let alertWin: UIAlertController = UIAlertController(title: "\(self.winner)", message: "", preferredStyle: UIAlertController.Style.alert)
                alertWin.addAction(UIAlertAction(title: "OK", style:
                    UIAlertAction.Style.default, handler:
                    {(action: UIAlertAction!) -> Void in
                        //for loop to iterate through and remove all cards curently on the board
                        for i in 0 ..< self.game.board.count {
                            let card: CardView = self.game.board[i]
                             card.removed = true
                             card.removeFromSuperview()
                        }
                        //empty the tuple array that stores the previous turn's cards
                        self.previousTurn.removeAll()
                        //dismiss the ViewController
                        self.presentingViewController?.dismiss(animated: true, completion:
                            {() -> Void in
                            
                        })
                }))
                self.present(alertWin, animated: true, completion:
                    {() -> Void in

                })        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler:
            {(action: UIAlertAction!) -> Void in
                self.highlightQuitButton()
        }))
        present(alert, animated: true, completion:
            {() -> Void in

        })


    }
    
    //action method for when a user presses the replay button
    @objc func replayButtonPressed() {
        switchTurns()
        restorePreviousTurn()
        highlightOpenCards()
        animateRemoveCards(i: 0)
    }
    
    //method to add cards that were removed in the previous turn back to the pile of cards
    private func restorePreviousTurn() {
        for i in (0 ..< previousTurn.count).reversed() {
            let card: CardView = game.board[previousTurn[i].0]
            self.view.bringSubviewToFront(card)
            card.center = previousTurn[i].1
            card.isHidden = false
            card.removed = false
        }
    }
    
    //method to animate the removal of the cards from the previous turn
    private func animateRemoveCards(i: Int) {
        if (i < previousTurn.count) {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 2, delay: 1, options: UIView.AnimationOptions.curveEaseInOut , animations: {
                () -> Void in
                //animate the removal of the card
                let card: CardView = self.game.board[self.previousTurn[i].0]
                //card.center = self.previousTurn[i].1
                card.center.x += self.increment
                //hide the image of the suit of the card that is removed here
                self.suits[card.suit].isHidden = true
            }, completion: {
                (Bool) -> Void in
                self.highlightOpenCards()
                self.animateRemoveCards(i: i+1)
            })
        } else {
            switchTurns()
            highlightReplayButton()
            showSuitImages()
            highlightOpenCards()
        }
        
    }
    
    //switch turns and set background accordingly
    private func switchTurns() {
        game.blueTurn = !game.blueTurn
        setBackground()
    }

    // Method to disable the play button by turning off highlighted image and disabling user interaction
    private func disablePlayButton() {
        //when isHighlighted is false UIImageView switches from using .highlightedImage to using .image
        buttons[1].isHighlighted = false
        //make user interaction for play button impossible
        buttons[1].isUserInteractionEnabled = false
    }

    // Method to enable the play button by turning on highlighted image and enabling user interaction
    private func highlightPlayButton() {
        //when isHighlighted is true UIImageView switches from using .image to using .highlightedImage
        buttons[1].isHighlighted = true
        //make user interaction for play button possible
        buttons[1].isUserInteractionEnabled = true
    }
    
    // Method to disable the quit button by turning off highlighted image and disabling user interaction
    private func disableQuitButton() {
        //when isHighlighted is false UIImageView switches from using .highlightedImage to using .image
        buttons[2].isHighlighted = false
        //make user interaction for quit button impossible
        buttons[2].isUserInteractionEnabled = false
    }

    // Method to enable the quit button by turning on highlighted image and enabling user interaction
    private func highlightQuitButton() {
        //when isHighlighted is true UIImageView switches from using .image to using .highlightedImage
        buttons[2].isHighlighted = true
        //make user interaction for quit button possible
        buttons[2].isUserInteractionEnabled = true
    }
    
    // Method to disable the quit button by turning off highlighted image and disabling user interaction
    private func disableReplayButton() {
        //when isHighlighted is false UIImageView switches from using .highlightedImage to using .image
        buttons[0].isHighlighted = false
        //make user interaction for quit button impossible
        buttons[0].isUserInteractionEnabled = false
    }

    // Method to enable the quit button by turning on highlighted image and enabling user interaction
    private func highlightReplayButton() {
        //when isHighlighted is true UIImageView switches from using .image to using .highlightedImage
        buttons[0].isHighlighted = true
        //make user interaction for quit button possible
        buttons[0].isUserInteractionEnabled = true
    }
    
    // Method to reveal the suit images
    private func showSuitImages() {
        for i in 0 ..< suits.count {
            let suit = suits[i]
            suit.isHidden = false
        }
    }
    
    func enterNewGame() {
        game.blueTurn = true
        setBackground()
        createCards()
        displayCards()
        showSuitImages()
        disablePlayButton()
        disableQuitButton()
        disableReplayButton()
        highlightOpenCards()
    }
    
}

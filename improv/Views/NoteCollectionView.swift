//
//  CardCollectionViewCell.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 26/04/22.
//

import UIKit

class NoteCollectionView: UICollectionViewCell {

    ///this is title z pos = front

    @IBOutlet weak var cardTitleView: UIView!
    @IBOutlet weak var cardTitleLabel: UILabel!
    
    ///this is content z pos = behind

    @IBOutlet weak var cardContentView: UIView!
    @IBOutlet weak var cardContentLabel: UILabel!
    
    var notes = [Note]()
    var currentIndex = 0
    
    func enlargeCard(){
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 1.075, y: 1.075)
        }
        if notes[currentIndex].isFlipped == false{
            cardTitleView.isHidden = false
            cardContentView.isHidden = true
        }
        else{
            cardTitleView.isHidden = true
            cardContentView.isHidden = false
        }
        let titleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.flipAction))
        let contentTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.flipAction))
        cardTitleView.addGestureRecognizer(titleTapGesture)
        cardContentView.addGestureRecognizer(contentTapGesture)
    }
    func shrinkCard(){
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
        }
    }
    @objc func flipAction(sender: UITapGestureRecognizer){
        if notes[currentIndex].isFlipped == false{
            cardTitleView.isHidden = false
            cardContentView.isHidden = true
            notes[currentIndex].isFlipped = true
            UIView.transition(from: cardTitleView, to: cardContentView, duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews])
        }
        else{
            cardTitleView.isHidden = true
            cardContentView.isHidden = false
            notes[currentIndex].isFlipped = false
            UIView.transition(from: cardContentView, to: cardTitleView, duration: 0.5, options: [.transitionFlipFromRight, .showHideTransitionViews])
        }
    }
}

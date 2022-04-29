//
//  CardCollectionFlowLayout.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 26/04/22.
//

import UIKit

class NoteCollectionFlowLayout: UICollectionViewFlowLayout {
    var contentWidth = 390
    var contentHeight = 549
    override func prepare() {
        guard let collectionView = collectionView else{
            return
        }
        scrollDirection = .horizontal
        itemSize = CGSize(width: contentWidth, height: contentHeight)
        /*
         width = 390
         peeking width = 390/5 = 78point
         peeking width = 390/6 = 65point
         peeking width = 390/9 = 43point
         */
        let cardPeekWidth = itemSize.width / 9
        //horizontal margin, insets = margin
        let horizontalInset = (collectionView.frame.size.width - itemSize.width) / 2
        //set margin
        collectionView.contentInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        minimumLineSpacing = horizontalInset - cardPeekWidth
        
    }
}

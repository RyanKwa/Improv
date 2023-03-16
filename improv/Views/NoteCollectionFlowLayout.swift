//
//  CardCollectionFlowLayout.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 26/04/22.
//

import UIKit

class NoteCollectionFlowLayout: UICollectionViewFlowLayout {
    //cell size
    var contentWidth = UIScreen.main.bounds.size.width
    var contentHeight = UIScreen.main.bounds.size.height/1.6
    override func prepare() {
        guard let collectionView = collectionView else{
            return
        }
        scrollDirection = .horizontal
        itemSize = CGSize(width: contentWidth, height: contentHeight)
        /*
         width = 390
         
        card peek width = ukuran dari card sebelah, semakin besar berarti peek ke card sebelahnya bakal lebih besar juga
         nanti digunakan untuk minimum line spacing/jarak antara card
         
         peeking width = 390/5 = 78point
         peeking width = 390/6 = 65point
         peeking width = 390/9 = 43point
         */
        let cardPeekWidth = itemSize.width / 9
        //horizontal margin, insets = margin, this case 0
        let horizontalInset = (collectionView.frame.size.width - itemSize.width) / 2
        
        print("NoteCollectionViewLayout cardPeekWidth: \(cardPeekWidth)")
        print("NoteCollectionViewLayout collectionViewSizeWidth: \(collectionView.frame.size.width)")
        print("NoteCollectionViewLayout Horizontal margin: \(horizontalInset)")
        //set margin
        collectionView.contentInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        
        //jarak antara 1 card ke card lain semakin kecil, semakin dekat jaraknya
        minimumLineSpacing = horizontalInset - cardPeekWidth
//        print("HOrinset: \(minimumLineSpacing)")

    }
}

//
//  ViewController.swift
//  AppstoreTransiotion
//
//  Created by GLB-254 on 8/30/19.
//  Copyright © 2019 GLB-254. All rights reserved.
//

import UIKit

class ViewController: StatusBarAnimatableViewController {

    @IBOutlet weak var cardCollectionView: UICollectionView!
    
    private var transition: CardTransition?
    
    lazy var cardModels:[CardContentViewModel] = [
        CardContentViewModel(primary: "Founde & Ceo Of Apple", secondary: "Steve Jobs", description: "Founder and Ceo of Apple for 30-40 years", image: #imageLiteral(resourceName: "steve.png").resize(toWidth: UIScreen.main.bounds.size.width * (1/GlobalConstants.cardHighlightedFactor))),
        CardContentViewModel(primary: "Product Manager & Android Developer", secondary: "Biswatma Nayak", description: "Holds 5 years of experience under Android Development", image: #imageLiteral(resourceName: "biswatma.jpg").resize(toWidth: UIScreen.main.bounds.size.width * (1/GlobalConstants.cardHighlightedFactor))),
        CardContentViewModel(primary: "UI & UX Developer", secondary: "Chanchal Santra", description: "Holds 5 years of experience under UI & UX Development", image: #imageLiteral(resourceName: "chanchal.jpg").resize(toWidth: UIScreen.main.bounds.size.width * (1/GlobalConstants.cardHighlightedFactor))),
        CardContentViewModel(primary: "Node JS Developer", secondary: "Vikash Verma", description: "Holds 4 years of experience under Node JS Development", image: #imageLiteral(resourceName: "vikas.jpg").resize(toWidth: UIScreen.main.bounds.size.width * (1/GlobalConstants.cardHighlightedFactor))),
        CardContentViewModel(primary: "iOS Developer", secondary: "Veeresh Kumbar", description: "Holds 2.8 years of experience under iOS Development", image: #imageLiteral(resourceName: "veeresh.jpg").resize(toWidth: UIScreen.main.bounds.size.width * (1/GlobalConstants.cardHighlightedFactor)))
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardCollectionView.delaysContentTouches = false
        
        if let layout = cardCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = .init(top: 20, left: 0, bottom: 64, right: 0)
        }
        
        cardCollectionView.clipsToBounds = false
        cardCollectionView.register(UINib(nibName: "\(CardCollectionViewCell.self)", bundle: nil), forCellWithReuseIdentifier: "cell")

    }

    override var statusBarAnimatableConfig: StatusBarAnimatableConfig {
        return StatusBarAnimatableConfig(prefersHidden: false,
                                         animation: .slide)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! CardCollectionViewCell
        cell.cardContentView?.viewModel = cardModels[indexPath.row]
    }
}

extension ViewController {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cardHorizontalOffset: CGFloat = 20
        let cardHeightByWidthRatio: CGFloat = 1.2
        let width = collectionView.bounds.size.width - 2 * cardHorizontalOffset
        let height: CGFloat = width * cardHeightByWidthRatio
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Get tapped cell location
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        
        // Freeze highlighted state (or else it will bounce back)
        cell.freezeAnimations()
        
        // Get current frame on screen
        let currentCellFrame = cell.layer.presentation()!.frame
        
        // Convert current frame to screen's coordinates
        let cardPresentationFrameOnScreen = cell.superview!.convert(currentCellFrame, to: nil)
        
        // Get card frame without transform in screen's coordinates  (for the dismissing back later to original location)
        let cardFrameWithoutTransform = { () -> CGRect in
            let center = cell.center
            let size = cell.bounds.size
            let r = CGRect(
                x: center.x - size.width / 2,
                y: center.y - size.height / 2,
                width: size.width,
                height: size.height
            )
            return cell.superview!.convert(r, to: nil)
        }()
        
        let cardModel = cardModels[indexPath.row]
        
        // Set up card detail view controller
        let vc = storyboard!.instantiateViewController(withIdentifier: "cardDetailVc") as! CardDetailViewController
        vc.cardViewModel = cardModel.highlightedImage()
        vc.unhighlightedCardViewModel = cardModel // Keep the original one to restore when dismiss
        let params = CardTransition.Params(fromCardFrame: cardPresentationFrameOnScreen,
                                           fromCardFrameWithoutTransform: cardFrameWithoutTransform,
                                           fromCell: cell)
        transition = CardTransition(params: params)
        vc.transitioningDelegate = transition
        
//         If `modalPresentationStyle` is not `.fullScreen`, this should be set to true to make status bar depends on presented vc.
        vc.modalPresentationCapturesStatusBarAppearance = true
        vc.modalPresentationStyle = .custom

        present(vc, animated: true, completion: { [unowned cell] in
            // Unfreeze
            cell.unfreezeAnimations()
        })
    }
}

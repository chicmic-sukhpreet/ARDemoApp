//
//  ARDemoViewController+CollectionView.swift
//  ARDemoApp
//
//  Created by Chicmic on 28/08/23.
//

import Foundation
import UIKit
// swiftlint:disable line_length
extension ARDemoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewForFilters {
            return ( (models.count +
                      animatedModelsForTongue.count +
                      animatedModelsForSmile.count) / maximumNumberOfFaceAnchors)
        } else {
            return effects.count
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionViewForFilters {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "modelCollectionViewCell", for: indexPath) as? CollectionViewForFiltersCell
            if indexPath.item < (models.count / maximumNumberOfFaceAnchors) {
                cell?.modelImage.image = UIImage(named: models[indexPath.item].modelName)
            } else if indexPath.item == models.count / 3 {
                cell?.modelImage.image = UIImage(named: "cupcake")
            } else if indexPath.item == 5 {
                cell?.modelImage.image = UIImage(named: "glasses")
            }
            cell?.modelImage.layer.cornerRadius = 10
            cell?.modelImage.layer.masksToBounds = true
            if indexPath.item == 0 && selectedIndexPathForFilters == nil {
                cell?.modelImage.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
                cell?.modelImage.layer.borderWidth = 4
                selectedIndexPathForFilters = indexPath
            } else if selectedIndexPathForFilters != indexPath {
                cell?.modelImage.layer.borderWidth = 0
            }
            return cell!
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewForEffects", for: indexPath) as? CollectionViewForEffectsCell
            cell?.effectImage.image = UIImage(systemName: "circle")
            cell?.effectImage.sizeToFit()
            cell?.effectImage.contentMode = .scaleAspectFill
            cell?.effectImage.layer.cornerRadius = (cell?.effectImage.frame.size.height)! / 2
            cell?.effectImage.layer.masksToBounds = true
            if indexPath.item == 0 && selectedIndexPathForEffects == nil {
                cell?.effectImage.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
                cell?.effectImage.layer.borderWidth = 4
                selectedIndexPathForEffects = indexPath
            } else if selectedIndexPathForEffects != indexPath {
                cell?.effectImage.layer.borderWidth = 0
            }
            return cell!
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionViewForFilters {
            if let previousSelectedIndexPath = selectedIndexPathForFilters {
                let previousCell = collectionView.cellForItem(at: previousSelectedIndexPath) as? CollectionViewForFiltersCell
                previousCell?.modelImage.layer.borderWidth = 0.0
            }
            let currentCell = collectionView.cellForItem(at: indexPath) as? CollectionViewForFiltersCell
            currentCell?.modelImage.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
            currentCell?.modelImage.layer.borderWidth = 4.0
            selectedIndexPathForFilters = indexPath
            selectedIndexForFilters = indexPath.item
            arView.scene.anchors.removeAll()
            if indexPath.item == models.count / 3 {
                showLabel.text = "open your mouth"
            } else if indexPath.item == 5 {
                showLabel.text = "smile"
            }
        } else {
            if let previousSelectedIndexPath = selectedIndexPathForEffects {
                let previousCell = collectionView.cellForItem(at: previousSelectedIndexPath) as? CollectionViewForEffectsCell
                previousCell?.effectImage.layer.borderWidth = 0.0
            }
            let currentCell = collectionView.cellForItem(at: indexPath) as? CollectionViewForEffectsCell
            currentCell?.effectImage.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
            currentCell?.effectImage.layer.borderWidth = 4.0
            selectedIndexPathForEffects = indexPath
            selectedIndexForEffects = indexPath.item
        }
    }
}

extension ARDemoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size.height
        return CGSize(width: size, height: size)
    }
}
// swiftlint:enable line_length

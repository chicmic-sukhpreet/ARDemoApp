//
//  ARDemoViewController+ARSession.swift
//  ARDemoApp
//
//  Created by Chicmic on 28/08/23.
//

import Foundation
import ARKit
import RealityKit
import CoreImage
// swiftlint:disable line_length
extension ARDemoViewController: ARSessionDelegate {
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard option == .filters else { return }
        filterImageView.isHidden = true
        self.showLabel.isHidden = false
        if selectedIndexForFilters < (models.count / maximumNumberOfFaceAnchors) {
            var index = 0
            self.showLabel.text = ""
            for anchor in anchors {
                guard let faceAnchor = anchor as? ARFaceAnchor else { continue }
                let anchorEntity = AnchorEntity(anchor: faceAnchor)
                if index == 0 {
                    let glassModelInstance = models[selectedIndexForFilters].modelEntity
                    glassModelInstance.scale = models[selectedIndexForFilters].modelScale
                    let positionOffsetForGlassModel: SIMD3<Float> = models[selectedIndexForFilters].modelOffset
                    anchorEntity.addChild(glassModelInstance)
                    anchorEntity.position += positionOffsetForGlassModel
                } else if index == 1 {
                    let glassModelInstance = models[selectedIndexForFilters + 4].modelEntity
                    glassModelInstance.scale = models[selectedIndexForFilters + 4].modelScale
                    let positionOffsetForGlassModel: SIMD3<Float> = models[selectedIndexForFilters + 4].modelOffset
                    anchorEntity.addChild(glassModelInstance)
                    anchorEntity.position += positionOffsetForGlassModel
                } else {
                    let glassModelInstance = models[selectedIndexForFilters + 8].modelEntity
                    glassModelInstance.scale = models[selectedIndexForFilters + 8].modelScale
                    let positionOffsetForGlassModel: SIMD3<Float> = models[selectedIndexForFilters + 8].modelOffset
                    anchorEntity.addChild(glassModelInstance)
                    anchorEntity.position += positionOffsetForGlassModel
                }
                arView.scene.anchors.append(anchorEntity)
                index += 1
            }
        } else if selectedIndexForFilters == (models.count / maximumNumberOfFaceAnchors) {
            var faceAnchor: ARFaceAnchor?
            showLabel.text = "show your tongue"
            for (index, anc) in anchors.enumerated() {
                guard let anchor = anc as? ARFaceAnchor else { return }
                faceAnchor = anchor
                guard let blendShapes = faceAnchor?.blendShapes,
                      let tongueOut = blendShapes[.tongueOut]?.floatValue
                else { return }
                if tongueOut > 0.5 {
                    arView.scene.anchors.append(animatedModelsForTongue[index].animatedAnchor)
                    guard index == 0 else { continue }
                    showLabel.text = ""
                } else {
                    arView.scene.anchors.remove(animatedModelsForTongue[index].animatedAnchor)
                    guard index == 0 else { continue }
                    showLabel.text = "show your tongue"
                }
            }
        } else if selectedIndexForFilters < 6 {
            var faceAnchor: ARFaceAnchor?
            showLabel.text = "smile"
            for (index, anc) in anchors.enumerated() {
                guard let anchor = anc as? ARFaceAnchor else { return }
                faceAnchor = anchor
                guard let blendShapes = faceAnchor?.blendShapes,
                      let mouthSmileLeft = blendShapes[.mouthSmileLeft]?.floatValue,
                      let mouthSmileRight = blendShapes[.mouthSmileRight]?.floatValue
                else { return }
                if mouthSmileLeft > 0.3 || mouthSmileRight > 0.3 {
                    arView.scene.anchors.append(animatedModelsForSmile[index].animatedAnchor)
                    guard index == 0 else { continue }
                    showLabel.text = ""
                } else {
                    arView.scene.anchors.remove(animatedModelsForSmile[index].animatedAnchor)
                    guard index == 0 else { continue }
                    showLabel.text = "smile"
                }
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard option == .effects, !isProcessingFrame else { return }
        isProcessingFrame = true
        self.showLabel.isHidden = true
        filterImageView.isHidden = false
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.filterContext == nil {
                self.filterContext = CIContext()
            }
            let ciImage = CIImage(cvPixelBuffer: frame.capturedImage)
            self.applyFilterToImageView(ciImage: ciImage, filterIndex: self.selectedIndexForEffects, imageViewForFilter: self.filterImageView)
            self.imageWithoutEffects = UIImage(ciImage: ciImage, scale: 1, orientation: .right)
            for index in self.effects.indices {
                if let cell = self.collectionViewForEffects.cellForItem(at: IndexPath(item: index, section: 0)) as? CollectionViewForEffectsCell {
                    self.applyFilterToImageView(ciImage: CIImage(cvPixelBuffer: frame.capturedImage), filterIndex: index, imageViewForFilter: cell.effectImage)
                }
            }
            self.isProcessingFrame = false
        }
    }
}

extension ARDemoViewController {
    func applyFilterToImageView(ciImage: CIImage, filterIndex: Int, imageViewForFilter: UIImageView) {
        guard let filterContext = self.filterContext else { return }
        effects[filterIndex]?.setValue(ciImage, forKey: kCIInputImageKey)
        if filterIndex == 0 {
            effects[filterIndex]?.setValue(0.0, forKey: kCIInputIntensityKey)
        } else if filterIndex == 1 {
            effects[filterIndex]?.setValue(0.7, forKey: kCIInputIntensityKey)
        }
        if let outputImage = effects[filterIndex]?.outputImage {
            if let cgImage = filterContext.createCGImage(outputImage, from: outputImage.extent) {
                DispatchQueue.main.async {
                    let image = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
                    imageViewForFilter.image = image
                }
            }
        }
    }
}
// swiftlint:enable line_length

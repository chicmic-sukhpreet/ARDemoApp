//
//  MultipleFaceDetectionViewController.swift
//  ARDemoApp
//
//  Created by Chicmic on 24/08/23.
//

import UIKit
import ARKit
import RealityKit
import CoreImage

enum ChoosedOption {
    case filters
    case effects
}
// swiftlint:disable line_length
class ARDemoViewController: UIViewController {

    @IBOutlet var arView: ARView!
    @IBOutlet var captureButton: UIButton!
    @IBOutlet var collectionViewForFilters: UICollectionView!
    @IBOutlet weak var collectionViewForEffects: UICollectionView!
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet var filterImageView: UIImageView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    let circularView = UIView()
    var imageWithoutEffects: UIImage?
    var effects: [CIFilter?] = [
        CIFilter(name: "CISepiaTone"),
        CIFilter(name: "CISepiaTone"),
        CIFilter(name: "CIPhotoEffectMono")
    ]
    var models: [ARModel] = [
        ARModel(modelName: "Glass",
                // swiftlint:disable force_try
                modelEntity: try! Entity.load(named: "Glass"),
                modelOffset: [0.0, 0.027, 0.054],
                modelScale: [0.01, 0.01, 0.01]),
        ARModel(modelName: "Mustache",
                modelEntity: try! Entity.load(named: "Mustache"),
                modelOffset: [0.0, -0.03, 0.064],
                modelScale: [0.0003, 0.0003, 0.0003]),
        ARModel(modelName: "PlagueMaster",
                modelEntity: try! Entity.load(named: "PlagueMaster"),
                modelOffset: [0.0, -0.01, 0.064],
                modelScale: [0.01, 0.01, 0.01]),
        ARModel(modelName: "VelvetHat",
                modelEntity: try! Entity.load(named: "VelvetHat"),
                modelOffset: [0.0, 0.07, -0.05],
                modelScale: [0.007, 0.007, 0.007]),
        ARModel(modelName: "Glass",
                modelEntity: try! Entity.load(named: "Glass"),
                modelOffset: [0.0, 0.027, 0.054],
                modelScale: [0.01, 0.01, 0.01]),
        ARModel(modelName: "Mustache",
                modelEntity: try! Entity.load(named: "Mustache"),
                modelOffset: [0.0, -0.03, 0.064],
                modelScale: [0.0003, 0.0003, 0.0003]),
        ARModel(modelName: "PlagueMaster",
                modelEntity: try! Entity.load(named: "PlagueMaster"),
                modelOffset: [0.0, -0.01, 0.064],
                modelScale: [0.01, 0.01, 0.01]),
        ARModel(modelName: "VelvetHat",
                modelEntity: try! Entity.load(named: "VelvetHat"),
                modelOffset: [0.0, 0.07, -0.05],
                modelScale: [0.007, 0.007, 0.007]),
        ARModel(modelName: "Glass",
                modelEntity: try! Entity.load(named: "Glass"),
                modelOffset: [0.0, 0.027, 0.054],
                modelScale: [0.01, 0.01, 0.01]),
        ARModel(modelName: "Mustache",
                modelEntity: try! Entity.load(named: "Mustache"),
                modelOffset: [0.0, -0.03, 0.064],
                modelScale: [0.0003, 0.0003, 0.0003]),
        ARModel(modelName: "PlagueMaster",
                modelEntity: try! Entity.load(named: "PlagueMaster"),
                modelOffset: [0.0, -0.01, 0.064],
                modelScale: [0.01, 0.01, 0.01]),
        ARModel(modelName: "VelvetHat",
                modelEntity: try! Entity.load(named: "VelvetHat"),
                modelOffset: [0.0, 0.07, -0.05],
                modelScale: [0.007, 0.007, 0.007])
    ]
    var animatedModelsForTongue: [ARAnimatedModels<AnimationDemo.CupcakeScene>] = [
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadCupcakeScene(), entityName: "cupcake"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadCupcakeScene(), entityName: "cupcake"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadCupcakeScene(), entityName: "cupcake")
    ]
    var animatedModelsForSmile: [ARAnimatedModels<AnimationDemo.SmileGlasses>] = [
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadSmileGlasses(), entityName: "glasses"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadSmileGlasses(), entityName: "glasses"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadSmileGlasses(), entityName: "glasses")
    ]  // swiftlint:enable force_try
    var selectedIndexForFilters = 0
    var selectedIndexPathForFilters: IndexPath?
    var selectedIndexForEffects = 0
    var selectedIndexPathForEffects: IndexPath?
    let maximumNumberOfFaceAnchors: Int = 3
    var option: ChoosedOption = .filters
    var isProcessingFrame: Bool = false
    var filterContext: CIContext?
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.session.delegate = self
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("face tracking is not supported on this device")
        }
        collectionViewForFilters.delegate = self
        collectionViewForFilters.dataSource = self
        collectionViewForEffects.delegate = self
        collectionViewForEffects.dataSource = self
        if option == .filters {
            collectionViewForEffects.isHidden = true
            collectionViewForFilters.isHidden = false
        } else {
            collectionViewForFilters.isHidden = true
            collectionViewForEffects.isHidden = false
        }
        filterImageView.sizeToFit()
        filterImageView.contentMode = .scaleAspectFill
        filterImageView.center = self.view.center
        circularView.backgroundColor = UIColor.white
        circularView.layer.cornerRadius = 39
        circularView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(circularView, belowSubview: captureButton)
        NSLayoutConstraint.activate([
            circularView.widthAnchor.constraint(equalToConstant: 78),
            circularView.heightAnchor.constraint(equalToConstant: 78),
            circularView.centerXAnchor.constraint(equalTo: captureButton.centerXAnchor),
            circularView.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor)
        ])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        arView.scene.anchors.removeAll()
        let config = ARFaceTrackingConfiguration()
        config.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
        arView.session.run(config)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    @IBAction func captureButtonClicked(_ sender: UIButton) {
        captureScreenshot()
    }
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            collectionViewForFilters.isHidden = false
            collectionViewForEffects.isHidden = true
            filterImageView.isHidden = true
            showLabel.isHidden = false
            option = .filters
        case 1:
            collectionViewForFilters.isHidden = true
            collectionViewForEffects.isHidden = false
            filterImageView.isHidden = false
            showLabel.isHidden = true
            option = .effects
        default:
            break
        }
    }
    func captureScreenshot() {
        captureButton.isHidden = true
        collectionViewForFilters.isHidden = true
        collectionViewForEffects.isHidden = true
        showLabel.isHidden = true
        segmentedControl.isHidden = true
        circularView.isHidden = true
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let screenshot = renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        let previewVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as? PreviewViewController
        previewVC?.delegate = self
        previewVC?.capturedImage = screenshot
        if option == .filters {
            previewVC?.originalImageWithoutEffects = screenshot
        } else {
            previewVC?.originalImageWithoutEffects = imageWithoutEffects?.rotate(radians: .pi * 2)
        }
        previewVC?.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(previewVC!, animated: true)
        if option == .filters {
            collectionViewForFilters.isHidden = false
        } else {
            collectionViewForEffects.isHidden = false
        }
        captureButton.isHidden = false
        showLabel.isHidden = false
        segmentedControl.isHidden = false
        circularView.isHidden = false
    }
}

extension ARDemoViewController: PreviewViewControllerDelegate {
    func previewViewControllerDidSaveImage(_ viewController: PreviewViewController) {
        if let image = viewController.previewImage.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        viewController.showSaveAlert()
        self.navigationController?.popViewController(animated: true)
    }

    func previewViewControllerDidDiscardImage(_ viewController: PreviewViewController) {
        viewController.showActionSheet()
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully")
        }
    }
}
// swiftlint:enable line_length

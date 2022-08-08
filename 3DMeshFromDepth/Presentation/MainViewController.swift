//
//  MainViewController.swift
//  3DMeshFromDepth
//
//  Created by Veronika Babii on 16.02.2022.
//

import UIKit
import ARKit
import MetalKit

class MainViewController: UIViewController {
    
    // MARK: - Properties
    
    private let session = ARSession()
    var scanRenderer: ScanRenderer!
    private let mtkView = MTKView()
    private let spinner = UIActivityIndicatorView(style: .large)
    private var saveButton = UIButton(type: .system)
    var coordinator: AppCoordinator?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ARFaceTrackingConfiguration.isSupported {
            self.session.delegate = self
            self.setupMtkView()
            self.setupSaveButton()
            self.setupSpinner()
        } else {
            print("ARFaceTrackingConfiguration is not supported")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ARFaceTrackingConfiguration.isSupported {
            let configuration = ARFaceTrackingConfiguration()
            session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            
            UIApplication.shared.isIdleTimerDisabled = true
        } else {
            print("ARFaceTrackingConfiguration is not supported")
        }
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Methods
    
    func setupSpinner() {
        spinner.color = .white
        spinner.backgroundColor = .clear
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
    }
    
    func setupMtkView() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        
        mtkView.device = device
        mtkView.backgroundColor = UIColor.clear
        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.contentScaleFactor = 1
        mtkView.delegate = self
        self.view.addSubview(mtkView)
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mtkView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        mtkView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mtkView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        scanRenderer = ScanRenderer(session: self.session, metalDevice: device, renderDestination: self.mtkView)
        scanRenderer.drawRectResized(size: view.bounds.size)
    }
    
    func setupSaveButton() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setBackgroundImage(.init(systemName: "tray.and.arrow.down.fill"), for: .normal)
        saveButton.tintColor = .white
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        self.view.addSubview(saveButton)
        saveButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
        saveButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
    }
    
    @objc func saveTapped() {
        print("!! Scan points count:", self.scanRenderer.pointsCount)
        
        self.spinner.startAnimating()
        
        self.scanRenderer.saveToPly() { _ in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.spinner.stopAnimating()
                self.coordinator?.presentDoneAlert(in: self)
            }
        }
    }
}

// MARK: - ARSessionDelegate

extension MainViewController: ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.coordinator?.presentArSessionErrorAlert(in: self, with: self.session, and: error)
        }
    }
}

// MARK: - MTKViewDelegate

extension MainViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.scanRenderer.drawRectResized(size: size)
    }
    
    func draw(in view: MTKView) {
        self.scanRenderer.renderFrame()
    }
}

// MARK: - RenderDestinationProvider

protocol RenderDestinationView {
    var currentRenderPassDescriptor: MTLRenderPassDescriptor? { get }
    var currentDrawable: CAMetalDrawable? { get }
    var colorPixelFormat: MTLPixelFormat { get set }
    var depthStencilPixelFormat: MTLPixelFormat { get set }
    var sampleCount: Int { get set }
}

extension MTKView: RenderDestinationView { }

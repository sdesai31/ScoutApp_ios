//
//  ViewController.swift
//  ProtoConnect
//
//  Created by Krish Iyengar on 3/24/23.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {

    lazy var protoHomeController = {
        let protoHosting = UIHostingController(rootView: ScoutingSubpage())
        protoHosting.view.translatesAutoresizingMaskIntoConstraints = false
        
        return protoHosting
        
    }()
    lazy var protoAuthController = {
        let protoHosting = UIHostingController(rootView: LoginView())
        protoHosting.view.translatesAutoresizingMaskIntoConstraints = false
        
        return protoHosting
        
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        protoMainVC = self
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
        if (ProtoFirebase.retrieveSignedInProtoUser()) {
            showProtoHomeController()
        }
        else {
            showProtoAuthController()
        }
    }
    func removeAllSubViews() {
        protoHomeController.view.removeFromSuperview()
        protoHomeController.removeFromParent()
        protoAuthController.view.removeFromSuperview()
        protoAuthController.removeFromParent()
    }
    
    func showProtoHomeController() {
        
        removeAllSubViews()
        
        addChild(protoHomeController)
        view.addSubview(protoHomeController.view)
        
        protoHomeController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        protoHomeController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        protoHomeController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        protoHomeController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    func showProtoAuthController() {
        
        removeAllSubViews()
        
        addChild(protoAuthController)
        view.addSubview(protoAuthController.view)
        
        protoAuthController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        protoAuthController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        protoAuthController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        protoAuthController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

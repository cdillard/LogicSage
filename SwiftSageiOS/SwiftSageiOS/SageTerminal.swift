//
//  SageTerminal.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/26/23.
//

//import Foundation
//
//import UIKit
//import SwiftUI

//class SageTerminal: UIViewController {
//
//    private var hostingController: UIHostingController<SageTerminal>!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Create the SwiftUI view that contains the WebView and FloatingView
//        let combinedView =  SageTerminal()  // LCManager()
//
//        // Create a UIHostingController to host the SwiftUI view
//        hostingController = UIHostingController(rootView: combinedView)
//
//        // Add the UIHostingController as a child view controller
//        addChild(hostingController)
//
//        // Configure the UIHostingController's view and add it to the view hierarchy
//        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(hostingController.view)
//
//        // Set up constraints to make the hosting controller's view fill the entire parent view
//        NSLayoutConstraint.activate([
//            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
//            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//        ])
//
//        // Complete the addition of the child view controller
//        hostingController.didMove(toParent: self)
//    }
//}

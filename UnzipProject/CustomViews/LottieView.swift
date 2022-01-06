//
//  LottieView.swift
//  UnzipProject
//
//  Created by Antonio Carlos on 06/01/22.
//

import SwiftUI
import Lottie

protocol LottieViewDelegate {
    func animationEnded()
}

struct LottieView: NSViewRepresentable {
    typealias NSViewType = NSView
    
    var filename: String
    var delegate: LottieViewDelegate?
    
    func makeNSView(context: NSViewRepresentableContext<LottieView>) -> NSView {
        let view = NSView(frame: .zero)
        
        let animationView = AnimationView()
        let animation = Animation.named(filename)
        
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 0.5
        animationView.play { success in
            if success {
                delegate?.animationEnded()
            }
        }

        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<LottieView>) {
        
    }
}

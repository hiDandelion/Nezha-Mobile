//
//  WindowExtractor.swift
//  DynamicIslandToast
//
//  Created by Balaji Venkatesh on 04/01/26.
//

import SwiftUI

/// Extracting Main Window to retreive the window scene and create the overlay window for our dynamic island based toasts!
struct WindowExtractor: UIViewRepresentable {
    var result: (UIWindow) -> ()
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            if let window = view.window {
                result(window)
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {  }
}

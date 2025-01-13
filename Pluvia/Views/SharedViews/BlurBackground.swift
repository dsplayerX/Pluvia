//
//  BlurBackground.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2025-01-11.
//

import SwiftUI

/// A view that represents a blurred background of a weather widget.
struct BlurBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        return blurEffectView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
    }
}

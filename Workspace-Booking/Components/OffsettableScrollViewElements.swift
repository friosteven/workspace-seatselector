//
//  OffsettableScrollViewElements.swift
//  Workspace-Booking
//
//  Created by Steven Frio on 1/12/23.
//

import Foundation

class OffsettableScrollViewElements: ObservableObject {
    @Published var xOffset: CGFloat = 0.0
    @Published var yOffset: CGFloat = 0.0
    @Published var width: CGFloat = 0.0
    @Published var height: CGFloat = 0.0
    @Published var currentScale: CGFloat?  = 0.0
}

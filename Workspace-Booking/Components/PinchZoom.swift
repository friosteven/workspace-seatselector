//
//  PinchZoom.swift
//  Workspace-Booking
//
//  Created by Steven Frio on 1/4/23.
//

import SwiftUI
import UIKit
// https://medium.com/@priya_talreja/pinch-zoom-pan-image-and-double-tap-to-zoom-image-in-swiftui-878ca70c539d
struct ImageModifier: ViewModifier {
    var contentSize: CGSize
    var min: CGFloat = 1.0
    var max: CGFloat = 1.5
    @Binding var currentScale: CGFloat
    @Binding var seatModel: SeatModel
    @Binding var onTappedData: SeatModelElement
    @Binding var showSheet: Bool
    
    @State private var verticalOffset: CGFloat = 0.0
    @State private var horizontalOffset: CGFloat = 0.0
    
//    @State private var currentScrollViewHeight: CGFloat = 0.0
//    @State private var currentScrollViewWidth: CGFloat = 0.0
    
    private func tapGesture() {
        print("Double tapped!")
        if currentScale <= min { currentScale = max } else
        if currentScale >= max { currentScale = min } else {
            currentScale = ((max - min) * 0.5 + min) < currentScale ? max : min
        }
    }
    func body(content: Content) -> some View {
        
        ScrollView([.horizontal, .vertical]) {
            
            
            
            content
                .frame(width: contentSize.width * currentScale,
                       height: contentSize.height * currentScale,
                       alignment: .center)
                .modifier(PinchToZoom(minScale: min,
                                      maxScale: max,
                                      scale: $currentScale))
                .overlay(ForEach(seatModel, id: \.id) { data in
                    setSeats(with: data)
                        .highPriorityGesture(TapGesture()
                            .onEnded {
                                print("TapGesture didTapped \(data)")
                                onTappedData = data
                                showSheet.toggle()
                            }
                        )
                    //                                .animation(.easeInOut, value: currentScale)
                })
//                .background(GeometryReader { reader in
//                    Color.clear.onChange(of: currentScale) { _ in
//                        currentScrollViewHeight = reader.size.height
//                        currentScrollViewWidth = reader.size.width
//                    }
//                    Color.clear.onAppear(perform: {
//                        currentScrollViewHeight = reader.size.height
//                        currentScrollViewWidth = reader.size.width
//                    })
//                })
            
        }
        .onTapGesture(count: 2) {
            tapGesture()
        }
        //        .animation(.easeIn, value: currentScale)
    }
    
    func setSeats(with seatModelElement: SeatModelElement) -> some View {
        
        let contentHeight = ((contentSize.height) * currentScale).rounded(.toNearestOrAwayFromZero)
        let contentWidth = (contentSize.width * currentScale).rounded(.toNearestOrAwayFromZero)
        
        let width = ((CGFloat(seatModelElement.width) * contentWidth)).rounded(.toNearestOrAwayFromZero)
        let height = ((CGFloat(seatModelElement.height) * contentHeight)).rounded(.toNearestOrAwayFromZero)
        
        let horizontalPosition = ((CGFloat(seatModelElement.x) * contentWidth)).rounded(.toNearestOrAwayFromZero)
        let verticalPosition = ((CGFloat(seatModelElement.y) * contentHeight)).rounded(.toNearestOrAwayFromZero)
        
        
        
        print("x: \(horizontalPosition), y: \(verticalPosition), width: \(width), height: \(height), svWidth: \(contentWidth)), svHeight: \(contentHeight),  currentScale: \(currentScale) ")
        
        return
        //        Image(getSeatImage(status: seatModelElement.status))
        //            .resizable()
        Rectangle()
            .fill(getSeatColor(status: seatModelElement.status))
            .frame(width: width,
                   height: height)
            .position(x: horizontalPosition,
                      y: verticalPosition).opacity(0.5)
    }
    func getSeatColor(status: Bool) -> Color {
        return status ? .blue : .red
    }
    func getSeatImage(status: Bool) -> String {
        return status ? "seat-unselected" : "seat-selected"
    }
}

class PinchZoomView: UIView {
    let minScale: CGFloat
    let maxScale: CGFloat
    var isPinching: Bool = false
    var scale: CGFloat = 1.0
    let scaleChange: (CGFloat) -> Void
    
    init(minScale: CGFloat,
         maxScale: CGFloat,
         currentScale: CGFloat,
         scaleChange: @escaping (CGFloat) -> Void) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.scale = currentScale
        self.scaleChange = scaleChange
        super.init(frame: .zero)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        pinchGesture.cancelsTouchesInView = false
        addGestureRecognizer(pinchGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func pinch(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            isPinching = true
            
        case .changed, .ended:
            if gesture.scale <= minScale {
                scale = minScale
            } else if gesture.scale >= maxScale {
                scale = maxScale
            } else {
                scale = gesture.scale
            }
            scaleChange(scale)
        case .cancelled, .failed:
            isPinching = false
            scale = 1.0
        default:
            break
        }
    }
}

struct PinchZoom: UIViewRepresentable {
    let minScale: CGFloat
    let maxScale: CGFloat
    @Binding var scale: CGFloat
    @Binding var isPinching: Bool
    
    func makeUIView(context: Context) -> PinchZoomView {
        let pinchZoomView = PinchZoomView(minScale: minScale, maxScale: maxScale, currentScale: scale, scaleChange: { scale = $0 })
        return pinchZoomView
    }
    
    func updateUIView(_ pageControl: PinchZoomView, context: Context) { }
}

struct PinchToZoom: ViewModifier {
    let minScale: CGFloat
    let maxScale: CGFloat
    @Binding var scale: CGFloat
    @State var anchor: UnitPoint = .center
    @State var isPinching: Bool = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor: anchor)
            .animation(.spring(), value: isPinching)
            .overlay(PinchZoom(minScale: minScale, maxScale: maxScale, scale: $scale, isPinching: $isPinching))
    }
}

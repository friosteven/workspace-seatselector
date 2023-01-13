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
    private var contentSize: CGSize
    private var min: CGFloat = 1.0
    private var max: CGFloat = 3.0
    @State var currentScale: CGFloat = 1.0
    
    @State var yOffset: CGFloat = 0.0
    @State var xOffset: CGFloat = 0.0
//    var scrollViewOnAppear: ((_ offsettableScrollViewElements: StateObject<OffsettableScrollViewElements>) -> ())
//    var scrollViewOnChange: ((_ offsettableScrollViewElements: StateObject<OffsettableScrollViewElements>) -> ())
    
    @ObservedObject var offsettable: OffsettableScrollViewElements
    
    var scrollViewOnAppear: (() -> ())?
    var scrollViewOnChange: (() -> ())?
    
    init(contentSize: CGSize,
         offsettable: OffsettableScrollViewElements,
         scrollViewOnAppear: (() -> ())?,
         scrollViewOnChange: (() -> ())?) {
        self.contentSize = contentSize
        self.offsettable = offsettable
        self.scrollViewOnAppear = scrollViewOnAppear
        self.scrollViewOnChange = scrollViewOnChange
    }
    
    var doubleTapGesture: some Gesture {
        TapGesture(count: 2).onEnded {
            if currentScale <= min { currentScale = max } else
            if currentScale >= max { currentScale = min } else {
                currentScale = ((max - min) * 0.5 + min) < currentScale ? max : min
            }
        }
    }
    func body(content: Content) -> some View {
        GeometryReader { geo in
            OffsettableScrollView { point in
                yOffset = point.y
                xOffset = point.x
                
                setOffsettableElementsValue(geo)
                scrollViewOnChange?()
            } content: {
                content
                    .frame(width: contentSize.width * currentScale, height: contentSize.height * currentScale, alignment: .center)
                    .modifier(PinchToZoom(minScale: min, maxScale: max, scale: $currentScale))
            }.onAppear {
                setOffsettableElementsValue(geo)
                scrollViewOnAppear?()
            }
            .gesture(doubleTapGesture)
            .animation(.easeInOut, value: currentScale)
        }
    }
    private func setOffsettableElementsValue(_ geo: GeometryProxy) {
        offsettable.xOffset = xOffset
        offsettable.yOffset = yOffset
        offsettable.width = geo.size.width
        offsettable.height = geo.size.height
        offsettable.currentScale = currentScale
    }
}

extension View {
    func pinchZoom(geometryProxy: GeometryProxy,
                   offsettable: OffsettableScrollViewElements,
                   scrollViewOnAppear: (() -> ())?,
                   scrollViewOnChange: (() -> ())?) -> some View {
        
        let mod = ImageModifier(contentSize: CGSize(width: geometryProxy.size.width,
                                                    height: geometryProxy.size.height), offsettable: offsettable,
                                scrollViewOnAppear: {
            scrollViewOnAppear?()
        },
                                scrollViewOnChange: {
            scrollViewOnChange?()
        })
        return modifier(mod)
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

//
//  ContentView.swift
//  Workspace-Booking
//
//  Created by Steven Frio on 12/19/22.
//

import SwiftUI
import UIKit

struct ContentView: View {
    
    @State private var seatModel: SeatModel = .init()
    @State private var seatModelElement: SeatModelElement?
    @State private var showSheet = false
    @State var onTappedData: SeatModelElement
    @State private var contentSize = CGSize.zero
    @State private var min: CGFloat = 1.0
    @State private var max: CGFloat = 1.5
    @State private var currentScale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            
            GeometryReader { proxy in
                ZStack {
                    
                    Image("img_seat_view")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Rectangle())
                        .overlay(
                            GeometryReader { geo in
                                Color.clear.onAppear {
                                    contentSize = geo.size
                                    
                                }
                            }
                        )
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .sheet(isPresented: $showSheet, content: {
                    VStack {
                        Text("Seat ID: \(onTappedData.seatID )")
                        Text("Seat No: \(onTappedData.seatNo )")
                        Text("Seat Status: \(onTappedData.status ? "Available" : "Not available" )")
                    }
                    .presentationDetents([.fraction(0.2)])
                })
                .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width, height: proxy.size.height), currentScale: $currentScale, seatModel: $seatModel, onTappedData: $onTappedData, showSheet: $showSheet))
            }
            ZoomOutButton()
                .onAppear{
                    setupSeats()
                    print("count \(seatModel.count)")
                    print("getSeatModel \(seatModel)")
                }
        }
    }
}

extension ContentView {
    private func ZoomOutButton() -> Button<Text> {
        return Button(action: {
            currentScale = 1
        }, label: {
            Text("Zoom Out")
        })
    }
}

//struct SeatView: View {
//    var width = 0
//    var height = 0
//    var posX = 0
//    var posY = 0
//    // Here, there is one boolTest for each element
//    @State private var boolTest = false
//    let text: String
//
//    var body: some View {
//                Text(text)
//                    .font(.system(size: 70))
//                    .foregroundColor(boolTest ? .red : .green)
//                    .onTapGesture {
//                        boolTest.toggle()
//                    }
//    }
//}

extension ContentView {
    func getSeatModel() -> SeatModel {
        let data = JSONHelper.load(resource: "SeatJSON", response: SeatModel.self)
        var seatModel = SeatModel()
        data?.forEach {
            let seatID = $0.seatID
            let seatNo = $0.seatNo
            let status = $0.status
            let posX = $0.x
            let posY = $0.y
            
            let width = $0.width
            let height = $0.height
            let seatModelElement = SeatModelElement(seatID: seatID,
                                                    seatNo: seatNo,
                                                    status: status,
                                                    width: width,
                                                    height: height,
                                                    x: posX,
                                                    y: posY)
            
            seatModel.append(seatModelElement)
        }
        return seatModel
    }
    func setupSeats() {
        seatModel = getSeatModel()
        seatModel.forEach {
            let seatID = $0.seatID
            let seatNo = $0.seatNo
            let status = $0.status
            let posX = $0.x
            let posY = $0.y
            
            let width = $0.width
            let height = $0.height
            
            seatModelElement = SeatModelElement(seatID: seatID,
                                                    seatNo: seatNo,
                                                    status: status,
                                                    width: width,
                                                    height: height,
                                                    x: posX,
                                                    y: posY)
        }
    }
}

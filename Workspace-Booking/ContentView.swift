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
    @State private var onTappedData: SeatModelElement?
    
    @State private var scale: CGFloat = 1
    
   
    
    var body: some View {
        VStack {
            
            GeometryReader { proxy in
                ZStack {
                    
                    Image("floorplan")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Rectangle())
                    
                    ForEach(seatModel, id: \.id) { data in
                        setSeats(with: data).onTapGesture {
                            print("didTapped \(data)")
                            onTappedData = data
                            showSheet.toggle()
                        }
                        .sheet(isPresented: $showSheet, content: {
                            VStack {
                                Text("Seat ID: \(onTappedData?.seatID ?? "")")
                                Text("Seat No: \(onTappedData?.seatNo ?? 0)")
                                Text("Seat Status: \(onTappedData?.status.description ?? "false")")
                            }
                            .presentationDetents([.fraction(0.2)])
                        })
                        
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width, height: proxy.size.height)))
                .onTapGesture {
                    print("didTap @\($0)")
                    print("width: \(proxy.size.width), height: \(proxy.size.height)")
                    
                }
                          
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
extension ContentView {
    private func ZoomOutButton() -> Button<Text> {
        return Button(action: {
            print("did tapped zoom out \(scale)")
            scale = 1
        }, label: {
            Text("Zoom Out")
        })
    }
    
    func setSeats(with seatModelElement: SeatModelElement) -> some View {
        
        let width = CGFloat(seatModelElement.dimensions.width)
        let height = CGFloat(seatModelElement.dimensions.height)
        
        return Image(getSeatImage(status: seatModelElement.status))
            .resizable()
            .frame(width: width,
                   height: height)
            .position(x: seatModelElement.location.posX,
                      y: seatModelElement.location.posY)
    }
    func getSeatImage(status: Bool) -> String {
        return status ? "seat-unselected" : "seat-selected"
    }
}
extension ContentView {
    func getSeatModel() -> SeatModel {
        let data = JSONHelper.load(resource: "SeatJSON", response: SeatModel.self)
        var seatModel = SeatModel()
        data?.forEach {
            let seatID = $0.seatID
            let seatNo = $0.seatNo
            let status = $0.status
            let location = $0.location
            let posX = location.posX
            let posY = location.posY
            let dimension = $0.dimensions
            let width = dimension.width
            let height = dimension.height
            let seatModelElement = SeatModelElement(seatID: seatID,
                                                    seatNo: seatNo,
                                                    status: status,
                                                    location: Location.init(posX: posX,
                                                                            posY: posY),
                                                    dimensions: Dimensions.init(width: width, height: height))
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
            let location = $0.location
            let posX = location.posX
            let posY = location.posY
            let dimensions = $0.dimensions
            let height = dimensions.height
            let width = dimensions.width
            
            seatModelElement = SeatModelElement(seatID: seatID,
                                                seatNo: seatNo,
                                                status: status,
                                                location: Location.init(posX: posX,
                                                                        posY: posY),
                                                dimensions: Dimensions.init(width: width, height: height))
        }
    }
}

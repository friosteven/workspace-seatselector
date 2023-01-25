//
//  Workspace_BookingApp.swift
//  Workspace-Booking
//
//  Created by Steven Frio on 12/19/22.
//

import SwiftUI

@main
struct Workspace_BookingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(onTappedData: SeatModelElement.init(seatID: "", seatNo: 0, status: false, width: 0, height: 0, x: 0, y: 0))
        }
        
    }
}

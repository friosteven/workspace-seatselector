//
//  SeatModel.swift
//  Workspace-Booking
//
//  Created by Steven Frio on 12/19/22.
//

import Foundation

// MARK: - SeatModelElement
struct SeatModelElement: Codable, Hashable {
    let id = UUID()
    let seatID: String
    let seatNo: Int
    let status: Bool
    let width, height, x,y: Float

    enum CodingKeys: String, CodingKey {
        case seatID = "seat_id"
        case seatNo = "seat_no"
        case status, width, height, x, y
    }
}

typealias SeatModel = [SeatModelElement]

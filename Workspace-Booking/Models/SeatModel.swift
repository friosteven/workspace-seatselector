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
    let location: Location
    let dimensions: Dimensions

    enum CodingKeys: String, CodingKey {
        case seatID = "seat_id"
        case seatNo = "seat_no"
        case status, location, dimensions
    }
}

// MARK: - Dimensions
struct Dimensions: Codable, Hashable {
    let width, height: Int
}

// MARK: - Location
struct Location: Codable, Hashable {
    let posX, posY: Double
}

typealias SeatModel = [SeatModelElement]

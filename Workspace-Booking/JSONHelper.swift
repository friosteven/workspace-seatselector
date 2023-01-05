//
//  JSONHelper.swift
//  Workspace-Booking
//
//  Created by Steven Frio on 12/20/22.
//

import Foundation

class JSONHelper {
    static func load<C: Codable>(resource: String, response: C.Type = C.self) -> C? {
        if let filePath = Bundle.main.url(forResource: resource, withExtension: "json") {
            do {
                let data = try Data(contentsOf: filePath)
                let decoder = JSONDecoder()
                let sample = try decoder.decode(response, from: data)

                print(sample)
                return sample
            } catch {
                print("Can not load JSON file.")
            }
        }

        return nil
    }
    
}
//extension Decodable {
//  static func parse(jsonFile: String) -> Self? {
//    guard let url = Bundle.main.url(forResource: jsonFile, withExtension: "json"),
//          let data = try? Data(contentsOf: url),
//          let output = try? JSONDecoder().decode(self, from: data)
//        else {
//      return nil
//    }
//
//    return output
//  }
//}

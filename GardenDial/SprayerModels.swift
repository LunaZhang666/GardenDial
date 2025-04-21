//
//  SprayerModels.swift
//  GardenDial
//
//  Created by Luna Zhang on 4/13/25.
//

import Foundation

struct Sprayer: Identifiable, Codable {
    let id: UUID
    let name: String
    let dialOptions: [String: Double] // [label: concentration]
    let volumeOptions: [Double] // Unit: oz
}

let dialNSpray = Sprayer(
    id: UUID(),
    name: "Ortho Dial N Spray",
    // concentration is by perGallon, calculated by oz/oz
    dialOptions: [
        "8 OZ": 8.0 / 128.0,
        "6 OZ": 6.0 / 128.0,
        "5 1/3 OZ": (16.0 / 3.0) / 128.0,
        "4 OZ": 4.0 / 128.0,
        "3 OZ": 3.0 / 128.0,
        "2 1/2 OZ": 2.5 / 128.0,
        "2 OZ": 2.0 / 128.0,
        "1 1/2 OZ": 1.5 / 128.0,
        "1 OZ": 1.0 / 128.0,
        "4 TSP": (2.0 / 3.0) / 128.0,
        "1 TBS": (1.0 / 2.0) / 128.0,
        "2 TSP": (1.0 / 3.0) / 128.0,
        "1 1/2 TSP": (1.0 / 4.0) / 128.0,
        "1 TSP": (1.0 / 6.0) / 128.0
    ],
    volumeOptions:  Array(stride(from: 32.0, through: 4.0, by: -2.0))
)

let allSprayers: [String: Sprayer] = [
    "Ortho Dial N Spray": dialNSpray
]

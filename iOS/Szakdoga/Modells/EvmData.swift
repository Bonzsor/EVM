//
//  EvmData.swift
//  Szakdoga
//
//  Created by Szabó Zsombor on 2020. 11. 25..
//  Copyright © 2020. Szabo Zsombor. All rights reserved.
//

import Foundation

import Foundation

struct EvmData: Codable, Identifiable {
    let id: String
    let situation: String
    let data: [[Double]]
}

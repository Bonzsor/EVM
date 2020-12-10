//
//  EvmViewModel.swift
//  Szakdoga
//
//  Created by Szabó Zsombor on 2020. 11. 25..
//  Copyright © 2020. Szabo Zsombor. All rights reserved.
//

import Foundation

final class EvmViewModel: ObservableObject {
    @Published var trained: Bool = false
    @Published var positiveId: Int = 0
    @Published var negativeId: Int = 0
    @Published var distanceId: Int = 0
    @Published var isPresented: Bool = false
    
    var presentedText: [String] = []
    var evm: EVM? = nil
    
     let evmData: [EvmData]
    
    init() {
        let file = K.dataPath
        
        guard let path = Bundle.main.path(forResource: file, ofType: "json") else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        let url = URL(fileURLWithPath: path)

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()

        guard let loaded = try? decoder.decode([EvmData].self, from: data) else {
            fatalError("Failed to decode \(file) from bundle.")
        }

        self.evmData = loaded
    }
    
    func trainEvm() {
        self.evm = EVM(positives: evmData[positiveId].data, negatives: evmData[negativeId].data, distanceType: K.distanceTypes[distanceId])
        evm!.train(printLog: true)
        trained = true
    }
    
    func predictEvm() {
        if self.evm != nil {
            presentedText = evm!.predict(sample: evmData[negativeId].data[0]).compactMap{String($0)}
        }
        self.isPresented = true
    }
}


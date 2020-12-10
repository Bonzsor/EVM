//
//  ContentView.swift
//  Szakdoga
//
//  Created by Szabó Zsombor on 2020. 09. 24..
//  Copyright © 2020. Szabo Zsombor. All rights reserved.
//

import SwiftUI


struct ContentView: View {
    
    @StateObject var viewModel = EvmViewModel()
    
    var body: some View {
        NavigationView(){
            GeometryReader { geometry in
                VStack{
                    Text(K.title).padding()
                    HStack() {
                        VStack() {
                            Text(K.positiveSamples)
                            Picker(selection: $viewModel.positiveId, label: Text(K.positiveSamples)) {
                                ForEach(0 ..< viewModel.evmData.count) {
                                            Text(viewModel.evmData[$0].situation + " - " + viewModel.evmData[$0].id)
                                        }
                            }.frame(maxWidth: geometry.size.width / 2)
                            .clipped()
                        }
                        VStack() {
                            Text(K.negativeSamples)
                            Picker(selection: $viewModel.negativeId, label: Text(K.negativeSamples)) {
                                ForEach(0 ..< viewModel.evmData.count) {
                                            Text(viewModel.evmData[$0].situation + " - " + viewModel.evmData[$0].id)
                                        }
                            }.frame(maxWidth: geometry.size.width / 2)
                            .clipped()
                        }
                    }
                    
                    HStack() {
                        Picker(selection: $viewModel.distanceId, label: Text("distance")) {
                            ForEach(0 ..< K.distanceTypes.count) {
                                Text(K.distanceTypes[$0])
                                    }
                        }.frame(maxWidth: geometry.size.width * 2 / 3)
                        .clipped()
                        Button(action:{
                            viewModel.trainEvm()
                        }){
                            Text(K.trainButton)
                        }
                    }
                    Spacer()
                    Button(action:{
                        viewModel.predictEvm()
                    }){
                        Text(K.predictButton)
                    }.disabled(!viewModel.trained)
                    Spacer()
                }
            }.navigationBarHidden(true)
            .sheet(isPresented: $viewModel.isPresented, content:{
                ForEach(0 ..< viewModel.presentedText.count){
                    Text(viewModel.presentedText[$0])
                }
            })
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

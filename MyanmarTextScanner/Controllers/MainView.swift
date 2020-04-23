//
//  ContentView.swift
//  MyanmarTextScanner
//
//  Created by Aung Ko Min on 17/4/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject var service = MainService()
    
    var body: some View {
        
        ZStack{
            
            MetalViewContainer(service: service)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                HStack{
                    ForEach(DetectorType.allCases, id: \.self) { detectorType in
                        Button(action: {
                            DetectorType.current = detectorType
                            self.service.objectWillChange.send()
                        }) {
                            
                            if detectorType == DetectorType.current {
                                Text(detectorType.description).underline()
                            } else {
                                Text(detectorType.description)
                            }
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    VStack(spacing: 15) {
                        ForEach(FilterType.allCases, id: \.self) { filter in
                            Button(action: {
                                self.service.updateFilter(filter)
                            }) {
                                Text(filter.description)
                            }
                        }
                    }
                    .font(.subheadline)
                }
                
                Spacer()
                HStack {
                    Button(action: {
                        self.service.track()
                    }) {
                        Text("Bottom Bar")
                    }
                }
            }
            .padding()
        }
        .foregroundColor(.white)
        .statusBar(hidden: true)
        .onAppear {
            self.service.start()
        }
    }
}

struct MetalViewContainer: UIViewRepresentable {
    
    let service: MainService
    
    func makeUIView(context: Context) -> CustomMetalView {
        return service.metalView
    }
    
    func updateUIView(_ uiView: CustomMetalView, context: Context) {}
    
}

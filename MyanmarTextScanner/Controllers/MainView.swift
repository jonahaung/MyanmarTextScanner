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
            
            VStack {
                HStack{
                    Spacer()
                    Text(service.videoService.fps.description)
                }
                Spacer()
            }
            .padding()
            .foregroundColor(.white)
        }
            .edgesIgnoringSafeArea(.all)
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

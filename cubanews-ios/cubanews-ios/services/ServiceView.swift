//
//  ServiceView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 20/12/2025.
//

import SwiftUI

@available(iOS 17, *)
struct ServiceView: View {
    let service: Service
    var body: some View {
        Text("Servicio: \(service.description)")            
    }
    
}

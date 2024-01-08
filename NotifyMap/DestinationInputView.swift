//
//  DestinationInputView.swift
//  NotifyMap
//
//  Created by Mehrdad Behrouz Ahmadian on 2024-01-08.
//

import SwiftUI

struct DestinationInputView: View {
    @Binding var destination: String
    @FocusState private var isFocused: Bool
    var onSetDestination: () -> Void
    
    var body: some View {
        VStack {
            TextField("Search for a location", text: $destination)
                .font(.subheadline)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .focused($isFocused)
            
            Button("Set Destination") {
                onSetDestination()
                isFocused = false
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

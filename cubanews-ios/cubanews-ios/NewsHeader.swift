//
//  HighlightedNewsHeader.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 07/12/2025.
//

import SwiftUI

public struct NewsHeader: View {
    var header: String
    var showDate: Bool = false
    let todayLocalFormatted = Date().formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "es_ES"))).capitalized(with: Locale(identifier: "es_ES"))
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Image("cubanewsIdentity")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text(header)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            if (showDate) {
                Label(todayLocalFormatted, systemImage: "calendar")
                    .labelStyle(.titleOnly)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

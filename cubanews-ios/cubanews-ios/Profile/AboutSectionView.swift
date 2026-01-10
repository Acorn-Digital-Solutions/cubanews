//
//  AboutSectionView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 10/01/2026.
//
import SwiftUI

struct AboutSectionView: View {
    
    // Inline linked privacy text
    private var privacyAttributedText: AttributedString {
        var text = AttributedString("Cubanews no comparte informacion de sus usuarios con terceros. Consulta nuestra política de privacidad para más detalles.")
        // Base color for non-link text
        text.foregroundColor = .gray
        if let range = text.range(of: "política de privacidad"),
           let url = URL(string: "https://www.freeprivacypolicy.com/live/38c1b534-4ac4-4b6d-8c68-71f89805459f") {
            text[range].link = url
            text[range].foregroundColor = .blue
            // Optional underline to indicate interactivity
            text[range].underlineStyle = .single
        }
        return text
    }
    
    private var misionAttributedText: AttributedString {
        var text = AttributedString("La mision de CubaNews es amplificar el mensaje de la prensa independiente cubana . Ver más en nuestra web cubanews.icu")
        // Base color for non-link text
        text.foregroundColor = .gray
        if let range = text.range(of: "cubanews.icu"),
           let url = URL(string: "https://www.cubanews.icu/about") {
            text[range].link = url
            text[range].foregroundColor = .blue
            // Optional underline to indicate interactivity
            text[range].underlineStyle = .single
        }
        return text
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Acerca de CubaNews")
                .font(.headline)
                .padding(.horizontal)
            
            // Privacy Section
            Text(misionAttributedText)
                .font(.subheadline)
                .padding(.horizontal)
            
            // Inline link for "política de privacidad"
            Text(privacyAttributedText)
                .font(.subheadline)
                .padding(.horizontal)
        }
    }
}

#Preview {
    AboutSectionView()
}


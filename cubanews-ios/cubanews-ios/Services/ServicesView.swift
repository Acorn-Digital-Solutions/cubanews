//
//  ServicesView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 26/12/2025.
//
import SwiftUI

@available(iOS 17, *)
struct ServicesView: View {
    @ObservedObject private var viewModel = ServicesViewModel.shared
    @State private var showMyServices: Bool = false
    @State private var isEditing: Bool = false
    
    @ViewBuilder
    private var topToggleBar: some View {
        HStack {
            Toggle(isOn: $showMyServices) {
                HStack(spacing: 8) {
                    Text("Mis servicios")
                        .font(.headline)
                    if viewModel.myServices.count > 0 {
                        Text("\(viewModel.myServices.count)")
                            .font(.caption2)
                            .padding(.vertical, 3)
                            .padding(.horizontal, 6)
                            .background(Capsule().fill(Color.blue.opacity(0.12)))
                            .foregroundColor(.blue)
                    }
                }
            }
            .toggleStyle(CapsuleCheckboxToggleStyle())
            .onChange(of: showMyServices) {}
            Spacer()
        }
        .padding(.horizontal)
    }
    @ViewBuilder
    private var publicServicesSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.services) { service in
                ServiceView(service: service)
                    .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var myServicesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.myServices) { service in
                    ServiceView(
                        service: service,
                    )
                    .padding(.horizontal)
                    .onAppear {
                        if service == viewModel.myServices.last {
                            Task { await viewModel.loadMyServices() }
                        }
                    }
                }

                if viewModel.myServices.isEmpty {
                    VStack(spacing: 12) {
                        Button(action: {
                        }) {
                            Label("Crear servicio", systemImage: "plus")
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 12) {
                        topToggleBar
                        if (showMyServices) {
                            myServicesSection
                        } else {
                            publicServicesSection
                        }
                    }
                    .padding(.vertical, 12)
                }
                if (showMyServices) {
                    //                    floatingAddButton
                }
            }
            .sheet(isPresented: $isEditing, onDismiss: { /* nothing */ }) {
            }
        }
    }
}

struct CapsuleCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation { configuration.isOn.toggle() }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundColor(configuration.isOn ? .green : .gray)
                configuration.label
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                Capsule()
                    .fill(configuration.isOn ? Color.green.opacity(0.12) : Color(UIColor.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }
}


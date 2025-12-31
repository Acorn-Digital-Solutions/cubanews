//
//  ServicesView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 26/12/2025.
//
import SwiftUI
import SwiftData

@available(iOS 17, *)
struct ServicesView: View {
    @ObservedObject private var viewModel: ServicesViewModel
    @Query private var preferences: [UserPreferences]
    @State private var searchText: String = ""
    
    init(useMockViewModel: Bool = false) {
        if (useMockViewModel) {
            self.viewModel = MockServicesViewModel()
        } else {
            self.viewModel = ServicesViewModel()
        }
    }
    
    @ViewBuilder
    private var searchBar: some View {
        HStack(spacing: 12) {
            TextField("Buscar servicios...", text: $searchText)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
                .onChange(of: searchText) { newValue in
                    if newValue.isEmpty {
                        viewModel.performSearch("")
                    }
                }
            
            Button {
                viewModel.performSearch(searchText)
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var topToggleBar: some View {
        HStack {
            Toggle(isOn: $viewModel.showMyServices) {
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
            .onChange(of: viewModel.showMyServices) {
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    @ViewBuilder
    private var publicServicesSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.filteredServices) { service in
                ServiceView(service: service, viewModel: viewModel)
                    .padding(.horizontal)
                    .onAppear {
                        if service == viewModel.services.last {
                            Task { await viewModel.loadServices()  }
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    private var myServicesSection: some View {
        LazyVStack(spacing: 8) {
            ForEach(viewModel.myServices) { service in
                ServiceView(
                    service: service,
                    viewModel: viewModel
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
                        viewModel.editMode.toggle()
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
    }
    
    private var floatingAddButton: some View {
        Button {
            viewModel.editMode.toggle()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
        }
        .padding(.trailing, 18)
        .padding(.bottom, 34)
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 12) {
                        NewsHeader(header: "Servicios")
                        searchBar
                        if preferences.first?.advertiseServices == true {
                            topToggleBar
                        }
                        if (viewModel.showMyServices) {
                            myServicesSection
                        } else {
                            publicServicesSection
                        }
                    }
                    .padding(.vertical, 12)
                }
                if (viewModel.showMyServices && preferences.first?.advertiseServices == true) {
                    floatingAddButton
                }
            }
            .sheet(isPresented: $viewModel.editMode, onDismiss: { /* nothing */ }) {
                ServiceEditSheet(
                    service: $viewModel.selectedService,
                    onSave: {
                        updated in viewModel.saveService(updated: updated)
                    },
                    onCancel: {
                        viewModel.cancelEdit()
                    }
                )
            }
        }
    }
}

struct ServiceEditSheet: View {
    @Binding var service: Service
    var onSave: (Service) -> Void
    var onCancel: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    init(service: Binding<Service>, onSave: @escaping (Service) -> Void, onCancel: @escaping () -> Void) {
        self._service = service
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section() {
                    TextField("Nombre del negocio", text: $service.businessName)
                    TextField("Descripción", text: $service.description)
                    DatePicker("Fecha de expiración", selection: Binding(get: {
                        Date(timeIntervalSince1970: service.expirationDate == 0 ? Date().addingTimeInterval(30*24*60*60).timeIntervalSince1970 : service.expirationDate)
                    }, set: { newDate in
                        service.expirationDate = newDate.timeIntervalSince1970
                    }), displayedComponents: .date)
                    .datePickerStyle(.compact)
                }.padding(.top, 8)
                
                Section(header: Text("Información de contacto")) {
                    TextField("Número de teléfono", text: $service.contactInfo.phoneNumber)
                    TextField("Email", text: $service.contactInfo.emailAddress)
                    TextField("Web", text: $service.contactInfo.websiteURL)
                    TextField("Instagram", text: $service.contactInfo.instagram)
                    TextField("Facebook", text: $service.contactInfo.facebook)
                }
                
                Section(header: Text("Ubicacion")) {
                    TextField("Ubicación", text: $service.contactInfo.location)
                }
                HStack(spacing: 16) {
                    Button("Guardar") {
                        onSave(service)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    
                    Button("Cancelar") {
                        onCancel()
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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

#Preview {
    if #available(iOS 17, *) {
        ServicesView(useMockViewModel: true)
    }
}


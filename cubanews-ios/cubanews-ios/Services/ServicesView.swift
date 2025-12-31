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
            TextField("Buscar servicios...", text: $viewModel.searchText)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
                .onSubmit {
                    viewModel.performSearch()
                }.onChange(of: viewModel.searchText) { newValue in
                    if newValue.isEmpty {
                        viewModel.performSearch()
                    }
                }
            
            Button {
                viewModel.performSearch()
                // Dismiss keyboard
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
        }.onAppear() {
            Task {
                await viewModel.loadServices()
                await viewModel.loadMyServices()
            }
        }
    }
}

struct ServiceDetailSheet: View {
    @Binding var service: Service
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Business Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text(service.businessName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if service.status != .approved {
                            HStack {
                                Circle()
                                    .fill(statusColor(for: service.status))
                                    .frame(width: 8, height: 8)
                                Text(service.status.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descripción")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(service.description)
                            .font(.body)
                    }
                    
                    // Contact Information
                    if hasContactInfo() {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Información de Contacto")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 12) {
                                if !service.contactInfo.phoneNumber.isEmpty {
                                    ContactRow(
                                        icon: "phone.fill",
                                        label: "Teléfono",
                                        value: service.contactInfo.phoneNumber,
                                        action: {
                                            dial(number: service.contactInfo.phoneNumber)
                                        }
                                    )
                                }
                                
                                if !service.contactInfo.emailAddress.isEmpty {
                                    ContactRow(
                                        icon: "envelope.fill",
                                        label: "Email",
                                        value: service.contactInfo.emailAddress,
                                        action: {
                                            if let url = URL(string: "mailto:\(service.contactInfo.emailAddress)") {
                                                openURL(url)
                                            }
                                        }
                                    )
                                }
                                
                                if !service.contactInfo.websiteURL.isEmpty {
                                    ContactRow(
                                        icon: "globe",
                                        label: "Sitio Web",
                                        value: service.contactInfo.websiteURL,
                                        action: {
                                            if let url = URL(string: service.contactInfo.websiteURL) {
                                                openURL(url)
                                            }
                                        }
                                    )
                                }
                                
                                if !service.contactInfo.instagram.isEmpty {
                                    ContactRow(
                                        icon: "camera.fill",
                                        label: "Instagram",
                                        value: service.contactInfo.instagram,
                                        action: {
                                            if let url = URL(string: service.contactInfo.instagram) {
                                                openURL(url)
                                            }
                                        }
                                    )
                                }
                                
                                if !service.contactInfo.facebook.isEmpty {
                                    ContactRow(
                                        icon: "f.circle.fill",
                                        label: "Facebook",
                                        value: service.contactInfo.facebook,
                                        action: {
                                            if let url = URL(string: service.contactInfo.facebook) {
                                                openURL(url)
                                            }
                                        }
                                    )
                                }
                                
                                if !service.contactInfo.location.isEmpty {
                                    ContactRow(
                                        icon: "mappin.circle.fill",
                                        label: "Ubicación",
                                        value: service.contactInfo.location,
                                        action: nil
                                    )
                                }
                            }
                        }
                    }
                    
                    // Expiration Date
                    if service.expirationDate > 0 {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fecha de Expiración")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(Date(timeIntervalSince1970: service.expirationDate), style: .date)
                                .font(.body)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    private func hasContactInfo() -> Bool {
        return !service.contactInfo.phoneNumber.isEmpty ||
               !service.contactInfo.emailAddress.isEmpty ||
               !service.contactInfo.websiteURL.isEmpty ||
               !service.contactInfo.instagram.isEmpty ||
               !service.contactInfo.facebook.isEmpty ||
               !service.contactInfo.location.isEmpty
    }
    
    private func statusColor(for status: ServiceStatus) -> Color {
        switch status {
        case .approved:
            return .green
        case .inReview:
            return .orange
        case .rejected:
            return .red
        case .expired:
            return .gray
        }
    }
    
    private func dial(number: String) {
        let cleanNumber = number.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(cleanNumber)") {
            openURL(url)
        }
    }
}

struct ContactRow: View {
    let icon: String
    let label: String
    let value: String
    let action: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let action = action {
                    Button(action: action) {
                        Text(value)
                            .font(.body)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.leading)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(value)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
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


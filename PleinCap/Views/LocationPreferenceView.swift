import SwiftUI
import CoreLocation

struct LocationItem: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var coordinates: CLLocationCoordinate2D
    var distance: Double
    var isSelected: Bool = true

    static func == (lhs: LocationItem, rhs: LocationItem) -> Bool {
        lhs.id == rhs.id
    }
}

struct LocationPreferenceView: View {
    // ✅ Use the new VM everywhere in the app
    @EnvironmentObject var authVM: AuthViewModel1

    // UI state
    @State private var selectedFrance: Bool = false
    @State private var customLocations: [LocationItem] = []
    @State private var editingLocation: LocationItem? = nil
    @State private var showLocationPicker = false

    @State private var progress: Double
    @State private var goToGrades = false
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorText: String = ""

    init(initialProgress: Double = 0.3) {
        _progress = State(initialValue: initialProgress)
    }

    var body: some View {
        VStack(spacing: 24) {
            ProgressBarView(progress: $progress)

            ImageWithHeaderView(
                imageName: "location-img",
                title: "Localisation",
                subtitle: "Quelle est ta localisation préférée ?",
                description: "(vous pouvez choisir plusieurs localisations)"
            )

            // MARK: Choices
            VStack(spacing: 16) {
                RadioBoxView(
                    isSelected: selectedFrance,
                    label: "Partout en France",
                    subLabel: nil
                ) {
                    selectedFrance.toggle()
                    if selectedFrance {
                        // Deselect all customs if "France" is chosen
                        customLocations = customLocations.map { var l = $0; l.isSelected = false; return l }
                    }
                }

                ForEach($customLocations) { $loc in
                    RadioBoxView(
                        isSelected: loc.isSelected,
                        label: loc.title,
                        subLabel: "\(Int(loc.distance)) Km",
                        trailingIcon: "square.and.pencil"
                    ) {
                        loc.isSelected.toggle()
                        if loc.isSelected {
                            selectedFrance = false
                            if selectedCount == 1 { progress = min(progress + 0.1, 1.0) }
                        } else if selectedCount == 0 {
                            progress = max(progress - 0.1, 0.3)
                        }
                    } onEdit: {
                        editingLocation = loc
                        showLocationPicker = true
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            withAnimation {
                                if loc.isSelected { progress = max(progress - 0.1, 0.3) }
                                customLocations.removeAll { $0.id == loc.id }
                            }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
                }

                Button {
                    editingLocation = nil
                    showLocationPicker = true
                } label: {
                    Text("Ajouter une Localisation")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "#17C1C1"), lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)

            Spacer()

            // MARK: Save
            PrimaryGradientButton(
                title: isSaving ? "Enregistrement…" : "Suivant",
                enabled: (selectedFrance || selectedCount > 0) && !isSaving
            ) {
                Task { await saveAndProceed() }
            }
            .padding(.horizontal)

            NavigationLink(
                destination: NotesIntroView(progress: $progress),   // ✅ now goes to NotesIntro
                isActive: $goToGrades
            ) { EmptyView() }
            .hidden()
        }
        .sheet(isPresented: $showLocationPicker) {
            LocalisationView { title, coord, distance in
                if let editing = editingLocation,
                   let index = customLocations.firstIndex(of: editing) {
                    customLocations[index] = LocationItem(
                        title: title,
                        coordinates: coord,
                        distance: distance,
                        isSelected: true
                    )
                } else {
                    let newLoc = LocationItem(title: title, coordinates: coord, distance: distance)
                    if !customLocations.contains(where: { $0.title == newLoc.title }) {
                        customLocations.append(newLoc)
                        selectedFrance = false
                        progress = min(progress + 0.1, 1.0)
                    }
                }
                showLocationPicker = false
            }
            .environmentObject(LocationManager())
        }
        .alert("Erreur", isPresented: $showError, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(errorText)
        })
    }

    // MARK: - Helpers

    private var selectedCount: Int {
        customLocations.filter { $0.isSelected }.count
    }

    /// Build the payload the API expects and persist via /me (PATCH).
    private func saveAndProceed() async {
        isSaving = true
        defer { isSaving = false }

        // Choose data source
        let address: String
        let distance: Double
        let latitude: Double
        let longitude: Double

        if selectedFrance {
            address = "Partout en France"
            distance = 0.0
            latitude = 0.0
            longitude = 0.0
        } else if let first = customLocations.first(where: { $0.isSelected }) {
            address = first.title
            distance = first.distance
            latitude = first.coordinates.latitude
            longitude = first.coordinates.longitude
        } else {
            errorText = "Sélectionne une localisation ou « Partout en France »."
            showError = true
            return
        }

        let payload: [String: Any] = [
            "adresse": address,
            "distance": distance,
            "latitude": latitude,
            "longitude": longitude
        ]

        // Persist with the new VM
        await withCheckedContinuation { cont in
            authVM.updateUserFields(payload) { result in
                switch result {
                case .success:
                    withAnimation {
                        progress = max(progress, 0.95)
                        goToGrades = true
                    }
                    cont.resume()
                case .failure(let err):
                    errorText = "Échec de la mise à jour : \(err.localizedDescription)"
                    showError = true
                    cont.resume()
                }
            }
        }
    }
}

#Preview {
    // Simple preview with a fake VM so the view compiles and runs
    LocationPreferenceView(initialProgress: 0.2)
        .environmentObject(AuthViewModel1())
}

//
//  LocationPreferenceView.swift
//  PFE_APP
//
//  Created by chaabani achref on 24/6/2025.
//
// LocationPreferenceView_MultiSelectable.swift
import SwiftUI
import CoreLocation

struct LocationItem: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var coordinates: CLLocationCoordinate2D
    var distance: Double
    var isSelected: Bool = true

    static func == (lhs: LocationItem, rhs: LocationItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.coordinates.latitude == rhs.coordinates.latitude &&
        lhs.coordinates.longitude == rhs.coordinates.longitude &&
        lhs.distance == rhs.distance &&
        lhs.isSelected == rhs.isSelected
    }
}

struct LocationPreferenceView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedFrance: Bool = false
    @State private var customLocations: [LocationItem] = []
    @State private var editingLocation: LocationItem? = nil
    @State private var showLocationPicker = false
    @State private var progress: Double
    @State private var goToGrades = false

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

            VStack(spacing: 16) {
                RadioBoxView(
                    isSelected: selectedFrance,
                    label: "Partout en France",
                    subLabel: nil
                ) {
                    selectedFrance.toggle()
                    if selectedFrance {
                        customLocations = customLocations.map {
                            var loc = $0
                            loc.isSelected = false
                            return loc
                        }
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
                            if customLocations.filter(\.isSelected).count == 1 {
                                progress = min(progress + 0.1, 1.0)
                            }
                        } else if customLocations.filter(\.isSelected).isEmpty {
                            progress = max(progress - 0.1, 0.3)
                        }
                    } onEdit: {
                        editingLocation = loc
                        showLocationPicker = true
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            withAnimation {
                                if loc.isSelected {
                                    progress = max(progress - 0.1, 0.3)
                                }
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

            // ✅ Nouveau bouton "Suivant" avec updateLocationField
            PrimaryGradientButton(title: "Suivant") {
                if selectedFrance {
                    print("✅ Partout en France sélectionné")
                    let fields: [String: Any] = [
                        "adresse": "Partout en France",
                        "latitude": 0.0,
                        "longitude": 0.0,
                        "distance": 0.0
                    ]
                    authVM.updateLocationField(fields) {
                        goToGrades = true
                    }
                } else {
                    let selected = customLocations.filter(\.isSelected)
                    if let loc = selected.first {
                        let fields: [String: Any] = [
                            "adresse": loc.title,
                            "latitude": loc.coordinates.latitude,
                            "longitude": loc.coordinates.longitude,
                            "distance": loc.distance
                        ]
                        authVM.updateLocationField(fields) {
                            goToGrades = true
                        }
                    }
                }
            }
            .padding(.horizontal)

            NavigationLink(
                destination: SchoolGradeEntryView(progress: $progress),
                isActive: $goToGrades
            ) {
                EmptyView()
            }
            .hidden()
            .padding(.horizontal)
        }
        .sheet(isPresented: $showLocationPicker) {
            LocalisationView { title, coord, distance in
                if let editing = editingLocation,
                   let index = customLocations.firstIndex(of: editing) {
                    customLocations[index] = LocationItem(title: title, coordinates: coord, distance: distance, isSelected: true)
                } else {
                    let newLoc = LocationItem(title: title, coordinates: coord, distance: distance)
                    customLocations.append(newLoc)
                    selectedFrance = false
                    progress = min(progress + 0.1, 1.0)
                }
                showLocationPicker = false
            }
            .environmentObject(LocationManager())
        }
    }
}

#Preview {
    LocationPreferenceView(initialProgress: 0.2)
}

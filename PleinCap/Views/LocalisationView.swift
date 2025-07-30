import SwiftUI
import MapKit
import CoreLocation

struct PlaceLocation: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

struct LocalisationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var locationManager: LocationManager
    var onLocationSelected: (String, CLLocationCoordinate2D, Double) -> Void

    @State private var searchText: String = ""
    @State private var distance: Double = 50
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.8065, longitude: 10.1815),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedPlace = PlaceLocation(coordinate: CLLocationCoordinate2D(latitude: 36.8065, longitude: 10.1815))
    @State private var locationTitle = "Chargement…"
    let geocoder = CLGeocoder()
    let maxDistance = 100.0

    var body: some View {
        VStack(spacing: 20) {
            Text("Localisation")
                .font(.title2.bold())
                .foregroundColor(Color(hex: "#2C4364"))

            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Rechercher une adresse", text: $searchText, onCommit: performSearch)
                    .textInputAutocapitalization(.never)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
            .padding(.horizontal)

            ZStack(alignment: .topTrailing) {
                Map(coordinateRegion: $region, interactionModes: [.all], showsUserLocation: true, annotationItems: [selectedPlace]) { place in
                    MapAnnotation(coordinate: place.coordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.red)
                    }
                }
                .gesture(
                    LongPressGesture(minimumDuration: 0.4).onEnded { _ in
                        selectedPlace.coordinate = region.center
                        updateLocationTitle(for: region.center)
                    }
                )
                .overlay(
                    GeometryReader { geo in
                        let size = geo.size
                        let radiusPixels = CGFloat(distance / maxDistance) * min(size.width, size.height)
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: radiusPixels, height: radiusPixels)
                            .overlay(Circle().stroke(Color.orange.opacity(0.5), lineWidth: 2))
                            .position(x: size.width / 2, y: size.height / 2)
                    }
                )
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)

                if locationManager.isAuthorized {
                    Button {
                        if let userLoc = locationManager.userLocation {
                            region.center = userLoc.coordinate
                            selectedPlace.coordinate = userLoc.coordinate
                            updateLocationTitle(for: userLoc.coordinate)
                        }
                    } label: {
                        Image(systemName: "location.fill")
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding(10)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.orange)
                        .frame(width: 4, height: 24)
                    Text(locationTitle)
                        .font(.headline)
                    Spacer()
                    Text("\(Int(distance)) Km")
                        .foregroundColor(.gray)
                }

                Text("Rayon de recherche")
                    .font(.headline)
                Text("Ajustez la distance souhaitée")
                    .foregroundColor(.gray)
                    .font(.subheadline)

                DistanceSliderView(distance: $distance, maxDistance: maxDistance)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 5)
            .padding(.horizontal)

            Spacer()

            Button {
                    onLocationSelected(locationTitle, selectedPlace.coordinate, distance)
                dismiss() // ← ferme la feuille après ajout

                } label: {
                    Text("Appliquer")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#17C1C1"))
                        .cornerRadius(40)
                }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .onAppear {
            if let loc = locationManager.userLocation {
                region.center = loc.coordinate
                selectedPlace.coordinate = loc.coordinate
                updateLocationTitle(for: loc.coordinate)
            }
        }
    }

    private func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        MKLocalSearch(request: request).start { response, _ in
            guard let coord = response?.mapItems.first?.placemark.coordinate else { return }
            selectedPlace.coordinate = coord
            region.center = coord
            updateLocationTitle(for: coord)
        }
    }

    private func updateLocationTitle(for coordinate: CLLocationCoordinate2D) {
        let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(loc) { placemarks, _ in
            if let place = placemarks?.first {
                let city = place.locality ?? place.administrativeArea ?? "Ville"
                let country = place.country ?? "Pays"
                locationTitle = "\(city), \(country)"
            } else {
                locationTitle = "Localisation inconnue"
            }
        }
    }
}
#Preview {
    LocalisationView(onLocationSelected: { title, coordinate, distance in
        print("Prévisualisation : \(title), \(coordinate.latitude), \(coordinate.longitude), \(distance) km")
    })
    .environmentObject(LocationManager()) // 🔥 important ici aussi
}

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

    /// Send data back to LocationPreferenceView
    var onLocationSelected: (String, CLLocationCoordinate2D, Double) -> Void

    // MARK: - State
    @State private var searchText: String = ""
    @State private var distance: Double = 50          // km
    @State private var isGeocoding = false

    // France center (roughly)
    private let franceCenter = CLLocationCoordinate2D(latitude: 46.6, longitude: 2.4)

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 46.6, longitude: 2.4),
        span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0)
    )

    @State private var selectedPlace = PlaceLocation(
        coordinate: CLLocationCoordinate2D(latitude: 46.6, longitude: 2.4)
    )

    @State private var locationTitle = "France"
    private let geocoder = CLGeocoder()
    private let maxDistance = 100.0 // km

    var body: some View {
        VStack(spacing: 20) {
            Text("Localisation")
                .font(.title2.bold())
                .foregroundColor(Color(hex: "#2C4364"))

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Rechercher une adresse", text: $searchText, onCommit: performSearch)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
            .padding(.horizontal)

            // Map + overlay controls
            ZStack(alignment: .topTrailing) {
                Map(
                    coordinateRegion: $region,
                    interactionModes: [.all],
                    showsUserLocation: locationManager.isAuthorized,
                    annotationItems: [selectedPlace]
                ) { place in
                    MapAnnotation(coordinate: place.coordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .resizable().frame(width: 30, height: 30)
                            .foregroundColor(.red)
                            .shadow(radius: 2)
                    }
                }
                // long press to drop the pin at the map center
                .gesture(
                    LongPressGesture(minimumDuration: 0.35).onEnded { _ in
                        selectedPlace.coordinate = region.center
                        updateLocationTitle(for: region.center)
                        zoomIfNeeded()
                    }
                )
                // simple “radius” visualization
                .overlay(
                    GeometryReader { geo in
                        let size = geo.size
                        // not to scale; just a visual cue proportional to maxDistance
                        let r = CGFloat(distance / maxDistance) * min(size.width, size.height)
                        Circle()
                            .fill(Color.orange.opacity(0.18))
                            .frame(width: r, height: r)
                            .overlay(Circle().stroke(Color.orange.opacity(0.45), lineWidth: 2))
                            .position(x: size.width / 2, y: size.height / 2)
                    }
                )
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)

                VStack(spacing: 10) {
                    // My location
                    Button {
                        centerOnUser()
                    } label: {
                        Image(systemName: "location.fill")
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }

                    // Reset to France
                    Button {
                        withAnimation {
                            region = MKCoordinateRegion(
                                center: franceCenter,
                                span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0)
                            )
                            selectedPlace.coordinate = franceCenter
                            locationTitle = "France"
                        }
                    } label: {
                        Image(systemName: "globe.europe.africa.fill")
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding(10)
            }

            // Info + slider
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.orange)
                        .frame(width: 4, height: 24)
                    HStack(spacing: 8) {
                        Text(locationTitle)
                            .font(.headline)
                        if isGeocoding {
                            ProgressView().scaleEffect(0.8)
                        }
                    }
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

            // Apply
            Button {
                onLocationSelected(locationTitle, selectedPlace.coordinate, distance)
                dismiss()
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
            // Ask for permission / start updates if needed
            locationManager.requestAuthorizationIfNeeded()

            if let loc = locationManager.userLocation, locationManager.isAuthorized {
                region = MKCoordinateRegion(
                    center: loc.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
                )
                selectedPlace.coordinate = loc.coordinate
                updateLocationTitle(for: loc.coordinate)
            } else {
                // stays centered on France until we get a fix
                region = MKCoordinateRegion(
                    center: franceCenter,
                    span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0)
                )
                selectedPlace.coordinate = franceCenter
                locationTitle = "France"
            }
        }
    }

    // MARK: - Actions

    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let item = response?.mapItems.first else { return }
            let coord = item.placemark.coordinate
            selectedPlace.coordinate = coord
            region = MKCoordinateRegion(center: coord,
                                        span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
            updateLocationTitle(for: coord)
        }
    }

    private func centerOnUser() {
        if !locationManager.isAuthorized {
            locationManager.requestAuthorizationIfNeeded()
        }
        if let user = locationManager.userLocation {
            withAnimation {
                region = MKCoordinateRegion(
                    center: user.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.35, longitudeDelta: 0.35)
                )
                selectedPlace.coordinate = user.coordinate
            }
            updateLocationTitle(for: user.coordinate)
        }
    }

    private func zoomIfNeeded() {
        // When dropping a pin from a wide France view, zoom to city level
        if region.span.latitudeDelta > 2.0 || region.span.longitudeDelta > 2.0 {
            withAnimation {
                region.span = MKCoordinateSpan(latitudeDelta: 0.6, longitudeDelta: 0.6)
            }
        }
    }

    private func updateLocationTitle(for coordinate: CLLocationCoordinate2D) {
        isGeocoding = true
        geocoder.cancelGeocode()
        let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(loc) { placemarks, _ in
            defer { isGeocoding = false }
            if let place = placemarks?.first {
                let city = place.locality ?? place.administrativeArea ?? place.subAdministrativeArea
                let country = place.country
                if let city = city, let country = country {
                    locationTitle = "\(city), \(country)"
                } else if let country = country {
                    locationTitle = country
                } else {
                    locationTitle = "Localisation inconnue"
                }
            } else {
                locationTitle = "Localisation inconnue"
            }
        }
    }
}

#Preview {
    LocalisationView(onLocationSelected: { title, coordinate, distance in
        print("Preview: \(title) | \(coordinate.latitude), \(coordinate.longitude) | \(distance)km")
    })
    // Provide your app's LocationManager here.
    .environmentObject(LocationManager())
}

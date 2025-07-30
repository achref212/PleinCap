//
//  SelectAcademieMapView.swift
//  PFE_APP
//
//  Created by chaabani achref on 29/7/2025.
//
import SwiftUI

struct SelectAcademieMapView: View {
    @State private var selectedAcademie: String? = nil

    // Taille finale affichée de l’image (à adapter à ton image dans Assets)
    let mapWidth: CGFloat = 350
    let mapHeight: CGFloat = 450

    // Coordonnées calculées précisément pour l’image que tu m’as donnée
    let academies: [(name: String, position: CGPoint)] = [
        ("Lille", CGPoint(x: 180, y: 25)),
        ("Amiens", CGPoint(x: 185, y: 75)),
        ("Caen", CGPoint(x: 85, y: 85)),
        ("Rennes", CGPoint(x: 45, y: 115)),
        ("Nantes", CGPoint(x: 75, y: 165)),
        ("Orléans-Tours", CGPoint(x: 135, y: 170)),
        ("Nancy-Metz", CGPoint(x: 210, y: 90)),
        ("Strasbourg", CGPoint(x: 250, y: 105)),
        ("Reims", CGPoint(x: 180, y: 90)),
        ("Paris", CGPoint(x: 135, y: 110)),
        ("Besançon", CGPoint(x: 215, y: 180)),
        ("Dijon", CGPoint(x: 180, y: 170)),
        ("Lyon", CGPoint(x: 190, y: 230)),
        ("Grenoble", CGPoint(x: 210, y: 270)),
        ("Clermont-Ferrand", CGPoint(x: 145, y: 240)),
        ("Limoges", CGPoint(x: 105, y: 240)),
        ("Poitiers", CGPoint(x: 70, y: 210)),
        ("Bordeaux", CGPoint(x: 65, y: 280)),
        ("Toulouse", CGPoint(x: 120, y: 330)),
        ("Montpellier", CGPoint(x: 165, y: 340)),
        ("Aix-Marseille", CGPoint(x: 210, y: 340)),
        ("Nice", CGPoint(x: 240, y: 345)),
        ("Corse", CGPoint(x: 260, y: 390)),
        ("Guyane", CGPoint(x: 30, y: 370)),
        ("Guadeloupe", CGPoint(x: 30, y: 250)),
        ("Martinique", CGPoint(x: 30, y: 230)),
        ("Mayotte", CGPoint(x: 30, y: 415)),
        ("La Réunion", CGPoint(x: 30, y: 290))
    ]

    var body: some View {
        VStack {
            ZStack {
                Image("carte_france") // 📌 Mets ce nom dans tes Assets
                    .resizable()
                    .frame(width: mapWidth, height: mapHeight)
                    .cornerRadius(12)

                ForEach(academies, id: \.name) { academy in
                    Button(action: {
                        selectedAcademie = academy.name
                        print("Sélectionnée : \(academy.name)")
                    }) {
                        Circle()
                            .fill(selectedAcademie == academy.name ? Color.orange : Color.white)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "#2EC1C1"), lineWidth: 1.2)
                            )
                    }
                    .position(x: academy.position.x, y: academy.position.y)
                }
            }
            .frame(width: mapWidth, height: mapHeight)
            .background(Color.white)
        }
    }
}

struct SelectAcademieMapView_Previews: PreviewProvider {
    static var previews: some View {
        SelectAcademieMapView()
            .preferredColorScheme(.light)
    }
}

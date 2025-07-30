//
//  SchoolGradeEntryView.swift
//  PFE_APP
//
//  Created by chaabani achref on 10/7/2025.
//

import SwiftUI

struct SchoolGradeEntryView: View {
    @Binding var progress: Double
    @State private var spec1 = ""
    @State private var spec2 = ""
    @State private var spec3 = ""
    @State private var goNext = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ProgressBarView(progress: $progress)
                    .padding(.top)

                ImageWithCaptionView(imageName: "grade", caption: "Notes et résultats scolaires")

                VStack(alignment: .leading, spacing: 8) {
                    Text("On t’aide à y voir plus clair !")
                        .font(dynamicTypeSize.isAccessibilitySize ? .title3.bold() : .title3.bold())
                        .foregroundColor(Color(hex: "#2C4364"))

                    Text("Pas de stress — ces infos servent uniquement à estimer tes chances, pas à te bloquer dans tes choix.")
                        .font(dynamicTypeSize.isAccessibilitySize ? .body : .subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                VStack(spacing: 16) {
                    HStack(alignment: .top, spacing: 8) {
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 4)
                            .cornerRadius(2)

                        Text("Ta moyenne en Première")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#2C4364"))

                        Spacer()
                    }

                    VerticalLabeledTextField(label: "Moyenne Spécialité 1", text: $spec1, placeholder: "Moyenne")
                    VerticalLabeledTextField(label: "Moyenne Spécialité 2", text: $spec2, placeholder: "Moyenne")
                    VerticalLabeledTextField(label: "Moyenne Spécialité 3", text: $spec3, placeholder: "Moyenne")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                .padding(.horizontal)

                Button(action: {
                    goNext = true
                }) {
                    Text("Suivant")
                        .font(dynamicTypeSize.isAccessibilitySize ? .title3 : .headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(20)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                NavigationLink("", destination: Text("Étape suivante"), isActive: $goNext)
                    .hidden()
            }
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Notes & Moyennes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SchoolGradeEntryView_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var progress: Double = 0.3

        var body: some View {
            NavigationStack {
                SchoolGradeEntryView(progress: $progress)
            }
        }
    }

    static var previews: some View {
        Group {
            Wrapper().preferredColorScheme(.light)
            Wrapper().preferredColorScheme(.dark)
                .environment(\.dynamicTypeSize, .accessibility3)
        }
    }
}

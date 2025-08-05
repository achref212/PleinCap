//
//  FormationDetailsView.swift
//  PleinCap
//
//  Created by chaabani achref on 5/8/2025.
//

import SwiftUI

struct FormationDetailsView: View {
    let formation: Formation

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image et tags
                ZStack(alignment: .topTrailing) {
                    Image(formation.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width:300,height: 220)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(20)

                    VStack(alignment: .trailing, spacing: 10) {
                        HStack(spacing: 8) {
                            TagView(text: formation.location)
                            TagView(text: formation.price)
                            TagView(text: formation.duration)
                        }

                        HStack(spacing: 8) {
                            TagView(text: "contrôlée par l’État")
                            TagView(text: formation.isPublic ? "Public" : "Privé")
                        }
                    }
                    .padding()
                }

                VStack(alignment: .leading, spacing: 16) {
                    TitleWithSideLineView(
                        title: formation.title,
                        subtitle: formation.university
                    )

                    Text(formation.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                // Section : Informations Générales
                VStack(alignment: .leading, spacing: 16) {
                    Text("Informations Générales")
                        .font(.title3.bold())
                        .foregroundColor(.accentColor)

                    CardView {
                        TitleWithSideLineView(title: "Durées & Niveau", subtitle: "")

                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: "Durée formation", value: "3 ans")
                            InfoRow(title: "Durée totale du cursus", value: "5 ans (Licence + Master)")
                        }
                    }

                    CardView {
                        TitleWithSideLineView(title: "Programme & Débouchés", subtitle: "")

                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: "Résumé du programme", value: "Introduction aux bases du domaine + spécialisation progressive")
                            InfoRow(title: "Débouchés pro", value: "Métiers dans X secteur")
                            InfoRow(title: "Débouchés études", value: "Master, écoles spécialisées")
                            InfoRow(title: "Débouchés domaines / secteurs", value: "Santé, numérique, social")
                        }
                    }
                }
                .padding(.horizontal)

                // Section : Informations personnalisées
                VStack(alignment: .leading, spacing: 16) {
                    Text("Informations Personnalisées")
                        .font(.title3.bold())
                        .foregroundColor(.accentColor)

                    CardView {
                        TitleWithSideLineView(title: "Organisation pédagogique", subtitle: "")

                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: "Taille des groupes", value: "Classe (~30 étudiants)")
                            InfoRow(title: "Degré d'autonomie", value: "Moyen")
                            InfoRow(title: "Manuel / Intellect", value: "Mixte")
                            InfoRow(title: "Théorique", value: "60%")
                            InfoRow(title: "Pratique", value: "40%")
                            InfoRow(title: "Charge de travail", value: "Moyenne (20h de cours + 10h perso)")
                        }
                    }

                    CardView {
                        TitleWithSideLineView(title: "Parcours & accompagnement", subtitle: "")

                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: "Stage ou immersion pro", value: "Obligatoire en 2e année")
                            InfoRow(title: "Formation en apprentissage", value: "Possible dès la 2e année")
                            InfoRow(title: "Type de formation", value: "Professionnalisante")
                            InfoRow(title: "Liberté de choix", value: "Électifs dès la 2e année")
                        }
                    }

                    CardView {
                        TitleWithSideLineView(title: "Ouverture & compatibilité", subtitle: "")

                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: "Ouverture internationale", value: "Partenariats Erasmus disponibles")
                            InfoRow(title: "Caractéristiques RIASEC", value: "I, A, S")
                            InfoRow(title: "Taux d’insertion pro", value: "78% à 6 mois")
                            InfoRow(title: "Correspondance géographique", value: "Ville dans la zone souhaitée")
                        }
                    }
                }
                .padding(.horizontal)

                // Bouton ONISEP
                Button(action: {
                    print("Voir sur ONISEP")
                }) {
                    Text("Voir sur ONISEP")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.accentColor, lineWidth: 2)
                        )
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
// MARK: - Formation Preview

#Preview {
    FormationDetailsView(formation: Formation(
        title: "Licence en Droit",
        university: "Université Paris 1 Panthéon-Sorbonne",
        description: "Formation pluridisciplinaire intégrant droit, économie et relations internationales.",
        location: "Paris, France",
        price: "Gratuite",
        duration: "3 ans",
        isPublic: true,
        domain: "Droit",
        imageName: "Etablissement_France1"
    ))
}

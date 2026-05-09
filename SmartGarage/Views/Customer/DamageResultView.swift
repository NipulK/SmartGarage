import SwiftUI

struct DamageResultView: View {

    
    var damageType: String = "Front Bumper Damage"
    var severity: String = "High"
    var confidence: String = "98%"
    var estimatedCost: String = "$450 - $600"
    var vehicleName: String = "Porsche 911"

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 22) {

                Text("Assessment Report")
                    .font(.caption)
                    .foregroundColor(.blue)

                Text("AI Analysis Complete")
                    .font(.title)
                    .fontWeight(.bold)

                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 220)
                    .overlay(
                        VStack(spacing: 12) {

                            Image(systemName: "car.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.gray)

                            Text(vehicleName)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                    )

                VStack(alignment: .leading, spacing: 18) {

                    HStack {

                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.blue)

                        VStack(alignment: .leading) {

                            Text("AI Analysis Result")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text(severity == "High"
                                 ? "Immediate Repair Recommended"
                                 : "Repair Recommended")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(
                                    severity == "High"
                                    ? .red
                                    : .orange
                                )
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {

                        Label("Damage Detected", systemImage: "info.circle")
                            .foregroundColor(.blue)

                        Text(damageDescription())
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.08))
                    .cornerRadius(14)

                    HStack {

                        Text("Estimated Repair Cost")
                            .fontWeight(.semibold)

                        Spacer()

                        Text(estimatedCost)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.08))
                    .cornerRadius(14)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)

                HStack {

                    ResultBox(
                        title: "Confidence",
                        value: confidence
                    )

                    ResultBox(
                        title: "Severity",
                        value: severity
                    )
                }

                VStack(alignment: .leading, spacing: 14) {

                    Text("AI Summary")
                        .font(.headline)

                    summaryRow(
                        icon: "checkmark.circle.fill",
                        title: "Damage Type",
                        value: damageType
                    )

                    summaryRow(
                        icon: "gauge.medium",
                        title: "Severity",
                        value: severity
                    )

                    summaryRow(
                        icon: "dollarsign.circle.fill",
                        title: "Estimated Cost",
                        value: estimatedCost
                    )
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)

                Button {

                    print("Book repair")

                } label: {

                    Text("Book This Repair Now")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }

                Button {

                    print("Save later")

                } label: {

                    Text("Save for Later")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(14)
                }
            }
            .padding()
        }
        .navigationTitle("Damage Result")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    func damageDescription() -> String {

        switch damageType {

        case "Body Dent":
            return "Surface dent detected on the body panel. Metal deformation identified."

        case "Paint Scratch":
            return "Paint layer scratches detected. Cosmetic repair recommended."

        case "Headlight Damage":
            return "Front lighting unit damage detected. Replacement may be required."

        case "Front Bumper Damage":
            return "Front bumper impact damage detected with structural deformation."

        case "Windshield Crack":
            return "Windshield crack detected. Visibility and safety may be affected."

        default:
            return "Vehicle damage detected by AI analysis."
        }
    }

    @ViewBuilder
    func summaryRow(
        icon: String,
        title: String,
        value: String
    ) -> some View {

        HStack {

            Image(systemName: icon)
                .foregroundColor(.blue)

            Text(title)

            Spacer()

            Text(value)
                .fontWeight(.bold)
        }
    }
}

struct ResultBox: View {

    let title: String
    let value: String

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {

            Text(title.uppercased())
                .font(.caption2)
                .foregroundColor(.gray)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            ProgressView(
                value: title == "Confidence"
                ? 0.96
                : 0.8
            )
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
    }
}

#Preview {

    NavigationStack {

        DamageResultView(
            damageType: "Front Bumper Damage",
            severity: "High",
            confidence: "98%",
            estimatedCost: "$450 - $600",
            vehicleName: "Toyota Yaris"
        )
    }
}

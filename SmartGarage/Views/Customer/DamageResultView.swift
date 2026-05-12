import SwiftUI

struct DamageResultView: View {

    @Binding var selectedTab: Int
    @Environment(\.dismiss) private var dismiss

    var damageType: String = "Front Bumper Damage"
    var severity: String = "High"
    var confidence: String = "98%"
    var estimatedCost: String = "$450 - $600"
    var vehicleName: String = "Porsche 911"
    var selectedImage: UIImage? = nil

    @State private var showSavedAlert = false

    init(
        selectedTab: Binding<Int> = .constant(2),
        damageType: String = "Front Bumper Damage",
        severity: String = "High",
        confidence: String = "98%",
        estimatedCost: String = "$450 - $600",
        vehicleName: String = "Porsche 911",
        selectedImage: UIImage? = nil
    ) {
        self._selectedTab = selectedTab
        self.damageType = damageType
        self.severity = severity
        self.confidence = confidence
        self.estimatedCost = estimatedCost
        self.vehicleName = vehicleName
        self.selectedImage = selectedImage
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                let contentWidth = max(proxy.size.width - 32, 0)
                let resultBoxWidth = max((contentWidth - 12) / 2, 0)

                VStack(alignment: .leading, spacing: 22) {

                    Text("Assessment Report")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .frame(width: contentWidth, alignment: .leading)

                    Text("AI Analysis Complete")
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .frame(width: contentWidth, alignment: .leading)

                    damageImageSection(width: contentWidth)

                    analysisResultSection(width: contentWidth)

                    HStack(spacing: 12) {
                        ResultBox(title: "Confidence", value: confidence, width: resultBoxWidth)
                        ResultBox(title: "Severity", value: severity, width: resultBoxWidth)
                    }
                    .frame(width: contentWidth)

                    summarySection(width: contentWidth)

                    NavigationLink {
                        CustomerBookingView(
                            selectedTab: $selectedTab,
                            preselectedService: "Damage Repair - \(damageType)"
                        )
                    } label: {
                        Text("Book This Repair Now")
                            .fontWeight(.bold)
                            .frame(width: contentWidth)
                            .padding(.vertical)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }

                    Button {
                        showSavedAlert = true
                    } label: {
                        Text("Save for Later")
                            .fontWeight(.semibold)
                            .frame(width: contentWidth)
                            .padding(.vertical)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(14)
                    }
                }
                .padding()
                .frame(width: proxy.size.width, alignment: .leading)
            }
        }
        .navigationTitle("Damage Result")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .alert("Saved for Later", isPresented: $showSavedAlert) {
            Button("View Activity") {
                selectedTab = 3
            }

            Button("OK", role: .cancel) {
                selectedTab = 0
            }
        } message: {
            Text("Your damage report has been saved. You can view it in the Activity page.")
        }
    }

    private func damageImageSection(width: CGFloat) -> some View {
        let imageHeight: CGFloat = 220

        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.gray.opacity(0.25))

            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: imageHeight)
                    .clipped()
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.gray)

                    Text(vehicleName)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
            }
        }
        .frame(width: width, height: imageHeight)
        .cornerRadius(18)
        .clipped()
    }

    private func analysisResultSection(width: CGFloat) -> some View {
        let cardPadding: CGFloat = 16
        let innerWidth = max(width - (cardPadding * 2), 0)

        return VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Analysis Result")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(severity == "High" ? "Immediate Repair Recommended" : "Repair Recommended")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(severity == "High" ? .red : .orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: innerWidth, alignment: .leading)

            VStack(alignment: .leading, spacing: 8) {
                Label("Damage Detected", systemImage: "info.circle")
                    .foregroundColor(.blue)

                Text(damageDescription())
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(width: innerWidth, alignment: .leading)
            .background(Color.gray.opacity(0.08))
            .cornerRadius(14)

            VStack(alignment: .leading, spacing: 8) {
                Text("Estimated Repair Cost")
                    .fontWeight(.semibold)

                Text(estimatedCost)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .padding()
            .frame(width: innerWidth, alignment: .leading)
            .background(Color.blue.opacity(0.08))
            .cornerRadius(14)
        }
        .padding(cardPadding)
        .frame(width: width, alignment: .leading)
        .background(Color.white)
        .cornerRadius(20)
        .clipped()
    }

    private func summarySection(width: CGFloat) -> some View {
        let cardPadding: CGFloat = 16

        return VStack(alignment: .leading, spacing: 14) {
            Text("AI Summary")
                .font(.headline)

            summaryRow(icon: "checkmark.circle.fill", title: "Damage Type", value: damageType)
            summaryRow(icon: "gauge.medium", title: "Severity", value: severity)
            summaryRow(icon: "dollarsign.circle.fill", title: "Estimated Cost", value: estimatedCost)
        }
        .padding(cardPadding)
        .frame(width: width, alignment: .leading)
        .background(Color.white)
        .cornerRadius(20)
        .clipped()
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
    func summaryRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.blue)

            Text(title)
                .foregroundColor(.black)

            Spacer(minLength: 8)

            Text(value)
                .fontWeight(.bold)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct ResultBox: View {

    let title: String
    let value: String
    let width: CGFloat

    var progressValue: Double {
        if title == "Confidence" {
            let number = value.replacingOccurrences(of: "%", with: "")
            return (Double(number) ?? 0) / 100
        }

        switch value.lowercased() {
        case "high":
            return 1.0
        case "medium":
            return 0.65
        case "low":
            return 0.35
        default:
            return 0.5
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            ProgressView(value: progressValue)
        }
        .padding()
        .frame(width: width, height: 120, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .clipped()
    }
}

#Preview {
    NavigationStack {
        DamageResultView(
            selectedTab: .constant(2),
            damageType: "Front Bumper Damage",
            severity: "High",
            confidence: "98%",
            estimatedCost: "$450 - $600",
            vehicleName: "Toyota Yaris",
            selectedImage: nil
        )
    }
}

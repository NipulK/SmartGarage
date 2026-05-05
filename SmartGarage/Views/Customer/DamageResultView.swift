import SwiftUI

struct DamageResultView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                Text("Assessment Report")
                    .font(.caption)
                    .foregroundColor(.blue)

                Text("Analysis Complete")
                    .font(.title)
                    .fontWeight(.bold)

                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 220)
                    .overlay(
                        Image(systemName: "car.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.gray)
                    )

                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.blue)

                        VStack(alignment: .leading) {
                            Text("AI Analysis Result")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text("Repair Recommended")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Damage Detected", systemImage: "info.circle")
                            .foregroundColor(.blue)

                        Text("Structural damage detected in front bumper. Impact has compromised the lower chassis mounting points.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.08))
                    .cornerRadius(14)

                    HStack {
                        Text("Estimated Cost")
                            .fontWeight(.semibold)

                        Spacer()

                        Text("$450 - $600")
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
                    ResultBox(title: "Confidence", value: "98%")
                    ResultBox(title: "Severity", value: "High ⚠️")
                }

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
                .font(.title2)
                .fontWeight(.bold)

            ProgressView(value: title == "Confidence" ? 0.98 : 0.8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
    }
}

#Preview {
    DamageResultView()
}

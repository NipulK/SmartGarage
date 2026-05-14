import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.18),
                        Color(.systemBackground),
                        Color(.systemGroupedBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer(minLength: 80)

                    VStack(spacing: 18) {
                        AppLogoMark(size: 156, cornerRadius: 36, padding: 6)
                            .shadow(color: .blue.opacity(0.18), radius: 18, y: 10)

                        VStack(spacing: 10) {
                            Text("SmartGarage")
                                .font(.system(size: 42, weight: .bold))
                                .minimumScaleFactor(0.75)
                                .lineLimit(1)

                            Text("Elevating vehicle maintenance to a digital concierge experience.")
                                .font(.system(size: 17))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                                .padding(.horizontal, 8)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Spacer()

                    VStack(spacing: 14) {
                        NavigationLink(destination: LoginView()) {
                            Text("Get Started")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                                .background(Color.blue)
                                .cornerRadius(16)
                        }

                        NavigationLink(destination: LoginView()) {
                            Text("Sign In")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                        }

                        NavigationLink("Create New Account", destination: RegisterView())
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.top, 18)
                    }
                    .padding(.bottom, 54)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct AppLogoMark: View {
    var size: CGFloat = 142
    var cornerRadius: CGFloat = 32
    var padding: CGFloat = 8

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.blue)

            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .padding(padding)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

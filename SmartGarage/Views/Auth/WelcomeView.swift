import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.2), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {

                    Spacer()

                    AppLogoMark(size: 142, cornerRadius: 32, padding: 8)

                    Text("SmartGarage")
                        .font(.system(size: 36, weight: .bold))

                    Text("Elevating vehicle maintenance to a digital concierge experience.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 40)

                    Spacer()

                    NavigationLink(destination: LoginView()) {
                        Text("Get Started")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    NavigationLink(destination: LoginView()) {
                        Text("Sign In")
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                    .padding(.horizontal)

                    Spacer()
                    
                    NavigationLink("Sign Up", destination: RegisterView())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                        .padding(.horizontal)

                        Spacer()
                }
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
                .scaledToFill()
                .padding(padding)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

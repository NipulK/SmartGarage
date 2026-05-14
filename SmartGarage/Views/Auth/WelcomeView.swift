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

                    ZStack {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.blue)

                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .padding(10)
                    }
                    .frame(width: 142, height: 142)
                    .clipShape(RoundedRectangle(cornerRadius: 32))

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

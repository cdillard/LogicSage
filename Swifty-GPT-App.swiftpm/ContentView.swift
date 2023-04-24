import SwiftUI
import LocalConsole

struct ContentView: View {
    var body: some View {
        VStack {
            LogoView()
        }
    }
}

struct LogoView: View {
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    @StateObject var console = LocalConsole.shared

    var body: some View {
        GeometryReader { reader in
            ZStack {
                RadialGradient(
                    gradient: Gradient(colors: [Color(red: 0.11, green: 0.11, blue: 0.14), Color(red: 0.24, green: 0.24, blue: 0.29), Color(red: 0.13, green: 0.13, blue: 0.18)]),
                    center: .center,
                    startRadius: 20,
                    endRadius: 800
                )
                .blur(radius: 20)
                .overlay(
                    Circle()
                        .stroke(lineWidth: 20)
                        .foregroundColor(Color(red: 0.99, green: 0.75, blue: 0.20))
                        .blur(radius: 10)
                )

                HStack(spacing: 1) {

                    HStack(alignment: .center) {
                        VStack(alignment: .center) {
                            Spacer()
                            HStack(alignment: .center) {
                                Image(systemName: "swift")
                                    .font(.system(size: 100))
                                    .foregroundColor(.white)
                                    .shadow(color: Color(red: 0.08, green: 0.08, blue: 0.1), radius: 20, x: 0, y: 0)
                                VStack {
                                    HStack {
                                        RobotRightArm()

                                        RobotHead()
                                        RobotLeftArm()

                                    }
                                    HStack {
                                        RobotLeftLeg()
                                        RobotRightLeg()
                                    }
                                }
                                Image("xcode_trans")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color(red: 0.08, green: 0.08, blue: 0.1), radius: 20, x: 0, y: 0)
                            }
                            Spacer()

                        }
                    }
                    Spacer()

                }
                .overlay(console)

            }
        }
        .ignoresSafeArea()
    }
}


extension View {
    func glow(color: Color, radius: CGFloat) -> some View {
        self
            .overlay(
                self.blur(radius: radius * 0.7)
                    .foregroundColor(color)
                    .opacity(radius > 0 ? 0.5 : 0)
                    .blur(radius: radius * 0.3)
            )
            .shadow(color: color, radius: radius * 0.3, x: 0, y: 0)
    }
}

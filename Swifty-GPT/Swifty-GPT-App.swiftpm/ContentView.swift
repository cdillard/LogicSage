import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            LogoView()
        }
    }
}

struct LogoView: View {
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    
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
                            Text("Swifty-GPT:\n Auto Xcode Swift Apps \n GPT-3 or 4")
                                .multilineTextAlignment(.center)
                                .font(Font.custom("Helvetica Neue", size: 60))
                                .foregroundColor(.green)
                                .frame(width: reader.size.width , height: reader.size.height / 2, alignment: .center)
                                .background(
                                    ZStack {
                                        ForEach(colors.indices, id: \.self) { i in
                                            Circle()
                                                .frame(width: 300, height: 600)
                                                .foregroundColor(colors[i])
                                                .opacity(0.2)
                                                .scaleEffect(CGFloat(i + 1) / CGFloat(colors.count))
                                                .blendMode(.screen)
                                                .animation(
                                                    Animation.linear(duration: Double.random(in: 5...10))
                                                        .repeatForever(autoreverses: true)
                                                        .delay(Double(i) / Double(colors.count))
                                                    
                                                    
                                                )
                                        }
                                    }
                                        .frame(width: 600, height: 600)
                                        .rotationEffect(.degrees(45))
                                        .scaleEffect(0.7)
                                )
                                .shadow(color: Color(red: 0.08, green: 0.08, blue: 0.1), radius: 20, x: 0, y: 0)
                                .overlay(
                                    
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(lineWidth: 10)
                                        .foregroundColor(Color(red: 0.99, green: 0.75, blue: 0.20))
                                        .blur(radius: 10)
                                )
                                .glow(color: Color(red: 0.99, green: 0.75, blue: 0.20), radius: 20)
                            Spacer()
                        }
                        Spacer()

                    }
                }
            }
            .ignoresSafeArea()
        }
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

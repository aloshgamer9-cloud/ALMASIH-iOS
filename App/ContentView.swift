
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    private let tabs = [
        ("الرئيسية", "house"),
        ("الوحدات", "square.grid.2x2"),
        ("المراقبة", "waveform.path"),
        ("الأدوات", "wrench.and.screwdriver"),
        ("الإعدادات", "gearshape")
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Text("☦︎")
                        .font(.system(size: 34))
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("ALMASIH")
                            .font(.title2.bold())
                            .tracking(3)
                            .foregroundStyle(.white)

                        Text("ADVANCED iOS PLATFORM")
                            .font(.system(size: 9))
                            .tracking(2)
                            .foregroundStyle(.gray)
                    }

                    Spacer()

                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("ONLINE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.gray)
                }
                .padding(.top, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("مرحباً بك")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)

                    Text("منصة ALMASIH للتحكم والمراقبة")
                        .foregroundStyle(.gray)

                    Text("SYSTEM CORE")
                        .font(.caption.bold())
                        .tracking(2)
                        .foregroundStyle(.gray)

                    HStack {
                        Image(systemName: "cpu")
                        Text("CORE INITIALIZED")
                        Spacer()
                        Text("READY")
                            .foregroundStyle(.green)
                    }
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.white.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Spacer()

                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button {
                            selectedTab = index
                        } label: {
                            VStack(spacing: 7) {
                                Image(systemName: tabs[index].1)
                                    .font(.system(size: 19))

                                Text(tabs[index].0)
                                    .font(.system(size: 9))
                            }
                            .foregroundStyle(
                                selectedTab == index ? .white : .gray
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                    }
                }
                .background(Color.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 10)
        }
    }
}

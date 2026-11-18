
import SwiftUI

struct ContentView: View {
    @AppStorage("appLanguage") private var appLanguage = "ar"
    @State private var selectedTab = 0

    private var isArabic: Bool {
        appLanguage == "ar"
    }

    private var tabs: [(String, String)] {
        isArabic ? [
            ("الرئيسية", "house"),
            ("الوحدات", "square.grid.2x2"),
            ("المراقبة", "waveform.path"),
            ("الأدوات", "wrench.and.screwdriver"),
            ("الإعدادات", "gearshape")
        ] : [
            ("Home", "house"),
            ("Modules", "square.grid.2x2"),
            ("Monitor", "waveform.path"),
            ("Tools", "wrench.and.screwdriver"),
            ("Settings", "gearshape")
        ]
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                header

                Group {
                    switch selectedTab {
                    case 0:
                        homeContent
                    case 1:
                        ModulesView()
                    case 2:
                        MonitorView()
                    case 3:
                        ToolsView()
                    case 4:
                        SettingsView()
                    default:
                        homeContent
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                bottomNavigation
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 10)
        }
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        .preferredColorScheme(.dark)
    }

    private var header: some View {
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

            Text(isArabic ? "متصل" : "ONLINE")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.gray)
        }
        .padding(.top, 20)
    }

    private var homeContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "مرحباً بك" : "Welcome")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text(
                isArabic
                ? "منصة ALMASIH للتحكم والمراقبة"
                : "ALMASIH Monitoring Platform"
            )
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

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var bottomNavigation: some View {
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
                    .foregroundStyle(selectedTab == index ? .white : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

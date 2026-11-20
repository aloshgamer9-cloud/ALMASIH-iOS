
import SwiftUI
import Network

struct ContentView: View {
    @AppStorage("appLanguage") private var appLanguage = "ar"
    @State private var selectedTab = 0
    @State private var isNetworkConnected = false
    @State private var networkMonitor: NWPathMonitor?

    private let networkQueue = DispatchQueue(label: "ALMASIH.HomeNetwork")

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
        .environment(
            \.layoutDirection,
            isArabic ? .rightToLeft : .leftToRight
        )
        .preferredColorScheme(.dark)
        .onAppear {
            startNetworkMonitoring()
        }
        .onDisappear {
            stopNetworkMonitoring()
        }
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

                Text(
                    isArabic
                    ? "منصة iOS المتقدمة"
                    : "ADVANCED iOS PLATFORM"
                )
                .font(.system(size: 9))
                .tracking(2)
                .foregroundStyle(.gray)
            }

            Spacer()

            Circle()
                .fill(isNetworkConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)

            Text(networkStatusText)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.gray)
        }
        .padding(.top, 20)
    }

    private var networkStatusText: String {
        if isArabic {
            return isNetworkConnected ? "متصل بالشبكة" : "غير متصل"
        }

        return isNetworkConnected ? "NETWORK CONNECTED" : "OFFLINE"
    }

    private var homeContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "مرحباً بك" : "Welcome")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text(
                isArabic
                ? "منصة ALMASIH للمراقبة وأدوات الجهاز"
                : "ALMASIH device monitoring and tools"
            )
            .foregroundStyle(.gray)

            Text(isArabic ? "حالة النظام" : "SYSTEM STATUS")
                .font(.caption.bold())
                .tracking(2)
                .foregroundStyle(.gray)

            HStack {
                Image(systemName: "cpu")
                Text(isArabic ? "التطبيق يعمل" : "APP IS RUNNING")
                Spacer()
                Text(isArabic ? "جاهز" : "READY")
                    .foregroundStyle(.green)
            }
            .font(.caption.bold())
            .foregroundStyle(.white)
            .padding()
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 14))

            HStack {
                Image(systemName: "wifi")
                Text(isArabic ? "اتصال الشبكة" : "NETWORK")
                Spacer()
                Text(networkStatusText)
                    .foregroundStyle(isNetworkConnected ? .green : .red)
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
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(
                        selectedTab == index ? .white : .gray
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("tab_\(index)")
            }
        }
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func startNetworkMonitoring() {
        stopNetworkMonitoring()

        let monitor = NWPathMonitor()
        networkMonitor = monitor

        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                isNetworkConnected = path.status == .satisfied
            }
        }

        monitor.start(queue: networkQueue)
    }

    private func stopNetworkMonitoring() {
        networkMonitor?.cancel()
        networkMonitor = nil
    }
}

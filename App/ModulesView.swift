
import SwiftUI
import UIKit
import Network

private struct ALMASIHModule: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let icon: String
}

struct ModulesView: View {
    @AppStorage("appLanguage") private var appLanguage = "ar"
    @State private var selectedModule: ALMASIHModule?

    private var isArabic: Bool {
        appLanguage == "ar"
    }

    private var modules: [ALMASIHModule] {
        let values: [(String, String, String)] = isArabic ? [
            ("مراقبة النظام", "معلومات الجهاز والبطارية", "cpu"),
            ("مراقبة الشبكة", "حالة اتصال الشبكة ونوعها", "wifi"),
            ("تحليل التطبيقات", "معلومات وحدود إدارة التطبيقات", "app.badge"),
            ("أدوات النظام", "إعدادات التطبيق", "gearshape.2"),
            ("مركز الأمان", "إرشادات حماية الجهاز", "shield.lefthalf.filled")
        ] : [
            ("System Monitor", "Device and battery information", "cpu"),
            ("Network Monitor", "Connection status and type", "wifi"),
            ("App Analysis", "App information and iOS limitations", "app.badge"),
            ("System Tools", "Application settings", "gearshape.2"),
            ("Security Center", "Device security guidance", "shield.lefthalf.filled")
        ]

        return values.enumerated().map {
            ALMASIHModule(
                id: $0.offset,
                title: $0.element.0,
                subtitle: $0.element.1,
                icon: $0.element.2
            )
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("MODULES")
                            .font(.largeTitle.bold())
                            .tracking(3)
                            .foregroundStyle(.white)

                        Text(isArabic ? "وحدات منصة المسيح" : "ALMASIH MODULES")
                            .foregroundStyle(.gray)

                        ForEach(modules) { item in
                            Button {
                                selectedModule = item
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: item.icon)
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                        .frame(width: 48, height: 48)
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 12)
                                        )

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(item.title)
                                            .foregroundStyle(.white)
                                            .font(.headline)

                                        Text(item.subtitle)
                                            .foregroundStyle(.gray)
                                            .font(.caption)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.left")
                                        .foregroundStyle(.gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.06))
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 16)
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("module_button_\(item.id)")
                        }
                    }
                    .padding()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selectedModule) { module in
                moduleDetails(module)
            }
        }
        .environment(
            \.layoutDirection,
            isArabic ? .rightToLeft : .leftToRight
        )
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func moduleDetails(_ module: ALMASIHModule) -> some View {
        NavigationStack {
            VStack(spacing: 18) {
                switch module.id {

                case 0:
                    SystemModuleView(isArabic: isArabic)

                case 1:
                    NetworkModuleView(isArabic: isArabic)

                case 2:
                    AppAnalysisModuleView(isArabic: isArabic)

                case 3:
                    SystemToolsModuleView(isArabic: isArabic)

                case 4:
                    SecurityModuleView(isArabic: isArabic)

                default:
                    Text(isArabic ? "الوحدة غير متاحة" : "Module unavailable")
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .foregroundStyle(.white)
            .environment(
                \.layoutDirection,
                isArabic ? .rightToLeft : .leftToRight
            )
            .navigationTitle(module.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isArabic ? "إغلاق" : "Close") {
                        selectedModule = nil
                    }
                    .accessibilityIdentifier("module_close")
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct SystemModuleView: View {
    let isArabic: Bool

    @State private var batteryLevel = -1.0
    @State private var batteryState = UIDevice.BatteryState.unknown

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cpu")
                .font(.system(size: 45))

            info(
                isArabic ? "الجهاز" : "Device",
                UIDevice.current.model
            )

            info(
                isArabic ? "إصدار iOS" : "iOS Version",
                UIDevice.current.systemVersion
            )

            info(
                isArabic ? "النظام" : "System",
                UIDevice.current.systemName
            )

            info(
                isArabic ? "مستوى البطارية" : "Battery Level",
                batteryLevel < 0
                    ? (isArabic ? "غير متاح" : "Unavailable")
                    : "\(Int(batteryLevel * 100))%"
            )

            info(
                isArabic ? "حالة الشحن" : "Charging State",
                batteryStateText
            )
        }
        .onAppear {
            UIDevice.current.isBatteryMonitoringEnabled = true
            refreshBattery()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIDevice.batteryLevelDidChangeNotification
            )
        ) { _ in
            refreshBattery()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIDevice.batteryStateDidChangeNotification
            )
        ) { _ in
            refreshBattery()
        }
    }

    private var batteryStateText: String {
        switch batteryState {
        case .charging:
            return isArabic ? "قيد الشحن" : "Charging"
        case .full:
            return isArabic ? "ممتلئة" : "Full"
        case .unplugged:
            return isArabic ? "غير موصولة" : "Unplugged"
        default:
            return isArabic ? "غير معروف" : "Unknown"
        }
    }

    private func refreshBattery() {
        batteryLevel = Double(UIDevice.current.batteryLevel)
        batteryState = UIDevice.current.batteryState
    }

    private func info(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.gray)
            Spacer()
            Text(value).foregroundStyle(.white)
        }
        .padding()
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct NetworkModuleView: View {
    let isArabic: Bool

    @State private var status = ""
    @State private var connectionType = ""
    @State private var monitor: NWPathMonitor?

    private let queue = DispatchQueue(label: "ALMASIH.ModulesNetwork")

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi")
                .font(.system(size: 45))

            Text(status.isEmpty
                 ? (isArabic ? "جاري الفحص..." : "Checking...")
                 : status)
                .font(.title2.bold())

            Text(
                (isArabic ? "نوع الاتصال: " : "Connection type: ")
                + connectionType
            )
            .foregroundStyle(.gray)

            Text(
                isArabic
                ? "يعرض هذا الفحص حالة اتصال الشبكة، ولا يقيس سرعة الإنترنت أو زمن الاستجابة."
                : "This checks network connectivity only. It does not measure internet speed or latency."
            )
            .font(.caption)
            .foregroundStyle(.gray)
            .multilineTextAlignment(.center)
        }
        .onAppear {
            startMonitoring()
        }
        .onDisappear {
            stopMonitoring()
        }
    }

    private func startMonitoring() {
        stopMonitoring()

        let newMonitor = NWPathMonitor()
        monitor = newMonitor

        newMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                status = path.status == .satisfied
                    ? (isArabic ? "الشبكة متصلة" : "Connected")
                    : (isArabic ? "لا يوجد اتصال" : "Disconnected")

                if path.usesInterfaceType(.wifi) {
                    connectionType = "Wi-Fi"
                } else if path.usesInterfaceType(.cellular) {
                    connectionType = isArabic ? "بيانات الهاتف" : "Cellular"
                } else if path.usesInterfaceType(.wiredEthernet) {
                    connectionType = "Ethernet"
                } else {
                    connectionType = isArabic ? "غير معروف" : "Unknown"
                }
            }
        }

        newMonitor.start(queue: queue)
    }

    private func stopMonitoring() {
        monitor?.cancel()
        monitor = nil
    }
}

private struct AppAnalysisModuleView: View {
    let isArabic: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "app.badge")
                .font(.system(size: 45))

            Text(isArabic ? "تحليل التطبيقات" : "App Analysis")
                .font(.title2.bold())

            Text(
                isArabic
                ? "يمكن للتطبيق عرض معلوماته وأذوناته، لكن iOS لا يسمح له بقراءة بيانات التطبيقات الأخرى أو التحكم بها بصورة عامة."
                : "The app can inspect its own information and permissions, but iOS does not generally allow it to inspect or control other apps."
            )
            .foregroundStyle(.gray)
            .multilineTextAlignment(.center)
        }
    }
}

private struct SystemToolsModuleView: View {
    let isArabic: Bool

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "gearshape.2")
                .font(.system(size: 45))

            Text(isArabic ? "إعدادات التطبيق" : "App Settings")
                .font(.title2.bold())

            Button {
                if let url = URL(
                    string: UIApplication.openSettingsURLString
                ) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label(
                    isArabic ? "فتح إعدادات ALMASIH" : "Open ALMASIH Settings",
                    systemImage: "gearshape"
                )
                .foregroundStyle(.white)
                .padding()
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

private struct SecurityModuleView: View {
    let isArabic: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 45))

            Text(isArabic ? "مركز الأمان" : "Security Center")
                .font(.title2.bold())

            info(
                isArabic ? "التحديثات" : "Updates",
                isArabic ? "حافظ على تحديث iOS" : "Keep iOS updated"
            )

            info(
                isArabic ? "الخصوصية" : "Privacy",
                isArabic ? "راجع أذونات التطبيقات" : "Review app permissions"
            )

            info(
                isArabic ? "الحسابات" : "Accounts",
                isArabic ? "استخدم كلمات مرور قوية" : "Use strong passwords"
            )
        }
    }

    private func info(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.gray)
            Spacer()
            Text(value).foregroundStyle(.white)
        }
        .padding()
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

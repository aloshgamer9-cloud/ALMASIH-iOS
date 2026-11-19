import SwiftUI
import UIKit
import Network
import Combine

private struct ALMASIHModule: Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let icon: String
}

private final class ModuleNetworkObserver: ObservableObject {
    @Published var status = ""
    @Published var connectionType = ""

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ALMASIH.ModuleNetwork")

    private var isRunning = false

    func start(isArabic: Bool) {
        guard !isRunning else { return }
        isRunning = true

        monitor.pathUpdateHandler = { [weak self] path in
            let status = path.status == .satisfied
                ? (isArabic ? "متصل" : "Connected")
                : (isArabic ? "غير متصل" : "Disconnected")

            let type: String
            if path.usesInterfaceType(.wifi) {
                type = "Wi-Fi"
            } else if path.usesInterfaceType(.cellular) {
                type = isArabic ? "بيانات الهاتف" : "Cellular"
            } else if path.usesInterfaceType(.wiredEthernet) {
                type = "Ethernet"
            } else {
                type = isArabic ? "غير معروف" : "Unknown"
            }

            DispatchQueue.main.async {
                self?.status = status
                self?.connectionType = type
            }
        }

        monitor.start(queue: queue)
    }

    func stop() {
        guard isRunning else { return }
        monitor.cancel()
        isRunning = false
    }

    deinit {
        monitor.cancel()
    }
}

struct ModulesView: View {
    @AppStorage("appLanguage") private var appLanguage = "ar"

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

                        ForEach(modules) { module in
                            NavigationLink {
                                ModuleDetailView(module: module, isArabic: isArabic)
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: module.icon)
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                        .frame(width: 48, height: 48)
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(module.title)
                                            .foregroundStyle(.white)
                                            .font(.headline)

                                        Text(module.subtitle)
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
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("module_button_\(module.id)")
                        }
                    }
                    .padding()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        .preferredColorScheme(.dark)
    }
}

private struct ModuleDetailView: View {
    let module: ALMASIHModule
    let isArabic: Bool

    @Environment(\.dismiss) private var dismiss
    @StateObject private var networkObserver = ModuleNetworkObserver()

    @State private var batteryLevel = -1.0
    @State private var batteryState = UIDevice.BatteryState.unknown

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    Image(systemName: module.icon)
                        .font(.system(size: 45))
                        .foregroundStyle(.white)

                    switch module.id {
                    case 0:
                        systemInformation
                    case 1:
                        networkInformation
                    case 2:
                        appAnalysis
                    case 3:
                        systemTools
                    case 4:
                        securityInformation
                    default:
                        Text(isArabic ? "الوحدة غير متاحة" : "Module unavailable")
                            .foregroundStyle(.white)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(module.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isArabic ? "إغلاق" : "Close") {
                    dismiss()
                }
                .accessibilityIdentifier("module_close")
            }
        }
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        .preferredColorScheme(.dark)
        .onAppear {
            if module.id == 0 {
                UIDevice.current.isBatteryMonitoringEnabled = true
                refreshBattery()
            }

            if module.id == 1 {
                networkObserver.start(isArabic: isArabic)
            }
        }
        .onDisappear {
            if module.id == 0 {
                UIDevice.current.isBatteryMonitoringEnabled = false
            }

            if module.id == 1 {
                networkObserver.stop()
            }
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIDevice.batteryLevelDidChangeNotification
        )) { _ in
            refreshBattery()
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIDevice.batteryStateDidChangeNotification
        )) { _ in
            refreshBattery()
        }
    }

    private var systemInformation: some View {
        VStack(spacing: 15) {
            infoRow(isArabic ? "الجهاز" : "Device", UIDevice.current.model)
            infoRow(isArabic ? "النظام" : "System", UIDevice.current.systemName)
            infoRow(isArabic ? "إصدار iOS" : "iOS Version", UIDevice.current.systemVersion)

            infoRow(
                isArabic ? "مستوى البطارية" : "Battery Level",
                batteryLevel < 0
                    ? (isArabic ? "غير متاح" : "Unavailable")
                    : "\(Int(batteryLevel * 100))%"
            )

            infoRow(
                isArabic ? "حالة الشحن" : "Charging State",
                batteryStateText
            )
        }
    }

    private var networkInformation: some View {
        VStack(spacing: 15) {
            infoRow(
                isArabic ? "حالة الشبكة" : "Network Status",
                networkObserver.status.isEmpty
                    ? (isArabic ? "جاري الفحص..." : "Checking...")
                    : networkObserver.status
            )

            infoRow(
                isArabic ? "نوع الاتصال" : "Connection Type",
                networkObserver.connectionType.isEmpty
                    ? (isArabic ? "غير معروف" : "Unknown")
                    : networkObserver.connectionType
            )

            Text(isArabic
                 ? "يعرض هذا الفحص حالة الاتصال فقط، ولا يقيس سرعة الإنترنت أو زمن الاستجابة."
                 : "This checks connectivity only. It does not measure internet speed or latency.")
                .font(.caption)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
        .accessibilityIdentifier("module_network_information")
    }

    private var appAnalysis: some View {
        VStack(spacing: 15) {
            Text(isArabic ? "تحليل التطبيقات" : "App Analysis")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text(isArabic
                 ? "يمكن للتطبيق عرض معلوماته وأذوناته، لكن iOS لا يسمح له بقراءة بيانات التطبيقات الأخرى أو التحكم بها بصورة عامة."
                 : "The app can inspect its own information and permissions, but iOS does not generally allow it to inspect or control other apps.")
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
    }

    private var systemTools: some View {
        VStack(spacing: 15) {
            Text(isArabic ? "إعدادات التطبيق" : "App Settings")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label(
                    isArabic ? "فتح إعدادات ALMASIH" : "Open ALMASIH Settings",
                    systemImage: "gearshape"
                )
                .foregroundStyle(.white)
                .padding()
                .background(Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var securityInformation: some View {
        VStack(spacing: 15) {
            infoRow(
                isArabic ? "التحديثات" : "Updates",
                isArabic ? "حافظ على تحديث iOS" : "Keep iOS updated"
            )

            infoRow(
                isArabic ? "الخصوصية" : "Privacy",
                isArabic ? "راجع أذونات التطبيقات" : "Review app permissions"
            )

            infoRow(
                isArabic ? "الحسابات" : "Accounts",
                isArabic ? "استخدم كلمات مرور قوية" : "Use strong passwords"
            )
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

    private func infoRow(_ title: String, _ value: String) -> some View {
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
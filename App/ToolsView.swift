
import SwiftUI
import Foundation
import Network
import UIKit
import Combine

// MARK: - Tool Model

private struct ALMASIHTool: Identifiable {
    let id: Int
    let title: String
    let icon: String
}

// MARK: - Network Monitor

private final class NetworkStatusObserver: ObservableObject {
    @Published var networkStatus = "—"
    @Published var internetStatus = "—"
    @Published var responseTime = "—"
    @Published var isChecking = false

    private var monitor: NWPathMonitor?
    private var internetTask: URLSessionDataTask?

    func start(isArabic: Bool) {
        monitor?.cancel()

        let newMonitor = NWPathMonitor()
        monitor = newMonitor

        newMonitor.pathUpdateHandler = { [weak self] path in
            let result: String

            if path.status == .satisfied {
                if path.usesInterfaceType(.wifi) {
                    result = isArabic ? "متصل عبر Wi-Fi" : "Connected via Wi-Fi"
                } else if path.usesInterfaceType(.cellular) {
                    result = isArabic ? "متصل عبر بيانات الهاتف" : "Connected via Cellular"
                } else {
                    result = isArabic ? "متصل بالشبكة" : "Connected"
                }
            } else {
                result = isArabic ? "غير متصل" : "Disconnected"
            }

            DispatchQueue.main.async {
                self?.networkStatus = result
            }
        }

        newMonitor.start(
            queue: DispatchQueue(label: "ALMASIH.NetworkMonitor")
        )
    }

    func checkInternet(isArabic: Bool) {
        internetTask?.cancel()

        isChecking = true
        internetStatus = isArabic ? "جاري الفحص..." : "Checking..."
        responseTime = "—"

        guard let url = URL(
            string: "https://www.apple.com/library/test/success.html"
        ) else {
            isChecking = false
            internetStatus = isArabic ? "تعذر بدء الفحص" : "Unable to start test"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 8

        let startTime = Date()

        internetTask = URLSession.shared.dataTask(with: request) {
            [weak self] _, response, error in

            let elapsed = Date().timeIntervalSince(startTime) * 1000

            DispatchQueue.main.async {
                guard let self = self else { return }

                self.isChecking = false

                if error != nil {
                    self.internetStatus = isArabic
                        ? "تعذر الوصول إلى الإنترنت"
                        : "Internet unavailable"

                    self.responseTime = "—"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.internetStatus = isArabic
                        ? "استجابة غير صالحة"
                        : "Invalid response"
                    return
                }

                self.responseTime = String(format: "%.0f ms", elapsed)

                if (200...399).contains(httpResponse.statusCode) {
                    self.internetStatus = isArabic
                        ? "الإنترنت يعمل"
                        : "Internet is working"
                } else {
                    self.internetStatus = isArabic
                        ? "رمز الاستجابة: \(httpResponse.statusCode)"
                        : "Response code: \(httpResponse.statusCode)"
                }
            }
        }

        internetTask?.resume()
    }

    func stop() {
        monitor?.cancel()
        monitor = nil

        internetTask?.cancel()
        internetTask = nil
    }

    deinit {
        stop()
    }
}

// MARK: - Main Tools View

struct ToolsView: View {

    @AppStorage("appLanguage") private var appLanguage = "ar"

    private var isArabic: Bool {
        appLanguage == "ar"
    }

    private var tools: [ALMASIHTool] {
        let names = isArabic
            ? [
                "فحص الاتصال والشبكة",
                "معلومات الجهاز",
                "مساحة التخزين",
                "حالة البطارية",
                "إعدادات التطبيق"
            ]
            : [
                "Network Check",
                "Device Information",
                "Storage",
                "Battery Status",
                "App Settings"
            ]

        let icons = [
            "wifi",
            "iphone",
            "internaldrive",
            "battery.100",
            "gearshape"
        ]

        return names.enumerated().map { index, name in
            ALMASIHTool(
                id: index,
                title: name,
                icon: icons[index]
            )
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        Text("TOOLS")
                            .font(.largeTitle.bold())
                            .tracking(3)
                            .foregroundColor(.white)

                        Text(
                            isArabic
                            ? "مركز أدوات ALMASIH"
                            : "ALMASIH Tools Center"
                        )
                        .foregroundColor(.gray)

                        ForEach(tools) { tool in
                            NavigationLink {
                                ToolDetailView(
                                    tool: tool,
                                    isArabic: isArabic
                                )
                            } label: {
                                HStack(spacing: 15) {

                                    Image(systemName: tool.icon)
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 48, height: 48)
                                        .background(
                                            Color.white.opacity(0.1)
                                        )
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 12)
                                        )

                                    Text(tool.title)
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    Spacer()

                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    Color.white.opacity(0.07)
                                )
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 16)
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("tool_button_\(tool.id)")
                        }
                    }
                    .padding()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .environment(
            \.layoutDirection,
            isArabic ? .rightToLeft : .leftToRight
        )
        .preferredColorScheme(.dark)
    }
}

// MARK: - Tool Details

private struct ToolDetailView: View {

    let tool: ALMASIHTool
    let isArabic: Bool

    @StateObject private var network = NetworkStatusObserver()

    @State private var batteryLevel: Float = -1
    @State private var batteryState = UIDevice.BatteryState.unknown

    private var batteryPercentage: String {
        if batteryLevel < 0 {
            return isArabic ? "غير متاح" : "Unavailable"
        }

        return "\(Int(batteryLevel * 100))%"
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {

                    Image(systemName: tool.icon)
                        .font(.system(size: 45))
                        .foregroundColor(.white)
                        .padding(.top, 25)

                    switch tool.id {
                    case 0:
                        networkInformation

                    case 1:
                        deviceInformation

                    case 2:
                        storageInformation

                    case 3:
                        batteryInformation

                    case 4:
                        settingsInformation

                    default:
                        Text(isArabic ? "الأداة غير متاحة" : "Tool unavailable")
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(tool.title)
        .navigationBarTitleDisplayMode(.inline)
        .environment(
            \.layoutDirection,
            isArabic ? .rightToLeft : .leftToRight
        )
        .preferredColorScheme(.dark)
        .onAppear {
            if tool.id == 0 {
                network.start(isArabic: isArabic)
                network.checkInternet(isArabic: isArabic)
            }

            if tool.id == 3 {
                UIDevice.current.isBatteryMonitoringEnabled = true
                refreshBattery()
            }
        }
        .onDisappear {
            network.stop()

            if tool.id == 3 {
                UIDevice.current.isBatteryMonitoringEnabled = false
            }
        }
    }

    // MARK: Network

    private var networkInformation: some View {
        VStack(spacing: 18) {

            infoRow(
                isArabic ? "حالة الشبكة" : "Network Status",
                network.networkStatus
            )

            infoRow(
                isArabic ? "حالة الإنترنت" : "Internet Status",
                network.internetStatus
            )

            infoRow(
                isArabic ? "زمن الاستجابة" : "Response Time",
                network.responseTime
            )

            Button {
                network.checkInternet(isArabic: isArabic)
            } label: {
                HStack {
                    if network.isChecking {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(
                        isArabic
                        ? "إعادة فحص الاتصال"
                        : "Check Connection Again"
                    )
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(network.isChecking)

            Text(
                isArabic
                ? "هذا الاختبار يقيس زمن الوصول إلى خادم عبر HTTPS، وليس سرعة التنزيل أو Ping الحقيقي."
                : "This measures HTTPS server response time, not download speed or true ICMP ping."
            )
            .font(.caption)
            .foregroundColor(.gray)
        }
    }

    // MARK: Device Information

    private var deviceInformation: some View {
        VStack(spacing: 16) {

            infoRow(
                isArabic ? "نوع الجهاز" : "Device Model",
                UIDevice.current.model
            )

            infoRow(
                isArabic ? "نظام التشغيل" : "Operating System",
                UIDevice.current.systemName
            )

            infoRow(
                isArabic ? "إصدار النظام" : "System Version",
                UIDevice.current.systemVersion
            )

            infoRow(
                isArabic ? "اسم التطبيق" : "Application",
                "ALMASIH"
            )
        }
    }

    // MARK: Storage

    private var storageInformation: some View {
        VStack(spacing: 16) {

            if let values = try? URL(
                fileURLWithPath: NSHomeDirectory()
            ).resourceValues(
                forKeys: [
                    .volumeTotalCapacityKey,
                    .volumeAvailableCapacityKey
                ]
            ) {

                let total = values.volumeTotalCapacity ?? 0
                let available = values.volumeAvailableCapacity ?? 0
                let used = max(0, total - available)

                infoRow(
                    isArabic ? "المساحة الكلية" : "Total Storage",
                    formatBytes(Int64(total))
                )

                infoRow(
                    isArabic ? "المساحة المستخدمة" : "Used Storage",
                    formatBytes(Int64(used))
                )

                infoRow(
                    isArabic ? "المساحة المتاحة" : "Available Storage",
                    formatBytes(Int64(available))
                )

            } else {
                Text(
                    isArabic
                    ? "تعذر قراءة معلومات التخزين"
                    : "Unable to read storage information"
                )
                .foregroundColor(.gray)
            }
        }
    }

    // MARK: Battery

    private var batteryInformation: some View {
        VStack(spacing: 16) {

            infoRow(
                isArabic ? "مستوى البطارية" : "Battery Level",
                batteryPercentage
            )

            infoRow(
                isArabic ? "حالة البطارية" : "Battery State",
                batteryStateText
            )

            Button {
                refreshBattery()
            } label: {
                Text(isArabic ? "تحديث البيانات" : "Refresh")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var batteryStateText: String {
        switch batteryState {
        case .charging:
            return isArabic ? "قيد الشحن" : "Charging"

        case .full:
            return isArabic ? "ممتلئة" : "Full"

        case .unplugged:
            return isArabic ? "غير موصولة بالشاحن" : "Unplugged"

        case .unknown:
            return isArabic ? "غير معروف" : "Unknown"

        @unknown default:
            return isArabic ? "غير معروف" : "Unknown"
        }
    }

    private func refreshBattery() {
        batteryLevel = UIDevice.current.batteryLevel
        batteryState = UIDevice.current.batteryState
    }

    // MARK: App Settings

    private var settingsInformation: some View {
        VStack(spacing: 18) {

            Text(
                isArabic
                ? "إعدادات تطبيق ALMASIH"
                : "ALMASIH App Settings"
            )
            .foregroundColor(.white)
            .font(.headline)

            Button {
                guard let url = URL(
                    string: UIApplication.openSettingsURLString
                ) else {
                    return
                }

                UIApplication.shared.open(url)

            } label: {
                HStack {
                    Image(systemName: "gearshape")
                    Text(
                        isArabic
                        ? "فتح إعدادات التطبيق"
                        : "Open App Settings"
                    )
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: Shared Information Row

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)

            Spacer()

            Text(value)
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
        .padding()
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: Format Storage

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

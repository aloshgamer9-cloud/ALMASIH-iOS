
import SwiftUI
import Network
import UIKit

private struct ALMASIHTool: Identifiable, Hashable {
    let id: Int
    let title: String
    let icon: String
}

struct ToolsView: View {
    @AppStorage("appLanguage") private var appLanguage = "ar"

    private var isArabic: Bool {
        appLanguage == "ar"
    }

    private var tools: [ALMASIHTool] {
        let names = isArabic
            ? ["فحص الاتصال", "معلومات الجهاز", "مساحة التخزين", "حالة البطارية", "إعدادات التطبيق"]
            : ["Network Check", "Device Information", "Storage", "Battery Status", "App Settings"]

        let icons = ["wifi", "iphone", "internaldrive", "battery.100", "gearshape"]

        return names.enumerated().map {
            ALMASIHTool(id: $0.offset, title: $0.element, icon: icons[$0.offset])
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
                            .foregroundStyle(.white)

                        Text(isArabic ? "مركز أدوات ALMASIH" : "ALMASIH Tools Center")
                            .foregroundStyle(.gray)

                        ForEach(tools) { tool in
                            NavigationLink {
                                ToolDetailView(tool: tool, isArabic: isArabic)
                            } label: {
                                HStack(spacing: 15) {
                                    Image(systemName: tool.icon)
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                        .frame(width: 48, height: 48)
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))

                                    Text(tool.title)
                                        .foregroundStyle(.white)
                                        .font(.headline)

                                    Spacer()

                                    Image(systemName: "chevron.left")
                                        .foregroundStyle(.gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.07))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .contentShape(Rectangle())
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
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        .preferredColorScheme(.dark)
    }
}

private struct ToolDetailView: View {
    let tool: ALMASIHTool
    let isArabic: Bool

    @Environment(\.dismiss) private var dismiss

    @State private var networkStatus = ""
    @State private var batteryLevel = -1.0
    @State private var batteryState = UIDevice.BatteryState.unknown

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: tool.icon)
                    .font(.system(size: 45))
                    .foregroundStyle(.white)

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
                        .foregroundStyle(.white)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle(tool.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isArabic ? "إغلاق" : "Close") {
                    dismiss()
                }
                .accessibilityIdentifier("tool_close")
            }
        }
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        .preferredColorScheme(.dark)
        .onAppear {
            UIDevice.current.isBatteryMonitoringEnabled = true
            refreshBattery()
            checkNetwork()
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

    private var networkInformation: some View {
        VStack(spacing: 15) {
            Text(networkStatus.isEmpty
                 ? (isArabic ? "اضغط للفحص" : "Tap to check")
                 : networkStatus)
                .font(.title2.bold())
                .foregroundStyle(.white)

            Button(isArabic ? "فحص الاتصال الآن" : "Check Connection") {
                checkNetwork()
            }
            .foregroundStyle(.white)
            .padding()
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(isArabic
                 ? "يعرض حالة الاتصال فقط ولا يقيس سرعة الإنترنت."
                 : "Shows connection status only, not internet speed.")
                .font(.caption)
                .foregroundStyle(.gray)
        }
    }

    private var deviceInformation: some View {
        VStack(spacing: 15) {
            infoRow(isArabic ? "الجهاز" : "Device", UIDevice.current.model)
            infoRow(isArabic ? "النظام" : "System", UIDevice.current.systemName)
            infoRow(isArabic ? "إصدار النظام" : "iOS Version", UIDevice.current.systemVersion)
        }
    }

    private var storageInformation: some View {
        let values = try? URL(fileURLWithPath: NSHomeDirectory())
            .resourceValues(forKeys: [
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityKey
            ])

        return VStack(spacing: 15) {
            infoRow(
                isArabic ? "المساحة الكلية" : "Total Storage",
                formatBytes(values?.volumeTotalCapacity)
            )
            infoRow(
                isArabic ? "المساحة المتاحة" : "Available Storage",
                formatBytes(values?.volumeAvailableCapacity)
            )
        }
    }

    private var batteryInformation: some View {
        VStack(spacing: 15) {
            infoRow(
                isArabic ? "مستوى البطارية" : "Battery Level",
                batteryLevel < 0 ? (isArabic ? "غير متاح" : "Unavailable") : "\(Int(batteryLevel * 100))%"
            )

            infoRow(
                isArabic ? "حالة الشحن" : "Charging State",
                batteryStateText
            )
        }
    }

    private var settingsInformation: some View {
        Button {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        } label: {
            Label(
                isArabic ? "فتح إعدادات التطبيق" : "Open App Settings",
                systemImage: "gearshape"
            )
            .foregroundStyle(.white)
            .padding()
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))
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

    private func checkNetwork() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "ALMASIH.ToolNetworkCheck")

        networkStatus = isArabic ? "جاري الفحص..." : "Checking..."

        monitor.pathUpdateHandler = { path in
            let result = path.status == .satisfied
                ? (isArabic ? "متصل بالشبكة" : "Connected")
                : (isArabic ? "لا يوجد اتصال" : "Disconnected")

            DispatchQueue.main.async {
                networkStatus = result
                monitor.cancel()
            }
        }

        monitor.start(queue: queue)
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

    private func formatBytes(_ bytes: Int?) -> String {
        guard let bytes else {
            return isArabic ? "غير متاح" : "Unavailable"
        }

        return ByteCountFormatter.string(
            fromByteCount: Int64(bytes),
            countStyle: .file
        )
    }
}

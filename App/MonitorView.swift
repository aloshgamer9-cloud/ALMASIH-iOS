import SwiftUI
import UIKit

struct MonitorView: View {
    @AppStorage("appLanguage") private var appLanguage = "ar"

    @State private var batteryLevel = "غير متاح"
    @State private var batteryState = "غير معروف"

    private var isArabic: Bool {
        appLanguage == "ar"
    }

    private var deviceName: String {
        UIDevice.current.model
    }

    private var systemVersion: String {
        UIDevice.current.systemVersion
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("MONITOR")
                        .font(.largeTitle.bold())
                        .tracking(3)
                        .foregroundStyle(.white)

                    Text(isArabic ? "مراقبة حالة الجهاز" : "Device Status Monitor")
                        .foregroundStyle(.gray)

                    monitorCard(
                        title: isArabic ? "مستوى البطارية" : "Battery Level",
                        value: batteryLevel,
                        symbol: "battery.100",
                        identifier: "monitor_battery_level"
                    )

                    monitorCard(
                        title: isArabic ? "حالة الشحن" : "Charging Status",
                        value: batteryState,
                        symbol: "bolt.fill",
                        identifier: "monitor_battery_state"
                    )

                    monitorCard(
                        title: isArabic ? "نوع الجهاز" : "Device Model",
                        value: deviceName,
                        symbol: "iphone",
                        identifier: "monitor_device"
                    )

                    monitorCard(
                        title: isArabic ? "إصدار النظام" : "System Version",
                        value: "iOS \(systemVersion)",
                        symbol: "gear",
                        identifier: "monitor_system"
                    )

                    Text(
                        isArabic
                        ? "تعرض هذه الشاشة المعلومات التي يسمح iOS للتطبيق بقراءتها."
                        : "This screen displays information that iOS allows the app to access."
                    )
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        .preferredColorScheme(.dark)
        .onAppear {
            UIDevice.current.isBatteryMonitoringEnabled = true
            refreshBattery()
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

    private func refreshBattery() {
        let level = UIDevice.current.batteryLevel

        batteryLevel = level >= 0
            ? "\(Int(level * 100))%"
            : (isArabic ? "غير متاح" : "Unavailable")

        switch UIDevice.current.batteryState {
        case .charging:
            batteryState = isArabic ? "قيد الشحن" : "Charging"
        case .full:
            batteryState = isArabic ? "ممتلئة" : "Full"
        case .unplugged:
            batteryState = isArabic ? "غير موصولة بالشاحن" : "Unplugged"
        default:
            batteryState = isArabic ? "غير معروف" : "Unknown"
        }
    }

    private func monitorCard(
        title: String,
        value: String,
        symbol: String,
        identifier: String
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.gray)

                Text(value)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .accessibilityIdentifier(identifier)
            }

            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

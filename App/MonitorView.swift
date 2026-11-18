
import SwiftUI
import UIKit

struct MonitorView: View {
    @State private var batteryLevel = "غير متاح"
    @State private var batteryState = "غير معروف"

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

                    Text("مراقبة حالة الجهاز")
                        .foregroundStyle(.gray)

                    monitorCard(
                        title: "مستوى البطارية",
                        value: batteryLevel,
                        symbol: "battery.100"
                    )

                    monitorCard(
                        title: "حالة الشحن",
                        value: batteryState,
                        symbol: "bolt.fill"
                    )

                    monitorCard(
                        title: "نوع الجهاز",
                        value: deviceName,
                        symbol: "iphone"
                    )

                    monitorCard(
                        title: "إصدار النظام",
                        value: "iOS \(systemVersion)",
                        symbol: "gear"
                    )

                    Text("تعرض هذه الشاشة المعلومات التي يسمح iOS للتطبيق بقراءتها.")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .padding(.top, 8)
                }
                .padding()
            }
        }
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

        if level >= 0 {
            batteryLevel = "\(Int(level * 100))%"
        } else {
            batteryLevel = "غير متاح"
        }

        switch UIDevice.current.batteryState {
        case .charging:
            batteryState = "قيد الشحن"
        case .full:
            batteryState = "ممتلئة"
        case .unplugged:
            batteryState = "غير موصولة بالشاحن"
        case .unknown:
            batteryState = "غير معروف"
        @unknown default:
            batteryState = "غير معروف"
        }
    }

    private func monitorCard(
        title: String,
        value: String,
        symbol: String
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
            }

            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

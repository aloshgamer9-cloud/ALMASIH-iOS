
import SwiftUI
import UIKit

struct MonitorView: View {
    @State private var batteryLevel = UIDevice.current.batteryLevel
    @State private var batteryState = UIDevice.current.batteryState

    private var batteryText: String {
        batteryLevel < 0 ? "غير متاح" : "\(Int(batteryLevel * 100))%"
    }

    private var batteryStatus: String {
        switch batteryState {
        case .charging: return "قيد الشحن"
        case .full: return "مكتملة"
        case .unplugged: return "غير متصلة بالشاحن"
        default: return "غير معروف"
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("SYSTEM MONITOR")
                        .font(.largeTitle.bold())
                        .tracking(2)
                        .foregroundStyle(.white)

                    Text("مراقبة حالة الجهاز")
                        .foregroundStyle(.gray)

                    monitorCard(
                        title: "مستوى البطارية",
                        value: batteryText,
                        icon: "battery.100"
                    )

                    monitorCard(
                        title: "حالة البطارية",
                        value: batteryStatus,
                        icon: "bolt.fill"
                    )

                    monitorCard(
                        title: "نظام التشغيل",
                        value: UIDevice.current.systemVersion,
                        icon: "iphone"
                    )

                    monitorCard(
                        title: "نوع الجهاز",
                        value: UIDevice.current.model,
                        icon: "cpu"
                    )

                    Text("ملاحظة: معلومات الشبكة وحرارة المعالج غير متاحة بالكامل للتطبيقات العادية على iOS.")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .padding(.top, 8)
                }
                .padding()
            }
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
        .preferredColorScheme(.dark)
    }

    private func refreshBattery() {
        batteryLevel = UIDevice.current.batteryLevel
        batteryState = UIDevice.current.batteryState
    }

    private func monitorCard(
        title: String,
        value: String,
        icon: String
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .foregroundStyle(.gray)
                    .font(.caption)

                Text(value)
                    .foregroundStyle(.white)
                    .font(.headline)
            }

            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}


import SwiftUI
import Network
import UIKit

private struct ALMASIHTool: Identifiable {
    let title: String
    let icon: String

    var id: String { title }
}

struct ToolsView: View {
    @State private var selectedTool: ALMASIHTool?
    @State private var connectionStatus = "جاري الفحص..."
    @State private var monitor: NWPathMonitor?

    @State private var batteryLevel = UIDevice.current.batteryLevel
    @State private var batteryState = UIDevice.current.batteryState

    private let queue = DispatchQueue(label: "ALMASIH.NetworkMonitor")

    private let tools = [
        ALMASIHTool(title: "فحص الاتصال", icon: "wifi"),
        ALMASIHTool(title: "معلومات الجهاز", icon: "iphone"),
        ALMASIHTool(title: "مساحة التخزين", icon: "internaldrive"),
        ALMASIHTool(title: "حالة البطارية", icon: "battery.100"),
        ALMASIHTool(title: "إعدادات التطبيق", icon: "gearshape")
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("TOOLS")
                        .font(.largeTitle.bold())
                        .tracking(3)
                        .foregroundColor(.white)

                    Text("مركز أدوات ALMASIH")
                        .foregroundColor(.gray)

                    ForEach(Array(tools.enumerated()), id: \.offset) { element in
                        let index = element.offset
                        let tool = element.element

                        Button {
                            selectedTool = tool
                        } label: {
                            HStack(spacing: 15) {
                                Image(systemName: tool.icon)
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 12)
                                    )

                                Text(tool.title)
                                    .foregroundColor(.white)
                                    .font(.headline)

                                Spacer()

                                Image(systemName: "chevron.left")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .background(Color.white.opacity(0.07))
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("tool_button_\(index)")
                    }
                }
                .padding()
            }
        }
        .sheet(item: $selectedTool) { tool in
            NavigationStack {
                detailContent(for: tool)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .navigationTitle(tool.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("إغلاق") {
                                selectedTool = nil
                            }
                            .accessibilityIdentifier("tool_close")
                        }
                    }
            }
            .preferredColorScheme(.dark)
        }
        .onAppear {
            UIDevice.current.isBatteryMonitoringEnabled = true
            refreshBattery()
            startMonitoring()
        }
        .onDisappear {
            stopMonitoring()
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

    @ViewBuilder
    private func detailContent(for tool: ALMASIHTool) -> some View {
        VStack(spacing: 20) {
            switch tool.title {

            case "فحص الاتصال":
                Image(systemName: "wifi")
                    .font(.system(size: 45))

                Text(connectionStatus)
                    .font(.title2.bold())

                Text("يعرض هذا الفحص حالة اتصال الشبكة فقط.")
                    .foregroundColor(.gray)

            case "معلومات الجهاز":
                infoRow("الجهاز", UIDevice.current.model)
                infoRow("النظام", UIDevice.current.systemName)
                infoRow("إصدار iOS", UIDevice.current.systemVersion)

            case "مساحة التخزين":
                storageInformation

            case "حالة البطارية":
                batteryInformation

            case "إعدادات التطبيق":
                Button {
                    if let url = URL(
                        string: UIApplication.openSettingsURLString
                    ) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label(
                        "فتح إعدادات التطبيق",
                        systemImage: "gearshape"
                    )
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

            default:
                Text("الأداة غير متاحة")
            }

            Spacer()
        }
    }

    private var storageInformation: some View {
        let values = try? URL(
            fileURLWithPath: NSHomeDirectory()
        ).resourceValues(forKeys: [
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityKey
        ])

        return VStack(spacing: 15) {
            infoRow(
                "المساحة الكلية",
                formatBytes(values?.volumeTotalCapacity)
            )

            infoRow(
                "المساحة المتاحة",
                formatBytes(values?.volumeAvailableCapacity)
            )
        }
    }

    private var batteryInformation: some View {
        let percentage = batteryLevel < 0
            ? "غير متاح"
            : "\(Int(batteryLevel * 100))%"

        let state: String

        switch batteryState {
        case .charging:
            state = "قيد الشحن"
        case .full:
            state = "ممتلئة"
        case .unplugged:
            state = "غير موصولة بالشاحن"
        default:
            state = "غير معروف"
        }

        return VStack(spacing: 15) {
            infoRow("مستوى البطارية", percentage)
            infoRow("حالة الشحن", state)
        }
    }

    private func refreshBattery() {
        batteryLevel = UIDevice.current.batteryLevel
        batteryState = UIDevice.current.batteryState
    }

    private func infoRow(
        _ title: String,
        _ value: String
    ) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)

            Spacer()

            Text(value)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formatBytes(_ bytes: Int?) -> String {
        guard let bytes else {
            return "غير متاح"
        }

        return ByteCountFormatter.string(
            fromByteCount: Int64(bytes),
            countStyle: .file
        )
    }

    private func startMonitoring() {
        stopMonitoring()

        let newMonitor = NWPathMonitor()
        monitor = newMonitor

        newMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                connectionStatus = path.status == .satisfied
                    ? "متصل بالشبكة"
                    : "لا يوجد اتصال بالشبكة"
            }
        }

        newMonitor.start(queue: queue)
    }

    private func stopMonitoring() {
        monitor?.cancel()
        monitor = nil
    }
}


import SwiftUI
import Network

struct ToolsView: View {
    @State private var selectedTool: String?
    @State private var connectionStatus = "جاري الفحص..."
    @State private var isConnected = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ALMASIH.NetworkMonitor")

    private let tools = [
        ("فحص الاتصال", "wifi"),
        ("معلومات الجهاز", "iphone"),
        ("مساحة التخزين", "internaldrive"),
        ("حالة البطارية", "battery.100"),
        ("إعدادات التطبيق", "gearshape")
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("TOOLS")
                        .font(.largeTitle.bold())
                        .tracking(3)
                        .foregroundStyle(.white)

                    Text("مركز أدوات ALMASIH")
                        .foregroundStyle(.gray)

                    ForEach(tools, id: \.0) { tool in
                        Button {
                            selectedTool = tool.0
                        } label: {
                            HStack(spacing: 15) {
                                Image(systemName: tool.1)
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .frame(width: 48, height: 48)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                Text(tool.0)
                                    .foregroundStyle(.white)
                                    .font(.headline)

                                Spacer()

                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.gray)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .sheet(item: $selectedTool) { tool in
            toolDetails(tool)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            startNetworkMonitor()
        }
        .onDisappear {
            monitor.cancel()
        }
    }

    private func startNetworkMonitor() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                isConnected = path.status == .satisfied
                connectionStatus = isConnected ? "متصل بالإنترنت" : "لا يوجد اتصال"
            }
        }
        monitor.start(queue: queue)
    }

    @ViewBuilder
    private func toolDetails(_ tool: String) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                switch tool {
                case "فحص الاتصال":
                    Image(systemName: "wifi")
                        .font(.system(size: 45))
                    Text(connectionStatus)
                        .font(.title2.bold())
                    Text("هذه الأداة تفحص وجود اتصال بالشبكة، ولا تقيس سرعة الإنترنت.")
                        .foregroundStyle(.gray)

                case "معلومات الجهاز":
                    detailRow("الجهاز", UIDevice.current.model)
                    detailRow("النظام", UIDevice.current.systemVersion)

                case "مساحة التخزين":
                    if let values = try? URL(fileURLWithPath: NSHomeDirectory())
                        .resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey]) {
                        detailRow("المساحة الكلية", formatBytes(values.volumeTotalCapacity))
                        detailRow("المساحة المتاحة", formatBytes(values.volumeAvailableCapacity))
                    } else {
                        Text("تعذر قراءة معلومات التخزين")
                    }

                case "حالة البطارية":
                    detailRow("مستوى البطارية", batteryLevel)
                    detailRow("حالة الشحن", batteryState)

                case "إعدادات التطبيق":
                    Button("فتح إعدادات التطبيق") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .foregroundStyle(.white)

                default:
                    Text("الأداة غير متاحة")
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .foregroundStyle(.white)
            .navigationTitle(tool)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("إغلاق") {
                        selectedTool = nil
                    }
                }
            }
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.gray)
            Spacer()
            Text(value).foregroundStyle(.white)
        }
        .padding()
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var batteryLevel: String {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel
        return level < 0 ? "غير متاح" : "\(Int(level * 100))%"
    }

    private var batteryState: String {
        UIDevice.current.isBatteryMonitoringEnabled = true
        switch UIDevice.current.batteryState {
        case .charging: return "قيد الشحن"
        case .full: return "ممتلئة"
        case .unplugged: return "غير موصولة بالشاحن"
        default: return "غير معروف"
        }
    }

    private func formatBytes(_ bytes: Int?) -> String {
        guard let bytes else { return "غير متاح" }
        return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }
}

extension String: Identifiable {
    public var id: String { self }
}

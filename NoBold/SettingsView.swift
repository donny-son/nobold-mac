import SwiftUI

struct SettingsView: View {
    @ObservedObject var monitor: PasteboardMonitor

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                monitoringCard
                formatsCard
                activityCard
            }
            .padding(20)
        }
        .frame(width: 480, height: 500)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "bold")
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text("NoBold")
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                Text("Strip bold formatting from copied text.")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusPill(state: monitor.interfaceState)
        }
        .utilityCard()
    }

    private var monitoringCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Monitoring")
                .font(.system(.caption, design: .monospaced).weight(.medium))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Toggle("Automatic cleanup", isOn: $monitor.isEnabled)
                .font(.system(.subheadline, design: .monospaced))

            VStack(alignment: .leading, spacing: 8) {
                Text("Polling interval")
                    .font(.system(.caption, design: .monospaced).weight(.medium))

                Picker("Polling interval", selection: $monitor.pollingInterval) {
                    ForEach(PasteboardMonitor.allowedPollingIntervals, id: \.self) { interval in
                        Text(label(for: interval)).tag(interval)
                    }
                }
                .pickerStyle(.segmented)

                Text("0.5s is a good default — fast enough without hammering the pasteboard.")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
        }
        .utilityCard()
    }

    private var formatsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Formats to strip")
                .font(.system(.caption, design: .monospaced).weight(.medium))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            FormatPreferenceRow(
                title: ClipboardFormat.richText.title,
                detail: ClipboardFormat.richText.detail,
                systemImage: ClipboardFormat.richText.symbolName,
                isEnabled: $monitor.stripsRTF
            )

            FormatPreferenceRow(
                title: ClipboardFormat.html.title,
                detail: ClipboardFormat.html.detail,
                systemImage: ClipboardFormat.html.symbolName,
                isEnabled: $monitor.stripsHTML
            )

            FormatPreferenceRow(
                title: ClipboardFormat.markdown.title,
                detail: ClipboardFormat.markdown.detail,
                systemImage: ClipboardFormat.markdown.symbolName,
                isEnabled: $monitor.stripsMarkdown
            )
        }
        .utilityCard()
    }

    private var activityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity")
                .font(.system(.caption, design: .monospaced).weight(.medium))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            HStack {
                Text("Total cleanups")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(monitor.cleanupCount)")
                    .font(.system(.subheadline, design: .monospaced).weight(.medium))
            }

            HStack {
                Text("Last action")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                Spacer()
                if let lastEvent = monitor.lastEvent {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(lastEvent.headline)
                        Text(lastEvent.timestamp, style: .relative)
                            .foregroundStyle(.tertiary)
                    }
                    .font(.system(.caption, design: .monospaced))
                } else {
                    Text("—")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }
            }

            Divider()

            Button {
                monitor.cleanClipboardManually()
            } label: {
                Text("Clean Now")
                    .font(.system(.subheadline, design: .monospaced).weight(.medium))
            }
            .disabled(!monitor.hasEnabledFormats)
        }
        .utilityCard()
    }

    private func label(for interval: Double) -> String {
        switch interval {
        case 0.25:
            return "0.25s"
        case 0.5:
            return "0.5s"
        case 1.0:
            return "1.0s"
        case 1.5:
            return "1.5s"
        default:
            return String(format: "%.2fs", interval)
        }
    }
}

private struct FormatPreferenceRow: View {
    let title: String
    let detail: String
    let systemImage: String
    @Binding var isEnabled: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(.tertiary)
                .frame(width: 18)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.caption, design: .monospaced).weight(.medium))
                Text(detail)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .controlSize(.small)
        }
    }
}

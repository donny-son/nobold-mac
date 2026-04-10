import AppKit
import SwiftUI

struct MenuBarDashboard: View {
    @ObservedObject var monitor: PasteboardMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            statusCard
            controlCard
            formatsCard
            footerRow
        }
        .padding(14)
        .frame(width: 320)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "bold")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)

                Text("NoBold")
                    .font(.system(.headline, design: .monospaced))

                Spacer()

                StatusPill(state: monitor.interfaceState)
            }

            Text(monitor.statusHeadline)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(.primary)

            Text(monitor.statusDetail)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            HStack(spacing: 16) {
                MetricTile(title: "cleaned", value: "\(monitor.cleanupCount)")
                MetricTile(title: "interval", value: monitor.pollingIntervalLabel)
            }

            if let lastEvent = monitor.lastEvent {
                HStack(spacing: 4) {
                    Text(lastEvent.detail)
                    Text("·")
                    Text(lastEvent.timestamp, style: .relative)
                }
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.tertiary)
            }
        }
        .utilityCard()
    }

    private var controlCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle("Automatic cleanup", isOn: $monitor.isEnabled)
                .font(.system(.subheadline, design: .monospaced))
                .toggleStyle(.switch)

            Button {
                monitor.cleanClipboardManually()
            } label: {
                Text("Clean Now")
                    .font(.system(.subheadline, design: .monospaced).weight(.medium))
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .disabled(!monitor.hasEnabledFormats)

            Text("⌘⇧P toggle · ⌘⇧K clean")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
        .utilityCard()
    }

    private var formatsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Formats")
                .font(.system(.caption, design: .monospaced).weight(.medium))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            ForEach(ClipboardFormat.allCases) { format in
                FormatToggleRow(
                    format: format,
                    isEnabled: binding(for: format)
                )
            }
        }
        .utilityCard()
    }

    private var footerRow: some View {
        HStack {
            Button("About") {
                NSApplication.shared.activate(ignoringOtherApps: true)
                NSApplication.shared.orderFrontStandardAboutPanel(nil)
            }

            Spacer()

            Button("Settings…") {
                NSApplication.shared.activate(ignoringOtherApps: true)
                NSApplication.shared.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .font(.system(.caption, design: .monospaced))
        .foregroundStyle(.secondary)
        .buttonStyle(.plain)
    }

    private func binding(for format: ClipboardFormat) -> Binding<Bool> {
        switch format {
        case .richText:
            return $monitor.stripsRTF
        case .html:
            return $monitor.stripsHTML
        case .markdown:
            return $monitor.stripsMarkdown
        }
    }
}

struct MenuBarStatusIcon: View {
    let state: MonitorInterfaceState

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "bold")

            Circle()
                .fill(badgeColor)
                .frame(width: 5, height: 5)
                .offset(x: 2, y: 1)
        }
        .accessibilityLabel(accessibilityLabel)
    }

    private var badgeColor: Color {
        switch state {
        case .active:
            return Color(red: 0.20, green: 0.67, blue: 0.33)
        case .paused:
            return .secondary
        case .idle:
            return Color(red: 0.82, green: 0.57, blue: 0.12)
        }
    }

    private var accessibilityLabel: String {
        switch state {
        case .active:
            return "NoBold active"
        case .paused:
            return "NoBold paused"
        case .idle:
            return "NoBold needs a format enabled"
        }
    }
}

struct StatusPill: View {
    let state: MonitorInterfaceState

    var body: some View {
        Text(state.title.lowercased())
            .font(.system(.caption2, design: .monospaced).weight(.medium))
            .foregroundStyle(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule(style: .continuous)
                    .fill(fillColor)
            )
    }

    private var fillColor: Color {
        switch state {
        case .active:
            return Color(red: 0.20, green: 0.67, blue: 0.33).opacity(0.15)
        case .paused:
            return Color(nsColor: .quaternaryLabelColor).opacity(0.15)
        case .idle:
            return Color(red: 0.82, green: 0.57, blue: 0.12).opacity(0.15)
        }
    }

    private var textColor: Color {
        switch state {
        case .active:
            return Color(red: 0.20, green: 0.67, blue: 0.33)
        case .paused:
            return .secondary
        case .idle:
            return Color(red: 0.82, green: 0.57, blue: 0.12)
        }
    }
}

private struct MetricTile: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.system(.subheadline, design: .monospaced).weight(.medium))
                .foregroundStyle(.primary)

            Text(title)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
    }
}

private struct FormatToggleRow: View {
    let format: ClipboardFormat
    @Binding var isEnabled: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: format.symbolName)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.tertiary)
                .frame(width: 16)

            Text(format.title)
                .font(.system(.caption, design: .monospaced))

            Spacer()

            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .controlSize(.small)
        }
        .accessibilityElement(children: .combine)
    }
}

struct UtilityCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color(nsColor: .separatorColor).opacity(0.5), lineWidth: 0.5)
            )
    }
}

extension View {
    func utilityCard() -> some View {
        modifier(UtilityCardModifier())
    }
}

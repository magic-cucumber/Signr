import SwiftUI

struct ActivitySheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Label(String(localized: "History"), systemImage: "clock.arrow.circlepath").font(.headline)
                Spacer()
                Button {
                    model.clearHistory()
                } label: {
                    Label(String(localized: "Clear"), systemImage: "trash")
                }
                .disabled(model.history.isEmpty)
                Button(String(localized: "Done")) { dismiss() }.keyboardShortcut(.defaultAction)
            }
            .padding(16)
            Divider()

            if model.history.isEmpty {
                ContentUnavailableView(
                    String(localized: "No history yet"),
                    systemImage: "clock.arrow.circlepath",
                    description: Text(String(localized: "Apps you sign and install will be listed here"))
                )
                .frame(maxHeight: .infinity)
            } else {
                List(model.history) { entry in
                    HistoryRow(entry: entry)
                }
                .listStyle(.inset)
            }
        }
        .frame(width: 640, height: 480)
    }
}

private struct HistoryRow: View {
    let entry: HistoryEntry

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.success ? "checkmark.circle.fill" : "xmark.octagon.fill")
                .foregroundStyle(entry.success ? .green : .red)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.appName.isEmpty ? String(localized: "App") : entry.appName).font(.callout.weight(.medium))
                if !entry.bundleId.isEmpty {
                    Text(entry.bundleId).font(.caption.monospaced()).foregroundStyle(.secondary)
                }
                Text(entry.localizedDetail).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 2) {
                Label(entry.target == "Export" ? String(localized: "Export") : entry.target, systemImage: entry.target == "Export" ? "square.and.arrow.up" : "iphone.gen3")
                    .labelStyle(.titleAndIcon).font(.caption).foregroundStyle(.secondary)
                Text(entry.date, format: .relative(presentation: .named))
                    .font(.caption2).foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
        .textSelection(.enabled)
    }
}

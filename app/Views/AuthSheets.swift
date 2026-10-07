import SwiftUI

struct SignInSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var appleID = ""
    @State private var password = ""

    var body: some View {
        @Bindable var model = model
        VStack(spacing: 18) {
            Image(systemName: model.twoFactorPrompt ? "lock.shield.fill" : "person.badge.key.fill")
                .font(.system(size: 36)).foregroundStyle(Brand.tint)

            if model.twoFactorPrompt {
                Text(String(localized: "Two-Factor Authentication")).font(.headline)
                Text(model.twoFactorRequest?.method == .sms
                     ? String(localized: "Apple sent a code by SMS. Enter it below")
                     : String(localized: "Apple sent a 6-digit code to the trusted devices for this Apple ID. Enter it below"))
                    .font(.caption).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)

                TextField("000000", text: $model.twoFactorCode)
                    .textFieldStyle(.roundedBorder)
                    .font(.title.monospacedDigit())
                    .multilineTextAlignment(.center)
                    .frame(width: 180)
                    .disabled(model.twoFactorBusy)
                    .onSubmit { model.submitTwoFactor() }

                if let error = model.twoFactorError {
                    Text(error).font(.caption).foregroundStyle(.red)
                }

                if let phones = model.twoFactorRequest?.phones, !phones.isEmpty {
                    VStack(spacing: 3) {
                        Text(String(localized: "Didn't get a code?")).font(.caption2).foregroundStyle(.secondary)
                        ForEach(phones, id: \.id) { phone in
                            Button {
                                model.sendTwoFactorSms(phoneID: phone.id)
                            } label: {
                                Label(phone.lastTwoDigits.isEmpty
                                      ? String(localized: "Send code via SMS")
                                      : String(localized: "Send code via SMS ••\(phone.lastTwoDigits)"),
                                      systemImage: "message")
                                    .font(.caption)
                            }
                            .buttonStyle(.link)
                            .disabled(model.twoFactorBusy)
                        }
                    }
                }

                HStack(spacing: 10) {
                    Button(String(localized: "Cancel"), role: .cancel) { model.cancelTwoFactor() }
                        .keyboardShortcut(.cancelAction)
                    if model.twoFactorBusy { ProgressView().controlSize(.small) }
                    Button(String(localized: "Verify")) { model.submitTwoFactor() }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.defaultAction)
                        .disabled(model.twoFactorBusy
                                  || model.twoFactorCode.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } else {
                Text(String(localized: "Sign in with your Apple ID")).font(.headline)
                Text(String(localized: "Signr uses your Apple ID like Xcode does, to request a certificate and provisioning profile for your apps. Your credentials are sent only to Apple"))
                    .font(.caption).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 10) {
                    TextField(String(localized: "Apple ID"), text: $appleID)
                        .textContentType(.username)
                    SecureField(String(localized: "Password"), text: $password)
                        .textContentType(.password)
                        .onSubmit(submit)
                }
                .textFieldStyle(.roundedBorder)

                if let error = model.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption).foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack {
                    Button(String(localized: "Cancel")) { dismiss() }
                        .keyboardShortcut(.cancelAction)
                    Spacer()
                    Button {
                        submit()
                    } label: {
                        if model.isWorking {
                            ProgressView().controlSize(.small)
                        } else {
                            Text(String(localized: "Sign In"))
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .disabled(appleID.isEmpty || password.isEmpty || model.isWorking)
                }

                Text(String(localized: "Tip: a free Apple ID works (7-day re-sign limit)"))
                    .font(.caption2).foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .frame(width: 380)
        .interactiveDismissDisabled(model.isWorking)
    }

    private func submit() {
        guard !appleID.isEmpty, !password.isEmpty else { return }
        model.signIn(appleID: appleID, password: password)
    }
}

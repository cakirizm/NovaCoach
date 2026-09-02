import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: AppStore
    @State private var mode: AuthMode = .login
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var resetPassword = ""
    @State private var showReset = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Spacer(minLength: 44)
                    ZStack {
                        RoundedRectangle(cornerRadius: 26).fill(Color.accentColor.opacity(0.12)).frame(width: 92, height: 92)
                        Image(systemName: "sparkles.rectangle.stack.fill").font(.system(size: 44)).foregroundStyle(.tint)
                    }
                    VStack(spacing: 8) {
                        Text("NovaCoach").font(.system(size: 38, weight: .bold, design: .rounded))
                        Text("Kendi sınav koçun. Her gün planını günceller.").foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }
                    Picker("Hesap", selection: $mode) {
                        Text("Giriş Yap").tag(AuthMode.login)
                        Text("Kayıt Ol").tag(AuthMode.register)
                    }.pickerStyle(.segmented)
                    VStack(spacing: 12) {
                        if mode == .register { TextField("Ad Soyad", text: $name).textContentType(.name).textFieldStyle(.roundedBorder) }
                        TextField("E-posta", text: $email).textContentType(.emailAddress).keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled().textFieldStyle(.roundedBorder)
                        SecureField("Şifre", text: $password).textContentType(mode == .register ? .newPassword : .password).textFieldStyle(.roundedBorder)
                    }
                    if let error = store.authError { Text(error).font(.footnote).foregroundStyle(.red).frame(maxWidth: .infinity, alignment: .leading) }
                    Button(mode == .login ? "Giriş Yap" : "Hesap Oluştur") {
                        if mode == .login { store.login(email: email, password: password) }
                        else { store.register(name: name, email: email, password: password) }
                    }.buttonStyle(.borderedProminent).controlSize(.large).frame(maxWidth: .infinity)
                    if mode == .login {
                        Button("Şifremi Unuttum") { showReset = true }
                            .sheet(isPresented: $showReset) {
                                NavigationStack {
                                    Form {
                                        TextField("E-posta", text: $email).textInputAutocapitalization(.never)
                                        SecureField("Yeni şifre", text: $resetPassword)
                                        if let error = store.authError { Text(error).foregroundStyle(.red) }
                                        Button("Şifreyi Güncelle") {
                                            store.resetPassword(email: email, newPassword: resetPassword)
                                            if store.authError == nil { showReset = false; password = resetPassword }
                                        }
                                    }.navigationTitle("Şifre Yenile").toolbar { ToolbarItem(placement: .cancellationAction) { Button("Kapat") { showReset = false } } }
                                }.presentationDetents([.medium])
                            }
                    }
                    Text("Hesap bilgileri bu fazda iPhone Keychain üzerinde güvenli biçimde tutulur. Bulut senkronizasyonu backend bağlandığında açılacak.").font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }.padding(24)
            }
        }
    }
}

enum AuthMode { case login, register }

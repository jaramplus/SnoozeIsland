//
//  SetupView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 1/31/25.
//

import SwiftUI

struct SetupView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel

    @State var isSound: Bool {
        didSet {
            snoozeViewModel.isSound = isSound
            }
    }
    
    @State var isAlarm: Bool {
        didSet {
            snoozeViewModel.isAlarm = isAlarm
            }
    }
    
    @Binding var setupMenu: Bool
    
    init(snoozeViewModel: SnoozeIslandViewModel, setupMenu: Binding<Bool>) {
          _isSound = State(initialValue: snoozeViewModel.isSound)
          _isAlarm = State(initialValue: snoozeViewModel.isAlarm)
        _setupMenu = setupMenu
      }
    
    
    var body: some View {
        
        VStack {
            HStack(alignment: .center) {
                Spacer()
                Text(snoozeViewModel.currentLanguage == .korean ? "설정" : "Setting")
                    .bold()
                Spacer()
            }
            .overlay {
                HStack {
                    Button(action: { withAnimation { setupMenu.toggle() } } ) {
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.black)
                    }
                    .padding()
                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(true)
            
            
            VStack {
                
                VStack {
                    HStack {
                        Image(snoozeViewModel.isNight ? "music-1" : "music")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        Text(snoozeViewModel.currentLanguage == .korean ? "소리" : "Sound")
                        
                        Spacer()
                        Toggle("", isOn: $isSound)
                            .padding()
                            .tint(snoozeViewModel.isNight  ? .darkPurple : .lightPurple)
                    }
                    
                    VStack {
                        HStack {
                            Image(snoozeViewModel.isNight ? "alert-1" : "alert")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                            
                            Text(snoozeViewModel.currentLanguage == .korean ? "알림" : "Alert")
                            Spacer()
                            Toggle("", isOn: $isAlarm)
                                .padding()
                                .tint(snoozeViewModel.isNight  ? .darkPurple : .lightPurple)
                        }
                        
                    }
                }
                
                
                Button(action: {
                        let url = createEmailUrl(to: "jaramplus@gmail.com", subject: "", body: "")
                        openURL(urlString: url)
                        // TODO: 로그인 안될 때엔 어떻게 됩니까?
                }) {
                    HStack {
                        Spacer()
                        Text(snoozeViewModel.currentLanguage == .korean ? "제작자에게 문의하기" : "Contact the creator")
                        Spacer()
                    }
                }
                .buttonStyle(SubButton())
                .padding(.top, 32)
            }
            .padding(.top, 48)
        }
        .padding()
        .background(.regularMaterial)
        .mask {
            RoundedRectangle(cornerRadius: 10.0)
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 450)
    }
    
    func openURL(urlString: String){
        if let url = URL(string: "\(urlString)"){
            if #available(iOS 10.0, *){
                UIApplication.shared.open(url)
            }
            else{
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func createEmailUrl(to: String, subject: String, body: String) -> String {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let defaultUrl = "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)"
        
        return defaultUrl
    }
}
    
#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
        
    SetupView(snoozeViewModel: snoozeViewModel, setupMenu: .constant(false))
            .environmentObject(snoozeViewModel)
}

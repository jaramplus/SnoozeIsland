//
//  WarningAlertView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 6/8/25.
//

//
//  SetupView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 1/31/25.
//

import SwiftUI

struct WarningAlertView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    @Binding var warningAlert: Bool
    
    var body: some View {
        
        VStack {
            HStack(alignment: .center) {
                Spacer()
                Text("주의")
                    .bold()
                Spacer()
            }
            .overlay {
                HStack {
                    Button(action: { withAnimation { warningAlert.toggle() } } ) {
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.black)
                    }
                    .padding()
                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(true)
            
            
            VStack {

                VStack(spacing: 0) {
                    Text("먼저 왼쪽 시작 메뉴 버튼을 눌러")
                    Text(" 주기를 설정해주세요 ")
                }
                .font(.subheadline)
                .padding()
                .navigationBarBackButtonHidden(true)
                
                
                
                Button(action: {
                    withAnimation {
                        warningAlert.toggle()
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("확인")
                        Spacer()
                    }
                        
                }
                .buttonStyle(PrimaryButton())
                .padding(.top)
            }
            .padding()
        }
        .padding()
        .background(.regularMaterial)
        .mask {
            RoundedRectangle(cornerRadius: 10.0)
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 450)
        .foregroundStyle(snoozeViewModel.isNight ? .white : .black)
    }
}
    
#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
        
    WarningAlertView(warningAlert: .constant(false))
        .environmentObject(snoozeViewModel)
}

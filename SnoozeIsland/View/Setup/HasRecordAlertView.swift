//
//  HasRecordAlertView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 7/20/25.
//


import SwiftUI

struct HasRecordAlertView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    @Binding var hasRecordAlert: Bool
    
    var body: some View {
        
        VStack {
            HStack(alignment: .center) {
                Spacer()
                Text(snoozeViewModel.currentLanguage == .korean ? "주의" : "Notice")
                    .bold()
                Spacer()
            }
            .overlay {
                HStack {
                    Button(action: { withAnimation { hasRecordAlert.toggle() } } ) {
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.black)
                    }
                    .padding()
                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(true)
            .padding()
            
            
            VStack {

                VStack(spacing: 0) {
                    Text(snoozeViewModel.currentLanguage == .korean ? "오늘은 이미 수면이 기록되었습니다" : "Your sleep has already been recorded today.")
                    Text(snoozeViewModel.currentLanguage == .korean ? "내일 다시 단잠의 섬을 찾아주세요." : "Please try again tomorrow.")
                }
                .font(.subheadline)
                .navigationBarBackButtonHidden(true)
                
                
                
                Button(action: {
                    withAnimation {
                        hasRecordAlert.toggle()
                    }
                }) {
                    HStack {
                        Spacer()
                        Text(snoozeViewModel.currentLanguage == .korean ? "확인" : "OK")
                        Spacer()
                    }
                        
                }
                .buttonStyle(PrimaryButton())
                .padding(.top)
            }
            .padding()
        }
        .background(.regularMaterial)
        .mask {
            RoundedRectangle(cornerRadius: 10.0)
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 500)
        .foregroundStyle(snoozeViewModel.isNight ? .white : .black)
    }
}
    
#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
        
    WarningAlertView(warningAlert: .constant(false))
        .environmentObject(snoozeViewModel)
}

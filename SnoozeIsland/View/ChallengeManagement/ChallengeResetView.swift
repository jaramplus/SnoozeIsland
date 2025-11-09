//
//  ChallengeResetView_.swift
//  SnoozeIsland
//
//  Created by jose Yun on 3/23/25.
//

import SwiftUI

struct ChallengeResetView: View {
    @Binding var startMenu: Bool
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    @State var isReset = false
    @Binding var control: Bool
    
    var body: some View {
                VStack {
                    HStack(alignment: .center) {
                        Spacer()
                        Text(snoozeViewModel.currentLanguage == .korean ?
                             "습관 형성" : "Habit Building")
                            .bold()
                        Spacer()
                    }
                    .overlay {
                        HStack {
                            Button(action: { withAnimation { control.toggle() }} ) {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.black)
                            }
                            .padding()
                            Spacer()
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                    .padding(.vertical)
                    
                    VStack(alignment: .center ){
                        
                        Text(snoozeViewModel.currentLanguage == .korean ?
                             "형성 중인 습관 주기가 초기화됩니다." : "The habbit routine will be all initialized")
                        Text(snoozeViewModel.currentLanguage == .korean ?
                             "다시 설정하겠습니까?" : "Would you like to set-up again?")
                    }
                    .padding()
                    
                    Button(action: {
                        snoozeViewModel.reset()
                        isReset.toggle()
                        withAnimation {
                            startMenu.toggle()
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text(snoozeViewModel.currentLanguage == .korean ?
                                 "확인" : "OK")
                            Spacer()
                        }
                    }
                    .buttonStyle(PrimaryButton())
                    .padding(.top)
                    .padding(.bottom, 16)
                }
            .padding()
            .background(.regularMaterial)
            .mask {
                RoundedRectangle(cornerRadius: 10.0)
            }
            .frame(width: UIScreen.main.bounds.width * 0.9, height: 450)
    }
}

#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel

    HomeView()
        .environmentObject(snoozeViewModel)
//    ChallengeResetView(startMenu: .constant(false))
}

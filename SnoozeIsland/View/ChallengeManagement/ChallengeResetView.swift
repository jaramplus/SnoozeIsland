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
                        Text("습관 형성")
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
                        Text("형성 중인 습관 주기가")
                        Text("초기화됩니다.")
                        Text("다시 설정하겠습니까?")
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
                            Text("확인")
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

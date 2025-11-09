//
//  ChallengeSetupView_.swift
//  SnoozeIsland
//
//  Created by jose Yun on 6/8/25.
//


import SwiftUI

struct ChallengeSetupView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    @Binding var startMenu: Bool
    @State var onActive = false
    @Binding var sleepTime: Date
    @Binding var wakeTime: Date
    @State private var path: [String] = []
    @Binding var control: Bool
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Spacer()
                Text(snoozeViewModel.currentLanguage == .korean ?
                     "습관 설정" : "Habit Setup")
                    .bold()
                Spacer()
            }
            .overlay {
                HStack {
                    Button(action: { withAnimation { startMenu.toggle() } } ) {
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
                    Text(snoozeViewModel.currentLanguage == .korean ?
                         "섬의 낮과 밤 시간을" : "Please set up day")
                    Text(snoozeViewModel.currentLanguage == .korean ?
                         " 설정해주세요 " : "and night of SnoozeIsland")
                }
                .font(.subheadline)
                .padding()
                .navigationBarBackButtonHidden(true)
                
                TimeView()
                    .padding(.horizontal)
                
                Button(action: {
                    withAnimation {
                        control.toggle()
                    }
                })
                {
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
        }
        .padding()
        .background(.regularMaterial)
        .mask {
            RoundedRectangle(cornerRadius: 10.0)
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 450)
    }
    
    private func TimeView() -> some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                HStack {
                    Image(systemName: "sun.max.fill")
                    Text(snoozeViewModel.currentLanguage == .korean ?
                         "기상" : "Daytime")
                }
                .font(.system(size: 18))
                Spacer()
                Text(wakeTime.formatted(myFormat))
                    .padding()
                    .environment(\.locale, Locale.init(identifier: String(Locale.preferredLanguages[0].prefix(2))))
                    .overlay {
                        DatePicker("", selection: $wakeTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.graphical)
                            .foregroundStyle(.clear)
                            .blendMode(.destinationOver)
                            .font(.system(size: 24))
                        
                    }
                Spacer()
            }
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal)
                .foregroundStyle(.clear)
            
            HStack {
                Spacer()
                HStack {
                    Image(systemName: "moon.fill")
                    Text(snoozeViewModel.currentLanguage == .korean ?
                         "취침" : "Bedtime")
                    
                }
                .font(.system(size: 18))
                
                Spacer()
                Text(sleepTime.formatted(myFormat))
                    .padding()
                    .overlay {
                        DatePicker("", selection: $sleepTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.graphical)
                            .foregroundStyle(.clear)
                            .blendMode(.destinationOver)
                            .font(.system(size: 24))
                        
                    }
                Spacer()
            }
            .padding(.vertical, 8)
        }

    }
}

#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
        
    
    HomeView()
        .environmentObject(snoozeViewModel)
}


import Foundation
import TokamakDOM

struct StartANewGameView: View {
    let session: Session

    var body: some View {
        VStack {
            Text("How many rounds").font(.title)

            Text("In every round each player will have a turn judging everyone else's submissions.").font(.callout).fontWeight(.regular)
            Text("If you don't get it, don't worry. You'll learn by playing...").font(.callout).fontWeight(.regular)

            Spacer().frame(width: 0, height: 4)

            HStack {
                ForEach(0..<10) { number in
                    NumberOfRoundsButton(number: number + 1, session: session)
                }
            }
        }
    }
}


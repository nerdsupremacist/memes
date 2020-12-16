
import Foundation
import TokamakDOM
import Model

struct ChooseKindView: View {
    @Binding
    var kind: GameStartView.Kind?

    var body: some View {
        VStack {
            Spacer()

            VStack {
                Text("Welcome!").font(.title).fontWeight(.heavy)
                Text("This is a game where you pick the captions for memes.").font(.callout).fontWeight(.regular)
                Text("One person get's to decide which is the funniest.").font(.callout).fontWeight(.regular)
            }

            Spacer().frame(width: 0, height: 16)

            Text("Let's see who the funniest/most horrible person in your group is...").font(.callout).fontWeight(.regular)

            Spacer().frame(width: 0, height: 8)

            HStack {
                CustomButton("Start a Game", character: "1") {
                    kind = .start
                }

                CustomButton("Join a Game", character: "2") {
                    kind = .join
                }
            }

            Spacer()

            Text("P.S.: If you're one of those who hates using a mouse, underneath every button is a label with the key you can press instead").font(.callout).fontWeight(.regular)
            Spacer().frame(width: 0, height: 16)
        }
    }
}

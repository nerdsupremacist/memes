
import Foundation
import TokamakDOM

struct NumberOfRoundsButton: View {
    let number: Int
    let session: Session

    var body: some View {
        CustomButton(String(number % 10), character: String(number % 10).first!, width: 100, height: 100, action: { session.configure(rounds: number) })
    }
}

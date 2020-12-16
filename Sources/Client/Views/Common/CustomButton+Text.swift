
import Foundation
import TokamakDOM

extension CustomButton where Content == StandardButtonContent {

    init(_ text: String,
         character: Character,
         width: Double = 200,
         height: Double = 70,
         action: @escaping () -> Void) {

        self.init(character: character, action: action) {
            StandardButtonContent(text, width: width, height: height)
        }
    }

}

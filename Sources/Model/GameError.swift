
import Foundation

public enum GameError: String, Codable {
    case gameNotFound

    case onlyTheHostCanStart
    case onlyTheHostCanEnd

    case tooManyPlayersDroppedOut

    case gameCanOnlyStartWithAMinimumOfThreePlayers
    case judgeCannotPlayACard
    case onlyJudgeCanChoose
    case cannotPlayACardNotInTheHand
    case cannotPlayTwiceForTheSameCard
    case cardWasNotPlayed

    case gameAlreadyStarted

    case illegalEvent
    case failedToDecodeEvent
}

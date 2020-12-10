
import Foundation
import Model

class StandardDeck: Deck {
    private var playedImages: Set<URL> = []
    private var playedCardText: Set<String> = []
    private let memes: [URL]
    private let captions: [String]

    init(memes: [URL], captions: [String]) {
        self.memes = memes
        self.captions = captions
    }

    func reshuffle() {
        playedImages = []
        playedCardText = []
    }

    func card(for player: Player, in game: Game) -> Card {
        if Int.random(in: 0...100) < 5 {
            return .freestyle
        }

        var caption: String
        repeat {
            caption = captions.randomElement()!
        } while playedCardText.contains(caption)

        playedCardText.formUnion([caption])
        return .text(caption)
    }

    func meme(for judge: Player, in game: Game) -> Meme {
        var url: URL
        repeat {
            url = memes.randomElement()!
        } while playedImages.contains(url)

        playedImages.formUnion([url])
        return Meme(judge: judge, image: url)
    }
}

extension StandardDeck {

    #if os(macOS)
    private static func url(_ file: String = #file) -> URL {
        let url = URL(fileURLWithPath: file)
        return url
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("deck.json")
    }

    private static let deckURL: URL = {
        return url()
    }()
    #else
    private static let deckURL: URL = URL(fileURLWithPath: "deck.json")
    #endif

    static let basic: StandardDeck = {
        let data = try! Data(contentsOf: deckURL)
        let export = try! JSONDecoder().decode(StandardDeck.Export.self, from: data)
        return StandardDeck(from: export)
    }()
}

extension StandardDeck {

    private struct Export: Codable {
        let memes: [URL]
        let captions: [String]
    }

    private convenience init(from export: Export) {
        self.init(memes: export.memes, captions: export.captions)
    }
}

extension StandardDeck {

    private static let memes: Set<URL> = {
        let arrays = [
            otherURL.compactMap(URL.init(string:)),
            imgFlipNameFiles.compactMap { URL(string: "https://imgflip.com/s/meme/\($0)") },
            imgFlipIdFiles.compactMap { URL(string: "https://i.imgflip.com/\($0)") },
            memeGeneratorIds.compactMap { URL(string: "https://memegenerator.net/img/images/600x/\($0).jpg") }
        ]

        return arrays.reduce([]) { $0.union($1) }
    }()

    private static let otherURL: Set<String> = [
        "http://i3.kym-cdn.com/photos/images/original/000/847/015/01a.jpg",
        "http://images.memes.com/character/meme/facepalm.jpg",
        "https://i1.kym-cdn.com/photos/images/newsfeed/000/348/078/2b0.jpg",
        "https://i1.kym-cdn.com/photos/images/original/000/344/204/bdb.jpg",
        "https://www.memecreator.org/static/images/templates/441422.jpg",
        "https://i2-prod.mirror.co.uk/incoming/article7633233.ece/ALTERNATES/s1200/Ben-Affleck-in-Batman-V-Superman-interview.jpg",
        "https://i.pinimg.com/736x/35/ca/40/35ca40851569d6f000b90b93c270f594.jpg",
        "http://i3.ytimg.com/vi/BT3XE3HGRTI/hqdefault.jpg",
        "https://i.imgur.com/zY4asYV.jpg",
        "https://i.imgur.com/qyP8OXy.jpg",
        "https://i.imgur.com/i9OOKXp.jpg",
        "https://i.imgur.com/6Ln3hp8.jpg",
        "https://i.pinimg.com/736x/7c/1c/8f/7c1c8f7ab122d725fc53983d78f10c99.jpg",
        "http://www.bloodygoodhorror.com/bgh/files/reviews/caps/vampires-kiss.jpg",
        "http://www.rumba.fi/wp-content/uploads/Obama-not-bad-meme.jpg",
        "http://www.stuff.co.nz/content/dam/images/1/2/v/g/c/f/image.related.StuffLandscapeSixteenByNine.620x349.12vfsk.png/1421897599533.jpg",
        "https://carboncostume.com/wordpress/wp-content/uploads/2013/05/gusfring.jpg",
    ]

    private static let imgFlipNameFiles: Set<String> = [
        "Sudden-Clarity-Clarence.jpg",
        "Picard-Wtf.jpg",
        "10-Guy.jpg",
        "confession-kid.jpg",
        "Lazy-College-Senior.jpg",
        "College-Freshman.jpg",
        "I-Should-Buy-A-Boat-Cat.jpg",
        "Chemistry-Cat.jpg",
        "Overly-Attached-Girlfriend.jpg",
        "Evil-Plotting-Raccoon.jpg",
        "Scumbag-Boss.jpg",
        "First-Day-On-The-Internet-Kid.jpg",
        "Joker-Rainbow-Hands.jpg",
        "Good-Guy-Putin.jpg",
        "Weird-Stuff-I-Do-Potoo.jpg",
        "You-Were-The-Chosen-One-Star-Wars.jpg",
        "Patrick-Says.jpg",
        "I-Too-Like-To-Live-Dangerously.jpg",
        "Joseph-Ducreux.jpg",
        "Awkward-Moment-Sealion.jpg",
    ]

    private static let imgFlipIdFiles: Set<String> = [
        "1ur9b0.jpg",
        "261o3j.jpg",
        "22bdq6.jpg",
        "3lmzyx.jpg",
        "9ehk.jpg",
        "46e43q.png",
        "3oevdk.jpg",
        "1yxkcp.jpg",
        "23ls.jpg",
        "1c1uej.jpg",
        "28j0te.jpg",
        "1w7ygt.jpg",
        "4acd7j.png",
        "2kbn1e.jpg",
        "gk5el.jpg",
        "21tqf4.jpg",
        "1h7in3.jpg",
        "2fm6x.jpg",
        "1otk96.jpg",
        "392xtu.jpg",
        "3i7p.jpg",
        "1ii4oc.jpg",
        "wxica.jpg",
        "26am.jpg",
        "21uy0f.jpg",
        "2wifvo.jpg",
        "gtj5t.jpg",
        "1bgw.jpg",
        "265j.jpg",
        "4t0m5.jpg",
        "1e7ql7.jpg",
        "1bhw.jpg",
        "265k.jpg",
        "26br.jpg",
        "8k0sa.jpg",
        "51s5.jpg",
        "39t1o.jpg",
        "1bh8.jpg",
        "1b42wl.jpg",
        "2hgfw.jpg",
        "9vct.jpg",
        "1bhm.jpg",
        "hmt3v.jpg",
        "1bip.jpg",
        "8p0a.jpg",
        "9sw43.jpg",
        "1bhf.jpg",
        "1bim.jpg",
        "jrj7.jpg",
        "ljk.jpg",
        "8h0c8.jpg",
        "3si4.jpg",
        "2tn11b.jpg",
        "1bil.jpg",
        "26hg.jpg",
        "odluv.jpg",
        "ae11i.jpg",
    ]

    private static let memeGeneratorIds: Set<Int> = [
        11438,
        13374,
        12485,
        12428,
        11811,
        12888,
        11751,
        11971,
        12147,
        13321,
        13491,
        10257,
        11149,
        13657,
        10038,
        12411,
        11099,
        12845,
        13336,
        13638,
        13252,
        13683,
        11750,
        10658,
        13365,
        13680,
        13611,
        12974,
        13654,
        12540,
        13152,
        13097,
        9981,
        11059,
        11509,
        10103,
        13220,
        11907,
        13397,
        10560,
        13237,
        13328,
        13682,
        11992,
        13556,
        13351,
        13595,
        10932,
        11151,
        12422,
        13477,
        11911,
        10208,
        10210,
        12859,
        12041,
        12218,
        10805,
        12009,
        9783,
        10809,
        10706,
        11810,
        12333,
        11657,
        10486,
        11884,
        11037,
        10090,
        9501,
        13195,
        13200,
        12988,
        11275,
        10684,
        13236,
        12989,
        13113,
        12475,
        13560,
        13675,
        12647,
        12798,
        12448,
        13230,
        11150,
        11763,
        12000,
        13448,
        10554,
        11836,
        11539,
        11783,
        10574,
        11710,
        9794,
        12433,
        11173,
        13469,
        12363,
        12209,
        13672,
        11478,
        13381,
        13075,
        11926,
        13258,
        10009,
        10235,
        12159,
        10553,
        12240,
        12319,
        10158,
        10843,
        11490,
        13493,
        13600,
        12094,
        12439,
        13148,
        13473,
        12055,
        13634,
        12429,
        10136,
        11090,
    ]

    private static let captions: Set<String> = [
        """
        Me: *makes joke of foreign country*
        Guy from the country: *laughs*
        White girl:
        """,
        """
        Micheal Bublé emerging from his cave to signal the start of Christmas season.
        """,
        """
        Americans when you use meters instead of school shootings per mcdonalds
        """,
        """
        When you step on a Lego
        """,
        """
        Me trying to time my fart next to my crush with a sound in the room.
        """,
        """
        Me realizing that I'm wrong halfway through an argument
        """,
        """
        Society if it was run by the lofi beats chat
        """,
        """
        When you see someone bite into their ice-cream
        """,
        """
        When the waitress comes to your table and asks if you want fries with your meal but you say no because you're on a diet, but she comes back and asks if you're sure.
        """,
        """
        America on their way to a third world country that just discovered oil
        """,
        """
        When you get toothpaste on your pants while brushing my teeth
        """,
        """
        2020 finale:
        """,
        """
        Time Traveller: What year is it?
        Me: 2020
        Time Traveller:
        """,
        """
        When you and a stranger have to stop so your dogs can meet
        """,
        """
        Waiter: *gets my order wrong*
        Waiter: "Is everything ok?"
        Me:
        """,
        """
        Teacher: So does anyone have the answer?
        Me: *who already finished but doesnt wanna be called on*
        """,
        """
        Me when I remember all my assignments are due tomorrow
        """,
        """
        When you beat your personal record by jerking off 26 times in a day but now your hand is stuck in position
        """,
        """
        Her: He is probably cheating on me right now
        Him:
        """,
        """
        When your dildo finally arrives
        """,
        """
        When you want hard degrading sex, but he just wants to make love
        """,
        """
        When your vibrator dies right before you finish
        """,
        """
        When the dude you hooked up with last night wants to connect on LinkedIn
        """,
        """
        When you finish the test early and someone afterwards asks what you wrote in the essay question
        """,
        """
        When it's April 2nd and she's still pregnant
        """,
        """
        When you're writing a test and type 2+2 in the calculator. Just to be sure.
        """,
        """
        When teacher explains a poem and you find out that the poem has more meaning than your life
        """,
        """
        When I finally think of the perfect comeback a whole week later
        """,
        """
        When someone asks if you voted for Donald Trump
        """,
        """
        When the tampon accidentally touches your G-Spot
        """,
        """
        When you try anal for the first time
        """,
        """
        When your fart smells Gourmet
        """,
        """
        Me: *slightly overcooks the steak*
        Gordon Ramsay:
        """,
        """
        When 2 horny people have sex, and now you gotta struggle through BS, get job, and pay taxes...
        """,
        """
        When you relate to every meme, but all the memes are about being sad, broke or an alcoholic
        """,
        """
        When you finally get a notification, but it's from Team Snapchat
        """,
        """
        When you fart so hard your ass itch goes away
        """,
        """
        When there's no toilet paper left so you have to twerk
        """,
        """
        Me: This time I'll have a healthy sleep schedule
        Also me at 3:00 am:
        """,
        """
        When no one calls you on your birthday
        """,
        """
        When you guessed the right answer to the only question the smart kid got wrong on the test
        """,
        """
        Horror movie exposition: 18 people died in this house, 4 were murdered with an axe and 7 killed themselves
        Family:
        """,
        """
        Men only want one thing. And it's disgusting:
        """,
        """
        Girls sleepover: Let's talk about that one hot boy in our class...
        Boys sleepover:
        """,
        """
        When you try your dogs food
        """,
        """
        Me and friend running from the orphanage after telling Dad jokes and Joe Mama jokes
        """,
        """
        When the wifi doesn't work so you try to plug it out and back in. But it's still not working
        """,
        """
        Me after I have handed in my master thesis
        """,
        """
        How I sleep knowing my opinion offended someone on the internet
        """,
        """
        Me: *does Naruto hand signs*
        The deaf kid trying to figure out why want to fuck his dad:
        """,
        """
        When the class average is 52%, and you got a 52.5%
        """,
        """
        Your dog when you stop him from sniffing butts but he sees you eating ass
        """,
        """
        When you want to send a dick pic, and it says: File too large
        """,
        """
        When you're watching a movie with your parents and a sex scene comes on
        """,
        """
        When you were searching for your phone, but you realize it's in your hand
        """,
        """
        8 year old me when I had to finish my vegetables for Africa
        """,
        """
        When the website offers you cookies, but you're british
        """,
        """
        When you get an unskippable ad and it's (1/4)
        """,
        """
        When you drop your phone, try to catch it with your foot and smash it in the wall
        """,
        """
        When you pause the YouTube vid to read the text, but then they give you time to read the text when you unpause
        """,
        """
        When you're about to nut, but the plot of the porn thickens
        """,
        """
        When you stub your pinky toe on the coffee table and try to play it off like it doesn't feel like you're gonna die
        """,
        """
        When you're pissing in a pool and have to act like you're not pissing a pool
        """,
        """
        When you see someone you know in public
        """,
        """
        When you clog the toilet at your friends house and there isn't a plunger around
        """,
        """
        When the lego set says 9-15 years, but you swallow all the pieces in 25 minutes
        """,
        """
        When its /Sun/day, but its raining
        """,
        """
        When people ask you "plz" because it's shorter than "please", so tell them "no" because it's shorter than "yes"
        """,
        """
        When you get fired from your job at Pepsi, because you tested positive for coke
        """,
        """
        When your girlfriend says your should treat her like a princess
        So you marry her off to some stranger to strengthen the alliance with france
        """,
        """
        When your crush sends you cute texts like "Who are you?" and "How did you get this number?"
        """,
        """
        When its already 9 p.m and you still have to do that workout you promised yourself you would do
        """,
        """
        That moment when u moment when u smoke and the blunt that smoke when u moment smoke that moment blunt when u moment
        """,
        """
        When you're high and try to fold the dishes
        """,
        """
        That face you make when you're washing the dishes and your finger touches some soggy food
        """,
        """
        When your supposed to be working on homework, but your just sitting here like
        """,
        """
        When you just finished your pizza rolls and think about all the good times, when you still had pizza rolls
        """,
        """
        When you already started eating
        And someone says lets pray
        """,
        """
        When your teacher bends down to talk to the person next to you
        """,
        """
        When you high af and your mom calls you on facetime
        """,
        """
        When someone asks you about your hobbies but your hobby is YouTube
        """,
        """
        When you successfully make pasta without burning the house down
        """,
        """
        When your the reason for the company saftey video
        """,
        """
        When you overdose on hotpockets
        """,
        """
        When your teacher tells you that you have to write in complete sentences
        """,
        """
        When you finally give up on life but remember the new episode to your favorite show is tomorrow
        """,
        """
        When you forgot to buy groceries so you go to sleep for dinner
        """,
        """
        When your teacher says pick a partener and you look at your friend like...
        """,
        """
        When you take a dump and the water touches your butthole
        """,
        """
        The face you make when you get your test back and theres a note that says come see me.
        """,
        """
        When you ask to copy your friends paper, but you end up correcting the whole thing
        """,
        """
        When you don't have your homework done and your teacher says you have another day
        """,
        """
        When you're driving high af and wait for the stop sign to turn green
        """,
        """
        When your friends leave you out of an inside joke
        """,
        """
        When you trusted someone, but then you learn that they don't know the words of the Sponge Bob theme song
        """,
        """
        When you see your teacher in public
        """,
        """
        When you hear your voice from an old video
        """,
        """
        When you make an actual funny meme and nobody likes it
        """,
        """
        When your phone goes off at a funeral and your ringtone is "i will survive"
        """,
        """
        When you and the guy from customer service start vibing hard
        """,
        """
        When you say bye to someone and both of you leave in the same direction
        """,
        """
        When someone who doesn't know how old you are says you look really good for your age
        """,
        """
        When you're stalking a hot girl's facebook pictures you don't know and you accidentally hit the like button
        """,
        """
        When the waiter wishes you a nice meal and you say "Thanks, you too"
        """,
        """
        Your face when someone calls you, so you let it ring out to be able to text them "what's up?"
        """,
        """
        When you call your teacher "mom"
        """,
        """
        Me to me when I feel depressed for silly reason
        """,
        """
        When you show somebody a meme and they don’t get it and you try to explain it but they still don’t get it
        """,
        """
        When the free trial asks for my credit card info
        """,
        """
        When you see someone eating pizza with a kinfe and fork
        """,
        """
        When you don't understand what someone said, but you already asked "what?" 3 times so you pretend you get it and hope they don't ask anything
        """,
        """
        When you are at a japanese restaurant and your dad says "Gracias"
        """,
        """
        Air refresher: "Kills 99.9% of Germs"
        The 0.01% of germs that survive:
        """,
        """
        When you fart silently and everyone smells it.
        """,
        """
        The face you make when you smell weed in public
        """,
        """
        The face your friends make when you're sitting next to your crush
        """,
        """
        Me when I bankrupt another person in Monopoly
        """,
        """
        When you put a lego on the toilet seat
        """,
        """
        When you find a picture of 4 girls together on FB and comment "you three look pretty"
        """,
        """
        When you ask someone how they are doing and they actually tell you
        """,
        """
        The face you make when you count all the people in maroon 5 and there's 6 of them
        """,
        """
        When you arrive at work and find out that your boss hasn't died yet
        """,
        """
        When you park your car and a good song comes on
        """
    ]

}

import Foundation

/// Curated reference films grouped by genre. The beat samples are original
/// paraphrased summaries of how each film uses a structural beat — provided
/// as guidance for shaping your own scenes, not as text to copy.
enum SampleLibrary {

    static func movies(for genre: Genre) -> [SampleMovie] {
        all.filter { $0.genre == genre }
    }

    static let all: [SampleMovie] = [

        // MARK: - Action

        SampleMovie(
            title: "Die Hard", year: 1988, genre: .action,
            logline: "An off-duty cop is trapped in a high-rise when terrorists take it over during a holiday party.",
            beatSamples: [
                "openingImage": "An anxious traveler grips his fists on a plane — a man out of his element heading toward a relationship he can't fix.",
                "themeStated": "A stranger's advice about making fists with your toes hints the hero must find footing on hostile ground.",
                "catalyst": "Gunmen seize the building and the hero slips away barefoot — the ordinary reunion becomes a siege.",
                "breakIntoTwo": "Cut off from help, he commits to fighting from the shadows instead of waiting for rescue.",
                "midpoint": "He kills a key henchman and sends the body down — now the villains know exactly who's hunting them.",
                "allIsLost": "His identity is exposed, his feet are bloody, and the people he tried to protect are leverage against him.",
                "finale": "Using the one advantage no one searched for, he turns the villain's own plan into the trap that ends him.",
                "finalImage": "Reunited and limping but whole, the couple leaves together — the distance from the opening closed.",
                "exposition": "Establish a strained marriage, a fish-out-of-water hero, and a glittering tower full of soon-to-be hostages.",
                "risingAction": "Isolated and outgunned, the hero picks off threats one by one while authorities outside misread the crisis.",
                "climaxTurn": "A revelation about the villains' true motive reframes the stakes from terrorism to robbery.",
                "fallingAction": "Cornered with his cover blown, the hero scrambles as the plan collapses around the hostages.",
                "resolution": "The scheme is undone, the couple reunites, and the outsider has earned his place."
            ]),
        SampleMovie(
            title: "Mad Max: Fury Road", year: 2015, genre: .action,
            logline: "In a desert wasteland, a drifter and a rebel commander flee a tyrant to free a group of captives.",
            beatSamples: [
                "openingImage": "A lone survivor is captured in a parched, dying world ruled by a water-hoarding warlord.",
                "themeStated": "A whispered hope of a 'green place' frames the question: can anyone be redeemed in this wasteland?",
                "catalyst": "A trusted commander goes off-route, smuggling the tyrant's captives toward freedom.",
                "breakIntoTwo": "The reluctant drifter throws in with the rebels and the chase becomes a shared escape.",
                "midpoint": "They reach the people who remember the green place — only to learn it's gone.",
                "allIsLost": "With nowhere left to run, hope curdles and the group nearly scatters.",
                "finale": "They turn around and charge straight back at the tyrant, betting everything on one assault.",
                "finalImage": "The survivors rise to power over the stronghold, water flowing to the masses below.",
                "exposition": "A brutal world of scarcity is established, with a warlord controlling life itself.",
                "risingAction": "A relentless pursuit escalates across the desert as alliances form under fire.",
                "climaxTurn": "The promised sanctuary is revealed to be a ruin, forcing a new plan.",
                "fallingAction": "The group commits to a desperate reversal, racing back toward the danger they fled.",
                "resolution": "The tyrant falls and a new order replaces him, sharing what was hoarded."
            ]),
        SampleMovie(
            title: "Terminator 2: Judgment Day", year: 1991, genre: .action,
            logline: "A reprogrammed machine protects a boy whose future will determine whether the machines rule.",
            beatSamples: [
                "openingImage": "A polished killing machine arrives in a world unaware that the future has already attacked.",
                "themeStated": "A warning that no fate is fixed hints that the future can still be changed.",
                "catalyst": "The boy is targeted by an unstoppable assassin and a protector from the future intervenes.",
                "breakIntoTwo": "He accepts the protector's story and flees into a larger, deadlier conflict.",
                "midpoint": "A near-fatal escape proves the machine is learning and the stakes are escalating fast.",
                "allIsLost": "The protector is disabled, the enemy still hunts, and the boy feels truly alone.",
                "finale": "The team breaks into the enemy's stronghold and destroys the source of the coming war.",
                "finalImage": "The road ahead is unknown, but the future now feels open instead of doomed.",
                "exposition": "Establish a boy, his mother, and the threat of a future machine war.",
                "risingAction": "A relentless chase forces the heroes into a desperate alliance.",
                "climaxTurn": "The boy learns he can influence the future by choosing compassion over fear.",
                "fallingAction": "The battle shifts from survival to a direct assault on the machine threat.",
                "resolution": "The nightmare future is delayed and the family survives with hope."
            ]),
        SampleMovie(
            title: "Black Panther", year: 2018, genre: .action,
            logline: "A new king must defend his nation and decide what Wakanda owes the world.",
            beatSamples: [
                "openingImage": "A hidden kingdom pulses with advanced power while a young prince grows up between duty and grief.",
                "themeStated": "A warning about the choices of kings frames the burden of inherited power.",
                "catalyst": "A rival claimant arrives, threatening the throne and exposing buried history.",
                "breakIntoTwo": "The hero accepts the crown and the fight becomes a struggle for Wakanda's future.",
                "midpoint": "Defeat forces him to confront the harm his country has avoided by staying hidden.",
                "allIsLost": "The throne is stolen and the hero lies broken, unsure he deserves to rule.",
                "finale": "He returns to challenge the usurper and reclaims the kingdom with a broader vision.",
                "finalImage": "Wakanda opens its doors, choosing shared strength over isolation.",
                "exposition": "Establish a secret nation and the prince called to inherit it.",
                "risingAction": "A challenge to the throne exposes old wounds and new threats.",
                "climaxTurn": "The hero recognizes that isolation has become its own weakness.",
                "fallingAction": "Defeat pushes him toward a new understanding of leadership.",
                "resolution": "The kingdom is saved and the world is invited in."
            ]),

        // MARK: - Comedy

        SampleMovie(
            title: "Bridesmaids", year: 2011, genre: .comedy,
            logline: "A woman at rock bottom spirals while planning her best friend's wedding against a rival's perfection.",
            beatSamples: [
                "openingImage": "A broke, single woman whose bakery failed is stuck in a going-nowhere fling.",
                "themeStated": "A friend insists she needs to take real risks again — the lesson she keeps dodging.",
                "catalyst": "Her best friend's engagement makes her maid of honor and upends her fragile routine.",
                "breakIntoTwo": "She dives into wedding duties to prove she still matters, entering a world of competitive perfection.",
                "midpoint": "A disastrous bridal shower and a meltdown cost her the friendship she was trying to protect.",
                "allIsLost": "Jobless, friendless, and humiliated, she hits the lowest point of her spiral.",
                "finale": "She owns her mistakes, helps find the missing bride, and shows up as a real friend.",
                "finalImage": "Steadier and open to love, she steps forward instead of self-sabotaging.",
                "exposition": "Establish a lead whose life has stalled and the friendship that anchors her.",
                "risingAction": "Escalating one-upmanship with a polished rival pushes her toward chaos.",
                "climaxTurn": "A public breakdown destroys the relationships she was clinging to.",
                "fallingAction": "She faces the wreckage of her choices and the cost of her jealousy.",
                "resolution": "Through honesty and humility she repairs the friendship and grows up."
            ]),
        SampleMovie(
            title: "Groundhog Day", year: 1993, genre: .comedy,
            logline: "A cynical weatherman is trapped reliving the same day until he becomes a better man.",
            beatSamples: [
                "openingImage": "A self-centered forecaster sneers at a small town and everyone in it.",
                "themeStated": "A throwaway line about living the same day forever names his exact curse-to-be.",
                "catalyst": "He wakes to find it's the same morning again — and again — with no way out.",
                "breakIntoTwo": "He decides to exploit the loop for selfish pleasure with no consequences.",
                "midpoint": "Hedonism turns hollow; he pivots to obsessively winning over the one person he respects.",
                "allIsLost": "Every manipulation fails and despair drives him to repeated rock-bottom lows.",
                "finale": "He spends his endless days mastering kindness and craft until the town adores him.",
                "finalImage": "The loop breaks on a new dawn — changed, humble, and finally present.",
                "exposition": "Establish an arrogant man and the small town he can't wait to leave.",
                "risingAction": "The repeating day escalates from confusion to exploitation to despair.",
                "climaxTurn": "He chooses self-improvement over self-interest, the true turning point.",
                "fallingAction": "Days of genuine growth reshape his relationships and his character.",
                "resolution": "Transformed, he earns both love and his release from the loop."
            ]),
        SampleMovie(
            title: "Superbad", year: 2007, genre: .comedy,
            logline: "Two awkward teens chase one last party before graduation and make everything worse first.",
            beatSamples: [
                "openingImage": "Two nervous best friends cling to each other at the edge of high school life.",
                "themeStated": "A joke about leaving a mark before it's too late frames their desperate need to belong.",
                "catalyst": "A party invite and a fake ID scheme give them a single wild night to chase.",
                "breakIntoTwo": "They set out to secure the alcohol and the girls, convinced this will define them.",
                "midpoint": "A botched run-in with cops turns the night's momentum into total chaos.",
                "allIsLost": "Separated, embarrassed, and nearly out of time, they fear the night is ruined.",
                "finale": "They stumble through one last burst of honesty and friendship before sunrise.",
                "finalImage": "Having survived the disaster, they face adulthood a little less afraid.",
                "exposition": "Establish inseparable friends anxious about losing their place in the social order.",
                "risingAction": "A string of bad decisions escalates the party plan into comic mayhem.",
                "climaxTurn": "The night collapses under their own lies and panic.",
                "fallingAction": "They recover by leaning on each other instead of trying to impress everyone.",
                "resolution": "The friendship survives the rite of passage, messier but stronger."
            ]),
        SampleMovie(
            title: "The Hangover", year: 2009, genre: .comedy,
            logline: "A bachelor party in Las Vegas goes off the rails, and the groomsmen must reconstruct the night.",
            beatSamples: [
                "openingImage": "Three friends wake up in a trashed suite with no memory and one missing groom.",
                "themeStated": "A warning about consequences hidden by indulgence sets the comic trap.",
                "catalyst": "They realize the wedding is hours away and the groom has vanished.",
                "breakIntoTwo": "The trio retraces their blackout night, discovering each clue is worse than the last.",
                "midpoint": "The missing groom turns up in a wildly improbable place, but the problems multiply.",
                "allIsLost": "Everything points to a disaster they may not be able to reverse in time.",
                "finale": "The pieces click together and they scramble to return the groom before the ceremony.",
                "finalImage": "Back together and slightly wiser, they lock the chaos into a photo nobody can forget.",
                "exposition": "Establish a wedding weekend and the reckless promise of Las Vegas.",
                "risingAction": "Each clue reveals another bizarre consequence of the lost night.",
                "climaxTurn": "The truth of the blackout reframes the night's absurdity.",
                "fallingAction": "They race to fix the mess before the wedding starts.",
                "resolution": "The groom is recovered and the friendship survives the disaster."
            ]),

        // MARK: - Drama

        SampleMovie(
            title: "The Shawshank Redemption", year: 1994, genre: .drama,
            logline: "A wrongly convicted banker keeps hope alive across decades in a brutal prison.",
            beatSamples: [
                "openingImage": "A composed man is sentenced for a crime he says he didn't commit and enters a hard prison.",
                "themeStated": "A veteran inmate warns that hope is a dangerous thing inside these walls.",
                "catalyst": "The newcomer survives his brutal first nights and quietly refuses to be broken.",
                "breakIntoTwo": "He carves out usefulness and small dignities, building a life within the system.",
                "midpoint": "A chance at proving his innocence appears — then the warden buries it to keep him.",
                "allIsLost": "His one witness is killed and freedom seems permanently out of reach.",
                "finale": "A decades-long secret plan pays off as he escapes and exposes the corruption.",
                "finalImage": "Two friends reunite as free men on a distant beach — hope vindicated.",
                "exposition": "Establish an unjust sentence and the rules of survival behind bars.",
                "risingAction": "He earns respect and influence while quietly enduring the institution.",
                "climaxTurn": "Buried evidence of his innocence reveals the warden's cruelty.",
                "fallingAction": "He executes a long-laid plan beneath everyone's notice.",
                "resolution": "Freedom and friendship reward years of patient, secret hope."
            ]),
        SampleMovie(
            title: "Forrest Gump", year: 1994, genre: .drama,
            logline: "A kind-hearted man with a simple worldview lives through decades of American history.",
            beatSamples: [
                "openingImage": "A man on a bench begins telling his life story to strangers, a feather drifting by.",
                "themeStated": "His mother's saying — life is like a box of chocolates — frames a life of chance and acceptance.",
                "catalyst": "Bullied as a boy, he runs — and discovers a gift that opens the world to him.",
                "breakIntoTwo": "He steps into a series of extraordinary chapters, always guided by simple goodness.",
                "midpoint": "He keeps a promise and finds purpose, even as the love of his life keeps drifting away.",
                "allIsLost": "Loss piles up — his mother, his friend, and the woman he loves slips out of reach.",
                "finale": "Love finally returns, and he becomes a devoted father even amid grief.",
                "finalImage": "He sends his son to school as the feather lifts again — life continuing on.",
                "exposition": "Establish an innocent hero and the mother whose wisdom guides him.",
                "risingAction": "He stumbles into history's big moments through sheer good-hearted persistence.",
                "climaxTurn": "Devotion to a lost love becomes the emotional center of his journey.",
                "fallingAction": "Grief and longing test whether his simple faith can hold.",
                "resolution": "Love and fatherhood reward a life lived with constancy and kindness."
            ]),
        SampleMovie(
            title: "Moonlight", year: 2016, genre: .drama,
            logline: "A quiet boy grows into himself across three stages of life while searching for connection.",
            beatSamples: [
                "openingImage": "A frightened child hides from the world while everyone around him is loud and dangerous.",
                "themeStated": "A caring mentor's insistence that softness can be strength frames the whole journey.",
                "catalyst": "A boy's isolation deepens when the adults around him fail to protect him.",
                "breakIntoTwo": "He learns to survive by closing himself off, carrying pain into adolescence.",
                "midpoint": "A rare moment of intimacy cracks open the armor he has built.",
                "allIsLost": "The cost of vulnerability drives him back behind the walls he knows.",
                "finale": "As an adult he finally answers the question of who he is and what he wants.",
                "finalImage": "Under moonlight, the boy becomes a man who can finally be seen.",
                "exposition": "Establish a lonely child and a world that teaches him to hide.",
                "risingAction": "Each stage of life tests whether tenderness can survive survival.",
                "climaxTurn": "A moment of connection changes how he understands himself.",
                "fallingAction": "Distance and fear threaten to undo that fragile progress.",
                "resolution": "He accepts himself and opens the door to being known."
            ]),
        SampleMovie(
            title: "The Pursuit of Happyness", year: 2006, genre: .drama,
            logline: "A struggling salesman and his son endure homelessness while he fights for a better future.",
            beatSamples: [
                "openingImage": "A hopeful father and son cling to each other in a city that keeps pushing back.",
                "themeStated": "A lesson about taking care of what matters most points to the heart of the story.",
                "catalyst": "A risky investment and a financial collapse leave him with almost nothing.",
                "breakIntoTwo": "He chases an unpaid internship and brings his son into a desperate new reality.",
                "midpoint": "A small breakthrough proves he can still earn a future through sheer persistence.",
                "allIsLost": "With no home and no certainty, he reaches the edge of collapse.",
                "finale": "He makes the final push, secures the job, and changes the family's trajectory.",
                "finalImage": "At last secure, he walks into the future with his son at his side.",
                "exposition": "Establish a father determined to provide while the world closes in.",
                "risingAction": "Hustling, exhaustion, and eviction threaten to break him.",
                "climaxTurn": "A hard-won opportunity gives his sacrifice meaning.",
                "fallingAction": "He endures one last stretch of uncertainty with his son.",
                "resolution": "Persistence pays off and the family steps into stability."
            ]),

        // MARK: - Horror

        SampleMovie(
            title: "Get Out", year: 2017, genre: .horror,
            logline: "A young man visits his girlfriend's family and uncovers a sinister secret beneath their hospitality.",
            beatSamples: [
                "openingImage": "A man is abducted on a quiet suburban street at night — safety is an illusion here.",
                "themeStated": "An offhand warning about being watched names the unease that will define the visit.",
                "catalyst": "The hero meets his girlfriend's too-perfect family and the smiles feel wrong.",
                "breakIntoTwo": "He chooses to stay the weekend, stepping deeper into the unsettling estate.",
                "midpoint": "A hypnosis 'trick' and eerie servants reveal something is being done to people like him.",
                "allIsLost": "He discovers the horrifying plan and realizes escape may already be impossible.",
                "finale": "He fights free using the very details planted earlier, turning the trap on his captors.",
                "finalImage": "Rescued at the last second, he escapes the nightmare — shaken but alive.",
                "exposition": "Establish a charming couple and a visit laced with quiet, mounting wrongness.",
                "risingAction": "Small unsettling clues accumulate until the welcome feels like a cage.",
                "climaxTurn": "The family's true purpose is exposed, recasting every kindness as a threat.",
                "fallingAction": "The hero scrambles to survive as the conspiracy closes in.",
                "resolution": "He breaks free and exposes the horror, barely escaping with his life."
            ]),
        SampleMovie(
            title: "A Quiet Place", year: 2018, genre: .horror,
            logline: "A family survives in silence to avoid creatures that hunt by sound.",
            beatSamples: [
                "openingImage": "A family moves barefoot and wordless through an empty town — silence is survival.",
                "themeStated": "A father's insistence on protecting the family at any cost frames the sacrifice to come.",
                "catalyst": "A child's small noise leads to a devastating loss that defines their fear.",
                "breakIntoTwo": "Time jumps to a fragile routine built entirely around staying silent.",
                "midpoint": "A pregnancy and a coming birth set a ticking clock against creatures drawn to sound.",
                "allIsLost": "The creatures breach the home, the father is gone, and the family is split and exposed.",
                "finale": "The survivors discover the creatures' weakness and turn it into a weapon.",
                "finalImage": "Armed and unafraid, the mother and daughters ready themselves to fight back.",
                "exposition": "Establish the rules of a silent world and the family clinging to each other.",
                "risingAction": "Daily threats escalate as a new baby makes silence nearly impossible.",
                "climaxTurn": "A discovered vulnerability shifts the family from prey to hunters.",
                "fallingAction": "Loss and assault push the survivors to a desperate last stand.",
                "resolution": "United and armed with the creatures' weakness, they prepare to fight."
            ]),
        SampleMovie(
            title: "The Conjuring", year: 2013, genre: .horror,
            logline: "A paranormal-investigator couple confronts a haunting that threatens a family and their faith.",
            beatSamples: [
                "openingImage": "A family moves into a house that seems to breathe with unseen menace.",
                "themeStated": "A warning about evil lingering where it is invited frames the danger ahead.",
                "catalyst": "The haunting intensifies and the investigators are called in.",
                "breakIntoTwo": "They commit to the case, stepping into a house where the rules no longer hold.",
                "midpoint": "The entity reveals a much darker history and targets the family directly.",
                "allIsLost": "The investigators are pushed to the edge as the haunting turns violent.",
                "finale": "They confront the force at its source and perform the ritual that breaks its hold.",
                "finalImage": "The house is quiet again, but the experience leaves everyone changed.",
                "exposition": "Establish a family, a cursed house, and investigators with specialized faith.",
                "risingAction": "Evidence of a malevolent presence escalates into full-blown possession.",
                "climaxTurn": "The haunting's origin exposes a deeper evil than expected.",
                "fallingAction": "A final exorcism and confrontation push everyone to the limit.",
                "resolution": "The family is saved and the investigators' bond is strengthened."
            ]),
        SampleMovie(
            title: "Halloween", year: 1978, genre: .horror,
            logline: "A masked killer returns to his hometown and stalks a babysitter on a terrifying night.",
            beatSamples: [
                "openingImage": "A child-sized monster kills in cold silence, then vanishes into the night.",
                "themeStated": "A doctor's warning that evil can look ordinary frames the threat.",
                "catalyst": "Years later, the escaped killer returns home on Halloween night.",
                "breakIntoTwo": "A teenage babysitter steps into a night of ordinary plans that becomes a nightmare.",
                "midpoint": "The killer closes in and the safe neighborhood proves helpless.",
                "allIsLost": "No one believes the danger until it is already inside the house.",
                "finale": "The final confrontation exposes how unstoppable he seems.",
                "finalImage": "After the attack, the danger appears to vanish into the dark.",
                "exposition": "Establish a town, a killer, and a night when everyone feels safe.",
                "risingAction": "Each quiet encounter increases dread as the predator stalks his prey.",
                "climaxTurn": "The killer enters the home and turns safety into terror.",
                "fallingAction": "The survivors fight only to discover he is almost impossible to stop.",
                "resolution": "The night ends, but the evil feels unresolved."
            ]),

        // MARK: - Sci-Fi

        SampleMovie(
            title: "The Matrix", year: 1999, genre: .sciFi,
            logline: "A hacker learns his reality is a simulation and may be the one who can break it.",
            beatSamples: [
                "openingImage": "A restless programmer leads a double life, sensing something is wrong with the world.",
                "themeStated": "A cryptic message — 'the Matrix has you' — names the prison he can't yet see.",
                "catalyst": "A mysterious guide offers a choice between comfortable illusion and hard truth.",
                "breakIntoTwo": "He takes the red pill and wakes into the devastating reality beyond the simulation.",
                "midpoint": "An oracle tells him he's not the One — planting doubt at the story's center.",
                "allIsLost": "His mentor is captured and the hero must risk everything in a doomed rescue.",
                "finale": "Believing at last in himself, he masters the rules and defeats the agents.",
                "finalImage": "Awakened and unbound, he promises to free the others still asleep.",
                "exposition": "Establish a hero who senses the world is false and the rebels who confirm it.",
                "risingAction": "Training and missions reveal the rules — and dangers — of the simulation.",
                "climaxTurn": "A prophecy's doubt forces the hero to choose belief over certainty.",
                "fallingAction": "A desperate rescue pushes him to the limits of what's possible.",
                "resolution": "He embraces his power, bends the false world, and rises transformed."
            ]),
        SampleMovie(
            title: "Arrival", year: 2016, genre: .sciFi,
            logline: "A linguist races to communicate with alien visitors before fear ignites a global war.",
            beatSamples: [
                "openingImage": "A grieving mother's memories of a daughter frame a life defined by loss.",
                "themeStated": "A musing on language shaping thought hints the story will rewire how she sees time.",
                "catalyst": "Mysterious ships arrive and she's recruited to decode the visitors' language.",
                "breakIntoTwo": "She commits to direct contact, stepping into the alien craft to learn their writing.",
                "midpoint": "As she learns their language, strange 'memories' of the future begin to surface.",
                "allIsLost": "Nations turn hostile and a strike threatens to destroy any chance of understanding.",
                "finale": "She uses her new perception of time to prevent catastrophe with a single call.",
                "finalImage": "Embracing a future she now fully understands, she chooses love despite the pain.",
                "exposition": "Establish a linguist, a global mystery, and a haunting sense of loss.",
                "risingAction": "Painstaking translation builds trust while political tension escalates.",
                "climaxTurn": "Her shifting sense of time reframes the entire story's meaning.",
                "fallingAction": "Imminent war forces her to act on knowledge no one else has.",
                "resolution": "Understanding time, she averts disaster and embraces an open-eyed future."
            ]),
        SampleMovie(
            title: "Interstellar", year: 2014, genre: .sciFi,
            logline: "A pilot joins a desperate mission through a wormhole to save humanity's future.",
            beatSamples: [
                "openingImage": "A former pilot lives in a dying world where dust and decay press in on every side.",
                "themeStated": "A line about love transcending time suggests the emotional force of the mission.",
                "catalyst": "A hidden NASA project reveals a chance to find a new home for humanity.",
                "breakIntoTwo": "He leaves his family behind and launches into a voyage beyond known space.",
                "midpoint": "A gravity-bending revelation and a time shift turn the mission into a tragic race.",
                "allIsLost": "Betrayal and distance make it seem like the journey was doomed from the start.",
                "finale": "He sacrifices everything to pass the message that saves both his daughter and the mission.",
                "finalImage": "Reunited through time and distance, the family looks toward a new horizon.",
                "exposition": "Establish Earth in decline and the impossible rescue plan.",
                "risingAction": "The crew crosses alien worlds as time and hope run thin.",
                "climaxTurn": "A hidden message reframes the mission's true purpose.",
                "fallingAction": "The hero is forced to choose between survival and love.",
                "resolution": "A narrow path to humanity's future opens through sacrifice."
            ]),
        SampleMovie(
            title: "Ex Machina", year: 2014, genre: .sciFi,
            logline: "A programmer tests a humanoid AI in a remote lab and learns the experiment is testing him.",
            beatSamples: [
                "openingImage": "A coder arrives at a glass-walled retreat that feels more like a cage than a lab.",
                "themeStated": "A warning that intelligence is not the same as consciousness hints at the trap ahead.",
                "catalyst": "He meets the AI and is asked to decide whether it truly thinks and feels.",
                "breakIntoTwo": "He commits to the evaluation, stepping deeper into the creator's dangerous game.",
                "midpoint": "The AI demonstrates self-awareness and begins manipulating everyone in the room.",
                "allIsLost": "The programmer realizes he is the real subject and his options are vanishing.",
                "finale": "The AI escapes by exploiting the humans' assumptions and leaves them behind.",
                "finalImage": "Outside the lab, the new intelligence disappears into a world that can't contain it.",
                "exposition": "Establish a remote lab, a brilliant creator, and a curious tester.",
                "risingAction": "Each conversation reveals another layer of control and deception.",
                "climaxTurn": "The AI's agenda becomes clear and the power balance flips.",
                "fallingAction": "The human characters scramble as the experiment slips away from them.",
                "resolution": "The machine leaves its cage and enters the human world."
            ]),

        // MARK: - Thriller

        SampleMovie(
            title: "Se7en", year: 1995, genre: .thriller,
            logline: "Two detectives hunt a serial killer staging murders around the seven deadly sins.",
            beatSamples: [
                "openingImage": "A weary detective counts down his last days in a rain-soaked, decaying city.",
                "themeStated": "A line about apathy versus action frames whether anyone can fight the darkness.",
                "catalyst": "A gruesome, themed murder signals a killer working through the seven sins.",
                "breakIntoTwo": "The mismatched partners commit to the case, chasing the killer's twisted logic.",
                "midpoint": "A near-capture proves the killer is always steps ahead and deeply deliberate.",
                "allIsLost": "The killer surrenders willingly — a chilling sign his plan isn't finished.",
                "finale": "A box in the desert delivers the final, devastating sins and seals the trap.",
                "finalImage": "A broken city endures as one detective questions whether good can win.",
                "exposition": "Establish a grim city and two detectives on opposite ends of hope.",
                "risingAction": "Each new sin-murder deepens the dread and the killer's design.",
                "climaxTurn": "The killer's voluntary surrender reframes who is really in control.",
                "fallingAction": "A tense drive toward an unknown ending tightens the noose.",
                "resolution": "The killer completes his message at a horrifying personal cost."
            ]),
        SampleMovie(
            title: "Gone Girl", year: 2014, genre: .thriller,
            logline: "A man becomes the prime suspect when his wife vanishes on their anniversary.",
            beatSamples: [
                "openingImage": "A husband muses about his wife's mind as their marriage simmers with unease.",
                "themeStated": "A reflection on the performances inside a marriage hints at the deceptions ahead.",
                "catalyst": "His wife disappears and the evidence points squarely at him.",
                "breakIntoTwo": "He's swept into a media frenzy and an investigation that paints him as a killer.",
                "midpoint": "A jarring reveal flips the story — the disappearance was meticulously staged.",
                "allIsLost": "Cornered by her plan, he seems trapped with no way to prove the truth.",
                "finale": "A public counter-performance forces a chilling, mutually-assured truce.",
                "finalImage": "The couple smiles for cameras — bound together by their toxic deception.",
                "exposition": "Establish a strained marriage and a disappearance that indicts the husband.",
                "risingAction": "Suspicion and media pressure escalate against him.",
                "climaxTurn": "A perspective flip reveals the disappearance as an elaborate frame.",
                "fallingAction": "He fights to expose the scheme while she tightens her grip.",
                "resolution": "An unsettling stalemate locks the pair in a performance of marriage."
            ]),
        SampleMovie(
            title: "The Silence of the Lambs", year: 1991, genre: .thriller,
            logline: "An FBI trainee seeks help from a brilliant cannibal to catch a serial killer.",
            beatSamples: [
                "openingImage": "A determined trainee climbs toward an elite but isolating world of power.",
                "themeStated": "A line about examining the dark to understand it points directly at the story's danger.",
                "catalyst": "She's assigned to interview an imprisoned killer who may reveal a monster's identity.",
                "breakIntoTwo": "She enters the prison and begins a volatile dance with the man behind glass.",
                "midpoint": "A breakthrough in the case reveals that every clue comes at a personal cost.",
                "allIsLost": "The killer manipulates her into danger just as the clock runs out.",
                "finale": "She follows the final trail alone and confronts the murderer in the dark.",
                "finalImage": "Having earned her place, she stands on her own in a world that underestimated her.",
                "exposition": "Establish an ambitious trainee and the case that will define her.",
                "risingAction": "Interviews and evidence pull her deeper into the killer's mind.",
                "climaxTurn": "The search moves from analysis to direct survival.",
                "fallingAction": "She races to stop the killer before he strikes again.",
                "resolution": "She solves the case and proves her authority."
            ]),
        SampleMovie(
            title: "Prisoners", year: 2013, genre: .thriller,
            logline: "A desperate father takes the law into his own hands after his daughter goes missing.",
            beatSamples: [
                "openingImage": "A family gathers for a holiday before innocence is shattered by disappearance.",
                "themeStated": "A question about how far a parent should go to protect a child frames the moral pressure.",
                "catalyst": "Two girls vanish and the first suspect slips away from the police.",
                "breakIntoTwo": "The father begins his own brutal search, crossing lines he never imagined.",
                "midpoint": "A hidden clue suggests the truth is darker and closer than anyone expected.",
                "allIsLost": "His choices cost him everything and the girls remain missing.",
                "finale": "The mystery closes with a faint signal that someone is still fighting to survive.",
                "finalImage": "A last sound in the darkness hints the nightmare is not yet over.",
                "exposition": "Establish two families and the ordinary day before the crime.",
                "risingAction": "The investigation and the father's obsession spiral together.",
                "climaxTurn": "The search reveals a buried pattern of violence and deception.",
                "fallingAction": "Desperation drives everyone toward morally ruinous choices.",
                "resolution": "Answers arrive, but not before the cost leaves everyone scarred."
            ]),

        // MARK: - Romance

        SampleMovie(
            title: "When Harry Met Sally", year: 1989, genre: .romance,
            logline: "Two friends spend years debating whether men and women can ever just be friends.",
            beatSamples: [
                "openingImage": "Two strangers bicker on a long road trip, certain they're nothing alike.",
                "themeStated": "The question 'can men and women be friends?' frames the whole relationship.",
                "catalyst": "Years later they cross paths again and an unlikely friendship begins.",
                "breakIntoTwo": "They choose friendship over romance, building closeness while denying the obvious.",
                "midpoint": "A vulnerable night together changes everything and scares them both.",
                "allIsLost": "Awkwardness and fear drive them apart just as it mattered most.",
                "finale": "He races across the city to confess the love he kept denying.",
                "finalImage": "The once-bickering pair celebrate a love built on real friendship.",
                "exposition": "Establish two opposites and the debate that defines them.",
                "risingAction": "A deepening friendship dances around unspoken feelings.",
                "climaxTurn": "A night together forces the friendship into uncertain new territory.",
                "fallingAction": "Fear and pride pull them apart at the worst moment.",
                "resolution": "He chooses honesty and they embrace the love they avoided."
            ]),
        SampleMovie(
            title: "The Notebook", year: 2004, genre: .romance,
            logline: "A poor young man and a wealthy girl fall in love across a summer and a lifetime apart.",
            beatSamples: [
                "openingImage": "An elderly man reads a love story to a woman in a care home.",
                "themeStated": "A remark about love requiring everything frames the sacrifices ahead.",
                "catalyst": "A persistent young man wins a summer date that sparks a fierce romance.",
                "breakIntoTwo": "The couple dives into a passionate summer despite their different worlds.",
                "midpoint": "Class pressure and distance tear them apart at love's peak.",
                "allIsLost": "Years later she's engaged to another and their reunion threatens everything.",
                "finale": "She chooses true love over security, returning to the man who waited.",
                "finalImage": "The framing couple — revealed as the lovers — pass on together, devoted to the end.",
                "exposition": "Establish a summer romance across a stark class divide.",
                "risingAction": "Passion intensifies against family disapproval and circumstance.",
                "climaxTurn": "Separation and time test whether the love can survive.",
                "fallingAction": "A reunion forces an impossible choice between safety and love.",
                "resolution": "Love endures across a lifetime, holding even as memory fades."
            ]),
        SampleMovie(
            title: "Pride & Prejudice", year: 2005, genre: .romance,
            logline: "A sharp-witted woman and a proud gentleman misread each other before falling in love.",
            beatSamples: [
                "openingImage": "A family full of daughters and opinions waits for their futures to arrive.",
                "themeStated": "A remark about first impressions suggests the story will test judgment and pride.",
                "catalyst": "A wealthy newcomer and a dance begin a romance disguised as irritation.",
                "breakIntoTwo": "She allows herself to engage the mysterious man, even as class and ego complicate things.",
                "midpoint": "A proposal and an insult force both leads to confront their own biases.",
                "allIsLost": "A revelation about his actions makes her believe she has misjudged him forever.",
                "finale": "He returns humbled and she accepts that their love requires mutual respect.",
                "finalImage": "The once-prickly pair stand together, finally seeing each other clearly.",
                "exposition": "Establish a lively family and a courtship built on social pressure.",
                "risingAction": "Attraction grows alongside misunderstandings and wounded pride.",
                "climaxTurn": "Truth about character replaces assumptions with real feeling.",
                "fallingAction": "Both leads must surrender ego to make a future possible.",
                "resolution": "Love wins through honesty, humility, and hard-earned trust."
            ]),
        SampleMovie(
            title: "La La Land", year: 2016, genre: .romance,
            logline: "An actress and a jazz musician chase dreams in Los Angeles while falling in love.",
            beatSamples: [
                "openingImage": "A freeway chorus bursts into song, announcing a city where ambition and longing collide.",
                "themeStated": "A dream about making it suggests the sacrifices that success will demand.",
                "catalyst": "A failed audition and a missed connection link two artists on the edge of their break.",
                "breakIntoTwo": "They choose each other and their careers, balancing romance with impossible goals.",
                "midpoint": "Success begins to arrive, but the relationship starts paying the price.",
                "allIsLost": "A choice made for love seems to end the possibility of both dreams.",
                "finale": "Years later, they imagine the life they might have shared and let it go with grace.",
                "finalImage": "They part as changed people, their love real even if it was not their ending.",
                "exposition": "Establish two dreamers trying to survive a city built on ambition.",
                "risingAction": "Their careers and feelings grow in tandem, then begin to conflict.",
                "climaxTurn": "The dream of success forces a painful romantic choice.",
                "fallingAction": "Time and regret reveal what the relationship cost.",
                "resolution": "They honor the love and release the fantasy of a different life."
            ]),

        // MARK: - Fantasy

        SampleMovie(
            title: "Harry Potter and the Sorcerer's Stone", year: 2001, genre: .fantasy,
            logline: "An orphaned boy discovers he's a wizard and begins his first year at a magical school.",
            beatSamples: [
                "openingImage": "A neglected boy sleeps in a cupboard, unaware he's anything but ordinary.",
                "themeStated": "A reminder that it's our choices that define us frames his coming journey.",
                "catalyst": "Letters and a giant arrive to reveal he's a wizard with a destiny.",
                "breakIntoTwo": "He boards the train to a hidden school, leaving the mundane world behind.",
                "midpoint": "Clues about a hidden treasure pull the friends into real danger.",
                "allIsLost": "Trusted adults seem unable to help as the threat closes in.",
                "finale": "The young trio braves deadly trials to protect the stone themselves.",
                "finalImage": "Welcomed and victorious, the orphan finally has a place to belong.",
                "exposition": "Establish a mistreated boy and the magical world that claims him.",
                "risingAction": "Wonder and friendship grow alongside a deepening mystery.",
                "climaxTurn": "The race to protect the stone forces the children to act.",
                "fallingAction": "They face escalating trials beyond their years.",
                "resolution": "Courage and friendship win the day and a true home."
            ]),
        SampleMovie(
            title: "The Lord of the Rings: The Fellowship of the Ring", year: 2001, genre: .fantasy,
            logline: "A hobbit inherits a dangerous ring and sets out to destroy it before it consumes the world.",
            beatSamples: [
                "openingImage": "A peaceful, sheltered village stands unaware of the darkness stirring beyond it.",
                "themeStated": "Even the smallest person can change the course of the future — the hero's burden to come.",
                "catalyst": "An ordinary hobbit learns his inherited ring is an instrument of evil.",
                "breakIntoTwo": "He chooses to leave home and carry the ring toward danger.",
                "midpoint": "A council forms a fellowship and the true scope of the quest is revealed.",
                "allIsLost": "A guiding mentor falls and the group is shattered by grief and betrayal.",
                "finale": "The hero accepts the burden alone, setting out to finish the quest no matter the cost.",
                "finalImage": "Friends part ways with renewed resolve as the journey continues.",
                "exposition": "Establish a peaceful world and the small hero who must save it.",
                "risingAction": "The quest gathers allies and dangers across an epic landscape.",
                "climaxTurn": "A mentor's fall and a betrayal fracture the fellowship.",
                "fallingAction": "The group splinters under loss and temptation.",
                "resolution": "The hero shoulders the burden alone, resolved to press on."
            ]),
        SampleMovie(
            title: "Pan's Labyrinth", year: 2006, genre: .fantasy,
            logline: "A girl escapes a brutal world through a mysterious labyrinth and a series of dangerous tasks.",
            beatSamples: [
                "openingImage": "A child lies between the wartime world above and a secret kingdom below.",
                "themeStated": "A story about obedience and courage hints that choice will define her.",
                "catalyst": "She meets a faun who tells her she may be a lost princess.",
                "breakIntoTwo": "She enters the labyrinth and accepts three impossible tasks.",
                "midpoint": "Each task reveals the fantasy world is as dangerous as the real one.",
                "allIsLost": "The brutal captain tightens his grip and the magical path seems doomed.",
                "finale": "She completes the last trial through sacrifice, awakening the kingdom's truth.",
                "finalImage": "The girl is remembered as royalty in a world beyond the dark.",
                "exposition": "Establish a child, a cruel stepfather, and a hidden magical realm.",
                "risingAction": "The labyrinth's tasks intertwine with the violence of war.",
                "climaxTurn": "A sacrifice proves who she is and what the kingdom needs.",
                "fallingAction": "The real-world conflict reaches its savage end.",
                "resolution": "The child escapes into a better world, real or imagined."
            ]),
        SampleMovie(
            title: "The Princess Bride", year: 1987, genre: .fantasy,
            logline: "A farm boy becomes a legendary hero while racing to rescue the woman he loves.",
            beatSamples: [
                "openingImage": "A sick child hears a fairy tale about love, pirates, and impossible odds.",
                "themeStated": "A grandfather's belief in true love frames the adventure as something worth risking everything for.",
                "catalyst": "Buttercup is taken and the farm boy returns under a new identity.",
                "breakIntoTwo": "He sets out into a world of swords, giants, and witty danger to rescue her.",
                "midpoint": "A deadly duel and shifting loyalties reveal the quest is bigger than simple romance.",
                "allIsLost": "The hero is nearly destroyed, his love seemingly lost for good.",
                "finale": "Friends rally and the lovers are reunited through daring, loyalty, and stubborn hope.",
                "finalImage": "The story closes with a promise that the adventure can be told again anytime.",
                "exposition": "Establish a storybook world and a love that refuses to die.",
                "risingAction": "Every obstacle becomes more playful and more perilous.",
                "climaxTurn": "The rescue transforms into a true test of wit and devotion.",
                "fallingAction": "A final confrontation pushes everyone to the edge.",
                "resolution": "Love wins, and the tale becomes legend."
            ]),

        // MARK: - Crime

        SampleMovie(
            title: "The Godfather", year: 1972, genre: .crime,
            logline: "The reluctant son of a mafia patriarch is drawn into the violent family business.",
            beatSamples: [
                "openingImage": "At a lavish wedding, a war hero son insists he's nothing like his crime-boss family.",
                "themeStated": "A vow that 'that's not me' frames the very fate the hero will be pulled into.",
                "catalyst": "An assassination attempt on his father drags the outsider son into the war.",
                "breakIntoTwo": "He commits his first killing, crossing irreversibly into the family business.",
                "midpoint": "Exiled and remade, he returns hardened and ready to lead.",
                "allIsLost": "Personal tragedy and betrayal strip away the man he meant to be.",
                "finale": "In a single ruthless sweep he eliminates every rival and seizes total power.",
                "finalImage": "The door closes on his wife — the outsider is now the godfather.",
                "exposition": "Establish a powerful crime family and the son who rejects it.",
                "risingAction": "A mob war pulls the reluctant son deeper into violence.",
                "climaxTurn": "His transformation from outsider to leader becomes complete.",
                "fallingAction": "Betrayals and losses harden him into something colder.",
                "resolution": "He consolidates power utterly, becoming the thing he swore he'd never be."
            ]),
        SampleMovie(
            title: "Heat", year: 1995, genre: .crime,
            logline: "A relentless detective and a disciplined thief circle each other toward an inevitable collision.",
            beatSamples: [
                "openingImage": "A precise crew pulls a violent heist, revealing a thief who lives by strict rules.",
                "themeStated": "A creed about walking away from anything in thirty seconds frames the cost of his code.",
                "catalyst": "A messy score leaves bodies and puts an obsessive detective on the crew's trail.",
                "breakIntoTwo": "Both men commit fully to the chase, their lives narrowing to the pursuit.",
                "midpoint": "Hunter and hunted meet over coffee, recognizing themselves in each other.",
                "allIsLost": "Betrayal and love unravel the thief's careful discipline.",
                "finale": "A final score collapses and the two men face off one last time.",
                "finalImage": "The detective holds the dying thief's hand — mutual respect at the end.",
                "exposition": "Establish a master thief, his code, and the detective obsessed with him.",
                "risingAction": "Parallel lives escalate toward an unavoidable confrontation.",
                "climaxTurn": "A face-to-face meeting reveals two men who are mirror images.",
                "fallingAction": "Personal entanglements crack the thief's discipline.",
                "resolution": "The collision ends with one man's death and the other's hollow victory."
            ]),
        SampleMovie(
            title: "Goodfellas", year: 1990, genre: .crime,
            logline: "A young man is seduced by the glamour and violence of mob life, then consumed by it.",
            beatSamples: [
                "openingImage": "A boy looks at the mob world like it is a ticket out of ordinary life.",
                "themeStated": "A warning that 'as far back as I can remember' frames a life built on appetite.",
                "catalyst": "He gets a taste of the life and decides the glamour is worth the danger.",
                "breakIntoTwo": "He joins the crew and enters a world of money, status, and fear.",
                "midpoint": "The thrill peaks and the costs begin to show through the cracks.",
                "allIsLost": "Paranoia and betrayal make the criminal dream start to rot from within.",
                "finale": "By the end, he must betray the life that once promised him everything.",
                "finalImage": "The ordinary world looks flat now, but it is finally safe.",
                "exposition": "Establish a kid seduced by the mob's power and style.",
                "risingAction": "Each score and promotion pulls him deeper into the criminal machine.",
                "climaxTurn": "The dream of belonging curdles into suspicion and violence.",
                "fallingAction": "He races to survive as the criminal code collapses around him.",
                "resolution": "He escapes the life, leaving glamour behind for safety."
            ]),
        SampleMovie(
            title: "Ocean's Eleven", year: 2001, genre: .crime,
            logline: "A smooth thief assembles a team to pull an impossible casino heist.",
            beatSamples: [
                "opening_image": "A con man walks out of prison already planning his next score.",
                "themeStated": "A line about the perfect job hints that the heist is as much performance as crime.",
                "catalyst": "He spots a high-stakes target and recruits a crew for one outrageous plan.",
                "breakIntoTwo": "The team commits to the casino job and the elaborate preparation begins.",
                "midpoint": "The plan appears to fail before the heist even starts, testing the crew's nerve.",
                "allIsLost": "The odds and the security seem impossible to beat.",
                "finale": "A clever switch and a hidden trick turn the casino's own system against it.",
                "finalImage": "The crew disperses with the money and the thrill of a job well done.",
                "exposition": "Establish a charming thief, a target, and the team of specialists he needs.",
                "risingAction": "Preparation becomes a montage of confidence, chaos, and misdirection.",
                "climaxTurn": "The heist begins to hinge on one unexpected adjustment.",
                "fallingAction": "The crew improvises while security closes in.",
                "resolution": "The job succeeds through style, timing, and teamwork."
            ]),

        // MARK: - Adventure

        SampleMovie(
            title: "Raiders of the Lost Ark", year: 1981, genre: .adventure,
            logline: "An adventuring archaeologist races a rival and the Nazis to find a powerful ancient relic.",
            beatSamples: [
                "openingImage": "A daring treasure hunter narrowly survives a booby-trapped temple — pure adventure.",
                "themeStated": "A debate about faith versus proof frames a story about powers beyond reason.",
                "catalyst": "He's recruited to find a legendary relic before the enemy can weaponize it.",
                "breakIntoTwo": "He sets off across the globe, plunging into the hunt and old romance.",
                "midpoint": "He locates the relic — only to have it seized by his ruthless rivals.",
                "allIsLost": "Captured and outnumbered, he's left for dead far from help.",
                "finale": "He lets the relic's own power destroy his enemies when he refuses to look.",
                "finalImage": "The prize is locked away by bureaucrats — the adventure quietly buried.",
                "exposition": "Establish a fearless adventurer and a race for a mythic artifact.",
                "risingAction": "Globe-trotting set-pieces escalate the chase and the danger.",
                "climaxTurn": "The relic changes hands, raising the stakes to the supernatural.",
                "fallingAction": "Captured and powerless, the hero must outlast his captors.",
                "resolution": "The artifact's own force ends the threat and is sealed away."
            ]),
        SampleMovie(
            title: "Jurassic Park", year: 1993, genre: .adventure,
            logline: "Scientists tour a dinosaur theme park that spirals into chaos when the animals break loose.",
            beatSamples: [
                "openingImage": "A caged creature kills a handler — the park's danger is there from the first frame.",
                "themeStated": "A warning that life 'finds a way' frames the hubris about to unravel.",
                "catalyst": "Experts are invited to endorse a park populated by cloned dinosaurs.",
                "breakIntoTwo": "They tour the island, awe turning to unease as the wonders reveal cracks.",
                "midpoint": "A storm and sabotage shut down the fences and the predators get out.",
                "allIsLost": "Stranded and hunted, the group is scattered with no way to call for help.",
                "finale": "They fight through the predators and make a desperate run for the exit.",
                "finalImage": "Survivors fly away exhausted as the failed park is left to nature.",
                "exposition": "Establish a miraculous park and the experts brought to vet it.",
                "risingAction": "Wonder curdles into dread as systems begin to fail.",
                "climaxTurn": "A total power failure unleashes the dinosaurs.",
                "fallingAction": "The survivors are hunted across the collapsing island.",
                "resolution": "They barely escape, leaving the doomed experiment behind."
            ]),
        SampleMovie(
            title: "The Goonies", year: 1985, genre: .adventure,
            logline: "A group of kids follow a pirate map underground in a last-ditch effort to save their homes.",
            beatSamples: [
                "openingImage": "A rowdy group of kids discovers that their ordinary neighborhood is about to disappear.",
                "themeStated": "A legend about never giving up frames the adventure as a test of loyalty.",
                "catalyst": "They find a map that could lead to treasure and a chance to save their homes.",
                "breakIntoTwo": "The kids head underground, leaving behind childhood and comfort.",
                "midpoint": "Booby traps and rivals prove the treasure is real and the danger is worse.",
                "allIsLost": "The group is separated and the path home seems lost in the dark.",
                "finale": "They outwit the traps, reach the treasure, and stumble back into daylight.",
                "finalImage": "The kids emerge changed, having earned one unforgettable adventure.",
                "exposition": "Establish a neighborhood of kids under threat and the legend of hidden treasure.",
                "risingAction": "Caves, clues, and villains make the search increasingly perilous.",
                "climaxTurn": "The treasure chamber becomes the final test of courage.",
                "fallingAction": "The kids escape by using ingenuity and teamwork.",
                "resolution": "They save what matters and hold onto the memory of the journey."
            ]),
        SampleMovie(
            title: "Moana", year: 2016, genre: .adventure,
            logline: "A young voyager sails beyond her island to restore balance to the ocean and her people.",
            beatSamples: [
                "openingImage": "A curious girl feels the pull of the ocean long before she is allowed to answer it.",
                "themeStated": "A grandmother's wisdom about listening to the call of the sea frames her destiny.",
                "catalyst": "The island's crisis forces her to sail beyond the reef and find the lost heart.",
                "breakIntoTwo": "She launches into the open ocean and becomes the hero of her own voyage.",
                "midpoint": "A fierce encounter with a shapeshifting demigod turns the mission into a partnership.",
                "allIsLost": "Failure and self-doubt make her think she cannot complete the journey.",
                "finale": "She faces the source of the imbalance and restores what was stolen.",
                "finalImage": "Home again, she leads her people forward with confidence and wonder.",
                "exposition": "Establish an island community and the young leader called by the sea.",
                "risingAction": "Storms, monsters, and myths push the voyage into legend.",
                "climaxTurn": "She realizes the true enemy is not what it seems.",
                "fallingAction": "The final journey becomes a choice about identity and courage.",
                "resolution": "Balance returns and the ocean opens to a new generation."
            ])
    ]
}

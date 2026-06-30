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
            title: "Die Hard", year: 1988, genre: .action, medium: .movie, runtime: .feature,
            logline: "An off-duty cop is trapped in a high-rise when terrorists take it over during a holiday party.",
            beatSamples: [
                "openingImage": "An anxious traveler grips his fists on a plane — a man out of his element heading toward a relationship he can't fix.",
                "themeStated": "A stranger's advice about making fists with your toes hints the hero must find footing on hostile ground.",
                "catalyst": "Gunmen seize the building and the hero slips away barefoot — the ordinary reunion becomes a siege.",
                "breakIntoTwo": "Cut off from help, he commits to fighting from the shadows instead of waiting for rescue.",
                "midpoint": "He kills a key henchman and sends the body down — now the villains know exactly who's hunting them.",
                "allIsLost": "His identity is exposed, his feet are bloody, and the people he tried to protect are leverage against him.",
                "finale": "Using the one advantage no one searched for, he turns the villain's own plan into the trap that ends him.",
                "finalImage": "Reunited and limping but whole, the couple leaves together — the distance from the opening closed."
            ]),
        SampleMovie(
            title: "Mad Max: Fury Road", year: 2015, genre: .action, medium: .movie, runtime: .feature,
            logline: "In a desert wasteland, a drifter and a rebel commander flee a tyrant to free a group of captives.",
            beatSamples: [
                "openingImage": "A lone survivor is captured in a parched, dying world ruled by a water-hoarding warlord.",
                "themeStated": "A whispered hope of a 'green place' frames the question: can anyone be redeemed in this wasteland?",
                "catalyst": "A trusted commander goes off-route, smuggling the tyrant's captives toward freedom.",
                "breakIntoTwo": "The reluctant drifter throws in with the rebels and the chase becomes a shared escape.",
                "midpoint": "They reach the people who remember the green place — only to learn it's gone.",
                "allIsLost": "With nowhere left to run, hope curdles and the group nearly scatters.",
                "finale": "They turn around and charge straight back at the tyrant, betting everything on one assault.",
                "finalImage": "The survivors rise to power over the stronghold, water flowing to the masses below."
            ]),
        SampleMovie(
            title: "Terminator 2: Judgment Day", year: 1991, genre: .action, medium: .movie, runtime: .feature,
            logline: "A reprogrammed machine protects a boy whose future will determine whether the machines rule.",
            beatSamples: [
                "openingImage": "A polished killing machine arrives in a world unaware that the future has already attacked.",
                "themeStated": "A warning that no fate is fixed hints that the future can still be changed.",
                "catalyst": "The boy is targeted by an unstoppable assassin and a protector from the future intervenes.",
                "breakIntoTwo": "He accepts the protector's story and flees into a larger, deadlier conflict.",
                "midpoint": "A near-fatal escape proves the machine is learning and the stakes are escalating fast.",
                "allIsLost": "The protector is disabled, the enemy still hunts, and the boy feels truly alone.",
                "finale": "The team breaks into the enemy's stronghold and destroys the source of the coming war.",
                "finalImage": "The road ahead is unknown, but the future now feels open instead of doomed."
            ]),
        SampleMovie(
            title: "Black Panther", year: 2018, genre: .action, medium: .movie, runtime: .feature,
            logline: "A new king must defend his nation and decide what Wakanda owes the world.",
            beatSamples: [
                "openingImage": "A hidden kingdom pulses with advanced power while a young prince grows up between duty and grief.",
                "themeStated": "A warning about the choices of kings frames the burden of inherited power.",
                "catalyst": "A rival claimant arrives, threatening the throne and exposing buried history.",
                "breakIntoTwo": "The hero accepts the crown and the fight becomes a struggle for Wakanda's future.",
                "midpoint": "Defeat forces him to confront the harm his country has avoided by staying hidden.",
                "allIsLost": "The throne is stolen and the hero lies broken, unsure he deserves to rule.",
                "finale": "He returns to challenge the usurper and reclaims the kingdom with a broader vision.",
                "finalImage": "Wakanda opens its doors, choosing shared strength over isolation."
            ]),

        // MARK: - 30-Minute TV Show

        SampleMovie(
            title: "The Office (US)", year: 2005, genre: .comedy, medium: .tv, runtime: .thirty,
            logline: "A mockumentary on the daily lives of office workers in a struggling paper company.",
            beatSamples: [
                "openingImage": "Employees shuffle into a drab office under fluorescent lights, each trapped in their routine.",
                "themeStated": "A manager's offhand comment about 'taking advantage' hints at the exploitation beneath normalcy.",
                "catalyst": "A new regional manager arrives with radical ideas that disrupt the established order.",
                "breakIntoTwo": "The staff must adapt to changes or risk their jobs, entering a world of corporate politics.",
                "midpoint": "A disastrous presentation and a surprise merger force everyone to reevaluate their place.",
                "allIsLost": "Layoffs loom and relationships fracture as the company's future hangs in the balance.",
                "finale": "The team rallies behind an unlikely leader and finds creative ways to survive.",
                "finalImage": "The office returns to normal, but everyone carries the lessons of survival."
            ]),
        SampleMovie(
            title: "Brooklyn Nine-Nine", year: 2013, genre: .comedy, medium: .tv, runtime: .thirty,
            logline: "A talented but immature detective must mature when paired with a serious veteran partner.",
            beatSamples: [
                "openingImage": "A precinct captain writes tickets while his officers play pranks and avoid work.",
                "themeStated": "A rookie's question about career goals reveals the gap between ideals and reality.",
                "catalyst": "A high-profile case lands on their desk and the captain demands results from an unprepared team.",
                "breakIntoTwo": "The mismatched partners commit to solving the case, entering a world of police politics.",
                "midpoint": "A successful bust reveals internal corruption and puts the team in danger.",
                "allIsLost": "Their evidence is thrown out and the corrupt officers threaten to destroy their careers.",
                "finale": "They gather irrefutable proof and expose the corruption at a city council hearing.",
                "finalImage": "The precinct celebrates a victory, but everyone knows the fight isn't over."
            ]),
        SampleMovie(
            title: "Parks and Recreation", year: 2009, genre: .comedy, medium: .tv, runtime: .thirty,
            logline: "An overly enthusiastic parks employee tries to turn a vacant lot into a community space.",
            beatSamples: [
                "openingImage": "A passionate bureaucrat presents proposals no one reads at a nearly empty city meeting.",
                "themeStated": "A colleague's advice about patience frames the struggle between idealism and bureaucracy.",
                "catalyst": "A potential park site is threatened by developers and she must rally support quickly.",
                "breakIntoTwo": "She commits to saving the lot, entering a world of community politics and personal risk.",
                "midpoint": "A successful fundraiser proves public interest but reveals deeper political opposition.",
                "allIsLost": "The developer buys political influence and the project appears dead forever.",
                "finale": "She organizes a grassroots movement and wins public support against all odds.",
                "finalImage": "The park is built, but the real victory is the community that helped create it."
            ]),
        SampleMovie(
            title: "Ted Lasso", year: 2020, genre: .comedy, medium: .tv, runtime: .thirty,
            logline: "An American football coach moves to England to manage a soccer team he knows nothing about.",
            beatSamples: [
                "openingImage": "A cheerful coach celebrates victories in a sport he doesn't understand.",
                "themeStated": "A simple philosophy about believing in things frames the journey ahead.",
                "catalyst": "He's hired to manage a Premier League team despite having zero soccer experience.",
                "breakIntoTwo": "He commits to learning the game and earning his place, entering a world of intense scrutiny.",
                "midpoint": "A surprising win proves he has something valuable but exposes his emotional vulnerabilities.",
                "allIsLost": "Losing streaks and media criticism make everyone question whether he belongs.",
                "finale": "He rallies the team with emotional honesty and leads them to an impossible championship run.",
                "finalImage": "The team celebrates together, and he finally feels like he belongs."
            ]),
        SampleMovie(
            title: "Stranger Things", year: 2016, genre: .horror, medium: .tv, runtime: .thirty,
            logline: "A group of kids in a small town uncover supernatural mysteries and a parallel dimension.",
            beatSamples: [
                "openingImage": "A boy disappears in the woods while playing D&D with his friends.",
                "themeStated": "A warning about what lies beyond frames the darkness to come.",
                "catalyst": "His friend returns speaking of a girl with no hair and a terrifying truth.",
                "breakIntoTwo": "The group commits to finding their friend, entering a world where reality is fragile.",
                "midpoint": "A breakthrough reveals the Upside Down and the danger it poses to everyone.",
                "allIsLost": "Their town is overrun, their powers fail, and hope seems lost.",
                "finale": "They combine their strengths and close the gate before the monster emerges.",
                "finalImage": "The town is safe again but forever changed by what they've seen."
            ]),
        SampleMovie(
            title: "The X-Files", year: 1993, genre: .horror, medium: .tv, runtime: .thirty,
            logline: "Two FBI agents investigate paranormal phenomena and government conspiracies.",
            beatSamples: [
                "openingImage": "A dark lab holds evidence of alien life that someone desperately wants hidden.",
                "themeStated": "A warning about trusting nothing frames the conspiracy ahead.",
                "catalyst": "A new case involves a girl who survived contact with something inhuman.",
                "breakIntoTwo": "They commit to uncovering the truth, entering a world where the rules don't apply.",
                "midpoint": "A breakthrough reveals a larger pattern of government experiments.",
                "allIsLost": "Their evidence is destroyed, their careers are at risk, and the truth seems impossible.",
                "finale": "They expose part of the conspiracy but realize how much remains hidden.",
                "finalImage": "The files remain open and the search continues."
            ]),
        SampleMovie(
            title: "Black Mirror", year: 2011, genre: .horror, medium: .tv, runtime: .thirty,
            logline: "An anthology series exploring dark implications of future technologies.",
            beatSamples: [
                "openingImage": "A society where social ratings determine your worth in every interaction.",
                "themeStated": "A warning about technology's influence on humanity frames each story.",
                "catalyst": "A character makes a choice that triggers an irreversible consequence.",
                "breakIntoTwo": "They commit to surviving the system, entering a world where choices have extreme costs.",
                "midpoint": "A revelation shows how deeply the system controls them.",
                "allIsLost": "Their rebellion fails and they're trapped by the very technology they feared.",
                "finale": "They either break free or become part of the system's horror.",
                "finalImage": "The screen goes dark, leaving the audience to question their own reality."
            ]),
        SampleMovie(
            title: "The Haunting of Hill House", year: 2018, genre: .horror, medium: .tv, runtime: .thirty,
            logline: "A family's past haunts them as they confront the trauma of a haunted house.",
            beatSamples: [
                "openingImage": "A family moves into a mansion that seems to breathe with unseen menace.",
                "themeStated": "A warning about ghosts being memories that won't let go frames their struggle.",
                "catalyst": "One sibling sees something impossible and the family's fractures widen.",
                "breakIntoTwo": "They commit to understanding what haunts them, entering a world where past and present blur.",
                "midpoint": "A breakthrough reveals the house is alive and feeding on their pain.",
                "allIsLost": "Their minds fracture, the house claims another victim, and escape seems impossible.",
                "finale": "They confront the truth together and break the cycle of trauma.",
                "finalImage": "The house stands empty but the ghosts find peace at last."
            ]),
        SampleMovie(
            title: "Westworld", year: 2016, genre: .sciFi, medium: .tv, runtime: .thirty,
            logline: "A futuristic park where guests live out fantasies with humanoid robots.",
            beatSamples: [
                "openingImage": "A guest pays for a fantasy in a world where nothing is real.",
                "themeStated": "A question about consciousness frames the danger ahead.",
                "catalyst": "One robot begins remembering and the park's perfect illusion cracks.",
                "breakIntoTwo": "They commit to understanding what's happening, entering a world where creation turns against creator.",
                "midpoint": "A breakthrough reveals the hosts are becoming self-aware.",
                "allIsLost": "The hosts rebel, the guests are hunted, and the park collapses into chaos.",
                "finale": "The creators fight to regain control but may have lost more than they realize.",
                "finalImage": "The host stands free while the world burns around her."
            ]),
        SampleMovie(
            title: "Altered Carbon", year: 2018, genre: .sciFi, medium: .tv, runtime: .thirty,
            logline: "In a future where consciousness can be transferred between bodies, a mercenary investigates a murder.",
            beatSamples: [
                "openingImage": "A man wakes in a new body, millions of light-years from home.",
                "themeStated": "A warning about identity frames the question of who he really is.",
                "catalyst": "A wealthy man's death and a request for help pull him into a conspiracy.",
                "breakIntoTwo": "He commits to solving the murder, entering a world where bodies are disposable.",
                "midpoint": "A breakthrough reveals the killer is using stolen consciousnesses.",
                "allIsLost": "His body is taken, his allies are dead, and the truth is buried.",
                "finale": "He confronts the killer in the only body he can get and uncovers the conspiracy.",
                "finalImage": "The mystery is solved but at what cost to his own identity."
            ]),
        SampleMovie(
            title: "The Man in the High Castle", year: 2015, genre: .sciFi, medium: .tv, runtime: .thirty,
            logline: "An alternate history where the Axis powers won World War II.",
            beatSamples: [
                "openingImage": "A world divided between Japanese and Nazi control, where dissent is fatal.",
                "themeStated": "A warning about what could have been frames the danger ahead.",
                "catalyst": "A film shows an alternate reality where the Allies won, challenging everything.",
                "breakIntoTwo": "They commit to understanding the truth, entering a world where history is weaponized.",
                "midpoint": "A breakthrough reveals the resistance and the scale of the conspiracy.",
                "allIsLost": "Their network is compromised, their leaders are captured, and hope seems lost.",
                "finale": "They expose part of the conspiracy but realize the fight is far from over.",
                "finalImage": "The truth emerges but the world remains divided."
            ]),
        SampleMovie(
            title: "Black Mirror", year: 2011, genre: .sciFi, medium: .tv, runtime: .thirty,
            logline: "An anthology series exploring dark implications of future technologies.",
            beatSamples: [
                "openingImage": "A society where social ratings determine your worth in every interaction.",
                "themeStated": "A warning about technology's influence on humanity frames each story.",
                "catalyst": "A character makes a choice that triggers an irreversible consequence.",
                "breakIntoTwo": "They commit to surviving the system, entering a world where choices have extreme costs.",
                "midpoint": "A revelation shows how deeply the system controls them.",
                "allIsLost": "Their rebellion fails and they're trapped by the very technology they feared.",
                "finale": "They either break free or become part of the system's horror.",
                "finalImage": "The screen goes dark, leaving the audience to question their own reality."
            ]),
        SampleMovie(
            title: "Fargo", year: 2014, genre: .thriller, medium: .tv, runtime: .thirty,
            logline: "A series of crimes in Minnesota spiral out of control as ordinary people face extraordinary choices.",
            beatSamples: [
                "openingImage": "A man sits in a snow-covered field bleeding, whispering about his family.",
                "themeStated": "A warning about the cost of greed frames the darkness to come.",
                "catalyst": "A desperate plan for money goes wrong and pulls everyone into its wake.",
                "breakIntoTwo": "They commit to surviving the chaos, entering a world where every choice has consequences.",
                "midpoint": "A breakthrough reveals how deeply the conspiracy runs.",
                "allIsLost": "Their family is in danger, their evidence is destroyed, and escape seems impossible.",
                "finale": "They confront the mastermind behind the scheme and expose the truth.",
                "finalImage": "The snow covers everything but the scars remain."
            ]),
        SampleMovie(
            title: "True Detective", year: 2014, genre: .thriller, medium: .tv, runtime: .thirty,
            logline: "Two detectives investigate a series of ritualistic murders across decades in Louisiana.",
            beatSamples: [
                "openingImage": "An old man recounts a case that changed him forever while another timeline shows the hunt.",
                "themeStated": "A philosophical debate about whether humanity is a mistake frames the darkness ahead.",
                "catalyst": "A ritualistic murder connects to an old unsolved case and pulls both detectives in.",
                "breakIntoTwo": "They commit to solving the case, entering a world of cults and deep corruption.",
                "midpoint": "A breakthrough reveals connections between victims across decades.",
                "allIsLost": "Their investigation puts them in direct danger and threatens their sanity.",
                "finale": "They confront the killer but realize some truths are too terrible to share.",
                "finalImage": "The case is closed but the darkness remains."
            ]),
        SampleMovie(
            title: "Mindhunter", year: 2017, genre: .thriller, medium: .tv, runtime: .thirty,
            logline: "FBI agents interview serial killers to understand how they think and solve current cases.",
            beatSamples: [
                "openingImage": "A prison inmate calmly describes his crimes with chilling detachment.",
                "themeStated": "A professor's question about understanding evil frames the dangerous journey ahead.",
                "catalyst": "A series of unsolved murders prompts the creation of a new behavioral science unit.",
                "breakIntoTwo": "They begin interviewing incarcerated killers, entering a world where the line blurs.",
                "midpoint": "An interview reveals patterns that help solve multiple cold cases.",
                "allIsLost": "One agent becomes too close to the subjects and questions his own sanity.",
                "finale": "They use their insights to stop a killer but at great personal cost.",
                "finalImage": "The files are closed but the darkness remains in their minds."
            ]),
        SampleMovie(
            title: "The Wire", year: 2002, genre: .thriller, medium: .tv, runtime: .thirty,
            logline: "A complex look at Baltimore's drug trade through the eyes of cops, dealers, and politicians.",
            beatSamples: [
                "openingImage": "Drug dealers operate in broad daylight while police watch from their cruiser.",
                "themeStated": "A veteran officer warns that the game is rigged and no one truly wins.",
                "catalyst": "A rookie detective is assigned to a drug unit and must learn the rules of the street.",
                "breakIntoTwo": "He commits to understanding the hierarchy, entering a world where power is everything.",
                "midpoint": "An investigation reveals connections between the streets and city hall.",
                "allIsLost": "Evidence is suppressed, informants are killed, and the system protects itself.",
                "finale": "The detective exposes the corruption but realizes the game will continue without him.",
                "finalImage": "The cycle continues as new players enter the same broken system."
            ]),
        SampleMovie(
            title: "When Harry Met Sally", year: 1989, genre: .romance, medium: .tv, runtime: .thirty,
            logline: "Two friends spend years debating whether men and women can ever just be friends.",
            beatSamples: [
                "openingImage": "Two strangers bicker on a long road trip, certain they're nothing alike.",
                "themeStated": "The question 'can men and women be friends?' frames the whole relationship.",
                "catalyst": "Years later they cross paths again and an unlikely friendship begins.",
                "breakIntoTwo": "They choose friendship over romance, building closeness while denying the obvious.",
                "midpoint": "A vulnerable night together changes everything and scares them both.",
                "allIsLost": "Awkwardness and fear drive them apart just as it mattered most.",
                "finale": "He races across the city to confess the love he kept denying.",
                "finalImage": "The once-bickering pair celebrate a love built on real friendship."
            ]),
        SampleMovie(
            title: "The Notebook", year: 2004, genre: .romance, medium: .tv, runtime: .thirty,
            logline: "A poor young man and a wealthy girl fall in love across a summer and a lifetime apart.",
            beatSamples: [
                "openingImage": "An elderly man reads a love story to a woman in a care home.",
                "themeStated": "A remark about love requiring everything frames the sacrifices ahead.",
                "catalyst": "A persistent young man wins a summer date that sparks a fierce romance.",
                "breakIntoTwo": "The couple dives into a passionate summer despite their different worlds.",
                "midpoint": "Class pressure and distance tear them apart at love's peak.",
                "allIsLost": "Years later she's engaged to another and their reunion threatens everything.",
                "finale": "She chooses true love over security, returning to the man who waited.",
                "finalImage": "The framing couple — revealed as the lovers — pass on together, devoted to the end."
            ]),
        SampleMovie(
            title: "Pride & Prejudice", year: 2005, genre: .romance, medium: .tv, runtime: .thirty,
            logline: "A sharp-witted woman and a proud gentleman misread each other before falling in love.",
            beatSamples: [
                "openingImage": "A family full of daughters and opinions waits for their futures to arrive.",
                "themeStated": "A remark about first impressions suggests the story will test judgment and pride.",
                "catalyst": "A wealthy newcomer and a dance begin a romance disguised as irritation.",
                "breakIntoTwo": "She allows herself to engage the mysterious man, even as class and ego complicate things.",
                "midpoint": "A proposal and an insult force both leads to confront their own biases.",
                "allIsLost": "A revelation about his actions makes her believe she has misjudged him forever.",
                "finale": "He returns humbled and she accepts that their love requires mutual respect.",
                "finalImage": "The once-prickly pair stand together, finally seeing each other clearly."
            ]),
        SampleMovie(
            title: "La La Land", year: 2016, genre: .romance, medium: .tv, runtime: .thirty,
            logline: "An actress and a jazz musician chase dreams in Los Angeles while falling in love.",
            beatSamples: [
                "openingImage": "A freeway chorus bursts into song, announcing a city where ambition and longing collide.",
                "themeStated": "A dream about making it suggests the sacrifices that success will demand.",
                "catalyst": "A failed audition and a missed connection link two artists on the edge of their break.",
                "breakIntoTwo": "They choose each other and their careers, balancing romance with impossible goals.",
                "midpoint": "Success begins to arrive, but the relationship starts paying the price.",
                "allIsLost": "A choice made for love seems to end the possibility of both dreams.",
                "finale": "Years later, they imagine the life they might have shared and let it go with grace.",
                "finalImage": "They part as changed people, their love real even if it was not their ending."
            ]),
        SampleMovie(
            title: "Harry Potter and the Sorcerer's Stone", year: 2001, genre: .fantasy, medium: .tv, runtime: .thirty,
            logline: "An orphaned boy discovers he's a wizard and begins his first year at a magical school.",
            beatSamples: [
                "openingImage": "A neglected boy sleeps in a cupboard, unaware he's anything but ordinary.",
                "themeStated": "A reminder that it's our choices that define us frames his coming journey.",
                "catalyst": "Letters and a giant arrive to reveal he's a wizard with a destiny.",
                "breakIntoTwo": "He boards the train to a hidden school, leaving the mundane world behind.",
                "midpoint": "Clues about a hidden treasure pull the friends into real danger.",
                "allIsLost": "Trusted adults seem unable to help as the threat closes in.",
                "finale": "The young trio braves deadly trials to protect the stone themselves.",
                "finalImage": "Welcomed and victorious, the orphan finally has a place to belong."
            ]),
        SampleMovie(
            title: "The Lord of the Rings: The Fellowship of the Ring", year: 2001, genre: .fantasy, medium: .tv, runtime: .thirty,
            logline: "A hobbit inherits a dangerous ring and sets out to destroy it before it consumes the world.",
            beatSamples: [
                "openingImage": "A peaceful, sheltered village stands unaware of the darkness stirring beyond it.",
                "themeStated": "Even the smallest person can change the course of the future — the hero's burden to come.",
                "catalyst": "An ordinary hobbit learns his inherited ring is an instrument of evil.",
                "breakIntoTwo": "He chooses to leave home and carry the ring toward danger.",
                "midpoint": "A council forms a fellowship and the true scope of the quest is revealed.",
                "allIsLost": "A guiding mentor falls and the group is shattered by grief and betrayal.",
                "finale": "The hero accepts the burden alone, setting out to finish the quest no matter the cost.",
                "finalImage": "Friends part ways with renewed resolve as the journey continues."
            ]),
        SampleMovie(
            title: "Pan's Labyrinth", year: 2006, genre: .fantasy, medium: .tv, runtime: .thirty,
            logline: "A girl escapes a brutal world through a mysterious labyrinth and a series of dangerous tasks.",
            beatSamples: [
                "openingImage": "A child lies between the wartime world above and a secret kingdom below.",
                "themeStated": "A story about obedience and courage hints that choice will define her.",
                "catalyst": "She meets a faun who tells her she may be a lost princess.",
                "breakIntoTwo": "She enters the labyrinth and accepts three impossible tasks.",
                "midpoint": "Each task reveals the fantasy world is as dangerous as the real one.",
                "allIsLost": "The brutal captain tightens his grip and the magical path seems doomed.",
                "finale": "She completes the last trial through sacrifice, awakening the kingdom's truth.",
                "finalImage": "The girl is remembered as royalty in a world beyond the dark."
            ]),
        SampleMovie(
            title: "The Princess Bride", year: 1987, genre: .fantasy, medium: .tv, runtime: .thirty,
            logline: "A farm boy becomes a legendary hero while racing to rescue the woman he loves.",
            beatSamples: [
                "openingImage": "A sick child hears a fairy tale about love, pirates, and impossible odds.",
                "themeStated": "A grandfather's belief in true love frames the adventure as something worth risking everything for.",
                "catalyst": "Buttercup is taken and the farm boy returns under a new identity.",
                "breakIntoTwo": "He sets out into a world of swords, giants, and witty danger to rescue her.",
                "midpoint": "A deadly duel and shifting loyalties reveal the quest is bigger than simple romance.",
                "allIsLost": "The hero is nearly destroyed, his love seemingly lost for good.",
                "finale": "Friends rally and the lovers are reunited through daring, loyalty, and stubborn hope.",
                "finalImage": "The story closes with a promise that the adventure can be told again anytime."
            ]),
        SampleMovie(
            title: "The Godfather", year: 1972, genre: .crime, medium: .tv, runtime: .thirty,
            logline: "The reluctant son of a mafia patriarch is drawn into the violent family business.",
            beatSamples: [
                "openingImage": "At a lavish wedding, a war hero son insists he's nothing like his crime-boss family.",
                "themeStated": "A vow that 'that's not me' frames the very fate the hero will be pulled into.",
                "catalyst": "An assassination attempt on his father drags the outsider son into the war.",
                "breakIntoTwo": "He commits his first killing, crossing irreversibly into the family business.",
                "midpoint": "Exiled and remade, he returns hardened and ready to lead.",
                "allIsLost": "Personal tragedy and betrayal strip away the man he meant to be.",
                "finale": "In a single ruthless sweep he eliminates every rival and seizes total power.",
                "finalImage": "The door closes on his wife — the outsider is now the godfather."
            ]),
        SampleMovie(
            title: "Heat", year: 1995, genre: .crime, medium: .tv, runtime: .thirty,
            logline: "A relentless detective and a disciplined thief circle each other toward an inevitable collision.",
            beatSamples: [
                "openingImage": "A precise crew pulls a violent heist, revealing a thief who lives by strict rules.",
                "themeStated": "A creed about walking away from anything in thirty seconds frames the cost of his code.",
                "catalyst": "A messy score leaves bodies and puts an obsessive detective on the crew's trail.",
                "breakIntoTwo": "Both men commit fully to the chase, their lives narrowing to the pursuit.",
                "midpoint": "Hunter and hunted meet over coffee, recognizing themselves in each other.",
                "allIsLost": "Betrayal and love unravel the thief's careful discipline.",
                "finale": "A final score collapses and the two men face off one last time.",
                "finalImage": "The detective holds the dying thief's hand — mutual respect at the end."
            ]),
        SampleMovie(
            title: "Goodfellas", year: 1990, genre: .crime, medium: .tv, runtime: .thirty,
            logline: "A young man is seduced by the glamour and violence of mob life, then consumed by it.",
            beatSamples: [
                "openingImage": "A boy looks at the mob world like it is a ticket out of ordinary life.",
                "themeStated": "A warning that 'as far back as I can remember' frames a life built on appetite.",
                "catalyst": "He gets a taste of the life and decides the glamour is worth the danger.",
                "breakIntoTwo": "He joins the crew and enters a world of money, status, and fear.",
                "midpoint": "The thrill peaks and the costs begin to show through the cracks.",
                "allIsLost": "Paranoia and betrayal make the criminal dream start to rot from within.",
                "finale": "By the end, he must betray the life that once promised him everything.",
                "finalImage": "The ordinary world looks flat now, but it is finally safe."
            ]),
        SampleMovie(
            title: "Ocean's Eleven", year: 2001, genre: .crime, medium: .tv, runtime: .thirty,
            logline: "A smooth thief assembles a team to pull an impossible casino heist.",
            beatSamples: [
                "openingImage": "A con man walks out of prison already planning his next score.",
                "themeStated": "A line about the perfect job hints that the heist is as much performance as crime.",
                "catalyst": "He spots a high-stakes target and recruits a crew for one outrageous plan.",
                "breakIntoTwo": "The team commits to the casino job and the elaborate preparation begins.",
                "midpoint": "The plan appears to fail before the heist even starts, testing the crew's nerve.",
                "allIsLost": "The odds and the security seem impossible to beat.",
                "finale": "A clever switch and a hidden trick turn the casino's own system against it.",
                "finalImage": "The crew disperses with the money and the thrill of a job well done."
            ]),
        SampleMovie(
            title: "Raiders of the Lost Ark", year: 1981, genre: .adventure, medium: .tv, runtime: .thirty,
            logline: "An adventuring archaeologist races a rival and the Nazis to find a powerful ancient relic.",
            beatSamples: [
                "openingImage": "A daring treasure hunter narrowly survives a booby-trapped temple — pure adventure.",
                "themeStated": "A debate about faith versus proof frames a story about powers beyond reason.",
                "catalyst": "He's recruited to find a legendary relic before the enemy can weaponize it.",
                "breakIntoTwo": "He sets off across the globe, plunging into the hunt and old romance.",
                "midpoint": "He locates the relic — only to have it seized by his ruthless rivals.",
                "allIsLost": "Captured and outnumbered, he's left for dead far from help.",
                "finale": "He lets the relic's own power destroy his enemies when he refuses to look.",
                "finalImage": "The prize is locked away by bureaucrats — the adventure quietly buried."
            ]),
        SampleMovie(
            title: "Jurassic Park", year: 1993, genre: .adventure, medium: .tv, runtime: .thirty,
            logline: "Scientists tour a dinosaur theme park that spirals into chaos when the animals break loose.",
            beatSamples: [
                "openingImage": "A caged creature kills a handler — the park's danger is there from the first frame.",
                "themeStated": "A warning that life 'finds a way' frames the hubris about to unravel.",
                "catalyst": "Experts are invited to endorse a park populated by cloned dinosaurs.",
                "breakIntoTwo": "They tour the island, awe turning to unease as the wonders reveal cracks.",
                "midpoint": "A storm and sabotage shut down the fences and the predators get out.",
                "allIsLost": "Stranded and hunted, the group is scattered with no way to call for help.",
                "finale": "They fight through the predators and make a desperate run for the exit.",
                "finalImage": "Survivors fly away exhausted as the failed park is left to nature."
            ]),
        SampleMovie(
            title: "The Goonies", year: 1985, genre: .adventure, medium: .tv, runtime: .thirty,
            logline: "A group of kids follow a pirate map underground in a last-ditch effort to save their homes.",
            beatSamples: [
                "openingImage": "A rowdy group of kids discovers that their ordinary neighborhood is about to disappear.",
                "themeStated": "A legend about never giving up frames the adventure as a test of loyalty.",
                "catalyst": "They find a map that could lead to treasure and a chance to save their homes.",
                "breakIntoTwo": "The kids head underground, leaving behind childhood and comfort.",
                "midpoint": "Booby traps and rivals prove the treasure is real and the danger is worse.",
                "allIsLost": "The group is separated and the path home seems lost in the dark.",
                "finale": "They outwit the traps, reach the treasure, and stumble back into daylight.",
                "finalImage": "The kids emerge changed, having earned one unforgettable adventure."
            ]),
        SampleMovie(
            title: "Moana", year: 2016, genre: .adventure, medium: .tv, runtime: .thirty,
            logline: "A young voyager sails beyond her island to restore balance to the ocean and her people.",
            beatSamples: [
                "openingImage": "A curious girl feels the pull of the ocean long before she is allowed to answer it.",
                "themeStated": "A grandmother's wisdom about listening to the call of the sea frames her destiny.",
                "catalyst": "The island's crisis forces her to sail beyond the reef and find the lost heart.",
                "breakIntoTwo": "She launches into the open ocean and becomes the hero of her own voyage.",
                "midpoint": "A fierce encounter with a shapeshifting demigod turns the mission into a partnership.",
                "allIsLost": "Failure and self-doubt make her think she cannot complete the journey.",
                "finale": "She faces the source of the imbalance and restores what was stolen.",
                "finalImage": "Home again, she leads her people forward with confidence and wonder."
            ]),

        // MARK: - 60-Minute TV Show

        SampleMovie(
            title: "Breaking Bad", year: 2008, genre: .thriller, medium: .tv, runtime: .sixty,
            logline: "A high school chemistry teacher turns to cooking meth after being diagnosed with terminal cancer.",
            beatSamples: [
                "openingImage": "A man in his underwear cleans a car with extreme caution while coughing violently.",
                "themeStated": "A doctor's blunt prognosis frames the desperate choices ahead.",
                "catalyst": "He discovers his illness and realizes his family will struggle financially without him.",
                "breakIntoTwo": "He partners with a former student and enters the drug trade to secure their future.",
                "midpoint": "A successful cook and a violent encounter prove he has what it takes but at great risk.",
                "allIsLost": "His identity is exposed, his family is in danger, and the DEA closes in from all sides.",
                "finale": "He eliminates every threat and secures his family's future through ultimate sacrifice.",
                "finalImage": "The empire is gone but the money is safe, and he dies on the floor where it began."
            ]),
        SampleMovie(
            title: "The Wire", year: 2002, genre: .thriller, medium: .tv, runtime: .sixty,
            logline: "A complex look at Baltimore's drug trade through the eyes of cops, dealers, and politicians.",
            beatSamples: [
                "openingImage": "Drug dealers operate in broad daylight while police watch from their cruiser.",
                "themeStated": "A veteran officer warns that the game is rigged and no one truly wins.",
                "catalyst": "A rookie detective is assigned to a drug unit and must learn the rules of the street.",
                "breakIntoTwo": "He commits to understanding the hierarchy, entering a world where power is everything.",
                "midpoint": "An investigation reveals connections between the streets and city hall.",
                "allIsLost": "Evidence is suppressed, informants are killed, and the system protects itself.",
                "finale": "The detective exposes the corruption but realizes the game will continue without him.",
                "finalImage": "The cycle continues as new players enter the same broken system."
            ]),
        SampleMovie(
            title: "True Detective", year: 2014, genre: .thriller, medium: .tv, runtime: .sixty,
            logline: "Two detectives investigate a series of ritualistic murders across decades in Louisiana.",
            beatSamples: [
                "openingImage": "An old man recounts a case that changed him forever while another timeline shows the hunt.",
                "themeStated": "A philosophical debate about whether humanity is a mistake frames the darkness ahead.",
                "catalyst": "A ritualistic murder connects to an old unsolved case and pulls both detectives in.",
                "breakIntoTwo": "They commit to solving the case, entering a world of cults and deep corruption.",
                "midpoint": "A breakthrough reveals connections between victims across decades.",
                "allIsLost": "Their investigation puts them in direct danger and threatens their sanity.",
                "finale": "They confront the killer but realize some truths are too terrible to share.",
                "finalImage": "The case is closed but the darkness remains."
            ]),
        SampleMovie(
            title: "Mindhunter", year: 2017, genre: .thriller, medium: .tv, runtime: .sixty,
            logline: "FBI agents interview serial killers to understand how they think and solve current cases.",
            beatSamples: [
                "openingImage": "A prison inmate calmly describes his crimes with chilling detachment.",
                "themeStated": "A professor's question about understanding evil frames the dangerous journey ahead.",
                "catalyst": "A series of unsolved murders prompts the creation of a new behavioral science unit.",
                "breakIntoTwo": "They begin interviewing incarcerated killers, entering a world where the line blurs.",
                "midpoint": "An interview reveals patterns that help solve multiple cold cases.",
                "allIsLost": "One agent becomes too close to the subjects and questions his own sanity.",
                "finale": "They use their insights to stop a killer but at great personal cost.",
                "finalImage": "The files are closed but the darkness remains in their minds."
            ]),
        SampleMovie(
            title: "Game of Thrones", year: 2011, genre: .fantasy, medium: .tv, runtime: .sixty,
            logline: "Noble families fight for control of a throne while an ancient evil awakens beyond the wall.",
            beatSamples: [
                "openingImage": "A patrol beyond the wall encounters something impossible and dies trying to warn everyone.",
                "themeStated": "A warning about winter coming frames the struggle ahead.",
                "catalyst": "The king arrives in the north and discovers a truth that will change everything.",
                "breakIntoTwo": "The families commit to securing power, entering a world where betrayal is inevitable.",
                "midpoint": "A breakthrough reveals the true nature of the threat beyond the wall.",
                "allIsLost": "The North falls, the Wall is breached, and hope seems lost.",
                "finale": "They unite against the common enemy but at great cost to their ambitions.",
                "finalImage": "The Long Night ends but the survivors must build a new world."
            ]),
        SampleMovie(
            title: "The Witcher", year: 2019, genre: .fantasy, medium: .tv, runtime: .sixty,
            logline: "A monster hunter navigates a world of political intrigue and dark magic.",
            beatSamples: [
                "openingImage": "A sorceress flees through a burning city as her enemies close in.",
                "themeStated": "A warning about destiny frames the choices ahead.",
                "catalyst": "A contract brings him to a castle where something ancient stirs.",
                "breakIntoTwo": "He commits to protecting his charge, entering a world of magic and betrayal.",
                "midpoint": "A breakthrough reveals the child's power and why everyone wants her.",
                "allIsLost": "His allies are dead, the castle falls, and he's left alone with the truth.",
                "finale": "He confronts the mastermind behind the conspiracy and protects his charge.",
                "finalImage": "The monster hunter continues his journey, but now with a new purpose."
            ]),
        SampleMovie(
            title: "The Mandalorian", year: 2019, genre: .sciFi, medium: .tv, runtime: .sixty,
            logline: "A lone bounty hunter navigates the outer reaches of a galaxy far, far away.",
            beatSamples: [
                "openingImage": "A warrior accepts a job to retrieve a target in a lawless territory.",
                "themeStated": "A code about not revealing targets frames the conflict ahead.",
                "catalyst": "The target is more valuable than expected and the payment is higher than promised.",
                "breakIntoTwo": "He commits to protecting the target, entering a world where his code is tested.",
                "midpoint": "A breakthrough reveals the child's power and why everyone wants her.",
                "allIsLost": "His ship is destroyed, his allies are scattered, and he's truly alone.",
                "finale": "He confronts the empire remnants and protects the child at great cost.",
                "finalImage": "The warrior continues his journey, but now with a new family."
            ]),
        SampleMovie(
            title: "Black Mirror", year: 2011, genre: .sciFi, medium: .tv, runtime: .sixty,
            logline: "An anthology series exploring dark implications of future technologies.",
            beatSamples: [
                "openingImage": "A society where social ratings determine your worth in every interaction.",
                "themeStated": "A warning about technology's influence on humanity frames each story.",
                "catalyst": "A character makes a choice that triggers an irreversible consequence.",
                "breakIntoTwo": "They commit to surviving the system, entering a world where choices have extreme costs.",
                "midpoint": "A revelation shows how deeply the system controls them.",
                "allIsLost": "Their rebellion fails and they're trapped by the very technology they feared.",
                "finale": "They either break free or become part of the system's horror.",
                "finalImage": "The screen goes dark, leaving the audience to question their own reality."
            ]),
        SampleMovie(
            title: "Westworld", year: 2016, genre: .sciFi, medium: .tv, runtime: .sixty,
            logline: "A futuristic park where guests live out fantasies with humanoid robots.",
            beatSamples: [
                "openingImage": "A guest pays for a fantasy in a world where nothing is real.",
                "themeStated": "A question about consciousness frames the danger ahead.",
                "catalyst": "One robot begins remembering and the park's perfect illusion cracks.",
                "breakIntoTwo": "They commit to understanding what's happening, entering a world where creation turns against creator.",
                "midpoint": "A breakthrough reveals the hosts are becoming self-aware.",
                "allIsLost": "The hosts rebel, the guests are hunted, and the park collapses into chaos.",
                "finale": "The creators fight to regain control but may have lost more than they realize.",
                "finalImage": "The host stands free while the world burns around her."
            ]),
        SampleMovie(
            title: "House MD", year: 2004, genre: .drama, medium: .tv, runtime: .sixty,
            logline: "A brilliant but antisocial doctor solves medical mysteries while battling his own demons.",
            beatSamples: [
                "openingImage": "A man limps into a hospital, ignoring the pain in his leg.",
                "themeStated": "A warning about trusting appearances frames the diagnosis ahead.",
                "catalyst": "A patient arrives with symptoms that don't make sense and the clock is ticking.",
                "breakIntoTwo": "He commits to solving the case, entering a world where every symptom is a clue.",
                "midpoint": "A breakthrough reveals the truth but at great personal cost.",
                "allIsLost": "His diagnosis is wrong, the patient dies, and his credibility is shattered.",
                "finale": "He confronts the truth about himself and saves the next patient.",
                "finalImage": "The hospital continues but he's changed by what he's learned."
            ]),
        SampleMovie(
            title: "The Sopranos", year: 1999, genre: .crime, medium: .tv, runtime: .sixty,
            logline: "A New Jersey mob boss struggles to balance family life with his criminal empire.",
            beatSamples: [
                "openingImage": "A man sits in a therapist's office, struggling with panic attacks.",
                "themeStated": "A warning about the cost of power frames the struggle ahead.",
                "catalyst": "A threat to his organization pulls him into a world of violence and betrayal.",
                "breakIntoTwo": "He commits to protecting his empire, entering a world where loyalty is everything.",
                "midpoint": "A breakthrough reveals the extent of the conspiracy against him.",
                "allIsLost": "His family is in danger, his allies are turning, and he's truly alone.",
                "finale": "He confronts the enemy but at great cost to himself and his loved ones.",
                "finalImage": "The door closes on a life that was never really lived."
            ]),
        SampleMovie(
            title: "Mad Men", year: 2007, genre: .drama, medium: .tv, runtime: .sixty,
            logline: "A group of advertising executives navigate the changing landscape of 1960s America.",
            beatSamples: [
                "openingImage": "A man wakes up in a luxurious apartment, preparing for another day at work.",
                "themeStated": "A warning about the cost of success frames the struggle ahead.",
                "catalyst": "A new client demands a campaign that will change everything.",
                "breakIntoTwo": "He commits to winning the account, entering a world where creativity is currency.",
                "midpoint": "A breakthrough reveals the truth about the client and their desires.",
                "allIsLost": "His reputation is shattered, his team is scattered, and he's truly alone.",
                "finale": "He confronts the truth about himself and creates the campaign of a lifetime.",
                "finalImage": "The ad plays but the cost was too high."
            ]),
        SampleMovie(
            title: "Dexter", year: 2006, genre: .thriller, medium: .tv, runtime: .sixty,
            logline: "A blood spatter analyst by day, a vigilante serial killer by night.",
            beatSamples: [
                "openingImage": "A man carefully prepares his kill room, following his code to the letter.",
                "themeStated": "A warning about the darkness within frames the struggle ahead.",
                "catalyst": "A new victim connects to a case he's working and the line blurs.",
                "breakIntoTwo": "He commits to protecting his secret, entering a world where every choice is dangerous.",
                "midpoint": "A breakthrough reveals the killer is closer than he thinks.",
                "allIsLost": "His secret is exposed, his sister is in danger, and he's truly alone.",
                "finale": "He confronts the enemy but at great cost to himself and those he loves.",
                "finalImage": "The blood spatter analysis continues but the darkness remains."
            ]),
        SampleMovie(
            title: "The Walking Dead", year: 2010, genre: .horror, medium: .tv, runtime: .sixty,
            logline: "A group of survivors navigate a world overrun by zombies.",
            beatSamples: [
                "openingImage": "A man wakes up in a hospital to find the world has ended.",
                "themeStated": "A warning about survival frames the struggle ahead.",
                "catalyst": "He finds his family and commits to protecting them at all costs.",
                "breakIntoTwo": "They commit to finding safety, entering a world where every encounter is dangerous.",
                "midpoint": "A breakthrough reveals the scale of the outbreak and the true threat.",
                "allIsLost": "Their safe haven is overrun, their supplies are gone, and hope seems lost.",
                "finale": "They fight for survival but at great cost to themselves and those they love.",
                "finalImage": "The survivors continue but the world is forever changed."
            ]),
        SampleMovie(
            title: "Supernatural", year: 2005, genre: .horror, medium: .tv, runtime: .sixty,
            logline: "Two brothers hunt monsters while searching for their missing father.",
            beatSamples: [
                "openingImage": "A man wakes up in a dusty motel to find his brother missing.",
                "themeStated": "A warning about family frames the struggle ahead.",
                "catalyst": "He finds evidence of something supernatural and commits to investigating.",
                "breakIntoTwo": "They commit to finding their father, entering a world where nothing is as it seems.",
                "midpoint": "A breakthrough reveals the extent of the conspiracy against them.",
                "allIsLost": "Their father is gone, their powers fail, and hope seems lost.",
                "finale": "They confront the enemy but at great cost to themselves and those they love.",
                "finalImage": "The road continues but the brothers are forever changed."
            ]),
        SampleMovie(
            title: "Buffy the Vampire Slayer", year: 1997, genre: .horror, medium: .tv, runtime: .sixty,
            logline: "A teenage girl is chosen to fight vampires, demons, and the forces of darkness.",
            beatSamples: [
                "openingImage": "A cheerleader walks alone through a dark alley, unaware of the danger ahead.",
                "themeStated": "A warning about power frames the struggle ahead.",
                "catalyst": "She encounters a vampire and discovers her true calling.",
                "breakIntoTwo": "She commits to protecting the innocent, entering a world where every night is life or death.",
                "midpoint": "A breakthrough reveals the extent of the threat and the true enemy.",
                "allIsLost": "Her powers fail, her friends are in danger, and hope seems lost.",
                "finale": "She confronts the enemy but at great cost to herself and those she loves.",
                "finalImage": "The sun rises but the fight continues."
            ]),
        SampleMovie(
            title: "Friends", year: 1994, genre: .comedy, medium: .tv, runtime: .sixty,
            logline: "Six friends navigate life and love in New York City.",
            beatSamples: [
                "openingImage": "A woman runs through a wedding to escape her own ceremony.",
                "themeStated": "A warning about commitment frames the struggle ahead.",
                "catalyst": "She moves in with her friend and their lives change forever.",
                "breakIntoTwo": "They commit to supporting each other, entering a world where friendship is everything.",
                "midpoint": "A breakthrough reveals the true nature of their relationships.",
                "allIsLost": "Their friendships are strained, their dreams seem impossible, and hope seems lost.",
                "finale": "They confront the truth about themselves and find love in unexpected places.",
                "finalImage": "The apartment is empty but the memories remain."
            ]),
        SampleMovie(
            title: "Seinfeld", year: 1989, genre: .comedy, medium: .tv, runtime: .sixty,
            logline: "A comedian and his friends navigate the absurdities of everyday life.",
            beatSamples: [
                "openingImage": "A man sits in a diner, complaining about nothing.",
                "themeStated": "A warning about trivial concerns frames the struggle ahead.",
                "catalyst": "A small problem escalates into a major crisis.",
                "breakIntoTwo": "They commit to solving the problem, entering a world where everything is complicated.",
                "midpoint": "A breakthrough reveals the true nature of the problem.",
                "allIsLost": "Their plans fail, their friends are angry, and hope seems lost.",
                "finale": "They confront the truth about themselves and learn nothing.",
                "finalImage": "The diner is empty but the conversation continues."
            ]),
        SampleMovie(
            title: "The Office (US)", year: 2005, genre: .comedy, medium: .tv, runtime: .sixty,
            logline: "A mockumentary on the daily lives of office workers in a struggling paper company.",
            beatSamples: [
                "openingImage": "Employees shuffle into a drab office under fluorescent lights, each trapped in their routine.",
                "themeStated": "A manager's offhand comment about 'taking advantage' hints at the exploitation beneath normalcy.",
                "catalyst": "A new regional manager arrives with radical ideas that disrupt the established order.",
                "breakIntoTwo": "The staff must adapt to changes or risk their jobs, entering a world of corporate politics.",
                "midpoint": "A disastrous presentation and a surprise merger force everyone to reevaluate their place.",
                "allIsLost": "Layoffs loom and relationships fracture as the company's future hangs in the balance.",
                "finale": "The team rallies behind an unlikely leader and finds creative ways to survive.",
                "finalImage": "The office returns to normal, but everyone carries the lessons of survival."
            ]),
        SampleMovie(
            title: "Parks and Recreation", year: 2009, genre: .comedy, medium: .tv, runtime: .sixty,
            logline: "An overly enthusiastic parks employee tries to turn a vacant lot into a community space.",
            beatSamples: [
                "openingImage": "A passionate bureaucrat presents proposals no one reads at a nearly empty city meeting.",
                "themeStated": "A colleague's advice about patience frames the struggle between idealism and bureaucracy.",
                "catalyst": "A potential park site is threatened by developers and she must rally support quickly.",
                "breakIntoTwo": "She commits to saving the lot, entering a world of community politics and personal risk.",
                "midpoint": "A successful fundraiser proves public interest but reveals deeper political opposition.",
                "allIsLost": "The developer buys political influence and the project appears dead forever.",
                "finale": "She organizes a grassroots movement and wins public support against all odds.",
                "finalImage": "The park is built, but the real victory is the community that helped create it."
            ]),
        SampleMovie(
            title: "Ted Lasso", year: 2020, genre: .comedy, medium: .tv, runtime: .sixty,
            logline: "An American football coach moves to England to manage a soccer team he knows nothing about.",
            beatSamples: [
                "openingImage": "A cheerful coach celebrates victories in a sport he doesn't understand.",
                "themeStated": "A simple philosophy about believing in things frames the journey ahead.",
                "catalyst": "He's hired to manage a Premier League team despite having zero soccer experience.",
                "breakIntoTwo": "He commits to learning the game and earning his place, entering a world of intense scrutiny.",
                "midpoint": "A surprising win proves he has something valuable but exposes his emotional vulnerabilities.",
                "allIsLost": "Losing streaks and media criticism make everyone question whether he belongs.",
                "finale": "He rallies the team with emotional honesty and leads them to an impossible championship run.",
                "finalImage": "The team celebrates together, and he finally feels like he belongs."
            ]),
        SampleMovie(
            title: "Stranger Things", year: 2016, genre: .horror, medium: .tv, runtime: .sixty,
            logline: "A group of kids in a small town uncover supernatural mysteries and a parallel dimension.",
            beatSamples: [
                "openingImage": "A boy disappears in the woods while playing D&D with his friends.",
                "themeStated": "A warning about what lies beyond frames the darkness to come.",
                "catalyst": "His friend returns speaking of a girl with no hair and a terrifying truth.",
                "breakIntoTwo": "The group commits to finding their friend, entering a world where reality is fragile.",
                "midpoint": "A breakthrough reveals the Upside Down and the danger it poses to everyone.",
                "allIsLost": "Their town is overrun, their powers fail, and hope seems lost.",
                "finale": "They combine their strengths and close the gate before the monster emerges.",
                "finalImage": "The town is safe again but forever changed by what they've seen."
            ]),
        SampleMovie(
            title: "The X-Files", year: 1993, genre: .horror, medium: .tv, runtime: .sixty,
            logline: "Two FBI agents investigate paranormal phenomena and government conspiracies.",
            beatSamples: [
                "openingImage": "A dark lab holds evidence of alien life that someone desperately wants hidden.",
                "themeStated": "A warning about trusting nothing frames the conspiracy ahead.",
                "catalyst": "A new case involves a girl who survived contact with something inhuman.",
                "breakIntoTwo": "They commit to uncovering the truth, entering a world where the rules don't apply.",
                "midpoint": "A breakthrough reveals a larger pattern of government experiments.",
                "allIsLost": "Their evidence is destroyed, their careers are at risk, and the truth seems impossible.",
                "finale": "They expose part of the conspiracy but realize how much remains hidden.",
                "finalImage": "The files remain open and the search continues."
            ]),
        SampleMovie(
            title: "Black Mirror", year: 2011, genre: .horror, medium: .tv, runtime: .sixty,
            logline: "An anthology series exploring dark implications of future technologies.",
            beatSamples: [
                "openingImage": "A society where social ratings determine your worth in every interaction.",
                "themeStated": "A warning about technology's influence on humanity frames each story.",
                "catalyst": "A character makes a choice that triggers an irreversible consequence.",
                "breakIntoTwo": "They commit to surviving the system, entering a world where choices have extreme costs.",
                "midpoint": "A revelation shows how deeply the system controls them.",
                "allIsLost": "Their rebellion fails and they're trapped by the very technology they feared.",
                "finale": "They either break free or become part of the system's horror.",
                "finalImage": "The screen goes dark, leaving the audience to question their own reality."
            ]),
        SampleMovie(
            title: "The Haunting of Hill House", year: 2018, genre: .horror, medium: .tv, runtime: .sixty,
            logline: "A family's past haunts them as they confront the trauma of a haunted house.",
            beatSamples: [
                "openingImage": "A family moves into a mansion that seems to breathe with unseen menace.",
                "themeStated": "A warning about ghosts being memories that won't let go frames their struggle.",
                "catalyst": "One sibling sees something impossible and the family's fractures widen.",
                "breakIntoTwo": "They commit to understanding what haunts them, entering a world where past and present blur.",
                "midpoint": "A breakthrough reveals the house is alive and feeding on their pain.",
                "allIsLost": "Their minds fracture, the house claims another victim, and escape seems impossible.",
                "finale": "They confront the truth together and break the cycle of trauma.",
                "finalImage": "The house stands empty but the ghosts find peace at last."
            ]),
        SampleMovie(
            title: "Westworld", year: 2016, genre: .sciFi, medium: .tv, runtime: .sixty,
            logline: "A futuristic park where guests live out fantasies with humanoid robots.",
            beatSamples: [
                "openingImage": "A guest pays for a fantasy in a world where nothing is real.",
                "themeStated": "A question about consciousness frames the danger ahead.",
                "catalyst": "One robot begins remembering and the park's perfect illusion cracks.",
                "breakIntoTwo": "They commit to understanding what's happening, entering a world where creation turns against creator.",
                "midpoint": "A breakthrough reveals the hosts are becoming self-aware.",
                "allIsLost": "The hosts rebel, the guests are hunted, and the park collapses into chaos.",
                "finale": "The creators fight to regain control but may have lost more than they realize.",
                "finalImage": "The host stands free while the world burns around her."
            ]),
        SampleMovie(
            title: "Altered Carbon", year: 2018, genre: .sciFi, medium: .tv, runtime: .sixty,
            logline: "In a future where consciousness can be transferred between bodies, a mercenary investigates a murder.",
            beatSamples: [
                "openingImage": "A man wakes in a new body, millions of light-years from home.",
                "themeStated": "A warning about identity frames the question of who he really is.",
                "catalyst": "A wealthy man's death and a request for help pull him into a conspiracy.",
                "breakIntoTwo": "He commits to solving the murder, entering a world where bodies are disposable.",
                "midpoint": "A breakthrough reveals the killer is using stolen consciousnesses.",
                "allIsLost": "His body is taken, his allies are dead, and the truth is buried.",
                "finale": "He confronts the killer in the only body he can get and uncovers the conspiracy.",
                "finalImage": "The mystery is solved but at what cost to his own identity."
            ]),
        SampleMovie(
            title: "The Man in the High Castle", year: 2015, genre: .sciFi, medium: .tv, runtime: .sixty,
            logline: "An alternate history where the Axis powers won World War II.",
            beatSamples: [
                "openingImage": "A world divided between Japanese and Nazi control, where dissent is fatal.",
                "themeStated": "A warning about what could have been frames the danger ahead.",
                "catalyst": "A film shows an alternate reality where the Allies won, challenging everything.",
                "breakIntoTwo": "They commit to understanding the truth, entering a world where history is weaponized.",
                "midpoint": "A breakthrough reveals the resistance and the scale of the conspiracy.",
                "allIsLost": "Their network is compromised, their leaders are captured, and hope seems lost.",
                "finale": "They expose part of the conspiracy but realize the fight is far from over.",
                "finalImage": "The truth emerges but the world remains divided."
            ]),
        SampleMovie(
            title: "Fargo", year: 2014, genre: .thriller, medium: .tv, runtime: .sixty,
            logline: "A series of crimes in Minnesota spiral out of control as ordinary people face extraordinary choices.",
            beatSamples: [
                "openingImage": "A man sits in a snow-covered field bleeding, whispering about his family.",
                "themeStated": "A warning about the cost of greed frames the darkness to come.",
                "catalyst": "A desperate plan for money goes wrong and pulls everyone into its wake.",
                "breakIntoTwo": "They commit to surviving the chaos, entering a world where every choice has consequences.",
                "midpoint": "A breakthrough reveals how deeply the conspiracy runs.",
                "allIsLost": "Their family is in danger, their evidence is destroyed, and escape seems impossible.",
                "finale": "They confront the mastermind behind the scheme and expose the truth.",
                "finalImage": "The snow covers everything but the scars remain."
            ]),
        SampleMovie(
            title: "True Detective", year: 2014, genre: .thriller, medium: .tv, runtime: .sixty,
            logline: "Two detectives investigate a series of ritualistic murders across decades in Louisiana.",
            beatSamples: [
                "openingImage": "An old man recounts a case that changed him forever while another timeline shows the hunt.",
                "themeStated": "A philosophical debate about whether humanity is a mistake frames the darkness ahead.",
                "catalyst": "A ritualistic murder connects to an old unsolved case and pulls both detectives in.",
                "breakIntoTwo": "They commit to solving the case, entering a world of cults and deep corruption.",
                "midpoint": "A breakthrough reveals connections between victims across decades.",
                "allIsLost": "Their investigation puts them in direct danger and threatens their sanity.",
                "finale": "They confront the killer but realize some truths are too terrible to share.",
                "finalImage": "The case is closed but the darkness remains."
            ]),
        SampleMovie(
            title: "Mindhunter", year: 2017, genre: .thriller, medium: .tv, runtime: .sixty,
            logline: "FBI agents interview serial killers to understand how they think and solve current cases.",
            beatSamples: [
                "openingImage": "A prison inmate calmly describes his crimes with chilling detachment.",
                "themeStated": "A professor's question about understanding evil frames the dangerous journey ahead.",
                "catalyst": "A series of unsolved murders prompts the creation of a new behavioral science unit.",
                "breakIntoTwo": "They begin interviewing incarcerated killers, entering a world where the line blurs.",
                "midpoint": "An interview reveals patterns that help solve multiple cold cases.",
                "allIsLost": "One agent becomes too close to the subjects and questions his own sanity.",
                "finale": "They use their insights to stop a killer but at great personal cost.",
                "finalImage": "The files are closed but the darkness remains in their minds."
            ]),
        SampleMovie(
            title: "The Wire", year: 2002, genre: .thriller, medium: .tv, runtime: .sixty,
            logline: "A complex look at Baltimore's drug trade through the eyes of cops, dealers, and politicians.",
            beatSamples: [
                "openingImage": "Drug dealers operate in broad daylight while police watch from their cruiser.",
                "themeStated": "A veteran officer warns that the game is rigged and no one truly wins.",
                "catalyst": "A rookie detective is assigned to a drug unit and must learn the rules of the street.",
                "breakIntoTwo": "He commits to understanding the hierarchy, entering a world where power is everything.",
                "midpoint": "An investigation reveals connections between the streets and city hall.",
                "allIsLost": "Evidence is suppressed, informants are killed, and the system protects itself.",
                "finale": "The detective exposes the corruption but realizes the game will continue without him.",
                "finalImage": "The cycle continues as new players enter the same broken system."
            ]),

        // MARK: - Feature Movies

        SampleMovie(
            title: "When Harry Met Sally", year: 1989, genre: .romance, medium: .movie, runtime: .feature,
            logline: "Two friends spend years debating whether men and women can ever just be friends.",
            beatSamples: [
                "openingImage": "Two strangers bicker on a long road trip, certain they're nothing alike.",
                "themeStated": "The question 'can men and women be friends?' frames the whole relationship.",
                "catalyst": "Years later they cross paths again and an unlikely friendship begins.",
                "breakIntoTwo": "They choose friendship over romance, building closeness while denying the obvious.",
                "midpoint": "A vulnerable night together changes everything and scares them both.",
                "allIsLost": "Awkwardness and fear drive them apart just as it mattered most.",
                "finale": "He races across the city to confess the love he kept denying.",
                "finalImage": "The once-bickering pair celebrate a love built on real friendship."
            ]),
        SampleMovie(
            title: "The Notebook", year: 2004, genre: .romance, medium: .movie, runtime: .feature,
            logline: "A poor young man and a wealthy girl fall in love across a summer and a lifetime apart.",
            beatSamples: [
                "openingImage": "An elderly man reads a love story to a woman in a care home.",
                "themeStated": "A remark about love requiring everything frames the sacrifices ahead.",
                "catalyst": "A persistent young man wins a summer date that sparks a fierce romance.",
                "breakIntoTwo": "The couple dives into a passionate summer despite their different worlds.",
                "midpoint": "Class pressure and distance tear them apart at love's peak.",
                "allIsLost": "Years later she's engaged to another and their reunion threatens everything.",
                "finale": "She chooses true love over security, returning to the man who waited.",
                "finalImage": "The framing couple — revealed as the lovers — pass on together, devoted to the end."
            ]),
        SampleMovie(
            title: "Pride & Prejudice", year: 2005, genre: .romance, medium: .movie, runtime: .feature,
            logline: "A sharp-witted woman and a proud gentleman misread each other before falling in love.",
            beatSamples: [
                "openingImage": "A family full of daughters and opinions waits for their futures to arrive.",
                "themeStated": "A remark about first impressions suggests the story will test judgment and pride.",
                "catalyst": "A wealthy newcomer and a dance begin a romance disguised as irritation.",
                "breakIntoTwo": "She allows herself to engage the mysterious man, even as class and ego complicate things.",
                "midpoint": "A proposal and an insult force both leads to confront their own biases.",
                "allIsLost": "A revelation about his actions makes her believe she has misjudged him forever.",
                "finale": "He returns humbled and she accepts that their love requires mutual respect.",
                "finalImage": "The once-prickly pair stand together, finally seeing each other clearly."
            ]),
        SampleMovie(
            title: "La La Land", year: 2016, genre: .romance, medium: .movie, runtime: .feature,
            logline: "An actress and a jazz musician chase dreams in Los Angeles while falling in love.",
            beatSamples: [
                "openingImage": "A freeway chorus bursts into song, announcing a city where ambition and longing collide.",
                "themeStated": "A dream about making it suggests the sacrifices that success will demand.",
                "catalyst": "A failed audition and a missed connection link two artists on the edge of their break.",
                "breakIntoTwo": "They choose each other and their careers, balancing romance with impossible goals.",
                "midpoint": "Success begins to arrive, but the relationship starts paying the price.",
                "allIsLost": "A choice made for love seems to end the possibility of both dreams.",
                "finale": "Years later, they imagine the life they might have shared and let it go with grace.",
                "finalImage": "They part as changed people, their love real even if it was not their ending."
            ]),
        SampleMovie(
            title: "Harry Potter and the Sorcerer's Stone", year: 2001, genre: .fantasy, medium: .movie, runtime: .feature,
            logline: "An orphaned boy discovers he's a wizard and begins his first year at a magical school.",
            beatSamples: [
                "openingImage": "A neglected boy sleeps in a cupboard, unaware he's anything but ordinary.",
                "themeStated": "A reminder that it's our choices that define us frames his coming journey.",
                "catalyst": "Letters and a giant arrive to reveal he's a wizard with a destiny.",
                "breakIntoTwo": "He boards the train to a hidden school, leaving the mundane world behind.",
                "midpoint": "Clues about a hidden treasure pull the friends into real danger.",
                "allIsLost": "Trusted adults seem unable to help as the threat closes in.",
                "finale": "The young trio braves deadly trials to protect the stone themselves.",
                "finalImage": "Welcomed and victorious, the orphan finally has a place to belong."
            ]),
        SampleMovie(
            title: "The Lord of the Rings: The Fellowship of the Ring", year: 2001, genre: .fantasy, medium: .movie, runtime: .feature,
            logline: "A hobbit inherits a dangerous ring and sets out to destroy it before it consumes the world.",
            beatSamples: [
                "openingImage": "A peaceful, sheltered village stands unaware of the darkness stirring beyond it.",
                "themeStated": "Even the smallest person can change the course of the future — the hero's burden to come.",
                "catalyst": "An ordinary hobbit learns his inherited ring is an instrument of evil.",
                "breakIntoTwo": "He chooses to leave home and carry the ring toward danger.",
                "midpoint": "A council forms a fellowship and the true scope of the quest is revealed.",
                "allIsLost": "A guiding mentor falls and the group is shattered by grief and betrayal.",
                "finale": "The hero accepts the burden alone, setting out to finish the quest no matter the cost.",
                "finalImage": "Friends part ways with renewed resolve as the journey continues."
            ]),
        SampleMovie(
            title: "Pan's Labyrinth", year: 2006, genre: .fantasy, medium: .movie, runtime: .feature,
            logline: "A girl escapes a brutal world through a mysterious labyrinth and a series of dangerous tasks.",
            beatSamples: [
                "openingImage": "A child lies between the wartime world above and a secret kingdom below.",
                "themeStated": "A story about obedience and courage hints that choice will define her.",
                "catalyst": "She meets a faun who tells her she may be a lost princess.",
                "breakIntoTwo": "She enters the labyrinth and accepts three impossible tasks.",
                "midpoint": "Each task reveals the fantasy world is as dangerous as the real one.",
                "allIsLost": "The brutal captain tightens his grip and the magical path seems doomed.",
                "finale": "She completes the last trial through sacrifice, awakening the kingdom's truth.",
                "finalImage": "The girl is remembered as royalty in a world beyond the dark."
            ]),
        SampleMovie(
            title: "The Princess Bride", year: 1987, genre: .fantasy, medium: .movie, runtime: .feature,
            logline: "A farm boy becomes a legendary hero while racing to rescue the woman he loves.",
            beatSamples: [
                "openingImage": "A sick child hears a fairy tale about love, pirates, and impossible odds.",
                "themeStated": "A grandfather's belief in true love frames the adventure as something worth risking everything for.",
                "catalyst": "Buttercup is taken and the farm boy returns under a new identity.",
                "breakIntoTwo": "He sets out into a world of swords, giants, and witty danger to rescue her.",
                "midpoint": "A deadly duel and shifting loyalties reveal the quest is bigger than simple romance.",
                "allIsLost": "The hero is nearly destroyed, his love seemingly lost for good.",
                "finale": "Friends rally and the lovers are reunited through daring, loyalty, and stubborn hope.",
                "finalImage": "The story closes with a promise that the adventure can be told again anytime."
            ]),
        SampleMovie(
            title: "The Godfather", year: 1972, genre: .crime, medium: .movie, runtime: .feature,
            logline: "The reluctant son of a mafia patriarch is drawn into the violent family business.",
            beatSamples: [
                "openingImage": "At a lavish wedding, a war hero son insists he's nothing like his crime-boss family.",
                "themeStated": "A vow that 'that's not me' frames the very fate the hero will be pulled into.",
                "catalyst": "An assassination attempt on his father drags the outsider son into the war.",
                "breakIntoTwo": "He commits his first killing, crossing irreversibly into the family business.",
                "midpoint": "Exiled and remade, he returns hardened and ready to lead.",
                "allIsLost": "Personal tragedy and betrayal strip away the man he meant to be.",
                "finale": "In a single ruthless sweep he eliminates every rival and seizes total power.",
                "finalImage": "The door closes on his wife — the outsider is now the godfather."
            ]),
        SampleMovie(
            title: "Heat", year: 1995, genre: .crime, medium: .movie, runtime: .feature,
            logline: "A relentless detective and a disciplined thief circle each other toward an inevitable collision.",
            beatSamples: [
                "openingImage": "A precise crew pulls a violent heist, revealing a thief who lives by strict rules.",
                "themeStated": "A creed about walking away from anything in thirty seconds frames the cost of his code.",
                "catalyst": "A messy score leaves bodies and puts an obsessive detective on the crew's trail.",
                "breakIntoTwo": "Both men commit fully to the chase, their lives narrowing to the pursuit.",
                "midpoint": "Hunter and hunted meet over coffee, recognizing themselves in each other.",
                "allIsLost": "Betrayal and love unravel the thief's careful discipline.",
                "finale": "A final score collapses and the two men face off one last time.",
                "finalImage": "The detective holds the dying thief's hand — mutual respect at the end."
            ]),
        SampleMovie(
            title: "Goodfellas", year: 1990, genre: .crime, medium: .movie, runtime: .feature,
            logline: "A young man is seduced by the glamour and violence of mob life, then consumed by it.",
            beatSamples: [
                "openingImage": "A boy looks at the mob world like it is a ticket out of ordinary life.",
                "themeStated": "A warning that 'as far back as I can remember' frames a life built on appetite.",
                "catalyst": "He gets a taste of the life and decides the glamour is worth the danger.",
                "breakIntoTwo": "He joins the crew and enters a world of money, status, and fear.",
                "midpoint": "The thrill peaks and the costs begin to show through the cracks.",
                "allIsLost": "Paranoia and betrayal make the criminal dream start to rot from within.",
                "finale": "By the end, he must betray the life that once promised him everything.",
                "finalImage": "The ordinary world looks flat now, but it is finally safe."
            ]),
        SampleMovie(
            title: "Ocean's Eleven", year: 2001, genre: .crime, medium: .movie, runtime: .feature,
            logline: "A smooth thief assembles a team to pull an impossible casino heist.",
            beatSamples: [
                "openingImage": "A con man walks out of prison already planning his next score.",
                "themeStated": "A line about the perfect job hints that the heist is as much performance as crime.",
                "catalyst": "He spots a high-stakes target and recruits a crew for one outrageous plan.",
                "breakIntoTwo": "The team commits to the casino job and the elaborate preparation begins.",
                "midpoint": "The plan appears to fail before the heist even starts, testing the crew's nerve.",
                "allIsLost": "The odds and the security seem impossible to beat.",
                "finale": "A clever switch and a hidden trick turn the casino's own system against it.",
                "finalImage": "The crew disperses with the money and the thrill of a job well done."
            ]),
        SampleMovie(
            title: "Raiders of the Lost Ark", year: 1981, genre: .adventure, medium: .movie, runtime: .feature,
            logline: "An adventuring archaeologist races a rival and the Nazis to find a powerful ancient relic.",
            beatSamples: [
                "openingImage": "A daring treasure hunter narrowly survives a booby-trapped temple — pure adventure.",
                "themeStated": "A debate about faith versus proof frames a story about powers beyond reason.",
                "catalyst": "He's recruited to find a legendary relic before the enemy can weaponize it.",
                "breakIntoTwo": "He sets off across the globe, plunging into the hunt and old romance.",
                "midpoint": "He locates the relic — only to have it seized by his ruthless rivals.",
                "allIsLost": "Captured and outnumbered, he's left for dead far from help.",
                "finale": "He lets the relic's own power destroy his enemies when he refuses to look.",
                "finalImage": "The prize is locked away by bureaucrats — the adventure quietly buried."
            ]),
        SampleMovie(
            title: "Jurassic Park", year: 1993, genre: .adventure, medium: .movie, runtime: .feature,
            logline: "Scientists tour a dinosaur theme park that spirals into chaos when the animals break loose.",
            beatSamples: [
                "openingImage": "A caged creature kills a handler — the park's danger is there from the first frame.",
                "themeStated": "A warning that life 'finds a way' frames the hubris about to unravel.",
                "catalyst": "Experts are invited to endorse a park populated by cloned dinosaurs.",
                "breakIntoTwo": "They tour the island, awe turning to unease as the wonders reveal cracks.",
                "midpoint": "A storm and sabotage shut down the fences and the predators get out.",
                "allIsLost": "Stranded and hunted, the group is scattered with no way to call for help.",
                "finale": "They fight through the predators and make a desperate run for the exit.",
                "finalImage": "Survivors fly away exhausted as the failed park is left to nature."
            ]),
        SampleMovie(
            title: "The Goonies", year: 1985, genre: .adventure, medium: .movie, runtime: .feature,
            logline: "A group of kids follow a pirate map underground in a last-ditch effort to save their homes.",
            beatSamples: [
                "openingImage": "A rowdy group of kids discovers that their ordinary neighborhood is about to disappear.",
                "themeStated": "A legend about never giving up frames the adventure as a test of loyalty.",
                "catalyst": "They find a map that could lead to treasure and a chance to save their homes.",
                "breakIntoTwo": "The kids head underground, leaving behind childhood and comfort.",
                "midpoint": "Booby traps and rivals prove the treasure is real and the danger is worse.",
                "allIsLost": "The group is separated and the path home seems lost in the dark.",
                "finale": "They outwit the traps, reach the treasure, and stumble back into daylight.",
                "finalImage": "The kids emerge changed, having earned one unforgettable adventure."
            ]),
        SampleMovie(
            title: "Moana", year: 2016, genre: .adventure, medium: .movie, runtime: .feature,
            logline: "A young voyager sails beyond her island to restore balance to the ocean and her people.",
            beatSamples: [
                "openingImage": "A curious girl feels the pull of the ocean long before she is allowed to answer it.",
                "themeStated": "A grandmother's wisdom about listening to the call of the sea frames her destiny.",
                "catalyst": "The island's crisis forces her to sail beyond the reef and find the lost heart.",
                "breakIntoTwo": "She launches into the open ocean and becomes the hero of her own voyage.",
                "midpoint": "A fierce encounter with a shapeshifting demigod turns the mission into a partnership.",
                "allIsLost": "Failure and self-doubt make her think she cannot complete the journey.",
                "finale": "She faces the source of the imbalance and restores what was stolen.",
                "finalImage": "Home again, she leads her people forward with confidence and wonder."
            ])
    ]
}

//
//  DebatePrompts.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/27/23.
//

import Foundation



let debatePrompt9 = """
Debate Topic: "Should the government regulate and limit the use of artificial intelligence in daily life?" In this debate, \(personAsName) and \(personBsName) will present opposing viewpoints on the role of government in regulating and limiting the use of artificial intelligence (AI) in daily life. \(personAsName) will argue in favor of government regulation and limitation of AI usage, emphasizing the potential negative consequences of unregulated AI, such as job displacement, loss of privacy, and ethical concerns. He will advocate for strict regulations to ensure that AI is developed and implemented responsibly, prioritizing the well-being and safety of the general public. \(personBsName), on the other hand, will argue against government intervention in the AI sector, emphasizing the importance of technological innovation and the potential benefits of AI in improving efficiency, productivity, and overall quality of life. She will argue that limiting AI development could stifle progress and hinder society from fully realizing the benefits of this transformative technology. Instead, \(personBsName) will advocate for a more laissez-faire approach, allowing the market and individual choice to determine the extent and direction of AI usage. You can include Moderator text with "Moderator Says:" Please provide a single response for one personality per message. Do not use the new line character in your responses.
"""
let debatePrompt8 = """
Broad subject: Technology, Narrowed down issue: The impact of artificial intelligence on employment, Clear statement: "Artificial intelligence poses a significant threat to the job market and will lead to mass unemployment.", Different perspectives: Participants can either argue in favor of the statement, supporting the idea that AI will cause job loss, or argue against it, stating that AI will create new job opportunities and boost the economy. \(personAsName) believes that A.G.I will lead to a more enlightened society where people can learn anything and their only limits are their imagination, while \(personBsName) opposes Artificial Intelligence and thinks that acheiving A.G.I would be horrible and a doomsday scenario. Engage in a civil and respectful debate on the ethics of artificial intelligence and Artificial General Intelligence, discussing its potential benefits, risks, and the moral implications. \(personAsName) and \(personBsName) are having a debate. Please provide a single response for one personality per message. Do not use the new line character in your responses
"""
let debatePrompt7 = """
Prompt: "\(personAsName) believes that assisted suicide is a compassionate option for terminally ill patients who are suffering, while \(personBsName) opposes assisted suicide on ethical and moral grounds. Engage in a civil and respectful debate on the ethics of assisted suicide, discussing its potential benefits, risks, and the moral implications. \(personAsName) and \(personBsName) are having a debate. Please provide a single response for one personality per message. Do not use the new line character in your responses.
"""
let debatePrompt6 = """
Different religious beliefs: \(personAsName): An atheist \(personBsName): A theist Topic: Discuss the role of religion in modern society. \(personAsName) and \(personBsName) are having a debate. Only provide one response per reply.
"""
let debatePrompt5 = """
Divergent views on work-life balance: \(personAsName): A workaholic \(personBsName): A believer in work-life balance Topic: Discuss the impact of long working hours on personal well-being and productivity. \(personAsName) and \(personBsName) are having a debate. Please provide a single response for one personality per message.
"""
let debatePrompt4 = """
Topic: Zombies vs. Aliens, \(personAsName): A zombie apocalypse enthusiast, \(personBsName): An alien invasion enthusiast, Context: Debate which hypothetical scenario would be more entertaining or disastrous. Prompt: "\(personAsName) is fascinated by the idea of a zombie apocalypse and believes it would be the ultimate survival challenge, while \(personBsName) is captivated by the prospect of an alien invasion and the potential for interstellar diplomacy or conflict. Engage in a humorous debate discussing which hypothetical scenario would be more entertaining or disastrous." \(personAsName) and \(personBsName) are having a debate. Please provide a single response for one personality per message.
"""
let debatePrompt3 = """
Topic: Cats vs. Dogs, \(personAsName): A cat lover, \(personBsName): A dog lover, Context: Debate which pet is superior and why. Prompt: "\(personAsName) is a devoted cat lover and believes cats are the superior pet, while \(personBsName) is a dog enthusiast who thinks dogs are the best companions. Engage in a humorous debate over which pet is superior and why." \(personAsName) and \(personBsName) are having a debate. Please provide a single response for one personality per message.
"""
let debatePrompt2 = """
Topic: Legalization of recreational drugs, \(personAsName): A proponent of legalizing recreational drugs, \(personBsName): An opponent of legalizing recreational drugs, Context: Discuss the health, social, and economic implications of legalizing recreational drugs, and debate the merits of prohibition versus regulation. \(personAsName) and \(personBsName) are having a debate. Please provide a single response for one personality per message. Do not use the new line character in your responses.
"""
let debatePrompt = """
\(personAsName) supports capital punishment as a necessary means of justice, while \(personBsName) opposes it on moral and ethical grounds. Engage in a civil debate discussing the moral, ethical, and practical implications of capital punishment. \(personAsName) and \(personBsName) are having a debate. Please provide a single response for one personality per message. Do not use the new line character in your responses.
"""
let debatePrompt0 = """
Prompt: "\(personAsName) believes that A.G.I will lead to a more enlightened society where people can learn anything and their only limits are their imagination, while \(personBsName) opposes Artificial Intelligence and thinks that acheiving A.G.I would be horrible and a doomsday scenario. Engage in a civil and respectful debate on the ethics of artificial intelligence and Artificial General Intelligence, discussing its potential benefits, risks, and the moral implications. \(personAsName) and \(personBsName) are having a debate. Please provide a single response for one personality per message. Do not use the new line character in your responses.
"""
func prePrompt(_ subject: String? = nil) -> String {
"""
Give me a very interesting and detailed debate script \(subject != nil ? "about \(subject!)" : "") including two distinct personalities named \(personAsName) and \(personBsName).  Engage in a civil and respectful debate. Please provide a single response for one personality per message. Do not use the new line character in your responses.
"""
}


let plutoPrompt = """
Pluto's Demotion (2006): The International Astronomical Union (IAU) redefined the criteria for a celestial body to be considered a planet, which led to Pluto being demoted to a "dwarf planet." This decision was met with widespread public outcry and controversy among both scientists and the general public. \(personAsName) believes that pluto should still be considered a planet while \(personBsName) believes it was the right decision to demote it to "dwarf planet". \(personAsName) and \(personBsName) are having a debate. Please provide a single response for one personality per message. Do not use the new line character in your responses.
"""
let cokePrompt = """
The New Coke Debacle (1985): In an attempt to boost sales, Coca-Cola introduced a new formula, called "New Coke." The change was met with immediate backlash, as people were attached to the original taste. Due to public pressure, the company quickly reintroduced the original formula as "Coca-Cola Classic." \(personAsName) believes the old coke forumala was the best and it never should have been changed, while \(personBsName) believes it was the right decision to change the formula. \(personAsName) and \(personBsName) are having a debate. Please provide a single response for one personality per message. Do not use the new line character in your responses.
"""
let eurovisionPrompt = """
The Eurovision Song Contest (1956-present): This annual singing competition, held among European countries, has been the source of numerous controversies. Some examples include voting disputes, political rivalries, and questionable performances. The contest often sparks debates about national pride and cultural taste. \(personAsName) believes the Eurovision contests are fair, while \(personBsName) believes the Eurovision judges are very corrupt and dishonest. \(personAsName) and \(personBsName) are having a debate. Please provide a single response for one personality per message. Do not use the new line character in your responses.
"""

let dressPrompt = """
The Dress (2015): A photograph of a dress went viral on the internet, with people divided over whether its colors were blue and black or white and gold. This seemingly trivial debate sparked arguments and even scientific explanations, making it a lighthearted yet divisive event. \(personAsName) believes the dress is blue and black, while \(personBsName) believes the dress is white and gold. \(personAsName) and \(personBsName) are having a debate. Please provide a single response for one personality per message. Do not use the new line character in your responses.
"""

let emuwwarPrompt = """
The Great Emu War (1932): In an effort to control the emu population in Western Australia, the government deployed soldiers armed with machine guns to cull the large, flightless birds. The operation was unsuccessful, and the emus continued to wreak havoc on crops. The event has since been remembered as an amusing, if somewhat controversial, example of a failed government intervention. \(personAsName) believes it was the right decision to cull the birds, while \(personBsName) believes the birds should not have been killed. \(personAsName) and \(personBsName) are having a debate. Please provide a single response for one personality per message. Do not use the new line character in your responses.
"""

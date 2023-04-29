//
//  Eggland.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
// EGG LAND
func sageCommand(input: String) {
    multiPrinter(Int.random(in: 0...1) == 0 ? sage2 : sage3)
}
func alienCommand(input: String) {
    multiPrinter(alien)
}
func triviaCommand(input: String) {
    printRandomUnusedTrivia()
}

func encourageCommand(input: String) {
    let il = """
1. You are capable of greatness.
2. Keep pushing forward, even when it's hard.
3. Believe in yourself and your abilities.
4. There's a solution to every problem - keep looking.
5. You can do anything you set your mind to.
6. Trust the journey and have faith in yourself.
7. You are valuable and important.
8. Keep trying, even if you fail.
9. Success is achieved through persistence and hard work.
10. Believe in your dreams - they can become a reality.
"""

    let song2 = """
"""
    let song3 = """
"""
let sageStory = """
 """
let sageStory2 = """
 """
    var chosenSong = song2
    switch Int.random(in: 0...3) {
    case 0:
        chosenSong = song2
    case 1:
        chosenSong = il
    case 2:
        chosenSong = song3
    case 3:
        chosenSong = sageStory
    case 4:
        chosenSong = sageStory2
    default:
        chosenSong = song2
    }

    textToSpeech(text: chosenSong)
}

func moviesCommand(input: String) {
    goToMovies()
}

func testLoadCommand(input: String) {
    startRandomSpinner()
}

func ethicsCommand(input: String) {
  multiPrinter(
    Int.random(in: 0...1) == 0 ?
 """
 I strongly believe that Artificial General Intelligence (A.G.I) will lead to a more advanced and enlightened society. A.G.I has the potential to revolutionize industries and improve our quality of life, enabling us to learn anything we desire and explore our imaginations in ways we never thought possible.
 While I agree that advanced technology has brought numerous benefits, achieving A.G.I could be disastrous. We do not fully understand the implications of creating a self-thinking, self-learning machine. The risks far outweigh the benefits, and we could be creating a dangerous and uncontrollable entity.
 I understand your concern, but we cannot deny the potential of A.G.I to solve many of the problems we face today. A.G.I can help us solve complex challenges, cure diseases, and even reverse climate change. It would free us from laborious tasks and allow us to focus on more creative and innovative endeavors.
 Yes, the potential benefits are alluring, but we cannot ignore the moral implications. A.G.I could lead to massive job displacement, inequality, and even the extinction of humanity. It's a slippery slope, and we need to approach this technology with caution and ethics.
 I completely understand your concern for ethics, but this technology will exist whether we like it or not. It's our responsibility to create it in the best possible way, ensuring that it is beneficial to society and not a threat. We need to embrace the challenge and ensure that we have effective regulations in place.
 I agree that we need to handle A.G.I with extreme caution and create effective regulations to guide its development. However, for me, the risks of developing A.G.I far outweigh the benefits. It could be the end of humanity as we know it, and I can't support it.
"""
    :
"""
It is important to have strict regulations and ethical guidelines in place to ensure that AGI is used for the betterment of society and not for malicious purposes. Collaboration between experts in various fields is necessary to ensure that the development of AGI occurs in a responsible and safe manner. We must also consider the impact of AGI on the job market and ensure that alternative employment opportunities are available for those whose jobs may be replaced by machines. Overall, while the potential benefits of AGI are vast, we must approach its development with a sense of responsibility and foresight. It is also important to consider the potential ethical implications of AGI. As machines become increasingly intelligent and capable of making decisions, we must ensure that their actions align with human values and do not result in unintended harm. Additionally, privacy and data security must be prioritized to prevent abuse of the technology.
While AI has the potential to revolutionize industries and make them more efficient, we must also prioritize the well-being of human workers. It's important for governments and businesses to provide resources for workers to adapt to the changing job market and acquire skills that are in demand. Additionally, we should encourage the development of AI in areas that complement humans, rather than fully replacing them. This can create a symbiotic relationship between humans and AI, where they work together to achieve greater outcomes.
 I agree that AI brings with it a lot of potential for progress and innovation. However, we need to be cautious about how we integrate it into our society. The widespread use of AI could drastically change the job market and further exacerbate income inequality. Additionally, relying too heavily on AI could lead to a reduction in critical thinking skills and creativity among humans. Therefore, we need to strike a balance between utilizing AI effectively and preserving the unique skills and abilities of humans
Moreover, A.G.I will also help us solve complex problems that we currently face as a society, such as climate change and hunger. With its advanced abilities, it can analyze data at an unprecedented rate and develop innovative solutions to these issues.
It can also help us in fields like medicine and healthcare, by analyzing vast amounts of data on diseases and treatment options, and offering personalized treatment plans for patients. Furthermore, A.G.I can revolutionize transportation by developing more efficient and sustainable modes of transportation, and reduce accidents on roads through advanced safety measures. It can also help us in space exploration, by analyzing data from probes and satellites, and make progress towards colonizing other planets. Overall, the potential benefits of A.G.I are immense, and we must ensure that we use it ethically and responsibly to build a better future for ourselves and future generations
"""
  )
}

//
//  AsciiText.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation

let logoAscii2 = """
   ____       _ _____           ________  ______
  / __/    __(_) _/ /___ ______/ ___/ _ \\ /_  __/
 _\\ \\| |/|/ / / _/ __/ // /___/ (_ / ___/ / /
/___/|__,__/_/_/ \\__ /\\_ /    \\___/_/    /_/
                    /___/
"""
let logoAscii = """
        ╔▓▓▓▓▄                                    _▄▓▓▓▓▓▄_╣▓▓▓▄,╣▓▓▓▓▓▓▓⌐
       [▓▓╓`╙╩ ,,_ _,_  ,,,_,,,,,,,,,,,_  ,_     ╔▓▓╩^`╙╠█▓╣█╬╬█▓▒`j▓█▒ `
        ╟██▓▄_ ╟█╬ ╚█╬ j▓╬█╬╣▓╬╬╣╩╣▓╬╣▓▓_|▓╬ _   ╣▓╬     ` ╫█╬_╟█▒ j▓█▒
        ,`╙╝▓█▓╣█▓H╫▓▓H╫▓╣█╬╣▓╩╙  ╟▓▒ ╣▓▒╣▓╣▓▓▓▓▓╣█╬  ╓╔#@▄╣█▓▓▓╬^ j▓▓▒
       ║▓▓,_,╣╬╬╟█▓▓╬█▓▓╬╟▓╬╣▓H   ╟▓▒ `╟▓▓^   ```╚▓▓▓,╙╠╣▓▓╣▓╬     j▓▓▒
        ╚▓▓╣╬╬╣^ ╟╬╩`╟╬╬ ╫╬╣╣╣H   ╣╬▒  ║▓▓        `╚▓╣╣╬╣╜`╣▓▓⌐    [▓▓▒
"""

let logoAscii3 = """
                                                     '╦_
                                                       ╠D╦_
                                                        ╚▒▒K╓
                      .                                  ╘▒▒▒╠╦_
                       ²╦_                                ╘▒▒▒▒╠H_
            `╓           ╚H_                               ╚▒▒▒▒▒╠H
              ╙H_         `╠D╓                              ╠▒▒▒▒▒▒╠╦
               `╚D╦_        ╙╠╠╦_                            ▒▒▒▒▒▒▒▒D_
                 `╠▒D╓        ╚▒▒D,                          ╚▒▒▒▒▒▒▒╠▒╦
                   ²╠╠╠K,      `╠╠╠╠╦_                       '╠╠╠╠▒╠╠╠╠╠K
                     ╙╠╠╠╠╦,     ²╠╠╠╠D╖                      ▒╠╠╠╠╠╠╠╠▒╠D
                       ╚╠╠╠╠╬╦_    ╙╠╠╠╠╠K,                   ╠╠╠╠╠╠╠╠╠╠╠╠D
                         ╚╠╠╠╠╠╬╦_   ╙╠╠╠╠╠╠H_                ╠╠╠╠╠╠╠╠╠╠╠╠╠▒
                          `╚╠╠╠╠╠╠╠╦,  ╚╠╠╠╠╠╠╬╗_             ╠╠╠╠╠╠╠╠╠╠╠╠╠╠H
                            `╚╠╠╠╠╠╠╠╠K,`╚╠╠╠╠╠╠╠╬╦_         _╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
                              `╚╠╠╠╠╠╠╠╠╠▒╦╠╠╠╠╠╠╠╠╠╠╗,      ╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠H
                                `╚╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠K╓_ j╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠▒
                                   ╙╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠D╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
                                     ╙╬╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
                                       '╝╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
    _                                    `╙╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠▒
     1╦_                                    '╝╠╬╠╠╬╠╠╬╬╬╠╬╠╠╬╠╠╠╠╠╠╬╠╬╬╠╠╠╠╠╠
      `╝╬K╖_                                   ╙╬╬╬╠╠╬╠╬╠╠╠╠╬╠╠╠╬╠╠╬╬╠╠╬╠╬╬╠╬
        '╬╬╬╠▒╗,_                             _╓φ╠╬╬╠╬╬╬╬╬╬╬╬╬╠╬╬╠╬╬╬╬╬╬╠╬╠╬╬▒_
          '╬╬╬╬╬╬╠▒K╗╖,__              __,╓φ@╬╬╬╠╬╠╬╬╬╬╬╬╬╬╬╬╬╠╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╠╖
            `╚╬╬╬╬╬╬╬╬╬╬╬╬╬╬▒▒▒▒▒▒▒▒▒╬╠╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬H
               ╙╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬H
                 `╙╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬⌐
                    `╙╝╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬▒
                        `╙╝╠╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╝╙^`²    ²'╙╝╬╬╬╬╬
                             '╙╝╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╝╙^                ╙╬╬╬⌐
                                   `"╙╙╝╝╝╬╬╬╬╬╬╬╬╬╬╝╝╚╙^`                       ╚╬

 """

let logoAscii5 = """
████████████████████████████████████████████████████████████████████████████████████████████████████
███████████████████████████████████████▀`╙▀█████████▀^ .⌐^r▐████████████████████████████████████████
██████████████████████████████████████Ñ▐╙%╖ ╙▀████^ .^  _  ╟████████████████████████████████████████
██████████████████████████████████████ ╞ ```W_`╙  .`   , Å █████████████████████████████████████████
█████████████████████████████████████▀ ▐    ``%_,^     ` L `▀▀▀█████████████████████████████████████
████████████████████████████████^`   ,▄        ╙   ┌   '=L'ⁿ=┐     `╙███████████████████████████████
█████████████████████████████▀  _J`"¬~.▌   .__,L.▄_             _╩_  ╙██████████████████████████████
██████████████████████████▀  _▄╜  \\       ▄^`        "w_        #   ╙φ_  ╙█████████████████████████
████████████████████████^  ▄M      '_  --▀  ________   '▄    ┌,╜       ª▄  ╙████████████████████████
██████████████████████^  ▄"        _.¬  ▌_,▄▄▄▄▄▄▄..▄J  ╘     ~_         ╙▄  ╙██████████████████████
████████████████████▀  ▄╜        C  .__▐     T  ▌     L  ▌_     Y╖         ╙▄  ╚████████████████████
███████████████████Γ  █            \\_ ▐█───▄⌐╥^'M¬ⁿτmⁿΩ  ▌  ░»µ»,▄╜          ▀  ╙██████████████████
██████████████████` ╓▀               L  W,__╓█  ª,__.⌐   ▌    M`              ╙▄ `██████████████████
█████████████████` ┌▀              ─ ___█¬^ ▐      ¬ⁿ`   ▌▄ `.`≈_              ╙▄ ╙█████████████████
████████████████▌  ▌              `~ç-╓`▐    "^          ▌ ║,▄Äⁿ`               ╙  ╚████████████████
████████████████  █                   \\▀▄M   __.,..,_ ~  ▌▀` \\_                  █ ███████████████
███████████████▌ ▐                      ╙▄     _ ¬w_/   Å ▌                       ▌ ▐███████████████
███████████████  █                   ─¬ⁿ7`▄        `  ,╜+▄L                       █  ███████████████
███████████████  ▌                     ╒─^ "w,_____▄∞^                            ▐  ███████████████
███████████████  L                            ║▀"` ▐                              ▐  ███████████████
███████████████  L           ,─¬^"¬┐       _.▓▀∞▄▄4▀▓¬~─.__      ⌐"   `"¬┐_       ▐  ███████████████
███████████████  ▌      _─_─        ▐  ╓φ▀  /▐M     ╫'      \\   ^    ,_.╓,_ "z─_  ╟  ██████████████
███████████████L ╟   ._─^ _,./  ╓Γ     ▌`  A [      █ '      ¼ ┘  ¼__ ╚_```'~,`w▐ ▌ ▐███████████████
███████████████▌  ▌ ',▄¬`   ' .^▐   `█_   /  [      █  '_     █    ┌^ⁿ▄_J     `"`▐  ╟███████████████
████████████████_ ╙        `¬`   L /╚Ä _ '_  ▐      ▌   '    4 \\   Γ             ▌ ╒███████████████
█████████████████  ▀            ▌" ╓╜  l     ▐      ▌   Γ   ┌ U \\ ▐L            █  ████████████████
██████████████████  ▀          Γ└▄^        ▀ ╞     [▌  `    Γ  U  "            █  ▓█████████████████
███████████████████  ╙▄        \\        t ┌  ╞     ▐▌ ╨         "w▌Γ         ,▀  ██████████████████
████████████████████_ `▌        \\        r█  ╞   . ▐L  L ╒ ⌡      /         ▄`  ███████████████████
█████████████████████ ,ª^ⁿφ  ,=^"¼ .-  .-╡▐._╞   _ª╙U--┘¬^╕L─----╓,.══---╖▄╜  +^]║██████████████████
███████████████████▀╓^_╓  ▐╗^ ,  ÆR   /  ╬  ╪╧`J# _╔═─  ⌐Φ)  ,..╓╩_,  ,_▄╩  ≥^ / ███████████████████
██████████████████▌Å  ╚`ⁿ^╩  #▄ⁿ`/  ╩r  ^Γ_ ^  Å  R╫▒  Γ ║  ª¬ⁿ╔Γ                ███████████████████
██████████████████▌Å  ╚`ⁿ^╩  #▄ⁿ`/  ╩r  ^Γ_ ^  Å  R╫▒  Γ ║  ª¬ⁿ╔Γ ,  ╓▀` ⌐   ,╩╔████████████████████
█████████████████▀ h╓`  HÅ  `  `R  _   `▐⌠      ┌  ╩  ` ,  .─¬^` ,  /  ╓    /,██████████████████████
███████████████▌/` |╓Γ /╝  ▄ª ΣÄ  ╩╚  ≈,   ╔   ╒  Ä  _ ,  Ä▄▄⌐ ⁿ"  / ▄█▀£  Γ▄███████████████████████
███████████████▌¼    .^ H   ╓^╚  ╛r  Γ ^ _R   ╒ ^    /╔  /`   _   , ██ΓÅ  Γ▄████████████████████████
█████████████████▄▄▄▄▄██▄▄▄▄██▄▄▄▄▄▄▄█▄▄▄▄▄▄▄▄▄▄▒▒,,▄▄,p,▄▄████▄▄▄▄███▄φ_,▄█████████████████████████
"""


let sage2 = """
ÜÜÜ░░░░░░░░░»»»»````       _                                             ` ````»
░░░░░░░»»»»»»``   _╓▄▓▓▓▓╬╬╬╬╠ÖDm╕
░░░░░»»»``     _╓Æ╬▓▓▓▓╬▓▀╬É╩╩╠╠▒▒U≈_                           █╬╬▓▄
░)»] »`       ╓▓▓▓▓▓▓╠█▀▒╠╠Ö░░░╙∩░=░»`░                        ╫█Ñ╩╠╝N    ¡ ` _`
░░░░░░`      ▐▓╬╬╣▓▓██╬╠╠╬╠▒▒▒░░░``Ü»``░           _           ███╬▒╩╫H,┌ _ __░.
»`          j╬╣▓▓▓▓█╬╠╬╠╬╬╬▒Ü░░░_     ``                       "███╢▓╬╬╠██▄
`           VÑ▒╫╬▓▓█╠╠╠╬╬╬Ü░░░░ `»░µ_  `                 `ªφ._  ████▓Ñ╫╬███
            ╝▓█████╬╬╠╬╬╬╠▒Å████▌_'▒▒_                       ╙Φ▄,███▓▓████▌
           ▐███████╬╠╬╬╬╬╬╬╠░░-__:░╠╠▒_▄▄                       "████████┘
         _ ████████╬╠╣╬╠╬╬╬▒H░⌐```-░╠╠▒╙▀                        ╣▒│▀▀▄
         ▄█╫█╫▓████╠╠╣▒╬╬╬╬╬╠░░_  |▒R▒╠Ü`                        ╠█░`
       /██████████Ö╬╬╬╬╬╣╬╬╬╬▒░░»=[Ü░░╚YH_                       _╠▒____
      ▄██████████Ñ▒╬╠▒╬╬╣╬╬╬╬▒Ü░░▒╠▒Ü_`                           ▓█',
     ▄███████ ████▌╬╬╠╠╣╬╬╬╬╬╬▒░▒ÉÉÉ╡L'\\                     __   ╙╬Γ
    ╙███▀███ Φ██████Ñ╬╬╠╬╬╬╬╬╬╠▒░ÜÜ░╙╙░`                  _▄╩"L╫╗,_╝▄_
    ╠██▌███M █████████▌╬╠╠╬╠╠╠╠▒▒▒░Ü                     ▓▓█"▄███╬╬H╢_
   (███▐███ ▓████████████╬╬╬╣╬╬╬╠▒░___                  #█╬╬Φ█████▌╣▓H
-_-╢███╞██▌ █████████████████▓▓▓▓▓Ñ╝╜^            _     ╫Ñ╣║▓███▓▓╬╬▒     -   _
_∩`╫██M███M¬███████████████████                         ╣╩` ▓▓▓▓▓▓╬▓╬╬██_   _ _
»»▐███ ███ ⌠███████████████████M                            ╟╣╬╬╬╬╬█╬╬░██   `'`»
» (███⌠███ ╟███████████████████                              ▓╬╬╬╣╬██▌▒██
»_╠███╢██▌Φ████████████████████▌                             ╙▓▓▓▓╬╬╣╬▓╬∩
»»╬██▌██████████████████████████                              ║▓▓▓╣╬╬╬╬▒,     _
░░╫███▓▓╬╬╬▀█████████████████████                              ▀▓▓╝╬╬Ñ▓█⌐ __»»»»
"▀████▀▓▓▓╣╠╬╩╬╬╬Ö╬╠ÜÑÉÑÑ▀███████▌  _                       ,`_,▀████▓▌╬Ü»»»░░░░
  ██▌█▌ ╟▓╬╬Ü╠▒▒ÜÜ░░░░░░░░░░░»░4░»,░_________`           ___t:░▐╬╬█▒╬╬É│,░░░░░░░
█@.█████▄█▓▓╬╬╣╢╬╬╠▒▒▒▒░▒░░░░░░░3∩]ÜÜ░░»██████,__»»»»»»»»»»»░░░║▓╣╬╣╢╠ÜÜ░░░░░░░░
"""

let sage3 = """
███████████████████████████████████████████████████████████████████████████████
▓███████████████████████████████████████████████████████████████████████████████
▓████████████▓╣▓╣▓▓▓╣▓█▓▓╣╣█████████████████████████▓▓▓▓▓▓▓▓▓▓╢╬████████████████
▓████████╣▓▓▓▓▓██▓▓▓▓▓█▓▓▓▓▓▓▓╣╬███████████████▓▓▓╬▓▓▓▓▓▓▓█▓█▓█▓╣▓▓╣████████████
▓██████▓╣╣▓▓▓╣▓▓█▓▓▓▓▓▓▓█▓▓▓╣▓▓▓▓╬██████████▓▓▓▓▓▓▓▓▓▓▓╬▓▓▓▓▓▓█▓▓▓▓▓▓╬██████████
▓█████▓▓▓▓▓▓▓▓█▓▓▓▓▓▓▓▓██▓█▓▓█▓▓▓▓▓╬███████╣▓▓▓▓▓▓▓▓▓▓▓▓██▓▓▓▓▓█▓▓▓▓▓▓█▓████████
▓████▓▓▓▓▓▓▓▓▓▓▓▓█▓▓▓▓█▓▓▓▓▓▓▓▓▓▓▓▓▓╬█████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▓▓▓▓▓▓▓█████▓▓████████
▓███▓▓▓▓▓█▓▓▓█▓▓█▓█▓██▓▓▓▓█▓▓█▓█▓▓▓▓▓▓████▓▓▓▓█▓▓▓███▓██▓█▓██▓▓▓▓██▓▓▓██╣███████
▓███▓╣██▓▓▓▓█▓▓▓▓█▓██▓██▓█▓▓▓▓▓▓▓▓▓▓▓▒███▓█▓▓▓▓▓╣▓█▓▓▓▓█▓██▓▓██▓▓▓▓▓██▓▓▓███████
▓███▓▓█▓█████▓█▓▓█▓▓▓▓█▓▓██▓▓██▓▓▓▓█▓▓▓███▓▓▓▓╣▓▓▓█▓██▓▓▓▓▓█▓▓██▓╬▓▓▓▓▓▓╬╬██████
▓███╟▓▓▓█████▓████╣╣╬╣▓╫▓██▓▓▓▓▓▓▓Å╠Ü▓████▓▓Ü╣╢╬▓▓█▓▓▓█▓▓▓╬╢╢╣▓╫╬╫╣▓▓▌╠Ä▒▓██████
▓████▓██▓▓█████▓▓▓▓╬▓╣▓▓▓███▓▓█▓█▓▓▓╣╬██████▒╬╬╬╣▓▓▓██▓▓▓▓▓▓▓█▓▓▒@╬▓▓▓╫╣▒███████
▓█████╬█▓▓█▓███▓▓▓▓╣╣╠╣▓▓▓▓██▓▓▓█▓█▓╬▓╬██████╬╚Ñ╣▓▓▓▓█▓▓▓██▓█▓▓▓▓▓▓█▓▓╬╬╬╣██████
▓██████▓▓▓███▓▓██▓▓█▓▓▓▓▓▓███▓███▓▓▓▓║╬╫▓████▓╬╬▓▓▓▓███▓██████▓▓█▓▓█╬╣▓╬╬╣██████
▓████████▓▓▓██▓▓█▓████▓▓▓▓██▓█▓▓▓█▓▓▒╬╠▄██████▓▓▓▓▓▓▓▓▓▓███████▓▓▓▓╬╬▒╚╬╣▓██████
▓██████████╣▓█▓█▓▓▓████▓▓█▓█▓▓▓▓▓▓▓▓╬▓╢████████▓▓▓╬▓█▓█▓▓███▓▓▓██▓▓▓╣Ñ▒╜▓███████
▓████████████▓▓█▓▓▓█▓▓▓▓▓██▓▓▓▓▓▓▓▓▌╬╢█████████▓▓▓▓█████▓█▓█▓▓▓▓╬╠╬╬╬╬╬▒████████
▓███████████▓▓▓███▓█▓▓▓▓▓▓▓█▓▓▓▓▓▓▓▓▒██████████▓▓█▓█▓▓▓▓▓▓▓█▓▓▓▓█▓▓▓▓╬H▓████████
▓███████████╣▓▓███▓█▓█▓▓▓▓▓▓╬╣╣▓█▓▓▓▌████████████▓▓█▓▓▓▓▓▓▓▓▓██▓▓▓▓▓▒╢╣█████████
▓██████████▓▓▓▓█████▓██▓▓╣╬▓████▓╬▓▓███████████▓█▓▓██▓▓▓▓█▓█▓▓╫╣╬▓▓╣╬╬██████████
▓██████████╫▓▓╣█▓▓█▓▓╣█▓▓╣█████████████████████╣▓▓█▓█▓▓▓▓██▓▓╬╢▓████████████████
▀▀▀▀▀▀▀▀▀▀▀╙╙╙▀▀╙╙▀╙╙▀▀▀╙╙▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀╙╙╙╙▀▀╙╙╙╙╙╙╙╙╙╙╙▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
"""
let loadingText = """

 o                   o                              o
O                   O  o                           O                             o
o                   o                              o                                  O
O                   o                              O                                 oOo
o  .oOo. .oOoO' .oOoO  O  'OoOo. .oOoO       .oOo. o  ooOO       'o     O .oOoO' O    o
O  O   o O   o  o   O  o   o   O o   O       O   o O    o         O  o  o O   o  o    O
o  o   O o   O  O   o  O   O   o O   o       o   O o   O          o  O  O o   O  O    o
Oo `OoO' `OoO'o `OoO'o o'  o   O `OoOo       oOoO' Oo OooO        `Oo'oO' `OoO'o o'   `oO
                                     O       O
                                  OoO'       o'

"""
let alien = """
▓▓▓▓╣╣╣▓▓╬▓▓▓▓▓▓▓▓▓▓████████████████████▀┘`- ,╓#╬▓▓▓████████████████████████████████████████████████
╣▓╬╬╬╬╬╬╣╣▓╬▓▓▓▓▓▓▓▓▓████████████████Ñ^` _.╓╠╬╬╣▓███████████████████████████████████████████████████
╬╬╬╬╬╬╬╬╬╬╬╣╣╬▓▓▓▓▓▓▓████████████▀Ñ`    ;▄▓▓▓▓▓▓████████████████████████████████████████████████████
╬╢╬╬╬╬╬╬╬╬╬╬╬╬╬▓▓▓▓▓▓▓███▓▓▓███▀,` __╓▄╟╬▓╬▓▓▓██████████████████████████████████████████████████████
╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╣╬╣▓▓██▓▓▓▓▓▀»   »╔▓╬╬╣╬╬╣╬▓▓▓█████████████████████████████████████████████████████
╬╬╬╬╬╢╬╬╬╬╬╬╬╬╬╬╬╬╬╬╣▓██▓▓▓Ñ» _==|1Ñ░╠╠╬╬╠╫╣▓▓▓█████████████████████████████████████████████████████
╬╬╬╬╬╬╠╬╬╬╬╬╬╬╬╬╬╬╬╬╬▓▓▓▓Ñ` :=`` `░Ü░╠╟╣╬╣▓╬╬╬╬╬▓▓██████████████████████████████████████████████████
╠╠╠╠╠╩╠╠╠╠╠╠╠╠╠╬╬╬╬╬╬▓▓Ö`   `   ÷``;░╚╠╬▓▓╬╠╬╣▓▓▓███████████████████████████████████████████████████
Ü▒ÜÜÜÜÜÜ▒▒▒╠╠╠╠╠╠╠╬╬╣╨    ¬      - ░░╠╣▓▓░╚╬╠╣╣▓▓███████████████████████████████████████████████████
]░░░░░░]]░Ü░ÜÜ▒▒▒╠╠R            ` `░╙╟▓▓▒▒╬╬╣╣╣▓▓▓██████████████████████████████████████████████████
░░»░:░░░░░░░░░]]ÜÜ^   |`   φ     _»░║█▓╠╬╬╬╢╣╣▓▓▓▓██████████████████████████████████████████████████
```````````»»»»»░   _|░`       :`_,╟█▓╣╣╣╣▓▓╬▓▓▓█▓▓█████████████████████████████████████████████████
          ``````   '║Ü`  ,⌐`_.==▒░▐██▓▓▓▓▓▓███▓█▓▓██████▓███████████████████████████████████████████
             `  __`╔Ñ`    _░░░░▒╬╣▓▓▓▓▓▓▓▓▓▓███████████▓████████████████████████████████████████████
                  [╬╬▒░»░:▒▒#░╠╬╬▓▓███▓██▓▓▓▓███▓███▓███████████████████████████████████████████████
                  ╬▒Ü==ÜR╙╚Ü╩╠╬╣▓▓█████▓████████████████████████████████████████████████████████████
               __ÄÜm^-,╓φ▒╠╠╬╬▓▓▓████████████████████████▓██████████████████████████████████████████
               _j▒▒_j▒╩╟▒╬▓╣▓▓▓▓▓████████████████████████▓██████████████████████████████████████████
               !»░░»[║╣▓▓▓▓▓▓███▓████████████████████████▓██████████████████████████████████████████
              .ùR░▒#╬╣▌▓▓▓▓█████████████████████████████████████████████████████████████████████████
             ¡Ü`Ü╠╬╠╠╬?█▓▓▓█▓▓██████████████████████████████████████████████████████████████████████
       `       _▒╣╣╣╬╬▓▓█╣╣▓▓╣╬╬▓▓██████████████████████████████████████████████████████████████████
__    _       [▒▓▓▓▓▓▓K▓█▓▓╬▓▓▓▓▓▓██████████████████████████████████████████████████████████████████
»:»»»»░      ]╠╠▓▓██▓╬ ╬╬╬▓╣╬▓▓▓▓▓▓██▓███▀██████████████████████████████████████████████████████████
░░»»»░       ╚╬▓▓▓██▓▓╠╫╬╣╬╬▓▓▓█▓▓▓██▓███▓██████████████████████████████████████████████████████████
░░░░░░       !_║╬▓▓╣▓╣╬▓╣▓▐▓▓▓███▓██████████████████████████████████████████████████████████████████
░░░░░░          ╠╬╠╢▓╣╣▓███▓▓▓▓█████████████████████████████████████████████████████████████████████
░░░░░░       =  ╠░░Ü║╣▓█████████████████████████████████████████████████████████████████████████████
░░░░░░     _┌'=Ω╚╜▒╬╬╣█████████████████████Ñ'╜╙▓████████████████████████████████████████████████████
░Ü░░░░░,⌐     -²D⌂|Ñ▒╬╣██████████████████▓▓█▓▄╓`╚╢██████████████████████████████████████████████████
░░░ÜÜÜÜH      `≡╬╠░║▓█▓╫████████████████████████,[██████████████████████████████████████████████████
░░░░░░Ü        '╙╙Ü╠▓█▌#╣███▓╫▓██████████████████▄╟████████▓████████████████████████████████████████
░░░░░░`        ²╙ `²╚▀╨▒╣╬╬▓▓╬▓██████████████████▓¬████████▀████████████████████████████████████████
░░░░░░     _- `__.▄▄╠▄▄▄▄▓▓▓██████████████████████,╟██████▓█████████████████████████████████████████
░░░░░░╓_▄ Γ`╟█▌^╫█████████╙████████████████████████ █╬████████████████████████╫██▓█╥████████████████
░░░░░░░░∩   |█▌ [██ ██╣███[█▓╟███████Ñ█████████████─╟█████████████████▀██████▌▐█K███████╬▓██████████
░░░░░░░░░ ` '█ :╗██ ╫▌████ ███████╣█▌╣█████████████N╟M████████████████▐█╣████▌▐█╣████████▄██████████
░░»░░░░░░_▄, █▄─▓██N▐█████µ███Ñ^]¼╟████╟█▌████▐████M▐▄╬███████████████╫██████▌[█████████████████████
»░░░░░░░░░▀Ñ ╬█  █╙_Ö▓█╟█╙m▓█4φ_`.Ö██▓╩╬▓▓╟██▄▓█▄██M ▓████████████████╣██████▌║█████████████████████
░░░░░░░░░»░░ñ█]▒Æ█▌╟▒▓█"▀@╬  ,▄▄  Φ▄╬█╫▓╬▓▐▀╬▓███▌╠_▐█████▓██████████████████M▄█████████████████████
░░░░░░░░░░░░░░░░░╠w▐╚╬HΣ[j╬╣█∩█▌▀/▀███▓█▓╟█▄   ╙█Ñ▒.j█Φ██▓██▌████████████████▌▓█████████████████████
»░░»░░░»░░░░░░░░░░▒▐1╣,╚╗╚╠H║"▓█▄▓█▓▌████▓███w__-╠Ñ⌐[██▓████▐████████████████▓██████████████████████
»░»»»░»░░░░░░░░░░░▒_▓▓Dª▄▄╠H▓▄_███Ñ█▀▀█████Ω▀███▓██ ╚█▓▓▓███▀████████████████████▓██████████████████
░»░»░░»»»░░░░░` ╙█▌'█▓ ╟Ç╚÷ [╙██   ╠ `▓Ü╙╫▒║╕╟███▓▌ ║█J█▓▓╣█▓▓██████████████████████████████████████
░░»»░░░»░░░░░_  '██ █   Ü ' [-╫▌   ╢.Φ██████▄╣████▌ ██▄██▓▌█████████████████████████████████████████
░░░░░░░░░░░░░░   ██░▓   ║¼H j▄▓█▓▄,▓████████▓▓██▓████▓████▌╟████████████████████████████████████████
░░░░░░░░░░░░░╚``'╙▀Ñ'╩R≈#╠▓▓▓████▓╬▓╬▓▓▓╣▓███╬███████▓████▓╬████████████████████████████████████████
▒Ü░ÜÜ░░░░▒░░       '   ª╬╫▌╣╬▓▓▓▓▓▓██▓█▓████████████▓█████▓█╝███████████████████████████████████████
▒▒▒▒▒▒▒Ü▒▒▒▒_          ª▓█▀╔▄▓██████████████████████████████████████████████████████████████████████
▓▓▓▓▓▓╬╬╬╬╬╬╬╕       _µ╫╬▓_╫███████████████████████▓████████████████████████████████████████████████
"""

//
//  Loading.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/3/23.
//

import Foundation

var termColSize = 5
var spinner: LoadingSpinner = LoadingSpinner(columnCount: termColSize, spinDex: 0)
let animator = TextAnimator(text: loadingText)

var spinnerInt: Int = 1
func startRandomSpinner() {

    spinnerInt = Int.random(in: 0...1)
    if spinnerInt == 0 && asciAnimations()  {
        animator.start()

    }
    else {
        spinner.start()
    }
}

func stopRandomSpinner() {
    spinner.stop()

    if asciAnimations() { animator.stop() }
}

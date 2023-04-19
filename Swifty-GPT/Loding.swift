//
//  Loading.swift
//
//
//  Created by Chris Dillard on 4/19/23.
//

import Foundation

var termColSize = 5
var spinner: LoadingSpinner = LoadingSpinner(columnCount: termColSize)
let animator = TextAnimator(text: loadingText)

var spinnerInt: Int = 1
func startRandomSpinner() {
    spinnerInt = Int.random(in: 0...1)
    if spinnerInt == 0 && asciAnimations  {
        animator.start()

    }
    else {
        spinner.start()
    }
}

func stopRandomSpinner() {
    spinner.stop()

    if asciAnimations { animator.stop() }
}

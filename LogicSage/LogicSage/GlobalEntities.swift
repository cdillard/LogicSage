//
//  GlobalEntities.swift
//  LogicSage
//
//  Created by Chris Dillard on 4/25/23.
//
#if os(xrOS)
import RealityKit

/// The root entity for entities placed during the game.
let spaceOrigin = Entity()

/// An anchor that helps calculate the position of clouds relative to the player.
let cameraAnchor = AnchorEntity(.head)

#endif

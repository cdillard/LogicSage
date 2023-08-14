//
//  Model.swift
//  
//
//  Created by Alberto Espinilla Garrido on 20/3/23.
//

import Foundation

enum TikiModel {
    static func getEncoding(_ name: String) -> Vocab? {
        if let encodingName = MODEL_TO_ENCODING[name],
           let vocab = Vocab.all.first(where: { $0.name == encodingName }) {
            return vocab
        }
        return findPrefix(with: name)
    }
}

private extension TikiModel {
    static let MODEL_PREFIX_TO_ENCODING: [String: String] = [
        // chat
        "gpt-4-": "cl100k_base",  // e.g., gpt-4-0314, etc., plus gpt-4-32k
        "gpt-3.5-turbo-": "cl100k_base",  // e.g, gpt-3.5-turbo-0301, -0401, etc.
    ]
    
    static let MODEL_TO_ENCODING: [String: String] = [
        // chat
        "gpt-4": "cl100k_base",
        "gpt-3.5-turbo": "cl100k_base",
        // text
        "text-davinci-003": "p50k_base",
        "text-davinci-002": "p50k_base",
        "text-davinci-001": "r50k_base",
        "text-curie-001": "r50k_base",
        "text-babbage-001": "r50k_base",
        "text-ada-001": "r50k_base",
        "davinci": "r50k_base",
        "curie": "r50k_base",
        "babbage": "r50k_base",
        "ada": "r50k_base",
        // code
        "code-davinci-002": "p50k_base",
        "code-davinci-001": "p50k_base",
        "code-cushman-002": "p50k_base",
        "code-cushman-001": "p50k_base",
        "davinci-codex": "p50k_base",
        "cushman-codex": "p50k_base",
        // edit
        "text-davinci-edit-001": "p50k_edit",
        "code-davinci-edit-001": "p50k_edit",
        // embeddings
        "text-embedding-ada-002": "cl100k_base",
        // old embeddings
        "text-similarity-davinci-001": "r50k_base",
        "text-similarity-curie-001": "r50k_base",
        "text-similarity-babbage-001": "r50k_base",
        "text-similarity-ada-001": "r50k_base",
        "text-search-davinci-doc-001": "r50k_base",
        "text-search-curie-doc-001": "r50k_base",
        "text-search-babbage-doc-001": "r50k_base",
        "text-search-ada-doc-001": "r50k_base",
        "code-search-babbage-code-001": "r50k_base",
        "code-search-ada-code-001": "r50k_base",
        // open source
        "gpt2": "gpt2",
        "gpt3": "gpt3",
    ]
    
    static func findPrefix(with name: String) -> Vocab? {
        guard let key = TikiModel.MODEL_PREFIX_TO_ENCODING.keys.first(where: { name.starts(with: $0) }),
              let name = TikiModel.MODEL_PREFIX_TO_ENCODING[key] ,
              let vocab = Vocab.all.first(where: { $0.name == name }) else {
            return nil
        }
        return vocab
    }
}

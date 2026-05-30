//
//  LoveCipher.swift
//  iLoveYou
//
//  Created by Christopher Huffaker on 5/28/26.
//

import Foundation

struct LoveCipher {
    static let shared = LoveCipher()

    private let letterToNumber: [Character: String] = [
        "a": "1", "b": "2", "c": "3", "d": "4", "e": "5", "f": "6", "g": "7",
        "h": "8", "i": "9", "j": "10", "k": "11", "l": "12", "m": "13",
        "n": "14", "o": "15", "p": "16", "q": "17", "r": "18", "s": "19",
        "t": "20", "u": "21", "v": "22", "w": "23", "x": "24", "y": "25",
        "z": "26"
    ]

    private let numberToLetter: [String: String] = [
        "1": "a", "2": "b", "3": "c", "4": "d", "5": "e", "6": "f", "7": "g",
        "8": "h", "9": "i", "10": "j", "11": "k", "12": "l", "13": "m",
        "14": "n", "15": "o", "16": "p", "17": "q", "18": "r", "19": "s",
        "20": "t", "21": "u", "22": "v", "23": "w", "24": "x", "25": "y",
        "26": "z"
    ]

    private let numberToToken: [String: String] = [
        "1": "1 & 14 & 0 & 14 & 1 & xx",
        "2": "2 & 15 & 0 & 15 & 2 & xx",
        "3": "3 & 16 & 0 & 16 & 3 & xx",
        "4": "4 & 17 & 0 & 17 & 4 & xx",
        "5": "5 & 18 & 0 & 18 & 5 & xx",
        "6": "6 & 19 & 0 & 19 & 6 & xx",
        "7": "7 & 20 & 0 & 20 & 7 & xx",
        "8": "8 & 21 & 0 & 21 & 8 & xx",
        "9": "9 & 22 & 0 & 22 & 9 & xx",
        "10": "10 & 23 & 0 & 23 & 10 & xx",
        "11": "11 & 24 & 0 & 24 & 11 & xx",
        "12": "12 & 25 & 0 & 25 & 12 & xx",
        "13": "13 & 26 & 0 & 26 & 13 & xx",
        "14": "0 & 1 & 14 & 0 & 14 & 1",
        "15": "0 & 2 & 15 & 0 & 15 & 2",
        "16": "0 & 3 & 16 & 0 & 16 & 3",
        "17": "0 & 4 & 17 & 0 & 17 & 4",
        "18": "0 & 5 & 18 & 0 & 18 & 5",
        "19": "0 & 6 & 19 & 0 & 19 & 6",
        "20": "0 & 7 & 20 & 0 & 20 & 7",
        "21": "0 & 8 & 21 & 0 & 21 & 8",
        "22": "0 & 9 & 22 & 0 & 22 & 9",
        "23": "0 & 10 & 23 & 0 & 23 & 10",
        "24": "0 & 11 & 24 & 0 & 24 & 11",
        "25": "0 & 12 & 25 & 0 & 25 & 12",
        "26": "0 & 13 & 26 & 0 & 26 & 13"
    ]
    private let spaceToken = "27 & 27 & 27 & 27 & 27 & 27"
    private let newlineToken = "28 & 28 & 28 & 28 & 28 & 28"

    private let allowedCipherCharacters = CharacterSet(charactersIn: "0123456789&xo. \n\r\t")

    private var tokenToNumber: [String: String] {
        Dictionary(uniqueKeysWithValues: numberToToken.map { ($1, $0) })
    }

    func sanitizePlaintext(_ input: String) -> String {
        let allowedCharacters = CharacterSet.letters.union(.whitespacesAndNewlines)
        let filteredScalars = input.lowercased().unicodeScalars.filter {
            $0.isASCII && allowedCharacters.contains($0)
        }
        return String(String.UnicodeScalarView(filteredScalars).prefix(250))
    }

    func sanitizeCiphertext(_ input: String) -> String {
        let scalars = input.lowercased().unicodeScalars.filter { allowedCipherCharacters.contains($0) }
        return String(String.UnicodeScalarView(scalars))
    }

    func encrypt(_ plaintext: String) -> String? {
        let sanitizedPlaintext = sanitizePlaintext(plaintext)
        guard !sanitizedPlaintext.isEmpty else {
            return nil
        }

        let characters = Array(sanitizedPlaintext)
        let tokens = characters.enumerated().compactMap { index, character -> String? in
            if character == " " {
                return nil
            }
            if character == "\n" {
                return nil
            }

            guard var token = letterToNumber[character].flatMap({ numberToToken[$0] }) else {
                return nil
            }

            let isWordTerminator: Bool = {
                guard index + 1 < characters.count else { return true }
                let next = characters[index + 1]
                return next == " " || next == "\n"
            }()

            if isWordTerminator {
                token += ".oo"
            }

            return token
        }

        let encryptableCharacterCount = characters.filter { $0 != " " && $0 != "\n" }.count
        guard encryptableCharacterCount > 0, tokens.count == encryptableCharacterCount else {
            return nil
        }

        return tokens.joined(separator: "\n")
    }

    func decrypt(_ ciphertext: String) -> String? {
        let lines = ciphertext
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !lines.isEmpty else {
            return nil
        }

        var decryptedCharacters: [String] = []

        for line in lines {
            let hasWordTerminator = line.hasSuffix(".oo")
            let normalizedLine = hasWordTerminator ? String(line.dropLast(3)) : line

            if normalizedLine == spaceToken {
                guard !hasWordTerminator else {
                    return nil
                }
                decryptedCharacters.append(" ")
                continue
            }
            if normalizedLine == newlineToken {
                guard !hasWordTerminator else {
                    return nil
                }
                decryptedCharacters.append("\n")
                continue
            }

            guard let numericValue = tokenToNumber[normalizedLine],
                  let letter = numberToLetter[numericValue] else {
                return nil
            }

            decryptedCharacters.append(letter)
            if hasWordTerminator {
                decryptedCharacters.append("\n")
            }
        }

        return decryptedCharacters.joined()
    }
}

struct SavedCipherMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let plaintext: String
    let encryptedText: String
    let createdAt: Date

    init(id: UUID = UUID(), plaintext: String, encryptedText: String, createdAt: Date) {
        self.id = id
        self.plaintext = plaintext
        self.encryptedText = encryptedText
        self.createdAt = createdAt
    }
}

enum SavedMessageStore {
    private static let storageKey = "savedCipherMessages"

    static func load() -> [SavedCipherMessage] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let messages = try? JSONDecoder().decode([SavedCipherMessage].self, from: data) else {
            return []
        }

        return messages.sorted { $0.createdAt > $1.createdAt }
    }

    static func save(_ messages: [SavedCipherMessage]) {
        guard let data = try? JSONEncoder().encode(messages) else {
            return
        }

        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

private extension Character {
    var isASCIILetter: Bool {
        unicodeScalars.count == 1 && unicodeScalars.allSatisfy { $0.properties.isAlphabetic && $0.isASCII }
    }
}

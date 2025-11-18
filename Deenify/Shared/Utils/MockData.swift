//
//  MockData.swift
//  Deenify - Mock Data for Development
//

import Foundation
import SwiftUI

struct MockData {

    // MARK: - Wisdom Cards (7-Day Rotation)

    static let wisdomCards: [WisdomCard] = [
        // Day 1 - Names of Allah
        WisdomCard(
            id: UUID(),
            type: .nameOfAllah,
            dayInCycle: 1,
            arabicText: "ٱلرَّحْمَـٰنُ",
            transliteration: "Ar-Rahman",
            translation: "The Most Merciful",
            explanation: "The One who wills and bestows infinite mercy upon all of creation. His mercy encompasses everything - from the air we breathe to the food we eat. Reflecting on this name reminds us that Allah's mercy is vast beyond our comprehension. When you make a mistake today, remember Ar-Rahman. His mercy is greater than any sin. Turn to Him with sincerity.",
            category: .mercy,
            source: "One of the 99 Names of Allah",
            isPremium: false
        ),

        // Day 2 - Dua
        WisdomCard(
            id: UUID(),
            type: .quickDua,
            dayInCycle: 2,
            arabicText: "اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ",
            transliteration: "Allahumma ihdini fiman hadayt",
            translation: "O Allah, guide me among those You have guided",
            explanation: "This beautiful dua from the Witr prayer asks Allah for guidance. It's a humble acknowledgment that we cannot find the right path without His help. We ask to be among those blessed souls whom Allah has already guided. Recite this dua during your Witr prayer tonight. When facing a difficult decision, repeat it sincerely and trust in Allah's guidance.",
            category: .worship,
            source: "Sunan Abu Dawud 1425",
            isPremium: false
        ),

        // Day 3 - Quranic Verse
        WisdomCard(
            id: UUID(),
            type: .quranicVerse,
            dayInCycle: 3,
            arabicText: "فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا",
            transliteration: "Fa inna ma'al usri yusra",
            translation: "For indeed, with hardship comes ease",
            explanation: "This profound verse from Surah Ash-Sharh appears twice in the same chapter - a divine emphasis on its importance. Notice it says 'with' hardship, not 'after'. The ease is already present even in your difficulty. One hardship cannot overcome two eases mentioned by Allah. When overwhelmed, recite this verse. Remember: your current struggle contains hidden blessings you'll recognize later.",
            category: .patience,
            source: "Quran 94:5-6",
            isPremium: false
        ),

        // Day 4 - Hadith
        WisdomCard(
            id: UUID(),
            type: .hadith,
            dayInCycle: 4,
            arabicText: "خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ",
            transliteration: "Khayrukum man ta'allama al-Qur'ana wa 'allamahu",
            translation: "The best among you are those who learn the Quran and teach it",
            explanation: "The Prophet ﷺ highlights the dual blessing of learning and teaching. Knowledge of the Quran isn't meant to be hoarded - it grows when shared. Even teaching one verse to your child or friend makes you among 'the best of people' in Allah's sight. Learn one new verse today, then share its meaning with someone - even via text message. You'll be among the best!",
            category: .knowledge,
            source: "Sahih Bukhari 5027",
            isPremium: false
        ),

        // Day 5 - Story
        WisdomCard(
            id: UUID(),
            type: .propheticStory,
            dayInCycle: 5,
            arabicText: "",
            transliteration: nil,
            translation: "A man was walking when he became very thirsty. He found a well, went down into it, drank his fill, then came out. Upon exiting, he saw a dog panting from thirst, eating mud. The man said: 'This dog has become as thirsty as I was.' He went back down the well, filled his shoe with water, held it in his mouth, climbed back up, and gave the dog water to drink. Allah appreciated his deed and forgave him.",
            explanation: "The companions asked: 'O Messenger of Allah, is there reward for us in serving animals?' He replied: 'There is reward for serving every living being.' This story shows that no act of kindness is too small in Allah's eyes - even quenching the thirst of a dog earned this man Paradise. Show mercy to Allah's creation today - feed a stray cat, water a plant, or help an animal in need.",
            category: .mercy,
            source: "Sahih Bukhari 2466",
            isPremium: false
        ),

        // Day 6 - Practical Tip
        WisdomCard(
            id: UUID(),
            type: .practicalTip,
            dayInCycle: 6,
            arabicText: "أَحَبُّ الأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ",
            transliteration: "Ahabbu al-a'mal ila Allahi adwamuha wa in qall",
            translation: "The most beloved deeds to Allah are the most consistent ones, even if they are small",
            explanation: "The Prophet ﷺ taught us that Allah values consistency over intensity. Praying two rakahs every night is better than praying 100 rakahs once a month. Small, steady actions build spiritual momentum and create lasting change in our hearts. Choose ONE small act of worship you can do every single day: 2 rakahs before sleep, morning adhkar, or one page of Quran. Start today and never stop.",
            category: .worship,
            source: "Sahih Muslim 782",
            isPremium: false
        ),

        // Day 7 - Scholar's Reflection
        WisdomCard(
            id: UUID(),
            type: .scholarReflection,
            dayInCycle: 7,
            arabicText: "",
            transliteration: nil,
            translation: "When Allah tests you, it is never to destroy you. When He removes something from your path, it is not to punish you. When He keeps you waiting, it is not to humiliate you. When things feel uncertain, it is not to confuse you. He is redirecting you, preparing you, protecting you, and perfecting your faith.",
            explanation: "Every trial is a divine curriculum designed specifically for your growth. The difficulty you're experiencing isn't random - it's purposeful. Allah is the Most Wise, and He never wastes your pain. Your struggles are shaping you into the person you need to become. Journal about your current challenge. Ask yourself: 'What is Allah teaching me through this?' You'll find profound wisdom in your struggles.",
            category: .patience,
            source: "Islamic Reflection",
            isPremium: false
        )
    ]

    // MARK: - Helper Methods

    /// Get wisdom card for specific day (1-7 cycle)
    static func wisdomCard(forDay day: Int) -> WisdomCard? {
        return wisdomCards.first { $0.dayInCycle == day }
    }

    /// Get today's wisdom card based on 7-day rotation
    static func todaysWisdomCard() -> WisdomCard? {
        let daysSinceEpoch = Calendar.current.dateComponents([.day], from: Date(timeIntervalSince1970: 0), to: Date()).day ?? 0
        let currentDayInCycle = (daysSinceEpoch % 7) + 1
        return wisdomCard(forDay: currentDayInCycle)
    }
}

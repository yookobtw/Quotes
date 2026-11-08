import Foundation

/// Built-in collection of classic, public-domain quotes.
enum QuoteLibrary {
    static let builtIn: [Quote] = {
        let raw: [(String, String, QuoteCategory)] = [
            // Wisdom
            ("The only true wisdom is in knowing you know nothing.", "Socrates", .wisdom),
            ("Knowing yourself is the beginning of all wisdom.", "Aristotle", .wisdom),
            ("We suffer more often in imagination than in reality.", "Seneca", .wisdom),
            ("Waste no more time arguing about what a good man should be. Be one.", "Marcus Aurelius", .wisdom),
            ("It is not that we have a short time to live, but that we waste a lot of it.", "Seneca", .wisdom),
            ("Wonder is the beginning of wisdom.", "Socrates", .wisdom),
            ("The unexamined life is not worth living.", "Socrates", .wisdom),
            ("Simplicity is the ultimate sophistication.", "Leonardo da Vinci", .wisdom),
            ("Nature does not hurry, yet everything is accomplished.", "Lao Tzu", .wisdom),
            ("Well done is better than well said.", "Benjamin Franklin", .wisdom),
            ("An investment in knowledge pays the best interest.", "Benjamin Franklin", .wisdom),
            ("He who has a why to live can bear almost any how.", "Friedrich Nietzsche", .wisdom),

            // Motivation
            ("It does not matter how slowly you go as long as you do not stop.", "Confucius", .motivation),
            ("Do what you can, with what you have, where you are.", "Theodore Roosevelt", .motivation),
            ("Whether you think you can, or you think you can’t — you’re right.", "Henry Ford", .motivation),
            ("Well begun is half done.", "Aristotle", .motivation),
            ("Energy and persistence conquer all things.", "Benjamin Franklin", .motivation),
            ("The secret of getting ahead is getting started.", "Mark Twain", .motivation),
            ("Luck is what happens when preparation meets opportunity.", "Seneca", .motivation),
            ("Begin at once to live, and count each separate day as a separate life.", "Seneca", .motivation),
            ("Great things are done by a series of small things brought together.", "Vincent van Gogh", .motivation),
            ("The journey of a thousand miles begins with one step.", "Lao Tzu", .motivation),
            ("Dwell on the beauty of life. Watch the stars, and see yourself running with them.", "Marcus Aurelius", .motivation),

            // Life
            ("Life is really simple, but we insist on making it complicated.", "Confucius", .life),
            ("Go confidently in the direction of your dreams. Live the life you have imagined.", "Henry David Thoreau", .life),
            ("In three words I can sum up everything I’ve learned about life: it goes on.", "Robert Frost", .life),
            ("Life can only be understood backwards; but it must be lived forwards.", "Søren Kierkegaard", .life),
            ("To live is the rarest thing in the world. Most people exist, that is all.", "Oscar Wilde", .life),
            ("Adopt the pace of nature: her secret is patience.", "Ralph Waldo Emerson", .life),
            ("Everything has beauty, but not everyone sees it.", "Confucius", .life),
            ("The best way out is always through.", "Robert Frost", .life),
            ("Be yourself; everyone else is already taken.", "Oscar Wilde", .life),

            // Happiness
            ("Happiness depends upon ourselves.", "Aristotle", .happiness),
            ("Very little is needed to make a happy life; it is all within yourself, in your way of thinking.", "Marcus Aurelius", .happiness),
            ("The happiness of your life depends upon the quality of your thoughts.", "Marcus Aurelius", .happiness),
            ("Folks are usually about as happy as they make their minds up to be.", "Abraham Lincoln", .happiness),
            ("For every minute you are angry you lose sixty seconds of happiness.", "Ralph Waldo Emerson", .happiness),
            ("Write it on your heart that every day is the best day in the year.", "Ralph Waldo Emerson", .happiness),
            ("Rule your mind or it will rule you.", "Horace", .happiness),

            // Courage
            ("Fortune favors the bold.", "Virgil", .courage),
            ("It is not because things are difficult that we do not dare; it is because we do not dare that things are difficult.", "Seneca", .courage),
            ("Courage is resistance to fear, mastery of fear — not absence of fear.", "Mark Twain", .courage),
            ("Do the thing you fear, and the death of fear is certain.", "Ralph Waldo Emerson", .courage),
            ("The only thing we have to fear is fear itself.", "Franklin D. Roosevelt", .courage),
            ("Difficulties strengthen the mind, as labor does the body.", "Seneca", .courage),
            ("Have the courage to use your own understanding.", "Immanuel Kant", .courage),
            ("You have power over your mind — not outside events. Realize this, and you will find strength.", "Marcus Aurelius", .courage),

            // Love
            ("Love all, trust a few, do wrong to none.", "William Shakespeare", .love),
            ("Where there is love there is life.", "Mahatma Gandhi", .love),
            ("Love is composed of a single soul inhabiting two bodies.", "Aristotle", .love),
            ("If you would be loved, love and be lovable.", "Benjamin Franklin", .love),
            ("The course of true love never did run smooth.", "William Shakespeare", .love),
            ("Love conquers all.", "Virgil", .love),
            ("Kindness in words creates confidence. Kindness in thinking creates profoundness. Kindness in giving creates love.", "Lao Tzu", .love),
        ]
        return raw.enumerated().map { index, item in
            Quote(id: "builtin-\(index)", text: item.0, author: item.1, category: item.2)
        }
    }()
}

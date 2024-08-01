require 'csv'

# Method to initialize the deck
def initialize_deck
    suits = ['♠', '♣', '♦', '♥']
    ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
    deck = suits.product(ranks)
    deck.shuffle!
end

# Method to calculate the total value of a hand
def calculate_total(hand)
    values = hand.map { |card| card[1] }

    total = 0
    values.each do |value|
        if value == 'A'
            total += 11
        elsif value.to_i == 0 # J, Q, K
            total += 10
        else
            total += value.to_i
        end
    end

    # Adjust for Aces
    values.select { |value| value == 'A' }.count.times do
        total -= 10 if total > 21
    end

    total
end

# Method to deal a card from the deck
def deal_card(deck, hand)
    hand << deck.pop
end

# Method to display the cards in a hand
def display_hand(hand)
    hand.map { |card| card.join('') }.join(', ')
end

# Method to display the current game status
def display_game_status(player_hand, dealer_hand, player_total, dealer_total, tokens)
    puts "Player's hand: #{display_hand(player_hand)} (#{player_total})"
    puts "Dealer's hand: #{display_hand(dealer_hand)} (#{dealer_total})"
    puts "Tokens: #{tokens}"
end

# Method to update the high score list
def update_high_scores(name, score)
    high_scores = CSV.read('high_scores.csv', headers: true) rescue []
    high_scores << [name, score]
    high_scores.sort_by! { |row| -row['Score'].to_i }
    CSV.open('high_scores.csv', 'w') do |csv|
        csv << high_scores.headers
        high_scores.each { |row| csv << row }
    end
end

# Method to play the game
def play_game
    puts 'Welcome to Blackjack!'

    # Initialize variables
    deck = initialize_deck
    player_hand = []
    dealer_hand = []
    player_total = 0
    dealer_total = 0
    tokens = 100

    loop do
        puts 'How many tokens would you like to bet? (Enter 0 to quit)'
        bet = gets.chomp.to_i

        if bet == 0
            puts 'Thanks for playing!'
            break
        elsif bet > tokens
            puts 'You do not have enough tokens. Please place a valid bet.'
            next
        end

        # Deal initial cards
        2.times do
            deal_card(deck, player_hand)
            deal_card(deck, dealer_hand)
        end

        player_total = calculate_total(player_hand)
        dealer_total = calculate_total(dealer_hand)

        display_game_status(player_hand, dealer_hand, player_total, dealer_total, tokens)

        # Player's turn
        while player_total < 21
            puts 'What would you like to do? (1 - Hit, 2 - Stand)'
            choice = gets.chomp.to_i

            if choice == 1
                deal_card(deck, player_hand)
                player_total = calculate_total(player_hand)
                display_game_status(player_hand, dealer_hand, player_total, dealer_total, tokens)

                if player_total == 21
                    puts 'Congratulations! You have a Blackjack!'
                    tokens += bet * 1.5
                    break
                elsif player_total > 21
                    puts 'Busted! You lose.'
                    tokens -= bet
                    break
                end
            elsif choice == 2
                break
            else
                puts 'Invalid choice. Please choose again.'
            end
        end

        # Dealer's turn
        while dealer_total < 17
            deal_card(deck, dealer_hand)
            dealer_total = calculate_total(dealer_hand)
        end

        display_game_status(player_hand, dealer_hand, player_total, dealer_total, tokens)

        # Determine the winner
        if dealer_total > 21
            puts 'Dealer busted! You win!'
            tokens += bet
        elsif dealer_total > player_total
            puts 'Dealer wins!'
            tokens -= bet
        elsif dealer_total < player_total
            puts 'You win!'
            tokens += bet
        else
            puts 'It\'s a tie!'
        end

        # Check if player has run out of tokens
        if tokens <= 0
            puts 'You have run out of tokens. Game over!'
            break
        end
    end

    # Update high scores
    puts 'Please enter your name for the high score list:'
    name = gets.chomp
    update_high_scores(name, tokens)
end

# Start the game
play_game
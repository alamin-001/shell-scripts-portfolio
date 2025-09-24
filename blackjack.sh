#!/bin/bash

# here are the game constansts
function gameConst() {
    case $1 in
        "MIN_PLAYERS") echo "1" ;;
        "MAX_PLAYERS") echo "4" ;;
        "BLACKJACK") echo "21" ;;
        "DEALER_STAND") echo "17" ;;
    esac
}

SUITS=("♥" "♦" "♣" "♠")
VALUES=("A" "2" "3" "4" "5" "6" "7" "8" "9" "10" "J" "Q" "K")

# declared the gaame variables
declare -a deck
declare -a dealerHand
gameActive=true
playerCount=0
playerNames=()
roundNum=1

initDeck() {
    deck=()
    local index=0
    for suit in "${SUITS[@]}"; do
        for value in "${VALUES[@]}"; do
            deck[$index]="$value$suit"
            ((index++))
        done
    done
}

shuffleDeck() {
    local temp rand size=${#deck[@]}
    for ((i=size-1; i>0; i--)); do
        rand=$((RANDOM % (i+1)))
        temp="${deck[$i]}"
        deck[$i]="${deck[$rand]}"
        deck[$rand]="$temp"
    done
    echo "Deck shuffled. May Lady Luck be with you, or at least sitting nearby!"
}

dealCard() {
    local size=${#deck[@]}
    if [[ $size -eq 0 ]]; then
        echo "Reshuffling deck..."
        initDeck
        shuffleDeck
        size=${#deck[@]}
    fi
    local cardIdx=$((RANDOM % size))
    local card="${deck[$cardIdx]}"
    unset "deck[$cardIdx]"
    deck=("${deck[@]}")
    echo "$card"
}

calcValue() {
    local hand=("$@")
    local sum=0 aceCount=0
    for card in "${hand[@]}"; do
        local value="${card:0:${#card}-1}"
        case $value in
            "A") ((aceCount++)); ((sum+=11)) ;;
            "K"|"Q"|"J"|"10") ((sum+=10)) ;;
            *) ((sum+=$value)) ;;
        esac
    done
    while [[ $sum -gt $(gameConst "BLACKJACK") && $aceCount -gt 0 ]]; do
        ((sum-=10)); ((aceCount--))
    done
    echo $sum
}

isBlackjack() {
    local hand=("$@")
    [[ ${#hand[@]} -eq 2 && $(calcValue "${hand[@]}") -eq $(gameConst "BLACKJACK") ]]
}

showRules() {
    clear
    echo "              BLACKJACK RULES OF ENGAGEMENT                    "
    echo "Goal::: Get closer to 21 than the dealer without going over"

    echo "Card values: 2-10 = face value, J/Q/K = 10, A = 1 or 11"
    
    echo "A Blackjack is an Ace + 10/J/Q/K on the initial deal"
    
    echo "Players take turns to 'Hit' (take card) or 'Stand' (stop)"
    
    
    echo "Dealer must hit until reaching at least 17 points"
    
    echo "Bust = Going over 21 = Instant loss"
    
    echo "Winning a round: Don't bust AND beat dealer's hand value"
    
    echo "In case of a tie, it's a 'Push' (no winner)"
    
    echo "Press ENTER to return to the game"
    read -r
}

showHand() {
    local name=$1; shift
    local hand=("$@")
    local value=$(calcValue "${hand[@]}")
    echo "$name's hand: ${hand[*]} (Value: $value)"
}

showDealerHidden() {
    local hand=("$@")
    echo "Dealer's hand: ${hand[0]} [Hidden Card]"
}

playerTurn() {
    local index=$1
    local name=${playerNames[$index]}
    local handKey="hand_$index"
    local -n hand="$handKey"
    echo "              $name's Turn - Round $roundNum     "
    showHand "$name" "${hand[@]}"

    if isBlackjack "${hand[@]}"; then
        echo "WOOHOO! $name hit a Blackjack! Luck is strong with this one!"
        return
    fi

    while true; do
        local value=$(calcValue "${hand[@]}")
        if [[ $value -gt $(gameConst "BLACKJACK") ]]; then
            echo "Oh no! $name BUSTED with $value!"
            break
        fi
        if [[ ${#hand[@]} -eq 5 && $value -le $(gameConst "BLACKJACK") ]]; then
            echo "AMAZING! $name achieved a Five-Card Charlie!"
            break
        fi
        echo -e "\nWhat would you like to do, $name?"
        echo "1) Hit me"
        echo "2) Stand"
        echo "3) View the rules"
        echo -n "Your choice: "
        read -r choice
        case $choice in
            1)
                local newCard=$(dealCard)
                hand+=("$newCard")
                echo "$name drew: $newCard"
                showHand "$name" "${hand[@]}"
                ;;
            2)
                echo "$name stands with $(calcValue "${hand[@]}")"
                break
                ;;
            3)
                showRules
                showHand "$name" "${hand[@]}"
                ;;
            *)
                echo "Invalid move. Try again!"
                ;;
        esac
    done
}

dealerTurn() {
    echo "                  Dealer's Turn - Round $roundNum      "
    echo "Dealer reveals hidden card"
    showHand "Dealer" "${dealerHand[@]}"
    if isBlackjack "${dealerHand[@]}"; then
        echo "Dealer has Blackjack!"
        return
    fi
    while [[ $(calcValue "${dealerHand[@]}") -lt $(gameConst "DEALER_STAND") ]]; do
        echo "Dealer hits"
        local newCard=$(dealCard)
        dealerHand+=("$newCard")
        echo "Dealer drew: $newCard"
        showHand "Dealer" "${dealerHand[@]}"
        if [[ $(calcValue "${dealerHand[@]}") -gt $(gameConst "BLACKJACK") ]]; then
            echo "Dealer BUSTED!"
            break
        fi
    done
    if [[ $(calcValue "${dealerHand[@]}") -le $(gameConst "BLACKJACK") ]]; then
        echo "Dealer stands with $(calcValue "${dealerHand[@]}")"
    fi
}

findWinners() {
    local dealerValue=$(calcValue "${dealerHand[@]}")
    local dealerHasBJ=false
    echo "                 Round $roundNum Results               "
    if isBlackjack "${dealerHand[@]}"; then
        dealerHasBJ=true
        echo "Dealer has Blackjack"
    fi
    for ((i=0; i<$playerCount; i++)); do
        local name=${playerNames[$i]}
        local handKey="hand_$i"
        local -n hand="$handKey"
        local playerValue=$(calcValue "${hand[@]}")
        local playerHasBJ=false
        if isBlackjack "${hand[@]}"; then
            playerHasBJ=true
        fi
        echo -n "$name: "
        if [[ ${#hand[@]} -eq 5 && $playerValue -le $(gameConst "BLACKJACK") ]]; then
            echo "WINS with Five-Card Charlie!"
            continue
        fi
        if [[ $playerValue -gt $(gameConst "BLACKJACK") ]]; then
            echo "LOSES (Busted)"
            continue
        fi
        if [[ $dealerValue -gt $(gameConst "BLACKJACK") ]]; then
            echo "WINS (Dealer busted)"
            continue
        fi
        if [[ $playerHasBJ == true && $dealerHasBJ == true ]]; then
            echo "PUSH (Both Blackjack)"
            continue
        fi
        if [[ $playerHasBJ == true && $dealerHasBJ != true ]]; then
            echo "WINS with BLACKJACK!"
            continue
        fi
        if [[ $playerHasBJ != true && $dealerHasBJ == true ]]; then
            echo "LOSES (Dealer has Blackjack)"
            continue
        fi
        if [[ $playerValue -gt $dealerValue ]]; then
            echo "WINS ($playerValue beats $dealerValue)"
        elif [[ $playerValue -lt $dealerValue ]]; then
            echo "LOSES ($dealerValue beats $playerValue)"
        else
            echo "PUSH (Tied at $playerValue)"
        fi
    done
}

resetRound() {
    dealerHand=()
    for ((i=0; i<$playerCount; i++)); do
        local handKey="hand_$i"
        eval "$handKey=()"
    done
    initDeck
    shuffleDeck
    for ((i=0; i<2; i++)); do
        for ((j=0; j<$playerCount; j++)); do
            local handKey="hand_$j"
            eval "$handKey+=(\"\$(dealCard)\")"
        done
        dealerHand+=("$(dealCard)")
    done
    ((roundNum++))
}

playGame() {
    clear
    echo "           WELCOME TO BASH BLACKJACK BONANZA             "
    echo "Where the cards are virtual, but the excitement is real!"
    while true; do
        echo -n "How many brave souls dare to challenge the dealer? (1-$(gameConst "MAX_PLAYERS")): "
        read -r playerCount
        if [[ $playerCount =~ ^[1-4]$ ]]; then
            break
        else
            echo "Please enter a valid number between 1 and 4."
        fi
    done
    for ((i=0; i<$playerCount; i++)); do
        echo -n "Enter name for Player $((i+1)): "
        read -r playerName
        [[ -z $playerName ]] && playerName="Player$((i+1))"
        playerNames[$i]=$playerName
        declare -a "hand_$i"
    done
    initDeck
    shuffleDeck
    while $gameActive; do
        resetRound
        echo "                  Round $roundNum Begin               "
        echo "Cards have been dealt"
        showDealerHidden "${dealerHand[@]}"
        for ((i=0; i<$playerCount; i++)); do
            playerTurn $i
        done
        dealerTurn
        findWinners
        echo -e "\nWould you like to play another round?"
        echo "1) Yes"
        echo "2) No"
        echo -n "Your choice: "
        read -r choice
        [[ $choice -ne 1 ]] && gameActive=false && echo "Thanks for playing my game"
    done
}

playGame
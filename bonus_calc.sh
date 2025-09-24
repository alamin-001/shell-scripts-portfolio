#!/bin/bash

# Bonus Calculator for Dodge Challenger Salespeople
# This script calculates the monthly salary bonus and tax for Dodge Challenger salespersons
# Based on their sales performance in a given month

# Clear the screen for better user experience
clear

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Validate that the inputs are numbers
validate_number_input() {
    if ! [[ $1 =~ ^[0-9]+$ ]]; then
        return 1
    fi
    return 0
}

# Validate that the inputs are alphabets
validate_name() {
    if ! [[ $1 =~ ^[A-Za-z\ \-\']+$ ]]; then
        return 1
    fi
    return 0
}

# Validating month input
validate_month() {
    local month=$1
    local valid_months=("January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December")
    
    for valid_month in "${valid_months[@]}"; do
        if [[ "$month" == "$valid_month" ]]; then
            return 0
        fi
    done
    return 1
}

# Calculating bonus based on sales amount
calculate_bonus() {
    local sales_amount=$1
    local bonus=0
    
    if (( $(echo "$sales_amount >= 650000" | bc -l) )); then
        bonus=30000
    elif (( $(echo "$sales_amount >= 500000" | bc -l) )); then
        bonus=25000
    elif (( $(echo "$sales_amount >= 400000" | bc -l) )); then
        bonus=20000
    elif (( $(echo "$sales_amount >= 300000" | bc -l) )); then
        bonus=15000
    elif (( $(echo "$sales_amount >= 200000" | bc -l) )); then
        bonus=10000
    fi
    
    echo $bonus
}

# Function to calculate tax based on annual salary
calculate_tax() {
    local monthly_salary=$1
    local annual_salary=$(echo "$monthly_salary * 12" | bc)
    local tax=0
    
    if (( $(echo "$annual_salary <= 12500" | bc -l) )); then
        tax=0
    elif (( $(echo "$annual_salary <= 50000" | bc -l) )); then
        tax=$(echo "($annual_salary - 12500) * 0.2 / 12" | bc)
    else
        if (( $(echo "$annual_salary <= 150000" | bc -l) )); then
            tax=$(echo "(50000 - 12500) * 0.2 + ($annual_salary - 50000) * 0.4" | bc)
            tax=$(echo "$tax / 12" | bc)
        else
            tax=$(echo "(50000 - 12500) * 0.2 + (150000 - 50000) * 0.4 + ($annual_salary - 150000) * 0.45" | bc)
            tax=$(echo "$tax / 12" | bc)
        fi
    fi
    
    printf "%.2f" $tax
}

# Performs bubble sort by salary
bubble_sort_by_salary() {
    local n=${#salesperson_names[@]}
    
    for ((i = 0; i < n-1; i++)); do
        for ((j = 0; j < n-i-1; j++)); do
            if (( $(echo "${net_salaries[$j]} < ${net_salaries[$j+1]}" | bc -l) )); then
                # This is to swap names
                temp=${salesperson_names[$j]}
                salesperson_names[$j]=${salesperson_names[$j+1]}
                salesperson_names[$j+1]=$temp
                
                # This ia to swaps salariess
                temp=${salaries[$j]}
                salaries[$j]=${salaries[$j+1]}
                salaries[$j+1]=$temp
                
                # This is to swap net salaries
                temp=${net_salaries[$j]}
                net_salaries[$j]=${net_salaries[$j+1]}
                net_salaries[$j+1]=$temp
                
                # This is to swap sales
                temp=${total_sales[$j]}
                total_sales[$j]=${total_sales[$j+1]}
                total_sales[$j+1]=$temp
                
                # This is to swap taxes
                temp=${taxes[$j]}
                taxes[$j]=${taxes[$j+1]}
                taxes[$j+1]=$temp
                
                # This is to swap bonuses
                temp=${bonuses[$j]}
                bonuses[$j]=${bonuses[$j+1]}
                bonuses[$j+1]=$temp
            fi
        done
    done
}

# Performs bubble sort by name intially i want to use normal sort
bubble_sort_by_name() {
    local n=${#salesperson_names[@]}
    
    for ((i = 0; i < n-1; i++)); do
        for ((j = 0; j < n-i-1; j++)); do
            if [[ "${salesperson_names[$j]}" > "${salesperson_names[$j+1]}" ]]; then
                # Swap names
                temp=${salesperson_names[$j]}
                salesperson_names[$j]=${salesperson_names[$j+1]}
                salesperson_names[$j+1]=$temp
                
                # Swap salaries
                temp=${salaries[$j]}
                salaries[$j]=${salaries[$j+1]}
                salaries[$j+1]=$temp
                
                # Swap net salaries
                temp=${net_salaries[$j]}
                net_salaries[$j]=${net_salaries[$j+1]}
                net_salaries[$j+1]=$temp
                
                # Swap sales
                temp=${total_sales[$j]}
                total_sales[$j]=${total_sales[$j+1]}
                total_sales[$j+1]=$temp
                
                # Swap taxes
                temp=${taxes[$j]}
                taxes[$j]=${taxes[$j+1]}
                taxes[$j+1]=$temp
                
                # Swap bonuses
                temp=${bonuses[$j]}
                bonuses[$j]=${bonuses[$j+1]}
                bonuses[$j+1]=$temp
            fi
        done
    done
}

# Dodge Challenger models and their prices
declare -A dodge_models
dodge_models["SXT"]="30000"
dodge_models["GT"]="35000"
dodge_models["R/T"]="42000"
dodge_models["Scat Pack"]="47000"
dodge_models["SRT Hellcat"]="65000"
dodge_models["SRT Hellcat Redeye"]="78000"
dodge_models["SRT Super Stock"]="85000"

cat << "EOF"
            DODGE CHALLENGER
     
EOF


printf "🔥 DODGE CHALLENGER SALES SUPERSTARS BONUS CALCULATOR 🔥\n"
printf "Where we turn horsepower into earning power!\n"

# Get the month
while true; do
    printf "What month are we crushing sales records for? "
    read month
    if validate_month "$month"; then
        printf "Alright! Let's calculate those fat stacks for \n"
        break
    else
        printf "Whoa there, speed racer! '$month' doesn't compute in our calendar. Try a real month like January or December.\n"
    fi
done

# Get number of salespersons
while true; do
    printf "\nHow many salespeople are in your dream team? (3-20): "
    read num_salespersons
    if validate_number_input "$num_salespersons"; then
        if (( num_salespersons >= 3 && num_salespersons <= 20 )); then
            printf "Perfect Ready to calculate bonuses for your $num_salespersons speed demons!\n"
            break
        else
            printf "Hold up! Our calculator can only handle between 3 and 20 sales pros. Try again, boss!\n"
        fi
    else
        printf "That's not a number I recognize! Are you trying to break the calculator?\n"
    fi
done

# Arrays to store salesperson data
declare -a salesperson_names
declare -a total_sales
declare -a bonuses
declare -a salaries
declare -a taxes
declare -a net_salaries

# Basic salary
basic_salary=2000

# Collect data for each salesperson
for ((i=0; i<num_salespersons; i++)); do
    printf "\n🏁 SALESPERSON #$((i+1)) DETAILS 🏁\n\n"
    
    # Get name of salespersn
    while true; do
        printf "What's this sales rockstar's name? "
        read name
        if validate_name "$name"; then
            salesperson_names[$i]="$name"
            printf "Excellent!$name$ is ready to burn rubber on the sales floor! \n"
            break
        else
            printf "That name looks suspicious. Names should only contain letters, spaces, hyphens, and apostrophes - no emoji or secret codes!\n"
        fi
    done
    
    # Display available models
    printf "\nAvailable Dodge Challenger Models:\n"
    for model in "${!dodge_models[@]}"; do
        printf "➤ $model ${dodge_models[$model]} \n"
    done
    printf "\n"
    
    # Get number of models sold
    while true; do
        printf "How many different Challenger models did ${salesperson_names[$i]} sell? "
        read num_models_sold
        if validate_number_input "$num_models_sold"; then
            if (( num_models_sold > 0 )); then
                printf "Nice variety! Let's break down those ${BOLD}$num_models_sold models.\n"
                break
            else
                printf "Zero models? Even my grandma sells at least one car! Try again.\n"
            fi
        else
            printf "That doesn't look like a number to me. Did you mean to type something else?\n"
        fi
    done
    
    local_sales=0
    
    # Get sales details for each model
    for ((j=0; j<num_models_sold; j++)); do
        printf "\n MODEL #$((j+1)) DETAILS:\n"
        
        # Get model name
        while true; do
            printf "${BLUE}Which Challenger model? (SXT, GT, R/T, Scat Pack, SRT Hellcat, SRT Hellcat Redeye, SRT Super Stock): ${RESET}"
            read model
            if [[ -n "${dodge_models[$model]}" ]]; then
                printf "${GREEN}The ${BOLD}$model${RESET}${GREEN} - excellent choice!${RESET}\n"
                break
            else
                printf "${RED}That's not on our lot! Check the spelling or try another model from our inventory.${RESET}\n"
            fi
        done
        
        # Get quantity sold
        while true; do
            printf "${BLUE}How many ${BOLD}$model${RESET}${BLUE} beasts did ${BOLD}${salesperson_names[$i]}${RESET}${BLUE} unleash on the streets? ${RESET}"
            read quantity
            if validate_number_input "$quantity"; then
                if (( quantity > 0 )); then
                    # Calculate sales for this model
                    model_sales=$(( quantity * ${dodge_models[$model]} ))
                    local_sales=$(( local_sales + model_sales ))
                    printf "${GREEN}WOW! ${BOLD}${salesperson_names[$i]}${RESET}${GREEN} sold ${BOLD}$quantity${RESET}${GREEN} ${BOLD}$model${RESET}${GREEN} models for a total of ${BOLD}${model_sales}${RESET}${GREEN}! 🔥${RESET}\n"
                    break
                else
                    printf "${RED}You can't sell 0 cars! That's just standing in the showroom looking pretty.${RESET}\n"
                fi
            else
                printf "${RED}That's not a valid number! Are you trying to cook the books?${RESET}\n"
            fi
        done
    done
    
    # Store total sales for this salesperson
    total_sales[$i]=$local_sales
    printf "\n${BOLD}${CYAN}💰 RESULTS FOR ${salesperson_names[$i]} 💰${RESET}\n"
    printf "${YELLOW}Total Sales: ${BOLD}${total_sales[$i]}${RESET}\n"
    
    # Calculate bonus
    bonuses[$i]=$(calculate_bonus ${total_sales[$i]})
    
    # Calculate the total monthly salary 
    salaries[$i]=$(( basic_salary + ${bonuses[$i]} ))
    
    # Calculate the taxes
    taxes[$i]=$(calculate_tax ${salaries[$i]})
    
    # Calculate net salary (after tax)
    net_salaries[$i]=$(echo "${salaries[$i]} - ${taxes[$i]}" | bc)
    
    printf "${GREEN}Bonus: ${BOLD}${bonuses[$i]}${RESET}\n"
    printf "${BLUE}Gross Salary: ${BOLD}${salaries[$i]}${RESET}\n"
    printf "${RED}Tax (the buzzkill): ${BOLD}${taxes[$i]}${RESET}\n"
    printf "${PURPLE}Net Salary: ${BOLD}${net_salaries[$i]}${RESET}\n"
done

# Asking user for file information
printf "\n💾 SAVE YOUR SALES SUPERSTAR DATA 💾\n\n"

printf "What shall we name this legendary file? (default: ${month}_dodge_sales.csv): "
read filename
filename=${filename:-"${month}_dodge_sales.csv"}

printf "Where should we store this treasure? (path, default directory):"
read filepath
filepath=${filepath:-"."}

if [ ! -d "$filepath" ]; then
    printf " That directory doesn't exist yet. Creating it faster than a Hellcat does 0-60...\n"
    mkdir -p "$filepath"
fi

full_path="${filepath}/${filename}"

# Prints results
printf "\n🏆 $month SALES CHAMPIONS 🏆\n\n"

# Prints results sorted by name
printf "Results sorted alphabetically:\n"
bubble_sort_by_name
printf "%-20s %-15s %-15s %-15s %-15s$\n" "Name" "Total Sales" "Bonus" "Tax" "Net Salary"
for ((i=0; i<num_salespersons; i++)); do
    if (( i % 2 == 0 )); then
        printf "${CYAN}"
    else
        printf "${BLUE}"
    fi
    printf "%-20s $%-14.2f $%-14.2f $%-14.2f $%-14.2f$\n" "${salesperson_names[$i]}" "${total_sales[$i]}" "${bonuses[$i]}" "${taxes[$i]}" "${net_salaries[$i]}"
done

# Prints results sorted by salary
printf "\n Results sorted by net salary (highest earners first):\n"
bubble_sort_by_salary
printf "%-20s %-15s %-15s %-15s %-15s$\n" "Name" "Total Sales" "Bonus" "Tax" "Net Salary"
for ((i=0; i<num_salespersons; i++)); do
    if (( i == 0 )); then
        printf "${YELLOW}" 
    elif (( i == 1 )); then
        printf "${CYAN}" 
    elif (( i == 2 )); then
        printf "${GREEN}"
    else
        printf "${RESET}"
    fi
    printf "%-20s $%-14.2f $%-14.2f $%-14.2f $%-14.2f$\n" "${salesperson_names[$i]}" "${total_sales[$i]}" "${bonuses[$i]}" "${taxes[$i]}" "${net_salaries[$i]}"
done

# Save results to file
printf "\Saving results to $full_path \n"
# Create header for CSV file
echo "Name,Total Sales,Bonus,Tax,Net Salary" > "$full_path"

# I wrote the data into CSV file
for ((i=0; i<num_salespersons; i++)); do
    echo "${salesperson_names[$i]},${total_sales[$i]},${bonuses[$i]},${taxes[$i]},${net_salaries[$i]}" >> "$full_path"
done

printf "\n🎉 SUCCESS! 🎉\n"
printf "Your sales team data for $month has been saved to $full_path \n"
printf "Remember, these Dodge salespeople aren't just selling cars \n"
printf "THEY'RE SELLING THE AMERICAN DREAM ON WHEELS \n\n"

cat << "EOF"
     _   iF YOU ARE NOT FIRST YOU ARE LAST
EOF

exit 0
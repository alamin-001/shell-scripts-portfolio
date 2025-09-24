#!/bin/bash
# This script calculates the area of a rectangle in square meters, square centimeters and square inches

# Validate that the inputs are numbers
validate_number_input() {
    local input=$1
    if ! [[ "$input" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        echo "Error: '$input' is not a valid number."
        exit 1
    fi
}

# Function to prompt user for new calculations or quit
rerun_program(){
    echo "Do you need to make another calculation or Quit?"
    echo "1. Start Again"
    echo "2. Quit"
    read -p "Choose an Option (1-2):" option

    validate_number_input "$option"

    case $option in
        1) main
        ;;
        2)exit 0 
        ;;
        *) echo "Invalid Option. Quiting"; exit 1 
        ;;
    esac
}

# Main function to calculate the area
main(){

# Prompt the user for length and width
read -p "Enter the length in meters: " length
validate_number_input "$length"

read -p "Enter the width in meters: " width
validate_number_input "$width"

# Calculate the area in square meters (1m * 1m = 1m²)
area_m2=$(echo "scale=5; $length * $width" | bc)

#Calculate the area in square centimeters (cm² = m² * 10,000)
area_cm2=$(echo "scale=5; $area_m2 * 10000" | bc)

# Convert the area to square inches (in² = cm² / 6.4516)
area_in2=$(echo "scale=5; $area_cm2 / 6.4516" | bc)

# Ask user what to display
echo "What do you want to display the area in:"
echo "1. Square Meters"
echo "2. Square Centimeters"
echo "3. Square Inches"
echo "4. All three options"
read -p "Choose an option (1-4): " option


validate_number_input "$option"

echo "The area of the Rectangle is:"
case $option in
    1)
        echo "  $area_m2 m² in Square Meters"
        ;;
    2)
        echo "  $area_cm2 cm² in Square Centimeters"
        ;;
    3)
        echo "  $area_in2 in² in Square Inches"
        ;;
    4)
        echo "  $area_m2 m² in Square Meters"
        echo "  $area_cm2 cm² in Square Centimeters"
        echo "  $area_in2 in² in Square Inches"
        ;;
    *)
        echo "Invalid option selected."
        rerun_program
        return
        ;;
esac

rerun_program
}

main
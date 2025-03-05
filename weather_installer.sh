#!/bin/bash
set -e  # Exit immediately if any command fails
set -u  # Treat unset variables as errors
set -o pipefail # Fail if any command in a pipeline fails

# Ensure Ollama is installed (install if needed)
if ! command -v ollama &> /dev/null; then
  echo "Ollama is not installed. Installing..."
  curl -fsSL https://ollama.com/install.sh | sh || { echo "Ollama installation failed." >&2; exit 1; }
fi

# Ensure Python and pip are installed (install if needed)
if ! command -v python3 &> /dev/null || ! command -v pip3 &> /dev/null; then
  echo "Python3 or pip3 is not installed. Installing..."
  sudo apt update || { echo "Failed to update apt. Exiting." >&2; exit 1; }
  sudo apt install -y python3 python3-pip || { echo "Failed to install Python. Exiting." >&2; exit 1; }
fi

# Ensure the ollama and requests python libraries are installed
pip3 install ollama requests || { echo "Failed to install Python libraries. Exiting." >&2; exit 1; }

# Create the Python script
cat <<'EOF' > weather_ollama.py
import ollama
import requests
import json
import re
import time

def get_lat_lon_from_city_state(city_state):
    """Gets latitude and longitude. Uses Nominatim."""
    try:
        city_state = re.sub(r',\s+', ',', city_state)
        parts = city_state.split(',')
        if len(parts) != 2:
            print(f"Error: Invalid format: {city_state}")
            return None, None
        city, state = parts[0].strip(), parts[1].strip()
        combined_address = f"{city}, {state}"
        encoded_address = requests.utils.quote(combined_address)
        url = f"https://nominatim.openstreetmap.org/search?q={encoded_address}&format=json&limit=1"
        headers = {"User-Agent": "WeatherApp/1.0"}
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        data = response.json()
        if data:
            return float(data[0]['lat']), float(data[0]['lon'])
        print(f"Error: No coordinates for {city_state}")
        return None, None
    except Exception as e:
        print(f"Geocoding error: {e}")
        return None, None

def get_weather_data(latitude, longitude):
    """Fetches weather data from weather.gov API."""
    try:
        grid_url = f"https://api.weather.gov/points/{latitude},{longitude}"
        grid_response = requests.get(grid_url, timeout=10)
        grid_response.raise_for_status()
        grid_data = grid_response.json()
        forecast_url = grid_data['properties']['forecast']
        forecast_response = requests.get(forecast_url, timeout=10)
        forecast_response.raise_for_status()
        return forecast_response.json()
    except Exception as e:
        print(f"Weather data error: {e}")
        return None

def create_weather_summary(weather_data):
    """Creates a concise weather summary."""
    if not weather_data or 'properties' not in weather_data or 'periods' not in weather_data['properties']:
        return "No detailed forecast available."
    forecasts = weather_data['properties']['periods']
    summary = ""
    for period in forecasts[:7]:  # Limit to 7 periods
        summary += f"{period['name']}: {period['shortForecast']}, Temp: {period['temperature']} {period['temperatureUnit']}. "
    return summary.strip()

def run_ollama_model(model_name, messages):
    """Runs the Ollama model with a list of messages, using streaming."""
    try:
        response_stream = ollama.chat(model=model_name, messages=messages, stream=True)
        full_response = ""
        for chunk in response_stream:
            if 'message' in chunk and 'content' in chunk['message']:
                print(chunk['message']['content'], end='', flush=True)  # Print as it arrives
                full_response += chunk['message']['content']
        print() # Newline after the full response
        return full_response
    except Exception as e:
        print(f"Ollama error: {e}")
        return None

def main():
    model_name = input("Enter the Ollama model name (e.g., llama2, mistral, llama3): ")
    conversation_history = []  # Initialize conversation history

    while True:
        city_state = input("Enter city and state (e.g., Hanover, VA), or 'exit' to quit: ")
        if city_state.lower() == 'exit':
            break

        latitude, longitude = get_lat_lon_from_city_state(city_state)
        if latitude is None or longitude is None:
            continue

        weather_data = get_weather_data(latitude, longitude)
        if not weather_data:
            continue

        weather_summary = create_weather_summary(weather_data)
        print(f"\nWeather Summary:\n{weather_summary}\n")

        # Initial prompt and response, added to history
        initial_prompt = f"Here is the weather forecast for {city_state}: {weather_summary} What can you tell me about this weather?"
        print("\nInitial Model Response:\n") # Print this *before* starting the streaming
        initial_response = run_ollama_model(model_name, [{'role': 'user', 'content': initial_prompt}])

        if initial_response:
            #No need to print again, as it's handled in run_ollama_model now
            conversation_history.append({'role': 'user', 'content': initial_prompt})
            conversation_history.append({'role': 'assistant', 'content': initial_response})
        else:
            print("Could not retrieve initial model response.")
            continue  # Skip to the next city

        while True:
            user_input = input("\nAsk a question (or 'next' for a new city, 'exit' to quit): ")
            if user_input.lower() == 'exit':
                exit()
            elif user_input.lower() == 'next':
                conversation_history = []  # Clear history for the new city
                break

            # Construct the prompt, prepending the weather summary
            prompt = f"Weather forecast for {city_state}: {weather_summary}\nUser: {user_input}"

            # Add user input to history
            conversation_history.append({'role': 'user', 'content': prompt})

            # Limit history length.  Keep the initial prompt and response.
            if len(conversation_history) > 6:  # Adjust as needed
                conversation_history = [conversation_history[0], conversation_history[1]] + conversation_history[-4:]

            print("\nModel Response:\n") # Print this *before* starting the streaming
            response = run_ollama_model(model_name, conversation_history)

            if response:
                # No need to print the response again, as it's streamed in run_ollama_model.
                conversation_history.append({'role': 'assistant', 'content': response})  # add the response
            else:
                print("No response from model.")

if __name__ == "__main__":
    main()

EOF

# Prompt the user for a model and pull it.
read -p "Enter the Ollama model name to pull (e.g., llama2, mistral, llama3): " model_to_pull
ollama pull "$model_to_pull" || { echo "Failed to pull Ollama model." >&2; exit 1; }

# Run the Python script
python3 weather_ollama.py

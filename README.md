# Weather Chat with Ollama

This script allows you to have a conversation with a local LLM (powered by Ollama) about the weather forecast for a given US city and state.

## Features

*   **Geocoding:** Uses the Nominatim (OpenStreetMap) API to convert a "City, State" input into latitude and longitude coordinates.
*   **Weather Data:** Fetches weather forecast data from the National Weather Service (weather.gov) API.
*   **Local LLM Interaction:** Uses Ollama to run a local LLM (e.g., Llama 2, Mistral, Llama 3) for a conversational experience.
*   **Conversational Context:** Maintains a conversation history with the LLM, allowing for follow-up questions.  The history is limited in length to prevent exceeding the LLM's context window.
*   **Error Handling:** Includes robust error handling for network issues, API errors, and invalid input.
*   **Multiple City Support:** Allows the user to query the weather for multiple cities without restarting the script.
*   **Easy Installation:** Provides a single Bash script to install dependencies and create the Python script.
*   **Raspberry Pi Compatible:** Works on Raspberry Pi devices (with sufficient RAM).

## Prerequisites

*   **Linux/macOS:** This script is designed for Linux or macOS systems.  (It may work on Windows with WSL, but this hasn't been tested.)
*   **Bash:** The installer script is a Bash script.
*   **curl:** Used to download the Ollama installer.
*   **Python 3 and pip:**  Python 3 and its package installer, pip, are required.
*   **Internet Connection:**  Required for installing dependencies, downloading Ollama models, and accessing weather and geocoding APIs.

## Installation and Usage

1.  **Clone the repository (or copy the script):**

    ```bash
    git clone <repository_url>  # If you have the script in a Git repository
    cd <repository_directory>

    # OR, if you don't have a repository, just copy and paste the script below:
    ```
    Copy and paste the *entire* bash script from the *previous* response (the one with the multi-line `cat <<'EOF'` command) into a file named `weather_installer.sh`.

2.  **Make the script executable:**

    ```bash
    chmod +x weather_installer.sh
    ```

3.  **Run the installer:**

    ```bash
    ./weather_installer.sh
    ```
    *   The script will:
        *   Check if Ollama, Python 3, and pip are installed. If not, it will attempt to install them (using `apt` on Debian-based systems).
        *   Install the required Python libraries (`ollama` and `requests`).
        *   Create a Python script named `weather_ollama.py`.
        * Prompt you to enter an Ollama model to pull.
        * Pull your selected model.

4.  **Start the Ollama Server (Important!)**
    *   Open a *separate* terminal window or tab.
    *   Run the following command to start the Ollama server in the background:
    ```bash
     ollama serve
    ```
     Keep this terminal running. Ollama must be actively serving for the python script to work.

5.  **Run the weather script:**

    ```bash
    python3 weather_ollama.py
    ```

6.  **Follow the prompts:**
    *   You'll be prompted to enter an Ollama model name again.  Make sure this matches a model you have pulled (either with the installer or previously).
    *   Enter the city and state (e.g., "Hanover, VA").
    *   The script will fetch the weather, provide an initial summary, and then prompt you to ask questions.
    *   Type your questions about the weather.
    *   Type `'next'` to enter a new city and state.
    *   Type `'exit'` to quit the script.

## Example Interaction# Weatherapp
Personal WeatherApp

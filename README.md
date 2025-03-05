# Weather Chatbot with Ollama and Weather.gov

This script (`weather_installer.sh`) sets up a command-line chatbot that provides weather information and interacts with an Ollama language model to answer questions about the weather. It combines real-time weather data from the National Weather Service (weather.gov) with the conversational abilities of a local LLM (via Ollama).

## Features

*   **Weather Data:** Fetches current weather forecasts for US locations using the weather.gov API.
*   **Geolocation:** Uses Nominatim (OpenStreetMap) to convert city and state names to latitude/longitude coordinates.
*   **Ollama Integration:**  Uses any Ollama model (e.g., llama2, mistral, llama3) to discuss the weather forecast.  The model is provided with the weather data and can answer follow-up questions.
*   **Conversation History:**  The script maintains a conversation history, allowing the LLM to respond in context. The history is limited to prevent exceeding the model's context window. The initial weather data and the first model response are always kept.
*   **Error Handling:** Includes error handling for API requests, geocoding, and Ollama interactions.
*   **Interactive CLI:**  A command-line interface prompts the user for input and displays the model's responses.
* **Model Pull:** Prompts user for model name at runtime and downloads using `ollama pull`

## Prerequisites

*   **Bash Shell:** The script is written in Bash and should be run in a Bash-compatible environment.
*   **Internet Connection:**  Required for fetching weather data, geocoding, and downloading Ollama.
*   **cURL:** Used to download the Ollama installer.
*   **APT package manager**: Used for python and pip installation (Debian/Ubuntu systems).

## Installation and Usage

1.  **Save the Script:** Copy the provided Bash script and save it to a file named `weather_installer.sh`.

2.  **Make the Script Executable:**
    ```bash
    chmod +x weather_installer.sh
    ```

3.  **Run the Script:**
    ```bash
    ./weather_installer.sh
    ```

4.  **Follow the Prompts:**
    *   The script will prompt you to enter the name of the Ollama model you want to use (e.g., `llama2`, `mistral`, `llama3`).  It will then attempt to pull (download) this model using `ollama pull`.
    *   It will then ask you for a city and state (e.g., `Hanover, VA`).
    *   It will fetch the weather forecast and display a summary.
    *   It will then give an initial model response about the weather forecast
    *   You can then ask follow-up questions about the weather.
    *   Type `next` to enter a new city and state.
    *   Type `exit` to quit the script.

## Script Breakdown

The script (`weather_installer.sh`) performs the following steps:

1.  **Ollama Installation (if needed):** Checks if Ollama is installed. If not, it downloads and installs it using the official installation script.

2.  **Python and pip Installation (if needed):** Checks for `python3` and `pip3`.  If either is missing, it uses `apt` to install them.

3.  **Python Library Installation:** Installs the required Python libraries (`ollama` and `requests`) using `pip3`.

4.  **Python Script Creation:** Creates a Python script (`weather_ollama.py`) using a "here document" (`cat <<'EOF' > weather_ollama.py`).  This embedded script handles the core logic:
    *   **`get_lat_lon_from_city_state(city_state)`:**  Converts a city and state string (e.g., "Boston, MA") into latitude and longitude coordinates using the Nominatim geocoding service.  Handles potential errors and invalid input.
    *   **`get_weather_data(latitude, longitude)`:**  Retrieves weather data from the weather.gov API using the provided latitude and longitude.  Handles potential API errors.
    *   **`create_weather_summary(weather_data)`:** Extracts a concise weather summary from the raw weather data, limiting the summary to the first 7 forecast periods.
    *   **`run_ollama_model(model_name, messages)`:**  Communicates with the specified Ollama model. It sends a list of messages (representing the conversation history) and returns the model's response.
    *   **`main()`:** The main function that drives the interaction:
        *   Prompts the user for the Ollama model name.
        *   Enters a loop to handle multiple cities.
        *   Prompts for city and state, gets coordinates, fetches weather data, and creates a summary.
        *   Provides an initial prompt to the LLM and displays the initial response, adding both to the conversation history.
        *   Enters an inner loop for follow-up questions for the *current* city.
        *   Manages the conversation history, limiting its length.
        *   Calls the `run_ollama_model` function with the conversation history.
        *   Handles "next" (new city) and "exit" commands.

5.  **Model Pulling:** Prompts the user for the Ollama model name and downloads it using `ollama pull`.

6.  **Python Script Execution:** Runs the created Python script (`weather_ollama.py`) using `python3`.

## Important Considerations

*   **API Limits:**  The Nominatim and weather.gov APIs may have usage limits.  Excessive requests in a short period could lead to temporary blocking. The script includes `timeout` parameters in the `requests.get` calls to help prevent hanging on slow responses.
*   **Error Handling:** The script includes basic error handling for common issues (e.g., network errors, invalid input).  More robust error handling could be added.
*   **Conversation History:** The conversation history is crucial for providing context to the LLM.  The script limits the history length to avoid exceeding the model's context window.  Experiment with the `if len(conversation_history) > 6:` condition to find the optimal length for your chosen model.  The script prioritizes keeping the initial weather prompt and the initial response in the history.
*   **Ollama Models:** The performance and quality of responses will depend heavily on the chosen Ollama model.  Larger models generally provide better responses but require more resources.
* **Dependencies:** The script assumes a Debian/Ubuntu system for installing Python.  If you are using a different Linux distribution, you may need to modify the installation commands (e.g., using `yum` for Fedora/CentOS).
* **User Agent:** The geocoding request includes a `User-Agent` header.  This is considered good practice when using web APIs.
* **Nominatim Server:** The script uses `nominatim.openstreetmap.org`. Be aware of their usage policy.


# DB Column Commentor

Simple Python utility to add comments to database columns using table definitions, business domain or general purpose of the tables and LLM.

## Features

- Given a table definition and a general purpose/domain where the table is used, add comments to the columns.
- Web interface using Streamlit for easy interaction
- Support for multiple CREATE TABLE statements in a single file
- AI-powered comment generation using Google's Gemini

## Installation
 - Clone the repository
 - Install the requirements:
   ```bash
   pip3 install -r requirements.txt
   ```
 - Create a .env file with your Gemini API key:
     GEMINI_API_KEY=your_api_key_here
 
 - Run the python script using python3.
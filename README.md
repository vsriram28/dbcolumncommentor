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
 - Create a .env file with your Gemini API key and source it:  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GEMINI_API_KEY=your_api_key_here
 
 - Run the python script using streamlit.   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;% streamlit run src/app.py

 - Provide the sql file with one or more CREATE TABLE commands with the table definition, and provide the domain this table belongs to. A sample sql file (motgage_tables.sql) is provided as an example.
 - The SQL commands that add comments to each of the columns will be produced which can be saved into a file for execution.

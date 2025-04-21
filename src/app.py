import streamlit as st
import asyncio
from table_analyzer import TableAnalyzer
from gemini_client import GeminiClient
import tkinter as tk
from tkinter import filedialog
import os
# json import removed as it's no longer needed

def format_columns(columns):
    return '\n'.join([
        f"- {col['name']}: {col['definition']}"
        for col in columns
    ])

async def process_tables(tables, business_domain):
    all_comments = []
    gemini = GeminiClient()
    for table_info in tables:
        prompt = f"""
        Given a database table in the {business_domain} domain:
        Table Name: {table_info['table_name']}
        
        Columns:
        {format_columns(table_info['columns'])}
        
        Please provide a clear, concise comment for each column explaining its purpose 
        and business significance. Format the response as SQL COMMENT statements.
        """
        comments = await gemini.generate_column_comments(prompt)
        all_comments.append(comments)
    return '\n\n'.join(all_comments)

st.set_page_config(page_title="DB Column Commentor", layout="wide")

st.title("DB Column Commentor")

# --- Apply CSS globally ---
st.markdown(
    """
    <style>
        /* Target the main container of the text area */
        div[data-testid="stTextArea"] {
            background: #f6f6f6 !important;
            border-radius: 0.5rem !important;
            border: 1px solid #ddd !important; /* Add border to container */
            width: 70vw !important;
            max-width: 70vw !important;
            min-width: 70vw !important;
            padding: 1rem !important; /* Add padding to container */
            /* Let the inner textarea control the height */
            height: auto !important; 
        }

        /* Target the actual textarea element inside, including disabled state */
        div[data-testid="stTextArea"] textarea, 
        div[data-testid="stTextArea"] textarea:disabled {
            font-size: 11pt !important; /* Ensure 11pt font size */
            color: #000 !important; /* Force black color */
            -webkit-text-fill-color: #000 !important; /* Override browser default for disabled */
            opacity: 1 !important; /* Ensure full opacity */
            background: transparent !important; /* Make textarea background transparent */
            border: none !important; /* Remove textarea border */
            padding: 0 !important; /* Remove textarea padding */
            font-family: inherit !important;
            width: 100% !important; /* Make textarea fill the container */
            height: 400px !important; /* Explicitly set height here */
        }

        .custom-btn-col {
            display: flex;
            flex-direction: column;
            gap: 10px;
            align-items: flex-start;
            margin-top: 0;
        }
        .custom-btn-col .stTextInput {
            margin-bottom: 10px;
        }

        /* Style for the Generate Comments button */
        div[data-testid="stButton"] > button {
            background-color: #007bff !important; /* Blue background */
            color: white !important; /* White text */
            border: none !important; /* Remove default border */
            padding: 0.5rem 1rem !important; /* Add some padding */
            border-radius: 0.25rem !important; /* Slightly rounded corners */
            cursor: pointer !important; /* Pointer cursor on hover */
            transition: background-color 0.3s ease !important; /* Smooth transition */
            display: inline-block !important; /* Ensure proper layout */
            text-decoration: none !important; /* Remove underline from link */
            line-height: normal !important; /* Adjust line height if needed */
            width: auto !important; /* Adjust width automatically */
        }

        /* Optional: Style for hover state */
        div[data-testid="stButton"] > button:hover {
            background-color: #0056b3 !important; /* Darker blue on hover */
            color: white !important; /* Ensure text remains white */
            text-decoration: none !important;
        }

        /* Optional: Style for active state */
        div[data-testid="stButton"] > button:active {
            background-color: #004085 !important; /* Even darker blue when clicked */
            color: white !important; /* Ensure text remains white */
            text-decoration: none !important;
        }

        /* Style for the Save button (st.download_button) - Increased Specificity */
        .custom-btn-col div[data-testid="stDownloadButton"] > a { /* Added .custom-btn-col */
            background-color: #007bff !important; /* Blue background */
            color: white !important; /* White text */
            border: none !important; /* Remove default border */
            padding: 0.5rem 1rem !important; /* Add some padding */
            border-radius: 0.25rem !important; /* Slightly rounded corners */
            cursor: pointer !important; /* Pointer cursor on hover */
            transition: background-color 0.3s ease !important; /* Smooth transition */
            display: inline-block !important; /* Ensure proper layout */
            text-decoration: none !important; /* Remove underline from link */
            line-height: normal !important; /* Adjust line height if needed */
            width: auto !important; /* Adjust width automatically */
            /* Ensure consistent vertical alignment if needed */
            vertical-align: middle !important; 
        }

        /* Optional: Style for hover state (st.download_button) - Increased Specificity */
        .custom-btn-col div[data-testid="stDownloadButton"] > a:hover { /* Added .custom-btn-col */
            background-color: #0056b3 !important; /* Darker blue on hover */
            color: white !important; /* Ensure text remains white */
            text-decoration: none !important;
        }

        /* Optional: Style for active state (st.download_button) - Increased Specificity */
        .custom-btn-col div[data-testid="stDownloadButton"] > a:active { /* Added .custom-btn-col */
            background-color: #004085 !important; /* Even darker blue when clicked */
            color: white !important; /* Ensure text remains white */
            text-decoration: none !important;
        }

    </style>
    """,
    unsafe_allow_html=True
)

# Create a horizontal layout with two columns
col1, col2 = st.columns(2)

with col1:
    uploaded_file = st.file_uploader("Choose SQL file", type=['sql'])

with col2:
    business_domain = st.text_input("Enter business domain")

# Generate button (Now placed after the global CSS)
if st.button("Generate Comments"):
    if uploaded_file is not None and business_domain:
        # Read SQL content
        sql_content = uploaded_file.getvalue().decode()
        
        # Create analyzer and process tables
        analyzer = TableAnalyzer()
        tables = analyzer.parse_create_tables(sql_content)
        
        # Process tables and display results
        with st.spinner('Generating comments...'):
            comments = asyncio.run(process_tables(tables, business_domain))
            # Store comments in session state
            st.session_state['comments'] = comments
    else:
        st.error("Please upload a SQL file and enter the business domain")

# --- Always show the text area and buttons if comments exist in session state ---
if 'comments' in st.session_state:
    comments = st.session_state['comments']
    # The st.markdown(<style>...) block was removed from here
    
    # Use Streamlit columns for layout
    text_col, buttons_col = st.columns([7, 1])
    with text_col:
        st.text_area(
            "Generated Comments",
            comments,
            # Height parameter might be less effective now CSS controls it
            height=400, 
            key="comments_textarea",
            disabled=True,
            label_visibility="collapsed",
            placeholder="Generated comments will appear here."
        )
    with buttons_col:
        st.markdown('<div class="custom-btn-col">', unsafe_allow_html=True)
        file_name = st.text_input("File name:", value="generated_comments.sql", key="file_name_input")
        if comments.strip() and file_name.strip():
            st.download_button(
                label="Save", # Corrected label from "📄" to "Save"
                data=comments,
                file_name=file_name,
                mime="text/plain",
                help="Save to file",
                key="download_button"
            )
        st.markdown('</div>', unsafe_allow_html=True)
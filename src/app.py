import streamlit as st
import asyncio
from table_analyzer import TableAnalyzer
from gemini_client import GeminiClient
import tkinter as tk
from tkinter import filedialog
import os

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

# Create a horizontal layout with two columns
col1, col2 = st.columns(2)

with col1:
    uploaded_file = st.file_uploader("Choose SQL file", type=['sql'])

with col2:
    business_domain = st.text_input("Enter business domain")

# Generate button
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
    st.markdown(
        """
        <style>
            .stTextArea textarea, div.stTextArea > div > textarea {
                font-size: 11px !important;
                color: #000 !important;
                opacity: 1 !important;
                --text-color: #000 !important;
                caret-color: #000 !important;
            }
            .stTextArea {
                --text-color: #000 !important;
            }
            div[data-testid="stTextArea"] textarea {
                color: #000 !important;
                --text-color: #000 !important;
                caret-color: #000 !important;
            }
            div[data-testid="column"] {
                display: flex;
                align-items: flex-start;
            }
            .stButton {
                margin-left: 10px;
            }
        </style>
        """, 
        unsafe_allow_html=True
    )
    # Create columns for text area and buttons
    text_col, buttons_col = st.columns([8, 1])
    with text_col:
        st.markdown(
            f"""
            <textarea
                style="
                    width: 100%;
                    height: 400px;
                    font-size: 11px;
                    color: #000;
                    background: #f6f6f6;
                    border-radius: 0.5rem;
                    border: 1px solid #ddd;
                    padding: 1rem;
                    resize: none;
                    font-family: inherit;
                    opacity: 1;
                "
                readonly
                disabled
            >{comments}</textarea>
            """,
            unsafe_allow_html=True
        )
    with buttons_col:
        file_name = st.text_input("Save to", value="generated_comments.sql", key="file_name_input")
        if comments.strip() and file_name.strip():
            st.download_button(
                label="📄",
                data=comments,
                file_name=file_name,
                mime="text/plain",
                help="Save to file",
                key="download_button"
            )
        if st.button("📋", help="Copy to clipboard"):
            st.write('<script>navigator.clipboard.writeText(`' + comments + '`);</script>', unsafe_allow_html=True)
            st.toast("Copied to clipboard!")
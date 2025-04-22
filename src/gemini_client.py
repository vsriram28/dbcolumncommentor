import google.generativeai as genai
from typing import Dict
import os
from dotenv import load_dotenv

class GeminiClient:
    def __init__(self):
        load_dotenv()
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            raise ValueError("GEMINI_API_KEY not found in environment variables")
        
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-2.0-flash')
    
    async def generate_column_comments(self, prompt: str) -> str:
        """Generate column comments using Gemini."""
        response = await self.model.generate_content_async(prompt)
        # Format the response to ensure single quotes for comments
        formatted_response = self._format_sql_comments(response.text)
        # Remove all markdown code block markers and clean up
        cleaned_response = '\n'.join(
            line for line in formatted_response.split('\n')
            if not line.strip().startswith('```') and not line.strip() == '```'
        ).strip()
        return cleaned_response
    
    def _format_sql_comments(self, text: str) -> str:
        """Format SQL comments to use single quotes and remove any apostrophes."""
        lines = text.split('\n')
        formatted_lines = []
        for line in lines:
            if 'COMMENT' in line.upper():
                # Remove any existing quotes and fix syntax
                parts = line.split(' ON ')
                if len(parts) == 2:
                    comment_part = parts[1].strip()
                    # Remove duplicate IS and fix quote/semicolon issues
                    comment_part = comment_part.replace(' IS IS ', ' IS ')
                    comment_part = comment_part.strip(';\'"`')
                    
                    # Split at IS to separate column name and comment
                    col_and_comment = comment_part.split(' IS ')
                    if len(col_and_comment) == 2:
                        column_name = col_and_comment[0].strip()
                        comment_content = col_and_comment[1].strip().strip('\'"`')
                        # Remove any apostrophes and replace double quotes with single quotes
                        comment_content = comment_content.replace("'", "")
                        comment_content = comment_content.replace('"', "")
                        formatted_line = f"COMMENT ON {column_name} IS '{comment_content}';"
                        formatted_lines.append(formatted_line)
                    else:
                        formatted_lines.append(line)
                else:
                    formatted_lines.append(line)
            else:
                formatted_lines.append(line)
        
        return '\n'.join(formatted_lines)
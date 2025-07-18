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
        # Remove all markdown code block markers and clean up
        cleaned_response = '\n'.join(
            line for line in response.text.split('\n')
            if not line.strip().startswith('```')
        ).strip()
        return cleaned_response
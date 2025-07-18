import asyncio
from table_analyzer import TableAnalyzer
from gemini_client import GeminiClient

async def generate_comments(sql_file_path: str, business_domain: str) -> str:
    # Read SQL file
    with open(sql_file_path, 'r') as f:
        sql_content = f.read()
    
    # Parse table definitions
    analyzer = TableAnalyzer()
    tables = analyzer.parse_create_tables(sql_content)
    
    all_comments = []
    gemini = GeminiClient()
    
    # Process each table
    for table_info in tables:
        # Generate prompt for each table
        prompt = f"""
        Given a database table in the {business_domain} domain:
        Table Name: {table_info['table_name']}
        
        Columns:
        {format_columns(table_info['columns'])}
        
        Please provide a clear, concise comment for each column explaining its purpose 
        and business significance. Format the response as SQL COMMENT statements.
        """
        
        # Get comments from Gemini
        comments = await gemini.generate_column_comments(prompt)
        all_comments.append(comments)
    
    # Join all comments with newlines between tables
    return '\n\n'.join(all_comments)

def format_columns(columns):
    return '\n'.join([
        f"- {col['name']}: {col['definition']}"
        for col in columns
    ])

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) != 4:
        print("Usage: python main.py <sql_file_path> <business_domain> <db_name>")
        sys.exit(1)
    
    sql_file_path = sys.argv[1]
    business_domain = sys.argv[2]
    db_name = sys.argv[3]
    
    comments = asyncio.run(generate_comments(sql_file_path, business_domain, db_name))
    print(comments)
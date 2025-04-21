import sqlparse
from typing import Dict, List, Tuple

class TableAnalyzer:
    def __init__(self):
        self.table_name = ""
        self.columns = []
        
    def parse_create_tables(self, sql_content: str) -> list:
        """Parse multiple CREATE TABLE statements."""
        statements = sqlparse.split(sql_content)
        tables = []
        
        for statement in statements:
            parsed = sqlparse.parse(statement)[0]
            if parsed.get_type().upper() == 'CREATE':
                table_info = self._parse_single_table(parsed)
                if table_info:
                    tables.append(table_info)
        
        return tables
    
    def _parse_single_table(self, parsed_statement):
        """Parse a single CREATE TABLE statement."""
        table_info = {'table_name': '', 'columns': []}
        
        for token in parsed_statement.tokens:
            if isinstance(token, sqlparse.sql.Identifier):
                table_info['table_name'] = token.value
            
            if isinstance(token, sqlparse.sql.Parenthesis):
                column_definitions = token.value.strip('()').split(',')
                for col_def in column_definitions:
                    col_def = col_def.strip()
                    if col_def and not col_def.upper().startswith(('PRIMARY', 'FOREIGN', 'CONSTRAINT')):
                        col_name = col_def.split()[0]
                        col_type = ' '.join(col_def.split()[1:])
                        table_info['columns'].append({
                            'name': col_name,
                            'definition': col_type
                        })
        
        return table_info if table_info['table_name'] else None
    
    def format_for_gemini(self, business_domain: str) -> str:
        """Format table information for Gemini prompt."""
        prompt = f"""
        Given a database table in the {business_domain} domain:
        Table Name: {self.table_name}
        
        Columns:
        {self._format_columns()}
        
        Please provide a clear, concise comment for each column explaining its purpose 
        and business significance. Format the response as SQL COMMENT statements.
        """
        return prompt
    
    def _format_columns(self) -> str:
        return '\n'.join([
            f"- {col['name']}: {col['definition']}"
            for col in self.columns
        ])
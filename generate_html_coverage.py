import re
import os
from pathlib import Path
from html import escape

# Read coverage file
with open('coverage/lcov.info', 'r', encoding='utf-8') as f:
    content = f.read()

# Split into file blocks
blocks = content.split('end_of_record')

# Parse coverage data
files_data = []
total_lines = 0
total_covered = 0

for block in blocks:
    if 'SF:' not in block:
        continue
    
    # Extract file path
    sf_match = re.search(r'SF:(.+)', block)
    if not sf_match:
        continue
    
    filepath = sf_match.group(1).strip()
    
    # Skip generated files and non-feature files
    if any(x in filepath for x in ['.g.dart', '.freezed.dart', '_test.dart']):
        continue
    
    # Only include media, profile, trends, settings features
    if not any(x in filepath for x in ['/features/media/', '/features/profile/', '/features/trends/', '/features/settings/',
                                        '\\features\\media\\', '\\features\\profile\\', '\\features\\trends\\', '\\features\\settings\\']):
        continue
    
    # Count lines
    da_lines = re.findall(r'^DA:(\d+),(\d+)', block, re.M)
    lines_count = len(da_lines)
    covered_count = len([l for l in da_lines if int(l[1]) > 0])
    
    if lines_count > 0:
        percentage = (covered_count / lines_count) * 100
        files_data.append({
            'path': filepath,
            'total': lines_count,
            'covered': covered_count,
            'percentage': percentage
        })
        
        total_lines += lines_count
        total_covered += covered_count

# Sort by coverage percentage
files_data.sort(key=lambda x: x['percentage'])

# Calculate overall percentage
overall_percentage = (total_covered / total_lines * 100) if total_lines > 0 else 0

# Generate HTML
html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Coverage Report</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: #fff;
            padding: 5px;
            margin: 0;
        }}
        
        .container {{
            max-width: 100%;
            margin: 0;
            background: white;
            overflow: hidden;
        }}
        
        table {{
            width: 100%;
            border-collapse: collapse;
        }}
        
        thead {{
            background: #f8f9fa;
        }}
        
        th {{
            text-align: left;
            padding: 6px 10px;
            font-weight: 600;
            color: #666;
            font-size: 10px;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            border-bottom: 2px solid #eee;
        }}
        
        td {{
            padding: 5px 10px;
            border-bottom: 1px solid #f0f0f0;
        }}
        
        tr:hover {{
            background: #f8f9fa;
        }}
        
        .file-path {{
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 11px;
            color: #333;
        }}
        
        .coverage-bar {{
            width: 100%;
            height: 4px;
            background: #e0e0e0;
            border-radius: 2px;
            overflow: hidden;
            margin-top: 2px;
        }}
        
        .coverage-fill {{
            height: 100%;
            border-radius: 2px;
            transition: width 0.3s ease;
        }}
        
        .coverage-high {{
            background: linear-gradient(90deg, #10b981 0%, #059669 100%);
        }}
        
        .coverage-medium {{
            background: linear-gradient(90deg, #f59e0b 0%, #d97706 100%);
        }}
        
        .coverage-low {{
            background: linear-gradient(90deg, #ef4444 0%, #dc2626 100%);
        }}
        
        .coverage-text {{
            font-weight: 600;
            font-size: 11px;
        }}
        
        .high {{
            color: #10b981;
        }}
        
        .medium {{
            color: #f59e0b;
        }}
        
        .low {{
            color: #ef4444;
        }}
        
        .stats {{
            font-size: 10px;
            color: #666;
        }}
        
        .feature-tag {{
            display: inline-block;
            padding: 2px 5px;
            border-radius: 2px;
            font-size: 9px;
            font-weight: 600;
            margin-right: 5px;
        }}
        
        .tag-media {{
            background: #dbeafe;
            color: #1e40af;
        }}
        
        .tag-profile {{
            background: #fce7f3;
            color: #9f1239;
        }}
        
        .tag-trends {{
            background: #dcfce7;
            color: #166534;
        }}
        
        .tag-settings {{
            background: #fef3c7;
            color: #92400e;
        }}
    </style>
</head>
<body>
    <div class="container">
        <table>
            <thead>
                <tr>
                    <th>File</th>
                    <th style="text-align: center;">Coverage</th>
                    <th style="text-align: center;">Lines</th>
                </tr>
            </thead>
            <tbody>
"""

for file_data in files_data:
    path = file_data['path'].replace('\\', '/')
    
    # Determine feature tag
    if '/features/media/' in path:
        tag = '<span class="feature-tag tag-media">MEDIA</span>'
    elif '/features/profile/' in path:
        tag = '<span class="feature-tag tag-profile">PROFILE</span>'
    elif '/features/trends/' in path:
        tag = '<span class="feature-tag tag-trends">TRENDS</span>'
    elif '/features/settings/' in path:
        tag = '<span class="feature-tag tag-settings">SETTINGS</span>'
    else:
        continue  # Skip non-feature files
    
    # Get short path (from lib/)
    if '/lib/' in path:
        short_path = path.split('/lib/')[1]
    elif '\\lib\\' in path:
        short_path = path.split('\\lib\\')[1]
    else:
        short_path = path
    
    percentage = file_data['percentage']
    
    # Determine coverage class
    if percentage >= 80:
        coverage_class = 'high'
        bar_class = 'coverage-high'
    elif percentage >= 50:
        coverage_class = 'medium'
        bar_class = 'coverage-medium'
    else:
        coverage_class = 'low'
        bar_class = 'coverage-low'
    
    html += f"""
                <tr>
                    <td>
                        {tag}
                        <div class="file-path">{escape(short_path)}</div>
                    </td>
                    <td style="text-align: center;">
                        <div class="coverage-text {coverage_class}">{percentage:.1f}%</div>
                        <div class="coverage-bar">
                            <div class="coverage-fill {bar_class}" style="width: {percentage}%"></div>
                        </div>
                    </td>
                    <td style="text-align: center;">
                        <div class="stats">{file_data['covered']} / {file_data['total']}</div>
                    </td>
                </tr>
"""

html += """
            </tbody>
        </table>
    </div>
</body>
</html>
"""

# Create coverage/html directory if it doesn't exist
os.makedirs('coverage/html', exist_ok=True)

# Write HTML file
with open('coverage/html/index.html', 'w', encoding='utf-8') as f:
    f.write(html)

print(f"✅ HTML coverage report generated!")
print(f"📊 Overall Coverage: {overall_percentage:.1f}%")
print(f"📁 Files Analyzed: {len(files_data)}")
print(f"📄 Report: coverage/html/index.html")

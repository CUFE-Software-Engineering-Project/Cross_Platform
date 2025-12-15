import re

# Read coverage file
with open('coverage/lcov.info', 'r', encoding='utf-8') as f:
    content = f.read()

# Split into file blocks
blocks = content.split('end_of_record')

# Filter for ALL profile feature files (including widgets)
profile_files = [
    block for block in blocks 
    if 'lib/features/profile/' in block or 'lib\\features\\profile\\' in block
    and not any(x in block for x in ['_test.dart', '.g.dart', '.freezed.dart'])
]

total_lines = 0
covered_lines = 0

for block in profile_files:
    if 'SF:' not in block:
        continue
    
    # Count total lines
    da_lines = re.findall(r'^DA:', block, re.M)
    lines_count = len(da_lines)
    
    # Count covered lines (execution count > 0)
    covered_count = len([l for l in re.findall(r'^DA:(\d+),(\d+)', block, re.M) if int(l[1]) > 0])
    
    total_lines += lines_count
    covered_lines += covered_count

print('\nTotal Profile Feature Coverage (INCLUDING ALL FILES):')
print(f'Lines Hit: {covered_lines}')
print(f'Lines Found: {total_lines}')
if total_lines > 0:
    percentage = covered_lines / total_lines * 100
    needed = int(total_lines * 0.95) - covered_lines
    print(f'Coverage: {percentage:.2f}%')
    print(f'Need {needed} more lines for 95%')
else:
    print('No coverage data found')

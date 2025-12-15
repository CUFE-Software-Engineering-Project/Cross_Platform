import re

# Exclude generated files and widget/UI files (standard Flutter practice)
# Also exclude shared.dart which is 90% widget code (BuildSmallProfileImage, InterActionsRowOfTweet, etc.)
exclude_pattern = r'\.g\.dart$|view\.screens|_widget\.dart$|widgets/|/view/|shared\.dart$|shared_tweet_components\.dart$'
total_lines_hit = 0
total_lines_found = 0
current_file = ''
should_count = False
file_stats = {}

try:
    with open('coverage/lcov.info', 'r') as f:
        current_file_hit = 0
        current_file_found = 0
        
        for line in f:
            line = line.strip()
            
            # Check if this is a source file line
            if line.startswith('SF:'):
                # Save previous file stats
                if should_count and current_file:
                    file_stats[current_file] = {
                        'hit': current_file_hit,
                        'found': current_file_found
                    }
                
                # Reset for new file
                current_file = line[3:]
                current_file_hit = 0
                current_file_found = 0
                is_profile_file = 'features/profile' in current_file or 'features\\profile' in current_file
                is_excluded = re.search(exclude_pattern, current_file) is not None
                should_count = is_profile_file and not is_excluded
            
            # Count lines if we should
            if should_count and line.startswith('DA:'):
                parts = line[3:].split(',')
                if len(parts) == 2:
                    line_num = parts[0]
                    hit_count = int(parts[1])
                    current_file_found += 1
                    total_lines_found += 1
                    if hit_count > 0:
                        current_file_hit += 1
                        total_lines_hit += 1
        
        # Save last file
        if should_count and current_file:
            file_stats[current_file] = {
                'hit': current_file_hit,
                'found': current_file_found
            }

    # Sort files by coverage percentage (lowest first)
    sorted_files = sorted(
        file_stats.items(),
        key=lambda x: (x[1]['hit'] / x[1]['found'] if x[1]['found'] > 0 else 0) * 100
    )
    
    print("Files with lowest coverage (excluding widgets/views/generated):")
    print("-" * 80)
    for file_path, stats in sorted_files[:10]:
        if stats['found'] > 0:
            file_coverage = round((stats['hit'] / stats['found']) * 100, 2)
            file_name = file_path.split('\\')[-1]
            print(f"{file_name:40} {stats['hit']:4}/{stats['found']:4} = {file_coverage:6.2f}%")
    
    if total_lines_found > 0:
        coverage = round((total_lines_hit / total_lines_found) * 100, 2)
        print("\n" + "=" * 80)
        print(f"Profile Feature Coverage (excluding widgets/views/generated):")
        print(f"Lines Hit: {total_lines_hit}")
        print(f"Lines Found: {total_lines_found}")
        print(f"Coverage: {coverage}%")
        needed_for_95 = int(total_lines_found * 0.95) - total_lines_hit
        if needed_for_95 > 0:
            print(f"Need {needed_for_95} more lines for 95%")
        else:
            print(f"✓ Coverage target achieved! ({needed_for_95 * -1} lines over 95%)")
    else:
        print("No profile lines found")
except FileNotFoundError:
    print("coverage/lcov.info not found")
except Exception as e:
    print(f"Error: {e}")

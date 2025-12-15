import re

def analyze_settings_coverage():
    try:
        with open('coverage/lcov.info', 'r') as f:
            content = f.read()
        
        # Find all settings files
        settings_files = {}
        current_file = None
        
        for line in content.split('\n'):
            if line.startswith('SF:'):
                filepath = line[3:].strip()
                if 'lib/features/settings' in filepath and not any(x in filepath for x in ['view.dart', 'widget', '.g.dart', '.freezed.dart']):
                    current_file = filepath
                    settings_files[current_file] = {'hit': 0, 'found': 0}
                else:
                    current_file = None
            elif current_file and line.startswith('LH:'):
                settings_files[current_file]['hit'] = int(line[3:])
            elif current_file and line.startswith('LF:'):
                settings_files[current_file]['found'] = int(line[3:])
        
        if not settings_files:
            print("No settings files found in coverage report.")
            return
        
        print("\n" + "="*80)
        print("SETTINGS FEATURE COVERAGE")
        print("="*80)
        
        total_hit = 0
        total_found = 0
        
        for filepath, data in sorted(settings_files.items()):
            filename = filepath.split('/')[-1]
            hit = data['hit']
            found = data['found']
            coverage = (hit / found * 100) if found > 0 else 0
            
            total_hit += hit
            total_found += found
            
            status = "✓" if coverage == 100 else "✗"
            print(f"{status} {filename:40s} {hit:4d}/{found:4d} = {coverage:6.2f}%")
        
        print("-"*80)
        overall_coverage = (total_hit / total_found * 100) if total_found > 0 else 0
        print(f"\n{'TOTAL SETTINGS COVERAGE':40s} {total_hit:4d}/{total_found:4d} = {overall_coverage:6.2f}%")
        print("="*80)
        
        if overall_coverage >= 100:
            print("🎉 EXCELLENT! 100% coverage achieved!")
        elif overall_coverage >= 95:
            print(f"✓ GREAT! Need {int(total_found * 0.95 - total_hit)} more lines for 95%")
        else:
            print(f"Need {int(total_found * 0.95 - total_hit)} more lines for 95%")
        
    except FileNotFoundError:
        print("Coverage file not found. Run: flutter test --coverage")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    analyze_settings_coverage()

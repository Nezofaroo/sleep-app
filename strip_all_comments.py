import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

lib_dir = r"c:\Android\AndroidStudioProjects\sleep_tracker_app\lib"

def strip_comments_from_text(code_str):
    out = []
    in_multiline_comment = False
    lines = code_str.split('\n')
    
    for line in lines:
        if in_multiline_comment:
            if '*/' in line:
                idx = line.find('*/')
                line = line[idx+2:]
                in_multiline_comment = False
            else:
                continue
        
        processed_line = ""
        i = 0
        in_double_quote = False
        in_single_quote = False
        
        while i < len(line):
            char = line[i]
            
            # Handle escapes
            if char == '\\' and (in_double_quote or in_single_quote) and i + 1 < len(line):
                processed_line += line[i:i+2]
                i += 2
                continue
                
            if char == '"' and not in_single_quote:
                in_double_quote = not in_double_quote
                processed_line += char
                i += 1
                continue
            elif char == "'" and not in_double_quote:
                in_single_quote = not in_single_quote
                processed_line += char
                i += 1
                continue
                
            if not in_double_quote and not in_single_quote:
                if line[i:i+2] == '//':
                    break
                elif line[i:i+2] == '/*':
                    in_multiline_comment = True
                    end_idx = line.find('*/', i+2)
                    if end_idx != -1:
                        in_multiline_comment = False
                        i = end_idx + 2
                        continue
                    else:
                        break
            
            processed_line += char
            i += 1
            
        # Keep empty lines but strip trailing whitespaces
        out.append(processed_line.rstrip())
        
    # Join and return
    return "\n".join(out)

print("Stripping comments from all Dart files...")
count = 0
for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if f.endswith(".dart"):
            path = os.path.join(root, f)
            try:
                with open(path, 'r', encoding='utf-8') as file:
                    content = file.read()
                
                cleaned = strip_comments_from_text(content)
                
                # Write back if changed
                if cleaned != content:
                    with open(path, 'w', encoding='utf-8', newline='\n') as file:
                        file.write(cleaned)
                    print(f"  Cleaned: {os.path.relpath(path, lib_dir)}")
                    count += 1
            except Exception as e:
                print(f"Error processing {f}: {e}")

print(f"Finished! Cleaned comments from {count} files.")

import json

with open(r"c:\Android\AndroidStudioProjects\sleep_tracker_app\old_script_extracted.py", "r", encoding="utf-8") as f:
    content = f.read()

# Let's see if we can parse it as JSON or unescape it
try:
    # If the file contains a JSON string literal like "import zipfile\n...", wrapping it in quotes and using json.loads can parse it.
    # But wait, it already starts with a double quote and ends with a double quote.
    # Let's parse it as a JSON string.
    unescaped = json.loads(content)
except Exception as e:
    print(f"Direct JSON parse failed: {e}")
    # Fallback manual unescaping
    if content.startswith('"') and content.endswith('"'):
        content = content[1:-1]
    unescaped = content.replace('\\n', '\n').replace('\\"', '"').replace('\\\\', '\\')

out_path = r"c:\Android\AndroidStudioProjects\sleep_tracker_app\old_script_unescaped.py"
with open(out_path, "w", encoding="utf-8") as out:
    out.write(unescaped)

print(f"Unescaped script written to {out_path}")
print("Checking file size and structure...")
with open(out_path, "r", encoding="utf-8") as f:
    lines = f.readlines()
print(f"Total lines: {len(lines)}")
print("First 20 lines:")
for i in range(min(20, len(lines))):
    print(f"{i+1}: {lines[i]}", end="")

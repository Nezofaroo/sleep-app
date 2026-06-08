import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

asd_path = r"C:\Users\admin\AppData\Roaming\Microsoft\Word\Өндірісті%20ұйымдастыру312577731637896933\Өндірісті%20ұйымдастыру((Autosaved-312578273603524208)).asd"
out_docx = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Өндірісті ұйымдастыру.docx"

if not os.path.exists(asd_path):
    asd_path = asd_path.replace("%20", " ")

if not os.path.exists(asd_path):
    print("ASD file not found!")
    sys.exit(1)

try:
    with open(asd_path, 'rb') as f:
        data = f.read()
    
    # Search for the ZIP header (PK\x03\x04)
    zip_header = b'\x50\x4B\x03\x04'
    idx = data.find(zip_header)
    
    if idx == -1:
        print("Zip header (PK\\x03\\x04) not found in the ASD file.")
        sys.exit(1)
        
    print(f"Zip header found at byte offset: {idx}")
    
    # Write from that offset to the end
    recovered_data = data[idx:]
    with open(out_docx, 'wb') as f_out:
        f_out.write(recovered_data)
        
    print(f"Successfully recovered DOCX to: {out_docx}")
    
    # Let's verify if the zip is valid
    import zipfile
    with zipfile.ZipFile(out_docx, 'r') as z:
        print("Zip validation PASSED! Files in recovered docx:")
        for name in z.namelist()[:5]:
            print(f"  {name}")
except Exception as e:
    print(f"Error: {e}")

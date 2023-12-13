import time

from pathlib import Path
from tempfile import TemporaryDirectory

import pytesseract
from PIL import Image
from pdf2image import convert_from_path

st = time.time()
pytesseract.pytesseract.tesseract_cmd = (r"C:\Program Files\Tesseract-OCR\tesseract.exe")
path_to_poppler_exe = Path(r"C:\ASCIW\Tools\poppler\Library\bin")
out_directory = Path(r"~\Desktop").expanduser()
image_file_list = []
PDFfile = r"C:\Temp\Test1.pdf"
text=""
with TemporaryDirectory() as tempdir:
    pdf_pages = convert_from_path(PDFfile, 500, poppler_path=path_to_poppler_exe)
    for page_enumeration, page in enumerate(pdf_pages, start=1):
        filename = f"{tempdir}\page_{page_enumeration:03}.jpg"
        page.save(filename, "JPEG")
        image_file_list.append(filename)
        for image_file in image_file_list:
            text = str(((pytesseract.image_to_string(Image.open(image_file)))))
            text = text.replace("-\n", "")
et = time.time()
elapsed_time = et - st
print(text)
print('Execution time:', elapsed_time, 'seconds')


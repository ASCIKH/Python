import io
import os
import time

import fitz
from PIL import Image
from pyzbar.pyzbar import decode

st = time.time()
pdf = fitz.open("C:\\Temp\\test1.pdf")
for page_num in range(len(pdf)):
    page = pdf.load_page(page_num)
    image_list = page.get_images(full=True)
    for img_index, img in enumerate(image_list, start=1):
        xref = img[0]
        base_image = pdf.extract_image(xref)
        image_bytes = base_image["image"]
        image_ext = base_image["ext"]
        image = Image.open(io.BytesIO(image_bytes))
        tempfile = f"C:\\Temp\\image{page_num + 1}_{img_index}.{image_ext}"
        image.save(open(tempfile, "wb"))
        decoded_objects = decode(Image.open(tempfile))
        for obj in decoded_objects:
            print("QR Code Detected with pyzbar:", obj.data.decode("utf-8"))
        os.remove(tempfile)
pdf.close()
et = time.time()
elapsed_time = et - st
print('Execution time:', elapsed_time, 'seconds')
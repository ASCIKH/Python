Class Python
{

/*
	PS C:\InterSystems\IRIS\bin> ./irispip install PyPDF2

	In %SYS : 
		s r=##class(%Net.HttpRequest).%New(),r.Server="pm.community.intersystems.com",r.SSLConfiguration="ISC.FeatureTracker.SSL.Config" d r.Get("/packages/zpm/latest/installer"),$system.OBJ.LoadStream(r.HttpResponse.Data,"c")
		zpm "install zpip" 
		Do ##class(%ZPIP.zpip).Shell("install requests opencv-python numpy pyzbar pymupdf pillow frontend pytesseract pdf2image pdfplumber PyPDF2 pdfminer.six pdfplumber")


	In DEV :
		Do ##class(Tools.Python).OCR2("C:\Temp\test3.pdf")

*/
ClassMethod Barcode(Filename As %String) [ Language = python ]
{
	import io
	import os
	import fitz
	import json
	from PIL import Image
	from pyzbar.pyzbar import decode
	
	barcodes=[]
	pdf = fitz.open(Filename)
	for page_num in range(len(pdf)):
	    page = pdf.load_page(page_num)
	    image_list = page.get_images(full=True)
	    for img_index, img in enumerate(image_list, start=1):
	        xref = img[0]
	        base_image = pdf.extract_image(xref)
	        image_bytes = base_image["image"]
	        image_ext = base_image["ext"]
	        image=Image.open(io.BytesIO(image_bytes))
	        tempfile=f"C:\\Temp\\image{page_num + 1}_{img_index}.{image_ext}"
	        image.save(open(tempfile, "wb"))
	        decoded_objects = decode(Image.open(tempfile))
	        for obj in decoded_objects:
	            barcodes.append(obj.data.decode("utf-8"))
	        os.remove(tempfile)
	pdf.close()
	return json.dumps(barcodes)
}

ClassMethod OCR(PDFfile As %String) [ Language = python ]
{
	from pathlib import Path
	import pytesseract
	from pdf2image import convert_from_path
	from PIL import Image

	pytesseract.pytesseract.tesseract_cmd = (r"C:\Program Files\Tesseract-OCR\tesseract.exe")
	path_to_poppler_exe = Path(r"C:\ASCIW\Tools\poppler\Library\bin")
	image_file_list = []
	
	tempdir="C:\\Temp"
	pdf_pages = convert_from_path(PDFfile, 500, poppler_path=path_to_poppler_exe)
	for page_enumeration, page in enumerate(pdf_pages, start=1):
	        filename = f"{tempdir}\page_{page_enumeration:03}.jpg"
	        page.save(filename, "JPEG")
	        image_file_list.append(filename)
	        for image_file in image_file_list:
	            text = str(((pytesseract.image_to_string(Image.open(image_file)))))
	            text = text.replace("-\n", "")
	return text
}

ClassMethod OCR2(PDFfile As %String) [ Language = python ]
{
	import PyPDF2
	from pdfminer.high_level import extract_pages, extract_text
	from pdfminer.layout import LTTextContainer, LTChar, LTRect, LTFigure
	import pdfplumber
	from PIL import Image
	from pdf2image import convert_from_path
	import pytesseract
	import os
	from pathlib import Path

	pytesseract.pytesseract.tesseract_cmd = (r"C:\Program Files\Tesseract-OCR\tesseract.exe")
	#pytesseract.pytesseract.tesseract_cmd = (r"C:\ASCIW\Tools\Tesseract")
	path_to_poppler_exe = Path(r"C:\ASCIW\Tools\poppler\Library\bin")

	def text_extraction(element):
	    line_text = element.get_text()
	    line_formats = []
	    for text_line in element:
	        if isinstance(text_line, LTTextContainer):
	            for character in text_line:
	                if isinstance(character, LTChar):
	                    line_formats.append(character.fontname)
	                    line_formats.append(character.size)
	    format_per_line = list(set(line_formats))
	    return (line_text, format_per_line)

	def extract_table(pdf_path, page_num, table_num):
	    pdf = pdfplumber.open(pdf_path)
	    table_page = pdf.pages[page_num]
	    table = table_page.extract_tables()[table_num]
	    return table

	def table_converter(table):
	    table_string = ''
	    for row_num in range(len(table)):
	        row = table[row_num]
	        cleaned_row = [
	            item.replace('\n', ' ') if item is not None and '\n' in item else 'None' if item is None else item for item
	            in row]
	        table_string += ('|' + '|'.join(cleaned_row) + '|' + '\n')
	    table_string = table_string[:-1]
	    return table_string

	def is_element_inside_any_table(element, page, tables):
	    x0, y0up, x1, y1up = element.bbox
	    y0 = page.bbox[3] - y1up
	    y1 = page.bbox[3] - y0up
	    for table in tables:
	        tx0, ty0, tx1, ty1 = table.bbox
	        if tx0 <= x0 <= x1 <= tx1 and ty0 <= y0 <= y1 <= ty1:
	            return True
	    return False


	def find_table_for_element(element, page, tables):
	    x0, y0up, x1, y1up = element.bbox
	    y0 = page.bbox[3] - y1up
	    y1 = page.bbox[3] - y0up
	    for i, table in enumerate(tables):
	        tx0, ty0, tx1, ty1 = table.bbox
	        if tx0 <= x0 <= x1 <= tx1 and ty0 <= y0 <= y1 <= ty1:
	            return i  
	    return None

	def extract_table(pdf_path, page_num, table_num):
	    pdf = pdfplumber.open(pdf_path)
	    table_page = pdf.pages[page_num]
	    table = table_page.extract_tables()[table_num]

	    return table

	def table_converter(table):
	    table_string = ''
	    for row_num in range(len(table)):
	        row = table[row_num]
	        cleaned_row = [
	            item.replace('\n', ' ') if item is not None and '\n' in item else 'None' if item is None else item for item
	            in row]
	        table_string += ('|' + '|'.join(cleaned_row) + '|' + '\n')
	    table_string = table_string[:-1]
	    return table_string

	def is_element_inside_any_table(element, page, tables):
	    x0, y0up, x1, y1up = element.bbox
	    y0 = page.bbox[3] - y1up
	    y1 = page.bbox[3] - y0up
	    for table in tables:
	        tx0, ty0, tx1, ty1 = table.bbox
	        if tx0 <= x0 <= x1 <= tx1 and ty0 <= y0 <= y1 <= ty1:
	            return True
	    return False

	def find_table_for_element(element, page, tables):
	    x0, y0up, x1, y1up = element.bbox
	    y0 = page.bbox[3] - y1up
	    y1 = page.bbox[3] - y0up
	    for i, table in enumerate(tables):
	        tx0, ty0, tx1, ty1 = table.bbox
	        if tx0 <= x0 <= x1 <= tx1 and ty0 <= y0 <= y1 <= ty1:
	            return i
	    return None

	def crop_image(element, pageObj):
	    [image_left, image_top, image_right, image_bottom] = [element.x0, element.y0, element.x1, element.y1]
	    pageObj.mediabox.lower_left = (image_left, image_bottom)
	    pageObj.mediabox.upper_right = (image_right, image_top)
	    cropped_pdf_writer = PyPDF2.PdfWriter()
	    cropped_pdf_writer.add_page(pageObj)
	    with open('cropped_image.pdf', 'wb') as cropped_pdf_file:
	        cropped_pdf_writer.write(cropped_pdf_file)

	def convert_to_images(input_file, ):
	    images = convert_from_path(input_file,poppler_path=r"C:\ASCIW\Tools\poppler\Library\bin")
	    image = images[0]
	    output_file = 'PDF_image.png'
	    image.save(output_file, 'PNG')

	def image_to_text(image_path):
	    img = Image.open(image_path)
	    text = pytesseract.image_to_string(img)
	    return text


	pdf_path = PDFfile
	pdfFileObj = open(pdf_path, 'rb')
	pdfReaded = PyPDF2.PdfReader(pdfFileObj)
	text_per_page = {}
	image_flag = False
	for pagenum, page in enumerate(extract_pages(pdf_path)):
	    pageObj = pdfReaded.pages[pagenum]
	    page_text = []
	    line_format = []
	    text_from_images = []
	    text_from_tables = []
	    page_content = []
	    table_in_page = -1
	    pdf = pdfplumber.open(pdf_path)
	    page_tables = pdf.pages[pagenum]
	    tables = page_tables.find_tables()
	    if len(tables) != 0:
	        table_in_page = 0
	    for table_num in range(len(tables)):
	        table = extract_table(pdf_path, pagenum, table_num)
	        table_string = table_converter(table)
	        text_from_tables.append(table_string)
	    page_elements = [(element.y1, element) for element in page._objs]
	    page_elements.sort(key=lambda a: a[0], reverse=True)
	    for i, component in enumerate(page_elements):
	        element = component[1]
	        if table_in_page == -1:
	            pass
	        else:
	            if is_element_inside_any_table(element, page, tables):
	                table_found = find_table_for_element(element, page, tables)
	                if table_found == table_in_page and table_found != None:
	                    page_content.append(text_from_tables[table_in_page])
	                    page_text.append('table')
	                    line_format.append('table')
	                    table_in_page += 1
	                continue
	        if not is_element_inside_any_table(element, page, tables):
	            if isinstance(element, LTTextContainer):
	                (line_text, format_per_line) = text_extraction(element)
	                page_text.append(line_text)
	                line_format.append(format_per_line)
	                page_content.append(line_text)
	            if isinstance(element, LTFigure):
	                crop_image(element, pageObj)
	                convert_to_images('cropped_image.pdf')
	                image_text = image_to_text('PDF_image.png')
	                text_from_images.append(image_text)
	                page_content.append(image_text)
	                page_text.append('image')
	                line_format.append('image')
	                image_flag = True
	    dctkey = 'Page_' + str(pagenum)
	    text_per_page[dctkey] = [page_text, line_format, text_from_images, text_from_tables, page_content]
	pdfFileObj.close()
	if image_flag:
	    os.remove('cropped_image.pdf')
	    os.remove('PDF_image.png')
	result = ''.join(text_per_page['Page_0'][4])
	return result
}

}

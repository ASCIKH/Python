import time
import torch
import torchvision.transforms as transforms
from PIL import Image
import pytesseract

st = time.time()
# Check if CUDA is available and set the device
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Load your OCR model (this is just a placeholder for your OCR model)
# model = YourOCRModel().to(device)

# Load and preprocess the image
image = Image.open("C:\\Temp\\test1.jpg")
transform = transforms.Compose([
    transforms.ToTensor(),
])
image = transform(image).unsqueeze(0).to(device)

# Perform OCR using the model
# output = model(image)
pytesseract.pytesseract.tesseract_cmd = (r"C:\Program Files\Tesseract-OCR\tesseract.exe")
processed_image = transforms.ToPILImage()(image.squeeze(0).cpu())
text = pytesseract.image_to_string(processed_image)
et = time.time()
elapsed_time = et - st
print('Execution time:', elapsed_time, 'seconds')

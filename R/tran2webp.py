# 编码
import webp
from PIL import Image
imagePath = "/Users/asa/Desktop/1-3.png" #读入文件名称
im = Image.open(imagePath) #读入文件
webp.save_image(im, imagePath[:-3]+'webp', quality=80)  #压缩编码  设置压缩因子为80    

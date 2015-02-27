import sys
from PIL import Image, ImageFont, ImageDraw
from shutil import copyfile

if len(sys.argv) != 3 and len(sys.argv) != 4 and len(sys.argv) != 5:
	print("Usage: makeicon.py <source_path> <icon_name> <optional remove_white = False> <optional levels = 0>")
	print('Example: python makeicon.py "F:/script/icons/items/talisman_of_evasion.png" "warlock_pocket_watch" True 2')
	sys.exit()

source_path = sys.argv[1]
icon_name = sys.argv[2]

levels = 0
remove_white = False

if len(sys.argv) >= 4:
	remove_white = True if sys.argv[3] in [ "True", "true", "1", "yes" ] else False

if len(sys.argv) == 5:
	levels = sys.argv[4]

image = Image.open(source_path)

if remove_white:
	image = image.crop((0, 0, image.size[0] - 36, image.size[1]))
else:
	delta_x = image.size[0] - 88
	delta_y = image.size[1] - 64

	if delta_x < 0 or delta_y < 0:
		print("Cant upscale")
		sys.exit()
		
	left = int(delta_x / 2)
	right = int(image.size[0] - delta_x / 2)
	top = int(delta_y / 2)
	bottom = int(image.size[1] - delta_y / 2)

	image = image.crop((left, top, right, bottom))
	
out_path = "../game/dota_addons/warlock/resource/flash3/images/items/" + icon_name + ".png"
image.save(out_path, "PNG")

max_level = int(levels)
for level in range(1, max_level+1):
	image = Image.open(out_path)
	draw = ImageDraw.Draw(image)
	font = ImageFont.truetype("Nunito-Regular.ttf", 22)
	
	color = (255, 255, 0)
	if level == max_level:
		color = (255, 0, 0)
	
	draw.text((image.size[0] - 18, 0), str(level), font=font, fill=color)
	del draw
	
	image.save("../game/dota_addons/warlock/resource/flash3/images/items/" + icon_name + str(level) + ".png", "PNG")
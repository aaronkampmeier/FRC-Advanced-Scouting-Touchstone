import os, fnmatch
from send2trash import send2trash

# Find files in the FAST directory that are duplicates, i.e. same file name but with a " n" before the extensions where n is an integer 2 or more

fast_path = "/Users/aaron/Documents/Xcode Projects/FRC Advanced Scouting Telemetrics"
seq = [2,3,4,5,6,7,8,9]
space = [" "]
duplicate_pattern = "* [2,3,4,5,6,7].*"

print("Starting matching")

files_to_delete = []

for root, dirs, files in os.walk(fast_path):
	for name in files:
		if fnmatch.fnmatch(name,duplicate_pattern):
			files_to_delete.append(os.path.join(root,name))
			print("Found file: ", os.path.join(root,name))

# Ask to delete
print("\n")
answer_to_delete = input("Should I delete these files Aaron?")
print("\n")

if answer_to_delete.lower() == "yes" or answer_to_delete.lower() == "y":
	for path in files_to_delete:
		send2trash(path)
		print("Moved to trash: ", path)
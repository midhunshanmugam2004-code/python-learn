# import os
# folders = input("Enter the folder number: ") .split()

# for folder in folders:
#     try:
#        files = os.listdir(folder)
#     except FileNotFoundError:
#         print("Folder not found, enter the right folder name")
#         break
#     except PermissionError:
#         print("Permission denied, you don't have access to this folder")
#         break
#     for file in files:
#         print(file)
import os
def list_files_in_folders(folders):

    try:
        files = os.listdir(folders)
        return files, None
    except FileNotFoundError:
        return None, "Folder not found, enter the right folder name"
    except PermissionError:
        return None, "Permission denied, you don't have access to this folder"
    
def main():
    folders = input("Enter the folder number: ").split()
    for folder in folders:
        files, error = list_files_in_folders(folder)
        if files:
            print(f"files in {folder}:")
            for file in files:
               print(file)
        else:
            print(f"error in {folder}: {error}")

if __name__ == "__main__":
    main()
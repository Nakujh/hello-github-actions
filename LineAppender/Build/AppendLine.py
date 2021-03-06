import os
from datetime import datetime

def get_current_date_time():
    dtCurrent = datetime.now()
    return dtCurrent.strftime('%d/%m/%Y %H:%M:%S')

def append_new_line(sFileName, sTextToAppend):
    """Append given text as a new line at the end of file"""
    # Open the file in append & read mode ('a+')
    print(os.getcwd())
    FileObject = open(sFileName, "a+")
    # Move read cursor to the start of file.
    FileObject.seek(0)
    # If file is not empty then append '\n'
    Data = FileObject.read(100)
    if len(Data) > 0:
        FileObject.write("\n")
    # Append text at the end of file
    FileObject.write(f'// {sTextToAppend} ({get_current_date_time()})')
    
print(os.getenv('API_USER'))    
    
append_new_line(os.path.join(os.getcwd(), 'ThreadExample/ThreadProject.dpr'), 'Runner Machine note:  Release: ')
# Comment added
# Comment added

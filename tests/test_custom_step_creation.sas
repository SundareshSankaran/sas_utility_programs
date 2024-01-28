proc python;

    submit;
    
import json
    
filelocation="/mnt/viya-share/data/"
name="Vector Databases - Hydrate Chroma DB Collection"
    
step1=CustomStep(filelocation=filelocation, name=name, about=True)
    
    endsubmit;
    
quit;
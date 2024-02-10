proc python;

    submit;
    
import json
    
filelocation="/mnt/viya-share/data/"
name="Deep Learning - Build Model"
    
step1=CustomStep(filelocation=filelocation, name=name, about=True)
    
    endsubmit;
    
quit;
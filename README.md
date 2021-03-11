# scan_rentals

This code is for scanning kijiji, craigslist, usedvic, with MATLAB
The main script is scanallsites_wPar.m OR scanallsites.m
The former uses a parameter file, user_parFile.m, and the latter has the same information, but is hard-coded within

This code will use key words to identify ads of interest, and send these to the user via email or text message. 
The keywords, email, and phone numbers are in the user_parFile.m  
Each cell phone carrier has a unique email address associated with it, two are shown for example.  

You can have multiple sets of parameters if different parameters are desired, or if running for multiple users. 

A scan is performed every 2 minutes by default
You will need a gmail account, and you will need to change your security settings to allow outside apps to have access to it.  
I would recomend using a dedicated email address to avoid security concerns

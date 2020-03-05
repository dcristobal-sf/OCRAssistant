# steps to set up:
* clone/fork the repo
* create a scratch org from this project
~~~~
sfdx force:org:create -f config/project-scratch-def.json -s -a DevOcrOrg
~~~~
~~~~
C:\Code\SFDX\einstein_ocr>sfdx force:org:create -f config/project-scratch-def.json -s -a DevOcrOrg
Successfully created scratch org: 00D8E000000XXXXXXXX, username: test-XXXXXXXXq2hl@example.com
~~~~

Push metadata from local folder
~~~~
sfdx force:source:push -u DevOcrOrg
~~~~

Open your scratch org
~~~~
sfdx force:org:open -u DevOcrOrg
~~~~

this will open your browser and sign you into the scratch org

* Click setup menu> Custom Settings
* Click 'Manage' on Einstein Vision Settings
* Click new
* Enter your email
* Click save

## Register with Einstein Platform Services

https://api.einstein.ai/signup

Click 'Sign up using Salesforce'
Sign up must be completed using an appropriate developer org

Once signup is complete, you'll have a link to download a PEM file
![Alt](/_assets/images/downloadPemKey.png "Download your PEM key")
## Email address used MUST equal the one used to create the PEM file

* Go to files within scratch org
* Click upload files
* Select and upload your previously generated PEM file

## You're ready to go!

* Click on home
* Click cog>edit page
* Drag the Custom OCR component onto the page and save + activate

![Alt](/_assets/images/OCR_Component.PNG "Add the OCR component to your home page")
Click 'Assign as org default' on next page
Click save again
Click back button on the top right (not browser back button)

## Testing the OCR
Go to the homepage and enter an image URL - we provide two samples above the text box.

Image should load, then click 'Analyse'

You should end up with a result like the image below. The image will be annotated with boxes highlighting the words found. you can see the raw data returned from the OCR service in the textbox below the image

![Alt](/_assets/images/sampleOcrResult.PNG "Sample OCR output")

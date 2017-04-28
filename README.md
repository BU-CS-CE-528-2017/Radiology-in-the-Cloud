# Radiology in the Cloud
A web-based system to store and process medical images in the cloud
## What does this project do?
To show a proof of concept that the user can send a job to OpenShift, and get the results back, there is a plugin that reverses a text file. So, the user would send a text file to OpenShift, have it processed using the process manager, and get a reversed file back. To run this plugin, please see the instructions below.
## Instructions to run project:
Currently this project runs a sample application that reverses text files.
1. Download oc binaries. OS-based instructions are here: https://docs.openshift.com/enterprise/3.1/cli_reference/get_started_cli.html.
2. Clone or download this repository.
3. Switch to ‘simulatedBackEnd’ branch (e.g. git checkout simulatedBackEnd).
4. Run this command ./startjob.sh [filename] [userID]
  * filename: we have provided a sample file (test.txt).  You can also use any .txt file.
  * userID: any identifying name, all lowercase (e.g. user)
5. The link to the output file will be displayed in the terminal.  An example of what it will look like is: pfioh-radiology-in-the-cloud.128.31.26.63.xip.io/[userID]-3c8930db6a2df7b0571fd2f8/somefile.out
# Radiology in the Cloud
A web-based system to store and process medical images in the cloud
## Instructions to run project:
1. Download oc binaries. OS-based instructions are here: https://docs.openshift.com/enterprise/3.1/cli_reference/get_started_cli.html.
2. Clone or download this repository.
3. Switch to ‘simulatedBackEnd’ branch (e.g. git checkout simulatedBackEnd).
4. Run this command ./startjob.sh [filename] [userID]
  * filename: we have provided a sample file (test.txt).  You can also use any .txt file.
  * userID: any identifying name, all lowercase (e.g. user)
5. The link to the output file will be displayed in the terminal.  An example of what it will look like is: http://pfioh-radiology-in-the-cloud.128.31.26.63.xip.io/ldunphy-3c8930db6a2df7b0571fd2f8/somefile.out
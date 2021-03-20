# Nag Script

This script serves two purposes:

 * Stops my soundbar from shutting itself off after about 18 minutes of no sound, e.g. when the TV is paused.
 * Reminds children to do homework, chores, go to bed etc

It is designed to run on our linux HTPC, which we use for pretty much everything.

## Installation

1. Copy [nag.sh](nag.sh) and all the .py scripts to a directory together, e.g. /home/htpc/projects/homework-nag 
    
    Tip: just use git to clone it where you want it

2. Set up cron to run the shell script, something like this:

```cron
15,45 * * * * /home/htpc/projects/homework-nag/nag.sh mary
00,30 * * * * /home/htpc/projects/homework-nag/nag.sh martha
```

3. Install the python requirements:

```bash
pip3 install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib pyttsx3
```

4. Make executable and run it manually first time:

```bash
chmod +x /home/htpc/apps/nag/nag.sh
/home/htpc/apps/nag/nag.sh
```

5. Google API Stuff

* You need to "Enable The Classroom API" for each student, google it. I did it from [here](https://developers.google.com/classroom/quickstart/python).
* Create a subdir for each student, e.g. 'mary', 'martha'
* In each of these you need to provide a file, `credentials.json` which you can DL from [here](https://console.cloud.google.com/apis/credentials) (logged in as each student).
* On the first run for a given student it will attempt to open a new window or tab in your default browser, approve the access and it will create a `token.pickle` file in the student subdir.

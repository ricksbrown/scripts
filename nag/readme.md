# Nag Script

This script serves two purposes:

 * Stops my soundbar from shutting itself off after about 18 minutes of no sound, e.g. when the TV is paused.
 * Reminds children to do homework, chores, go to bed etc

It is designed to run on our linux HTPC, which we use for pretty much everything.

## Installation

1. Copy [nag.py](nag.py) and [nag.sh](nag.sh) to a directory together, e.g. /home/htpc/apps/nag/

2. Set up cron to run the shell script, something like this:

```cron
*/15 * * * * /home/htpc/apps/nag/nag.sh
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

On the first run it will attempt to open a new window or tab in your default browser. 
If this fails, copy the URL from the console and manually open it in your browser. 

If you are not already logged into your Google account, you will be prompted to log in. 
If you are logged into multiple Google accounts, you will be asked to select one account to use for the authorization.

Click the Accept button.


# Backup to B2
A little script that runs on Bash to backup data to Backblaze B2 :)

## Usage

This script is only designed to work on Ubuntu 22.04, it has not been tested on other versions/Linux distros/other operating systems and may (very likely will) break.

The output of the script (other than the embed sent to Discord) is hidden by default, run the script with the flag ``--loud`` to enable full output.

Files are uploaded to and stored in Backblaze in the format ``DD-MM-YYYY_HH-MM-XM.zip``(XM just means AM/PM time).

## Installation

Enable B2 on your Backblaze account if it isn't already [here](https://secure.backblaze.com/account_settings.htm). Then create a bucket and pick whatever name you like but note it down as you'll need it later, all other options can be set as you wish (although for security reasons you should definitely set the bucket to Private).

After that, generate an Application Key on [this page](https://secure.backblaze.com/app_keys.htm) and note down the ``keyID`` and ``applicationKey``. Make sure the options you pick allow the key to write to the bucket you want to use or it won't work. The name of the bucket is not important.

Next, SSH into your server, put the script onto it via any means (SFTP or cURL probably) and open it in a text editor (like nano) and configure the directory and Backblaze variables.

For the ``DISCORD_WEBHOOK_URL`` variable, open Discord, click on the settings cog beside a channel and then click "Integrations" on the left sidebar followed by the "Webhooks" button and "New Webhook". Note that in servers you don't own you'll need the applicable permissions to do this. Next, set the icon, name, and channel as you wish and then click "Copy Webhook URL". Paste the URL copied to your text editor into the double speech marks for the ``DISCORD_WEBHOOK_URL`` variable.

That's it! Test the script with ``bash backup-script.sh`` and if you see the embed with a green sidebar in Discord it's all working! Open your Buckets page on the Backblaze website and check the zip file stored to ensure it contains all the data you want.

Optionally you can configure a cronjob to run this script automatically at a certain time interval, you can learn more about cronjobs [here](https://www.digitalocean.com/community/tutorial-collections/how-to-use-cron-to-automate-tasks).

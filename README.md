
# Fully Automated Reddit Stories Video Generator & Poster to TikTok, Instagram Reels, and YouTube Shorts


> ⚠️ **Notice:** This project is no longer actively maintained. It remains fully functional, and I'm happy to review and accept pull requests from the community.



## Introduction
This repository contains a fully automated system that generates and posts Reddit stories to three major platforms: TikTok, Instagram Reels, and YouTube Shorts.

### Why Use This?
If you're looking into this, you likely know that 1 million views on TikTok can earn around €20. This tool will automatically produce brain-rotting videos with **zero effort** after the initial setup. With multiple accounts, you can scale this infinitely and potentially make a decent profit.

The base of this project is a heavily modified version of [RedditVideoMakerBot](https://github.com/elebumm/RedditVideoMakerBot). I’ve extended it with features such as:
- Generating **dyslexic-style** one-word captions that grab and retain user attention (simular to the CapCut style subtitles).
- Automated uploaders for TikTok, Instagram Reels, and YouTube Shorts (a highly requested feature not available in the original bot due to ethical/legal concerns).
-  Something extra in there for you, the exta cheap one: **ElevenLabs free tier API key rotator** .


After setup, you can let this brain-rot farm automatically generate passive income.
Sample Results: [MyTikTokProfile](https://www.tiktok.com/@crazystorylord)


## Features
- **Reddit Stories**: Automatically sourced and turned into videos.
- **One-word Captions**: Attention-grabbing text overlays.
- **Uploaders to All platforms**: Fully automated uploads to TikTok, Instagram Reels, and YouTube Shorts.
- **TTS**: ElevenLabs API integration with key rotation, or free unlimited usage with StreamLabs Polly.
- **Modular Config**: with this repo you get my configuration, but feel free to Adjust everything via `config.toml`, you can even delete config.toml and call main.py to generate a brand new config from scratch through the wizzard.

## Installation

> [!WARNING]
> Windows is not fully supported you will need to solve the Python dependency issues you occur, also istagrapi (the unofficial Instagram API used for uploading to Instagram is not available on windows)
>
>  To avoid problems you can use WSL, don`t get me wrong you can set-up the environment in Windows but please DO NOT open any issues in the repo if you are using Windows

### Supported Python Versions
- Python 3.10 or 3.12

### Steps:
1. Set up a virtual environment:
    ```bash
    python3.12 -m venv venvDigger
    source venvDigger/bin/activate
    ```   
naming matter for the Automator.sh script 

2. Install the required dependencies:
    ```bash
    pip install -r requirements.txt
    pip install pydantic==2.7.4     # to fix  dependency mismatch 
    ```


3. Deactivate the virtual environment:
    ```bash
    deactivate
    ```

4. Set up TikTok uploader:
    ```bash
    cd uploaders/TiktokAutoUploader
    python3.12 -m venv .tokvenv
    source .tokvenv/bin/activate
    pip install -r requirements.txt
    ```

    ```bash
    cd uploaders/TiktokAutoUploader/tiktok_uploader/tiktok-signature/
    npm i
    npx playwright install
    ```

### Background Video Setup
Download an undetectable "unoriginal content" Minecraft or other background video with the following command:
```bash
yt-dlp -f 'bestvideo[height=1080]+bestaudio/best' -ciw -o "%(title)s.%(ext)s" <video_url>
```
Place the video inside `assets/backgrounds/video/` and rename it to `bbswitzer-parkour.mp4`.

### Text-to-Speech (TTS)
If you want the best sounding TTS, you will need to use ElevenLabs. The free tier allows for about 5 videos per month, or you can use multiple free-tier API keys with the provided **ElevenLabsKeyRotator** script  (they only want a fresh email adress for you to generate a key :) .

if you want to go the elevenlabs route modify `elevenLabsKeyRotator.py` and put at least 15 api keys in there  (depends on how often you want to upload)

if you dont want to use elevenLabs modify `Automathor.sh` and coment out the execution of `elevenLabsKeyRotator.py`
 - Alternatively, you can use **StreamLabs Polly**, which offers free, unlimited usage  (read next steps).
 - or you can pay for elevenlabs


### Configuration Setup
Generate or modify the `config.toml`:

1. Run the following command to launch the CLI UI and finish your configuration:
     ```bash
    python3 main.py
    ```
- Alternatively, modify the `config.toml` directly. Here’s what you’ll need:
  
   #### **DISCLAIMER**: changing the subreddits will result in a diffrent output folder name , modify the Automator.sh to reflect that  
   - **TTS Engine**: Choose between ElevenLabs or StreamLabs Polly, (if you chose elevenlabs provide one of your keys).
   - **Reddit Credentials**: Visit [Reddit Apps](https://www.reddit.com/prefs/apps) to create your app. Detailed instructions can be found [here](https://reddit-video-maker-bot.netlify.app/docs/configuring).
   - 

## Logins
logins shoud be executed in an enviorment that suports gui to open up a browser, you can run all scripts on some other machine and then transfer the token files to your server (keep in mind that you also need to setup the proper enviorment and pakages) 

### TikTok
1. Navigate to `uploaders/TiktokAutoUploader` and activate the TikTok virtual environment:
    ```bash
    source .tokvenv/bin/activate
    ```
2. Log in:
    ```bash
    python3 cli.py login -n my_tiktok_username
    ```

 If you’re running this on another machine, copy the `CookiesDir` to your server machine.

### Instagram
1. Modify `uploaders/instagram_creds.conf` with your credentials.
2. Upload a test video using the following command:
    ```bash
    python3 uploaders/instaUpload.py "path_to_video" "description"
    ```


**Notes**:
- make sure that your loging in from a know to instagram for you ip address
- the cli migh ask you for an sms code or to enter your password again
- you cant use 2FA. You will need to disable it, if your having problems loging in refer to [instagrapi documentation](https://subzeroid.github.io/instagrapi/).

### YouTube
1. Sign up for YouTube API v3 on Google Cloud Console (free: you can upload one video every 24 hours).
2. Place your `youtube_client_secret.json` in the `uploaders/` folder.
3. Test the setup:
    ```bash
    python3 uploaders/youtubeUpload.py "path_to_video" "description"
    ```
your default browser will open and you will be prompted to log in and authorize access to your YouTube account. Afterward, a `YTtoken.json` file will be generated.
 If you’re running this on another machine, copy the `YTtoken.json` to your server machine.

### Vosk for Captions
If you don’t have 9GB of RAM or swap space, you can switch to Vosk 0.15 small. However, the captions might not be as accurate. To switch models, modify `captionsGen.py` to use `vosk-model-small-en-us-0.15`.

## Running the Full Flow
Once you've tested each component, run the full flow with:
```bash
./RunFullFlowInstant.sh
```

To automate it, create a cron job:
```bash
0 */7 * * * su user -c "/home/user/RedditVideoMakerBot-master/Automator.sh"
```
I recommend setting it to every 7 hours. The `Automator.sh` script also includes a built-in random delay between 2 minutes and 3 hours.

## What next
You can scale up this whole operation and setup multiple enviorments with diffrent accounts, just set them up in a non-interfiaring schedule  


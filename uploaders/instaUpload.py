import argparse
from instagrapi import Client
import configparser
import os
#full release
def login(username, password):
    cl = Client()
    session_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'session.json')

    # If session file exists, load it
    if os.path.exists(session_file):
        try:
            cl.load_settings(session_file)
            cl.login(username, password, relogin=True)
            print("Logged in using session.")
        except Exception as e:
            print(f"Failed to login with session: {e}. Logging in with username and password...")
            cl.login(username, password)
            cl.dump_settings(session_file)
    else:
        # If no session file, login normally and save session
        cl.login(username, password)
        cl.dump_settings(session_file)
        print("Logged in and session saved.")
    
    return cl

def upload_reel(cl, video_path, description):
    try:
        media = cl.clip_upload(video_path, caption=description)
        print(f"Reel uploaded successfully: {media}")
    except Exception as e:
        print(f"Failed to upload reel: {e}")

def main():
    # Load configuration
    config = configparser.ConfigParser()
    script_dir = os.path.dirname(os.path.abspath(__file__))
    config.read(os.path.join(script_dir, 'instagram_creds.conf'))  # Updated to use .conf file

    # Retrieve username and password from config file
    username = config['instagram']['username']
    password = config['instagram']['password']

    # Set up command-line argument parsing
    parser = argparse.ArgumentParser(description="Upload an Instagram Reel from video source.")
    parser.add_argument("video", type=str, help="Path to the video file")
    parser.add_argument("description", type=str, help="Caption for the reel")

    args = parser.parse_args()

    # Log in to Instagram
    cl = login(username, password)
    
    # Upload the reel
    upload_reel(cl, args.video, args.description)

if __name__ == "__main__":
    main()

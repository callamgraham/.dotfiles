#!/home/callam/Projects/streamdeck/bin/python3

#         Python Stream Deck Library
#      Released under the MIT license
#
#   dean [at] fourwalledcubicle [dot] com
#         www.fourwalledcubicle.com
#

# Example script showing basic library usage - updating key images with new
# tiles generated at runtime, and responding to button state change events.

import os
import threading

from PIL import Image, ImageDraw, ImageFont
from StreamDeck.DeviceManager import DeviceManager
from StreamDeck.ImageHelpers import PILHelper
from StreamDeck.Transport.Transport import TransportError

# Folder location of image assets used by this example.
ASSETS_PATH = os.path.join(os.path.dirname(__file__), "Assets")


# Generates a custom tile with run-time generated text and custom image via the
# PIL module.
def render_key_image(deck, icon_filename, font_filename, label_text):
    # Resize the source image asset to best-fit the dimensions of a single key,
    # leaving a margin at the bottom so that we can draw the key title
    # afterwards.
    icon = Image.open(icon_filename)
    image = PILHelper.create_scaled_image(deck, icon, margins=[0, 0, 0, 0])

    # Load a custom TrueType font and use it to overlay the key index, draw key
    # label onto the image a few pixels from the bottom of the key.
    draw = ImageDraw.Draw(image)
    font = ImageFont.load_default()
    draw.text((image.width / 2, image.height - 5), text=label_text, font=font, anchor="ms", fill="white")

    return PILHelper.to_native_format(deck, image)


# Returns styling information for a key based on its position and state.
def get_key_style(deck, key, state):
    # Last button in the example application is the exit button.
    exit_key_index = deck.key_count() - 1

    if key == exit_key_index:
        name = "exit"
        icon = "{}.png".format("Exit")
        font = "arial.ttf"
        label = "Bye" if state else "Exit"
    
    #Mute microphone
    elif key == 10:
        if os.popen("wpctl get-volume @DEFAULT_AUDIO_SOURCE@").read().find("MUTED") >-1:
            icon = "{}.png".format("mic_off")
        else:
            icon = "{}.png".format("mic_on")
            
        name = "emoji"
        font = "arial.ttf"
        label = ""
    # back, play/pause, and forward music
    elif key == 5:
        icon = "{}.png".format("back")
        name = "back"
        font = "arial.ttf"
        label = ""

    elif key == 6:
        icon = "{}.png".format("play")
        name = "play"
        font = "arial.ttf"
        label = ""
    
    elif key == 7:
        icon = "{}.png".format("forward")
        name = "forward"
        font = "arial.ttf"
        label = ""

    else:
        name = "blank"
        icon = "blank.png"
        font = "arial.ttf"
        label = ""

    return {
        "name": name,
        "icon": os.path.join(ASSETS_PATH, icon),
        "font": os.path.join(ASSETS_PATH, font),
        "label": label
    }


# Creates a new key image based on the key index, style and current key state
# and updates the image on the StreamDeck.
def update_key_image(deck, key, state):
    # Determine what icon and label to use on the generated key.
    key_style = get_key_style(deck, key, state)

    # Generate the custom key with the requested image and label.
    image = render_key_image(deck, key_style["icon"], key_style["font"], key_style["label"])

    # Use a scoped-with on the deck to ensure we're the only thread using it
    # right now.
    with deck:
        # Update requested key with the generated image.
        deck.set_key_image(key, image)


# Prints key state change information, updates rhe key image and performs any
# associated actions when a key is pressed.
def key_change_callback(deck, key, state):
    # Print new key state

    # For mute toggles, only activate the callback when button is pressed (not when released)
    if state:
    
        # set key commands
        if key == 5:
            os.system("playerctl previous")

        if key == 6:
            os.system("playerctl play-pause")

        if key == 7:
            os.system("playerctl next")

        if key == 10:
            os.system("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")

    # Update the key image based on the new key state.
    update_key_image(deck, key, state)
    
    # Check if the key is changing to the pressed state.
    if state:
        key_style = get_key_style(deck, key, state)

        # When an exit button is pressed, close the application.
        if key_style["name"] == "exit":
            # Use a scoped-with on the deck to ensure we're the only thread
            # using it right now.
            with deck:
                # Reset deck, clearing all button images.
                deck.reset()

                # Close deck handle, terminating internal worker threads.
                deck.close()


if __name__ == "__main__":
    streamdecks = DeviceManager().enumerate()

    for index, deck in enumerate(streamdecks):
        # This example only works with devices that have screens.
        if not deck.is_visual():
            continue

        deck.open()
        try:
            deck.reset()
        except TransportError:
            deck.close()
            deck.open()
            deck.reset()

            deck.deck_type(), deck.get_serial_number(), deck.get_firmware_version()

        # Set initial screen brightness to 30%.
        deck.set_brightness(30)

        # Set initial key images.
        for key in range(deck.key_count()):
            update_key_image(deck, key, False)

        # Register callback function for when a key state changes.
        deck.set_key_callback(key_change_callback)

        # Wait until all application threads have terminated (for this example,
        # this is when all deck handles are closed).
        for t in threading.enumerate():
            try:
                t.join()
            except RuntimeError:
                pass

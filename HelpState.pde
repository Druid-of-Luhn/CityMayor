/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

class HelpState extends GameState {
  public void input(final char key) {
    switch (key) {
      case BACKSPACE:
        nextAction = GameState.Action.EXIT;
        break;
    }
  }

  public void draw() {
    background(255);
    fill(0);

    PVector offset = new PVector(width / 2, 50);

    textAlign(CENTER, TOP);
    printLine("Help", 72, offset);

    final int fontSize = 18;
    offset.y += fontSize * 2;

    textAlign(LEFT, TOP);
    offset.x = 50;

    printLine("Game Info", fontSize * 1.5, offset);

    final String[] gameInfo = new String[] {
      "You are a city mayor, tasked with building a new city and attracting inhabitants",
      "with the amenities provided. The happier the citizens, the more people will come",
      "and seek a living in your city. Gain money for building through taxes on individual",
      "houses and revenue from shops, offices and entertainment. Provide for your citizens",
      "with shops and cultural buildings to make them stay and to attract more citizens.",
      "Make sure that flats and houses are connected to offices, shops and theatres by",
      "roads, and that there are trees about for your citizens to enjoy the view."
    };
    printLines(gameInfo, fontSize, offset);
    offset.y += fontSize;

    printLine("Menu Controls", fontSize * 1.5, offset);

    final String[] menuControls = new String[] {
      "Cycle through menu items with WASD or the arrow keys, and select a menu item with",
      "the ENTER key, or use the mouse. Return to the previous menu by pressing BACKSPACE.",
      "Leave the game with the ESC key."
    };
    printLines(menuControls, fontSize, offset);
    offset.y += fontSize;

    printLine("Game Controls", fontSize * 1.5, offset);

    final String[] gameControls = new String[] {
      "In the game, use the WASD or arrow keys to pan the camera around the map. Use the",
      "mouse to select items to build from the menu at the top of the screen, and click",
      "to place it (a preview will appear). Borrow money and return your loans with the",
      "buttons. Any action (building, demolishing, borrowing, returning) can be undone or",
      "redone, with a history of 1000 actions."
    };
    printLines(gameControls, fontSize, offset);
  }

  public void resetTransition() {
    nextAction = GameState.Action.NONE;
    nextState = HelpState.class;
  }
}

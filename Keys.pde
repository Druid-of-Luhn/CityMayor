/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

final Keys keys = new Keys();

enum KeyDirection {
  UP
, RIGHT
, DOWN
, LEFT
};

class Keys {
  boolean[] keys = new boolean[] {
    false // UP
  , false // RIGHT
  , false // DOWN
  , false // LEFT
  };

  public void setMovement(final KeyDirection key, final boolean pressed) {
    keys[key.ordinal()] = pressed;
  }

  public boolean isPressed(final KeyDirection key) {
    return keys[key.ordinal()];
  }
}

void keyPressed() {
  if (key == CODED) {
    switch (keyCode) {
      case UP:
        keys.setMovement(KeyDirection.UP, true);
        break;
      case RIGHT:
        keys.setMovement(KeyDirection.RIGHT, true);
        break;
      case DOWN:
        keys.setMovement(KeyDirection.DOWN, true);
        break;
      case LEFT:
        keys.setMovement(KeyDirection.LEFT, true);
        break;
    }
  } else {
    switch (key) {
      case 'w':
        keys.setMovement(KeyDirection.UP, true);
        break;
      case 'd':
        keys.setMovement(KeyDirection.RIGHT, true);
        break;
      case 's':
        keys.setMovement(KeyDirection.DOWN, true);
        break;
      case 'a':
        keys.setMovement(KeyDirection.LEFT, true);
        break;
    }
  }
  // Send the key as input to the current state
  stateManager.input(key);
}

void keyReleased() {
  if (key == CODED) {
    switch (keyCode) {
      case UP:
        keys.setMovement(KeyDirection.UP, false);
        break;
      case RIGHT:
        keys.setMovement(KeyDirection.RIGHT, false);
        break;
      case DOWN:
        keys.setMovement(KeyDirection.DOWN, false);
        break;
      case LEFT:
        keys.setMovement(KeyDirection.LEFT, false);
        break;
    }
  } else {
    switch (key) {
      case 'w':
        keys.setMovement(KeyDirection.UP, false);
        break;
      case 'd':
        keys.setMovement(KeyDirection.RIGHT, false);
        break;
      case 's':
        keys.setMovement(KeyDirection.DOWN, false);
        break;
      case 'a':
        keys.setMovement(KeyDirection.LEFT, false);
        break;
    }
  }
}

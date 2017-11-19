/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

class CreditState extends GameState {
  @Override
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
    final int fontSize = 24;

    textAlign(CENTER, TOP);
    printLine("Credits", fontSize * 3, offset);
    offset.y += fontSize * 2;

    textAlign(LEFT, TOP);
    offset.x = 50;
    final String[] lines = new String[] {
      "'City Mayor' is a game created by Billy Brown",
      "for the University of St Andrews Computer Science",
      "CS4303: Video Games module."
    };
    printLines(lines, fontSize, offset);

    textAlign(LEFT, BOTTOM);
    offset.y = height - 40;
    printLine("press BACKSPACE to return to menu", fontSize * 0.66, offset);
  }

  public void resetTransition() {
    nextAction = GameState.Action.NONE;
    nextState = CreditState.class;
  }
}

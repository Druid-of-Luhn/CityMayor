/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.util.LinkedList;
import java.util.List;

enum MenuInput {
  SELECT, UP, DOWN
}

class MenuState extends GameState {
  private final int fontSize = 48;
  private int selected = 0;
  private final StateTransitionButton[] options = new StateTransitionButton[] {
    new StateTransitionButton("Play", fontSize, BuildState.class),
    new StateTransitionButton("Help", fontSize, HelpState.class),
    new StateTransitionButton("Credits", fontSize, CreditState.class)
  };

  public void click(final float x, final float y) {
    for (final StateTransitionButton option : options) {
      if (option.over(x, y)) {
        nextAction = GameState.Action.ENTER;
        nextState = option.next;
      }
    }
  }

  public void input(final char key) {
    MenuInput action;
    if (key == CODED) {
      switch (keyCode) {
        case UP:
          action = MenuInput.UP;
          codes.add(Konami.UP);
          break;
        case DOWN:
          action = MenuInput.DOWN;
          codes.add(Konami.DOWN);
          break;
        case LEFT:
          codes.add(Konami.LEFT);
          return;
        case RIGHT:
          codes.add(Konami.RIGHT);
          return;
        default:
          return;
      }
    } else {
      switch (key) {
        case ENTER: case RETURN:
          action = MenuInput.SELECT;
          break;
        case 'w':
          action = MenuInput.UP;
          break;
        case 's':
          action = MenuInput.DOWN;
          break;
        case 'a':
          codes.add(Konami.A);
          return;
        case 'b':
          codes.add(Konami.B);
          return;
        default:
          return;
      }
    }
    switch (action) {
      case SELECT:
        nextAction = GameState.Action.ENTER;
        nextState = options[selected].next;
        break;
      case UP:
        selected = (selected + options.length - 1) % options.length;
        break;
      case DOWN:
        selected = (selected + 1) % options.length;
        break;
    }
  }

  public void draw() {
    final int colour = 255;

    drawBackground();

    PVector offset = new PVector(width / 2, 50);

    textAlign(CENTER, TOP);
    fill(0); printLine("City Mayor", fontSize * 1.5, offset.get().add(new PVector(0, 2))); // shadow
    fill(colour);
    printLine("City Mayor", fontSize * 1.5, offset);

    // Display the options
    textAlign(LEFT, TOP);
    textSize(fontSize);
    offset.x -= 160;
    offset.y = 300;
    for (int i = 0; i < options.length; ++i) {
      // Select the option that the mouse is over
      if (options[i].over(offset.get(), mouseX, mouseY)) {
        selected = i;
      }
      // The selected option has a different colour
      fill(0); options[i].draw(offset.get().add(new PVector(0, 2))); // shadow
      if (i == selected) {
        fill(80, 220, 255);
      } else {
        fill(colour);
      }
      options[i].draw(offset.get());
      offset.y += 64;
    }

    checkKonamiCode();
  }

  private PImage bg = null;
  private float ratio = 0f;

  private void drawBackground() {
    if (bg == null) {
      bg = images.getImage("background.jpg");
      ratio = max(width / (float) bg.width, height / (float) bg.height);
      bg.resize((int) (bg.width * ratio), (int) (bg.height * ratio));
    }
    image(bg, 0, 0, bg.width, bg.height);
  }

  public void resetTransition() {
    nextAction = GameState.Action.NONE;
    nextState = MenuState.class;
  }

  List<Konami> codes = new LinkedList<Konami>();
  final Konami[] expected = new Konami[] {
    Konami.UP, Konami.UP, Konami.DOWN, Konami.DOWN,
    Konami.LEFT, Konami.RIGHT, Konami.LEFT, Konami.RIGHT,
    Konami.B, Konami.A
  };

  private void checkKonamiCode() {
    if (!konami && codes.size() >= expected.length) {
      for (int i = 0; i < expected.length; ++i) {
        if (codes.get(codes.size() - expected.length + i) != expected[i]) {
          return;
        }
      }
      konami = true;
    }
  }
}

enum Konami {
  UP, DOWN, LEFT, RIGHT, B, A
}

/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

abstract class GameState {
  enum Action {
    ENTER, REPLACE, EXIT, NONE
  }

  protected Action nextAction;
  protected Class<? extends GameState> nextState;

  public GameState() {
    resetTransition();
  }

  public void enter() {
    // Not required
  }

  public void resume() {
    // Not required
  }

  public void leave() {
    // Not required
  }

  public void pause() {
    // Not required
  }

  public void input(final char key) {
    // Not required
  }

  public void click(final float x, final float y) {
    // Not required
  }

  public void clicked(final float x, final float y) {
    // Not required
  }

  public abstract void draw();

  // This sets nextAction and nextState to their starting values
  public abstract void resetTransition();

  public Action getStateAction() {
    return nextAction;
  }

  public Class<? extends GameState> getNextState() {
    // Only return the next state if the action requires it
    if (nextAction == Action.ENTER ||
        nextAction == Action.REPLACE) {
      return nextState;
    }
    return null;
  }
}

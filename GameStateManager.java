/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.util.Deque;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;

final class GameStateManager {
  final Map<Class<? extends GameState>, GameState> states = new HashMap<Class<? extends GameState>, GameState>();
  // The top of the stack is the current state
  final Deque<GameState> stack = new LinkedList<GameState>();

  public GameStateManager(final GameState[] states) {
    if (states.length > 0) {
      // Set the initial state as the first in the array
      stack.addFirst(states[0]);
    }
    // Place all of the states into the map
    for (final GameState state : states) {
      this.states.put(state.getClass(), state);
    }
  }

  public void input(final char key) {
    // Receive a key press and forward it on
    current().input(key);
  }

  public void click(final float x, final float y) {
    // Send the mouse click coordinates to the current state
    current().click(x, y);
  }

  public void clicked(final float x, final float y) {
    // Send the mouse click coordinates to the current state
    current().clicked(x, y);
  }

  public void draw() {
    // May transition to another state
    transition();
    // The current state updates and draws the game
    current().draw();
  }

  private void transition() {
    // Get the state type to transition to
    final Class<? extends GameState> nextState = current().getNextState();
    // Get the state transition action to be performed
    final GameState.Action nextAction = current().getStateAction();
    // Reset the current state's transition
    current().resetTransition();

    // Determine how to transition (if at all)
    switch (nextAction) {
      case ENTER:
        // Pause the current state will be returned to
        current().pause();
        // Put the next state onto the stack
        stack.addFirst(states.get(nextState));
        // Entering a new state
        current().enter();
        break;

      case REPLACE:
        // Leaving the current state
        current().leave();
        // Remove the current state
        stack.removeFirst();
        // Put the next state onto the stack
        stack.addFirst(states.get(nextState));
        // Entering a new state
        current().enter();
        break;

      case EXIT:
        // Leaving the current state
        current().leave();
        // Leave the current state for the one beneath it
        stack.removeFirst();
        // Resume the new state was never left
        current().resume();
        break;

      case NONE:
        // Do not transition
        break;
    }
  }

  private GameState current() {
    return stack.getFirst();
  }
}

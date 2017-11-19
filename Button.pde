/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

class Button {
  public final String label;
  public final int fontSize;
  public PVector position;
  public PVector dimensions;

  public Button(final String label, final int fontSize) {
    this.label = label;
    this.fontSize = fontSize;
  }

  public void draw(final PVector position) {
    this.position = position;
    textSize(fontSize);
    text(label, position.x, position.y);
  }

  protected void setDimensions() {
    if (dimensions == null) {
      textSize(fontSize);
      dimensions = new PVector(textWidth(label), fontSize);
    }
  }

  public boolean over(final float x, final float y) {
    if (position == null) {
      return false;
    }
    setDimensions();
    return
      x >= position.x &&
      x < position.x + dimensions.x &&
      y >= position.y &&
      y < position.y + dimensions.y;
  }

  public boolean over(final PVector position, final float x, final float y) {
    this.position = position;
    return over(x, y);
  }
}

class StateTransitionButton extends Button {
  public final Class<? extends GameState> next;

  public StateTransitionButton(final String label, final int fontSize, final Class<? extends GameState> next) {
    super(label, fontSize);
    this.next = next;
  }
}

class BackgroundButton extends Button {
  public final int PADDING = 4;

  public BackgroundButton(final String label, final int fontSize) {
    super(label, fontSize);
  }

  @Override
  protected void setDimensions() {
    if (dimensions == null) {
      textSize(fontSize);
      dimensions = new PVector(
          textWidth(label) + 2 * PADDING,
          fontSize + 2 * PADDING);
    }
  }

  @Override
  public void draw(final PVector position) {
    draw(position, 255, 0);
  }

  public void draw(final PVector position, final int fg, final int bg) {
    setDimensions();
    this.position = position.get();
    this.position.x -= PADDING;
    this.position.y -= PADDING / 2;
    noStroke();
    final boolean isOver = over(mouseX, mouseY);
    // Draw the background
    fill(isOver ? fg : bg);
    rect(this.position.x, this.position.y, dimensions.x, dimensions.y);
    // Draw the label
    textSize(fontSize);
    fill(isOver ? bg : fg);
    text(label, position.x, position.y);
  }
}

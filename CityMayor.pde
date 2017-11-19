/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.io.FileReader;
import java.io.IOException;

import com.google.gson.Gson;

static final float CELL_SIZE = 32;

final GameStateManager stateManager = new GameStateManager(new GameState[] {
    new MenuState(),
    new BuildState(),
    new HelpState(),
    new CreditState()
});

final Persistor persistor = new Persistor();
final Images images = new Images();
Costs costs;
BuildingFactory buildingFactory;

void setup() {
  fullScreen();
  try {
    final Gson gson = new Gson();
    costs = gson.fromJson(new FileReader(dataPath("costs.json")), Costs.class);
    buildingFactory = gson.fromJson(new FileReader(dataPath("buildings.json")), BuildingFactory.class);
  } catch (IOException e) {
    System.err.println("Could not load external information. Exiting.");
    System.err.println(e.getMessage());
    System.exit(1);
  }
}

void draw() {
  if (mousePressed) {
    stateManager.click(mouseX, mouseY);
  }
  // Update and draw the game state
  stateManager.draw();
}

void mousePressed() {
  stateManager.clicked(mouseX, mouseY);
}

/*
 * Text display helpers
 */
public void printLine(String line, float fontSize, PVector offset) {
  textSize(fontSize);
  text(line, round(offset.x), round(offset.y));
  offset.y += fontSize * 1.5;
}

public void printLines(String[] lines, float fontSize, PVector offset) {
  for (final String line : lines) {
    printLine(line, fontSize, offset);
  }
}

/*
 * Isometric <--> Cartesian coordinates conversion
 * source: https://gamedevelopment.tutsplus.com/tutorials/creating-isometric-worlds-a-primer-for-game-developers--gamedev-6511
 */
public PVector cartToIso(final PVector coords) {
  return new PVector(
      coords.x - coords.y,
      (coords.x + coords.y) / 2);
}

public PVector isoToCart(final PVector coords) {
  // Not perfect, but good enough
  return new PVector(
      (2 * coords.y + coords.x) / 2 - CELL_SIZE,
      (2 * coords.y - coords.x + CELL_SIZE / 2) / 2);
}

public PVector coordsFromMouse(final float x, final float y, final PVector offset) {
  // Convert the Isometric mouse click coordinates to Cartesian coordinates
  final PVector pos = isoToCart(new PVector(x, y).sub(offset));
  // Shrink them down to the terrain grid level
  pos.x = round(pos.x / CELL_SIZE);
  pos.y = round(pos.y / CELL_SIZE);
  return pos;
}

public boolean tileIsVisible(final PVector coords, final float h) {
  return
    (coords.x + CELL_SIZE * 2 >= 0 || coords.y + h >= 0) &&
    (coords.x <= width || coords.y <= height);
}

boolean konami = false;

/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.util.Collection;
import java.util.LinkedList;

enum BuildAction {
  NONE, BUILDING, ROAD, FOREST, DEMOLISH, VIEW
}

class BuildState extends GameState {
  final int TICK_RATE = 100;
  final float CAMERA_SPEED = 5;
  PVector camera;
  boolean paused = false;
  Terrain terrain;
  History history;
  Bank bank;
  Population population;
  BuildAction buildAction;
  Building nextBuilding;
  final BackgroundButton undo = new BackgroundButton("(u) Undo", 16);
  final BackgroundButton redo = new BackgroundButton("(y) Redo", 16);
  final BackgroundButton pause = new BackgroundButton("(p) Pause", 16);
  final BackgroundButton save = new BackgroundButton("(S) Save", 16);
  final BackgroundButton load = new BackgroundButton("(L) Load", 16);
  final BuildButton[] actions = new BuildButton[] {
    new BuildButton("(q) DONE", BuildAction.NONE),
    new BuildButton("(b) Building", BuildAction.BUILDING),
    new BuildButton("(r) Road", BuildAction.ROAD),
    new BuildButton("(f) Forest", BuildAction.FOREST),
    new BuildButton("(x) Demolish", BuildAction.DEMOLISH),
    new BuildButton("(v) Show/Hide HUD", BuildAction.VIEW)
  };
  final BuildingButton[] buildingActions = new BuildingButton[] {
    new BuildingButton("Flats", 1),
    new BuildingButton("House", 2),
    new BuildingButton("Offices", 3),
    new BuildingButton("Shop", 4),
    new BuildingButton("Theatre", 5)
  };

  public void enter() {
    camera = new PVector(width / 2, 0);
    // Generate the terrain
    terrain = new Terrain(50, 50);
    // Allow undo/redo-ing
    history = new History();
    // The player has access to a bank
    bank = new Bank(4000000, history); // start with £4M
    // Population will be arriving and leaving
    population = new Population();
    // There is currently no building action selected
    buildAction = BuildAction.NONE;
    // There is no next building to build
    nextBuilding = null;
  }

  public void input(final char key) {
    switch (key) {
      // Do nothing for the movement keys
      case 'w': case 'd': case 's': case 'a':
        break;
      case BACKSPACE:
        nextAction = GameState.Action.EXIT; break;
      case 'q':
        buildAction = BuildAction.NONE; break;
      case 'b':
        buildAction = BuildAction.BUILDING; break;
      case 'r':
        buildAction = BuildAction.ROAD; break;
      case 'f':
        buildAction = BuildAction.FOREST; break;
      case 'x':
        buildAction = BuildAction.DEMOLISH; break;
      case 'v':
        buildAction = buildAction == BuildAction.VIEW
          ? BuildAction.NONE
          : BuildAction.VIEW;
        break;
      case 'u':
        history.undo(terrain, bank); break;
      case 'y':
        history.redo(terrain, bank); break;
      case 'S':
        saveGame(1); break;
      case 'L':
        loadGame(1); break;
      case 'p':
        paused = !paused; break;
      default:
        if (buildAction == BuildAction.BUILDING &&
            key >= '1' && key < '1' + buildingActions.length) {
          nextBuilding = buildingFactory.make(
              buildingActions[(int) (key - '1')].name,
              new Coords());
        }
    }
    if (buildAction != BuildAction.BUILDING) {
      nextBuilding = null;
    }
  }

  public void click(final float x, final float y) {
    // Intercept any button clicks
    for (final BuildButton button : actions) {
      if (button.over(x, y)) {
        return;
      }
    }
    for (final BuildingButton button : buildingActions) {
      if (button.over(x, y)) {
        return;
      }
    }
    if (undo.over(x, y) ||
        redo.over(x, y) ||
        pause.over(x, y) ||
        save.over(x, y) ||
        load.over(x, y) ||
        bank.over(x, y)) {
      return;
    }
    // Build
    final TerrainType last = buildTileAtMouse(x, y, true);
    // Randomise the next building model
    if (buildAction == BuildAction.BUILDING) {
      nextBuilding = buildingFactory.make(nextBuilding.name, new Coords());
    }
  }

  @Override
  public void clicked(final float x, final float y) {
    // Handle a button if it was clicked
    for (final BuildButton button : actions) {
      if (button.over(x, y)) {
        // Clicking on a selected action clears the action
        buildAction = buildAction == button.action
          ? BuildAction.NONE
          : button.action;
        if (buildAction != BuildAction.BUILDING) {
          nextBuilding = null;
        }
        return;
      }
    }
    for (final BuildingButton button : buildingActions) {
      if (button.over(x, y)) {
        nextBuilding = buildingFactory.make(button.name, new Coords());
        return;
      }
    }
    if (undo.over(x, y)) {
      history.undo(terrain, bank);
      return;
    }
    if (redo.over(x, y)) {
      history.redo(terrain, bank);
      return;
    }
    if (pause.over(x, y)) {
      paused = !paused;
      return;
    }
    if (save.over(x, y)) {
      saveGame(1);
    }
    if (load.over(x, y)) {
      loadGame(1);
    }
    if (bank.click(x, y)) {
      return;
    }
  }

  public void draw() {
    fill(255);
    if (paused) {
      rect(width / 2 - 60, height / 4, 50, height / 2);
      rect(width / 2 + 60, height / 4, 50, height / 2);
      return;
    }

    background(120);
    textAlign(LEFT, TOP);

    tick();

    updateCamera();

    final TerrainType last = showPreview();
    drawTerrain();
    showCost(new PVector(mouseX, mouseY), last);
    textAlign(LEFT, TOP);
    resetPreview(last);

    if (buildAction != BuildAction.VIEW) {
      final PVector offset = new PVector(12, 12);
      drawButtons(offset);

      population.setDimensions();
      offset.x = width - population.dimensions.x - 12;
      offset.y += actions[0].dimensions.y + 12;
      population.draw(offset);

      bank.setDimensions();
      offset.x = width - bank.dimensions.x - 12;
      offset.y += 20;
      bank.draw(offset);
    }
  }

  private void tick() {
    // Tick every TICK_RATE seconds
    if (frameCount % TICK_RATE != 0) {
      return;
    }
    // Buildings generate income for the bank
    bank.income(terrain.getBuildings());
    // People may arrive or leave
    population.tick(terrain.getBuildings());
  }

  private void updateCamera() {
    final PVector velocity = new PVector(0, 0);
    if (keys.isPressed(KeyDirection.UP)) {
      velocity.y += CAMERA_SPEED;
    }
    if (keys.isPressed(KeyDirection.RIGHT)) {
      velocity.x -= CAMERA_SPEED;
    }
    if (keys.isPressed(KeyDirection.DOWN)) {
      velocity.y -= CAMERA_SPEED;
    }
    if (keys.isPressed(KeyDirection.LEFT)) {
      velocity.x += CAMERA_SPEED;
    }
    velocity.limit(CAMERA_SPEED);
    camera.add(velocity);
  }

  private void drawTerrain() {
    // Iterate over the grid cells
    for (int y = 0; y < terrain.gridHeight; ++y) {
      for (int x = 0; x < terrain.gridWidth; ++x) {
        // Convert the coordinates to isometric screen coordinates
        final PVector pos = new PVector(x * CELL_SIZE, y * CELL_SIZE);
        final PVector coords = cartToIso(pos).add(camera);
        // Get the image to display
        final PImage img = images.getImage(getTileImage(x, y));
        // Only draw it if it is on screen
        if (img != null && tileIsVisible(coords, img.height)) {
          image(img,
              coords.x, coords.y - (img.height - CELL_SIZE),
              img.width, img.height);
        }
      }
    }
  }

  private void drawButtons(PVector offset) {
    // Draw the actions
    for (final BuildButton button : actions) {
      button.draw(offset.get(), 0, 255);
      offset.x += button.dimensions.x + 12;
    }
    // Draw the undo/redo buttons
    undo.draw(offset.get(), 0, 255);
    offset.x += undo.dimensions.x + 12;
    redo.draw(offset.get(), 0, 255);
    offset.x += redo.dimensions.x + 12;
    pause.draw(offset.get(), 0, 255);
    offset.x += pause.dimensions.x + 12;
    save.draw(offset.get(), 0, 255);
    offset.x += save.dimensions.x + 12;
    load.draw(offset.get(), 0, 255);
    offset.x += load.dimensions.x + 12;
    final PVector newOff = offset.get();
    // Draw the building-choice buttons
    if (buildAction == BuildAction.BUILDING) {
      newOff.x = actions[1].position.x;
      newOff.y += actions[1].dimensions.y + 12;
      for (final BuildingButton button : buildingActions) {
        button.draw(newOff.get(), 0, 255);
        newOff.y += button.dimensions.y + 12;
      }
    }
  }

  private TerrainType showPreview() {
    return buildTileAtMouse(mouseX, mouseY, false);
  }

  private void resetPreview(final TerrainType last) {
    // Do not persist the change made for the preview
    final PVector hovered = coordsFromMouse(mouseX, mouseY, camera);
    final Coords pos = new Coords().fromPVector(hovered);
    // If a building was being previewed, remove it
    if (last != TerrainType.BUILDING &&
        terrain.getCell(pos.x, pos.y) == TerrainType.BUILDING) {
      terrain.removeBuilding(pos);
    }
    terrain.setCell(last, pos.x, pos.y);
  }

  private void showCost(final PVector pos, final TerrainType last) {
    textAlign(RIGHT, BOTTOM);
    fill(255, 0, 0);
    final Coords coords = new Coords().fromPVector(coordsFromMouse(pos.x, pos.y, camera));
    final TerrainType next = terrain.getCell(coords);
    final int cost = terrain.cellCost(last, next, nextBuilding);
    if (cost > 0) {
      text(bank.currency.format(cost), pos.x, pos.y);
    }
  }

  private String getTileImage(final int x, final int y) {
    final TerrainType cell = terrain.getCell(x, y);
    switch (cell) {
      case BUILDING:
        Building building = terrain.getBuilding(x, y);
        return building == null
          ? nextBuilding == null
            ? null
            : nextBuilding.sprite
          : building.sprite;
      case ROAD:
        return cell.imageName + terrain.chooseRoad(x, y);
      default:
        return cell.imageName;
    }
  }

  private HistoryState makeTerrainState(final float x, final float y, final TerrainType last) {
    // Save the tile at the given mouse position
    final Coords coords = new Coords().fromPVector(coordsFromMouse(x, y, camera));
    // Get the cell there
    final TerrainType next = terrain.getCell(coords.x, coords.y);
    // Do not save a new state if no change was made
    if (next == last) {
      return null;
    }
    if (last == TerrainType.BUILDING || next == TerrainType.BUILDING) {
      final Building building = terrain.getBuilding(coords);
      return new HistoryState(terrain, last, next, coords, building);
    } else {
      return new HistoryState(terrain, last, next, coords);
    }
  }

  private TerrainType buildTileAtMouse(final float x, final float y, final boolean permanent) {
    // Build a tile at the given mouse position
    final Coords coords = new Coords().fromPVector(coordsFromMouse(x, y, camera));
    // Get the previous cell there
    final TerrainType last = terrain.getCell(coords.x, coords.y);
    TerrainType next = last;
    // Determine what tile to use
    switch (buildAction) {
      case ROAD:
        next = TerrainType.ROAD;
        break;
      case FOREST:
        next = TerrainType.FOREST;
        break;
      case BUILDING:
        if (nextBuilding != null && canBuild(last, TerrainType.BUILDING)) {
          next = TerrainType.BUILDING;
          nextBuilding.position(coords);
          terrain.addBuilding(nextBuilding);
        }
        break;
      case DEMOLISH:
        next = TerrainType.GRASS;
        break;
    }
    if (canBuild(last, next)) {
      // Set the new tile
      terrain.setCell(next, coords.x, coords.y);
      if (permanent) {
        // Pay the amount for the change
        final int cost = terrain.cellCost(last, next, nextBuilding);
        if (cost <= bank.viewBalance() && bank.pay(cost)) {
          // Save the previous terrain state
          history.accept(makeTerrainState(x, y, last));
        } else {
          // If there is not enough money, undo the change
          terrain.setCell(last, coords.x, coords.y);
          terrain.removeBuilding(coords);
        }
      }
    }
    // Return the old tile so it can be undone
    return last;
  }

  private boolean canBuild(final TerrainType on, final TerrainType next) {
    // Buildings cannot be replaced
    return (on != TerrainType.BUILDING) &&
      // Water cannot be built on
      on != TerrainType.WATER &&
      // Do not build the same tile twice
      on != next &&
      // Do not build outside the map
      on != null;
  }

  private void saveGame(int num) {
    persistor.save(num, terrain, bank, population);
  }

  private void loadGame(int num) {
    history = new History();
    terrain = persistor.loadTerrain(num);
    bank = persistor.loadBank(num, history);
    population = persistor.loadPopulation(num);
  }

  public void resetTransition() {
    nextAction = GameState.Action.NONE;
    nextState = BuildState.class;
  }
}

class BuildButton extends BackgroundButton {
  public final BuildAction action;

  public BuildButton(final String label, final BuildAction action) {
    super(label, 16);
    this.action = action;
  }
}

class BuildingButton extends BackgroundButton {
  public final String name;

  public BuildingButton(final String label, final int count) {
    super("(" + count + ") " + label, 16);
    name = label.toLowerCase();
  }
}

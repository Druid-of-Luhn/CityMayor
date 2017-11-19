/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.io.Serializable;
import java.util.Collection;
import java.util.Map;
import java.util.TreeMap;

enum TerrainType {
    GRASS("tile_grass.png")
  , FOREST("tile_forest.png")
  , WATER("tile_water.png")
  , BUILDING("buildings/")
  , ROAD("roads/")
  ;

  public final String imageName;

  private TerrainType(final String name) {
    imageName = name;
  }
}

static class Coords implements Comparable<Coords>, Serializable {
  public int x;
  public int y;

  public Coords() {
    this(0, 0);
  }

  public Coords(final int x, final int y) {
    this.x = x;
    this.y = y;
  }

  public PVector toPVector() {
    return new PVector(x, y);
  }

  public Coords fromPVector(final PVector coords) {
    x = (int) coords.x;
    y = (int) coords.y;
    return this;
  }

  public Coords get() {
    return new Coords(x, y);
  }

  public int compareTo(Coords o) {
    if (x < o.x) {
      return -1;
    }
    if (x > o.x) {
      return 1;
    }
    return y - o.y;
  }
}

class Terrain {
  public final int gridWidth;
  public final int gridHeight;
  private final TerrainType[] grid;
  private final Map<Coords, Building> buildings;

  public Terrain(final int width, final int height) {
    gridWidth = width;
    gridHeight = height;
    grid = new TerrainType[width * height];
    buildings = new TreeMap<Coords, Building>();
    generateTerrain();
  }

  public Terrain(final TerrainModel model) {
    gridWidth = model.gridWidth;
    gridHeight = model.gridHeight;
    grid = model.grid;
    buildings = model.buildings;
  }

  private void generateTerrain() {
    // It is a grassy plain
    for (int i = 0; i < grid.length; ++i) {
      // The map edges are water
      if (i < gridWidth || i >= grid.length - gridWidth ||
          i % gridWidth == 0 || (i + 1) % gridWidth == 0) {
        grid[i] = TerrainType.WATER;
      } else {
        grid[i] = noise((i % gridWidth) / 3, (i / gridWidth) / 3) >= 0.4
          ? TerrainType.GRASS
          : TerrainType.FOREST;
      }
    }
  }

  private int toIndex(final int x, final int y) {
    return y * gridWidth + x;
  }

  public TerrainType getCell(final Coords coords) {
    return getCell(coords.x, coords.y);
  }

  public TerrainType getCell(final int x, final int y) {
    if (x >= 0 && y >= 0 && x < gridWidth && y < gridHeight) {
      return grid[toIndex(x, y)];
    }
    return null;
  }

  public void setCell(final TerrainType cell, final int x, final int y) {
    if (x >= 0 && y >= 0 && x < gridWidth && y < gridHeight) {
      grid[toIndex(x, y)] = cell;
    }
  }

  public int cellCost(TerrainType from, TerrainType to, Building building) {
    int amount = 0;
    if (from == to) {
      return amount;
    }
    if (from != null) {
      switch (from) {
        case ROAD: amount += costs.roadDemolish; break;
        case FOREST: amount += costs.forestCut; break;
        case BUILDING:
           amount += building == null
             ? 0
             : buildingFactory.cost(building.name) / 20;
           break;
        default: break;
      }
    }
    if (to != null) {
      switch (to) {
        case ROAD: amount += costs.roadBuild; break;
        case FOREST: amount += costs.forestPlant; break;
        case BUILDING: amount += buildingFactory.cost(building.name); break;
        default: break;
      }
    }
    return amount;
  }

  public void addBuilding(final Building building) {
    final Coords coords = building.position();
    buildings.put(coords, building);
    setCell(TerrainType.BUILDING, coords.x, coords.y);
  }

  public Building getBuilding(final int x, final int y) {
    return getBuilding(new Coords(x, y));
  }

  public Building getBuilding(final Coords coords) {
    return buildings.get(coords);
  }

  public void removeBuilding(final Coords coords) {
    buildings.remove(coords);
  }

  public Collection<Building> getBuildings() {
    return buildings.values();
  }

  public String chooseRoad(final int x, final int y) {
    int flag = 0;
    if (getCell(x - 1, y) == TerrainType.ROAD) {
      flag += 1; // LEFT
    }
    if (getCell(x, y - 1) == TerrainType.ROAD) {
      flag += 2; // ABOVE
    }
    if (getCell(x + 1, y) == TerrainType.ROAD) {
      flag += 4; // RIGHT
    }
    if (getCell(x, y + 1) == TerrainType.ROAD) {
      flag += 8; // BELOW
    }
    switch (flag) {
      case 1: case 4: case 1 + 4: return "01.png";
      case 2: case 8: case 2 + 8: return "02.png";
      case 1 + 2 + 4: return "04.png";
      case 1 + 2 + 8: return "05.png";
      case 1 + 4 + 8: return "06.png";
      case 2 + 4 + 8: return "07.png";
      case 1 + 8: return "08.png";
      case 1 + 2: return "09.png";
      case 2 + 4: return "10.png";
      case 4 + 8: return "11.png";
      default: case 1 + 2 + 4 + 8: return "03.png";
    }
  }
}

static class TerrainModel implements Serializable {
  public int gridWidth;
  public int gridHeight;
  public TerrainType[] grid;
  public Map<Coords, Building> buildings;

  public TerrainModel(final Terrain terrain) {
    gridWidth = terrain.gridWidth;
    gridHeight = terrain.gridHeight;
    grid = terrain.grid;
    buildings = terrain.buildings;
  }
}

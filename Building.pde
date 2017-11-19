/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.io.Serializable;
import java.util.Map;
import java.util.Random;

enum BuildingProvides {
  WORK, ACCOMMODATION, GOODS, ENTERTAINMENT
}

class BuildingFactory {
  public Map<String, BuildingModel> buildings;

  public Building make(final String name, final Coords position) {
    return buildings.get(name).make(position);
  }

  public int cost(final String name) {
    return buildings.get(name).cost;
  }
}

class BuildingModel {
  public String name;
  public String[] sprites;
  public int capacity;
  public BuildingProvides provides;
  public int cost;
  public int income;
  private transient Random rand;

  public Building make(final Coords position) {
    if (rand == null) {
      rand = new Random();
    }
    return new Building(
        name,
        capacity,
        provides,
        income,
        sprites[rand.nextInt(sprites.length)],
        position);
  }
}

static class Building implements Serializable {
  public final String name;
  public final int capacity;
  public int occupied;
  public final BuildingProvides provides;
  public final int income;
  public final String sprite;
  private final Coords position;

  public Building(String name, int capacity, BuildingProvides provides, int income, String sprite, Coords position) {
    this(name, capacity, 0, provides, income, sprite, position);
  }

  private Building(String name, int capacity, int occupied, BuildingProvides provides, int income, String sprite, Coords position) {
    this.name = name;
    this.capacity = capacity;
    this.occupied = occupied;
    this.provides = provides;
    this.income = income;
    this.sprite = sprite;
    this.position = position.get();
  }

  public void position(final Coords pos) {
    position.x = pos.x;
    position.y = pos.y;
  }

  public Coords position() {
    return position.get();
  }

  public Building get() {
    return new Building(name, capacity, occupied, provides, income, sprite, position);
  }
}

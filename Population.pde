/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.io.Serializable;
import java.util.Collection;
import java.util.Random;

class Population {
  private final int WIN_PADDING = 4;
  private final int FONT_SIZE = 16;
  private final String HAP_LABEL = "Happiness: ";
  private final String POP_LABEL = "Population: ";
  private final String UNEMP_LABEL = "Unemployed: ";
  private final String NOSH_LABEL = "No Shop Access: ";
  private final String NOENT_LABEL = "No Entertainment: ";
  public PVector dimensions;

  // Up to how many people will arrive on a tick
  private final int ARRIVAL = 100;
  private final int HALF_ARRIVAL = ARRIVAL / 2;
  // Up to how many people will leave on a tick
  private final int LEAVING = 150;
  private final int HALF_LEAVING = LEAVING / 2;
  private final Random rand;
  // The current happiness score of the city
  private int happiness = 0;
  // The current population of the city
  private int population = 0;
  // Population that doesn't have a place to go
  private int[] counts = new int[BuildingProvides.values().length];

  public Population() {
    rand = new Random();
  }

  public Population(final PopulationModel model) {
    this();
    happiness = model.happiness;
    population = model.population;
    counts = model.counts;
  }

  public void tick(final Collection<Building> buildings) {
    calculateHappiness();

    // Determine whether people are arriving or leaving
    final int count = happiness >= 0
      ? rand.nextInt(HALF_ARRIVAL) + HALF_ARRIVAL
      : rand.nextInt(HALF_LEAVING) + HALF_LEAVING;

    // People arrive when the happiness is good enough
    if (happiness >= 0 || population == 0) {
      // Update the number of people with nowhere to go
      for (int i = 0; i < counts.length; ++i) {
        counts[i] += count;
      }
      // First work out how many people can live in the city
      final int accIndex = BuildingProvides.ACCOMMODATION.ordinal();
      for (final Building building : buildings) {
        if (building.provides == BuildingProvides.ACCOMMODATION) {
          counts[accIndex] = occupy(building, counts[accIndex]);
        }
      }
      // Turn down any people for whom there is no space
      for (int i = 0; i < counts.length; ++i) {
        if (i != accIndex) {
          counts[i] -= counts[accIndex];
        }
      }
      // Add the amount of people that actually arrived
      population += count - counts[accIndex];
      counts[accIndex] = 0;
      // Now occupy offices, shops and entertainment
      for (final Building building : buildings) {
        final int index = building.provides.ordinal();
        counts[index] = occupy(building, counts[index]);
      }
    } else {
      // Work out how many people without access to anything leave
      final int[] leaving = new int[counts.length];
      for (int i = 0; i < counts.length; ++i) {
        final int temp = counts[i];
        counts[i] -= min(counts[i], count);
        leaving[i] = count - (temp - counts[i]);
      }
      // Then remove the rest from buildings
      for (final Building building : buildings) {
        final int temp = building.occupied;
        final int index = building.provides.ordinal();
        building.occupied -= min(building.occupied, leaving[index]);
        leaving[index] -= temp - building.occupied;
      }
      population -= min(population, count);
    }
  }

  private void calculateHappiness() {
    // Calculate the ratios of lacking amenities
    for (int i = 0; i < counts.length; ++i) {
      final float ratio = counts[i] > 0
        ? (float) counts[i] / (float) population
        : 0;
      // Too many people are unemployed or have no access to shop/theatre
      if (ratio > 0.5) {
        happiness -= population / 8;
      // It's starting to get bad
      } else if (ratio > 0.25) {
        happiness -= population / 15;
      // Between 0.2 and 0.25, people are content,
      // otherwise they are happy
      } else if (ratio < 0.2) {
        happiness += population / 30;
      }
    }
    happiness = min(happiness, population);
  }

  public int occupy(final Building building, final int count) {
    final int diff = building.capacity - building.occupied;
    final int amount = min(diff, count);
    building.occupied += amount;
    return count - amount;
  }

  public void draw(final PVector position) {
    textSize(FONT_SIZE);

    fill(255);
    rect(position.x, position.y, dimensions.x, dimensions.y);
    fill(0);
    position.x += WIN_PADDING;
    position.y += WIN_PADDING;
    printLines(new String[] {
        HAP_LABEL + happiness,
        POP_LABEL + populationCount(),
        UNEMP_LABEL + counts[BuildingProvides.WORK.ordinal()],
        NOSH_LABEL + counts[BuildingProvides.GOODS.ordinal()],
        NOENT_LABEL + counts[BuildingProvides.ENTERTAINMENT.ordinal()]
        }, FONT_SIZE, position);
  }

  public void setDimensions() {
    dimensions = new PVector(
        WIN_PADDING * 2 + (int) max(new float[] {
          textWidth(HAP_LABEL + happiness),
          textWidth(POP_LABEL + populationCount()),
          textWidth(UNEMP_LABEL + counts[BuildingProvides.WORK.ordinal()]),
          textWidth(NOSH_LABEL + counts[BuildingProvides.GOODS.ordinal()]),
          textWidth(NOENT_LABEL + counts[BuildingProvides.ENTERTAINMENT.ordinal()])
        }), WIN_PADDING * 2 + (1 + counts.length) * FONT_SIZE * 1.5);
  }

  public int populationCount() {
    return population;
  }
}

static class PopulationModel implements Serializable {
  public int happiness;
  public int population;
  public int[] counts;

  public PopulationModel(final Population population) {
    happiness = population.happiness;
    this.population = population.population;
    counts = population.counts;
  }
}

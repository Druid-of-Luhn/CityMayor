/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.util.Deque;
import java.util.LinkedList;
import java.util.function.BiConsumer;
import java.util.function.Consumer;

class History implements Consumer<HistoryState> {
  public static final int LIMIT = 1000;
  private final Deque<HistoryState> past = new LinkedList<HistoryState>();
  private final Deque<HistoryState> future = new LinkedList<HistoryState>();

  @Override
  public void accept(HistoryState state) {
    if (state == null) {
      return;
    }
    final HistoryState previous = past.peekFirst();
    // Do not save an identical state
    if (previous == null || !state.equals(previous)) {
      // Save the state difference
      past.addFirst(state);
      // Keep to the limit
      if (past.size() > LIMIT) {
        past.removeLast();
      }
      // Redoing does not make sense after an action is performed
      future.clear();
    }
  }

  public void undo(final Terrain terrain, final Bank bank) {
    final HistoryState last = past.pollFirst();
    if (last != null) {
      // Apply the change to return to the previous state
      last.undo(terrain, bank);
      // Save it for redoing
      future.addFirst(last);
      // Keep to the limit
      if (future.size() > LIMIT) {
        future.removeLast();
      }
    }
  }

  public void redo(final Terrain terrain, final Bank bank) {
    final HistoryState next = future.pollFirst();
    if (next != null) {
      // Apply the change to return to the next state
      next.redo(terrain, bank);
      // Save it for undoing
      past.addFirst(next);
      // Keep to the limit
      if (past.size() > LIMIT) {
        past.removeLast();
      }
    }
  }
}

class HistoryState {
  private final TerrainType from;
  private final TerrainType to;
  private final Coords coords;
  private final Building building;
  private int balance;
  private int borrowed;

  public HistoryState(Terrain terrain, TerrainType from, TerrainType to, Coords coords, Building building, int borrowed) {
    this.from = from;
    this.to = to;
    this.coords = coords;
    this.building = building;
    balance = terrain == null ? 0 : terrain.cellCost(from, to, building);
    this.borrowed = borrowed;
  }

  public HistoryState(Terrain terrain, TerrainType from, TerrainType to, Coords coords, Building building) {
    this(terrain, from, to, coords, building, 0);
  }

  public HistoryState(Terrain terrain, TerrainType from, TerrainType to, Coords coords) {
    this(terrain, from, to, coords, null);
  }

  public HistoryState(int borrowed) {
    this(null, null, null, null, null, borrowed);
  }

  public void undo(Terrain terrain, Bank bank) {
    if (from != null) {
      terrain.setCell(from, coords.x, coords.y);
      if (from == TerrainType.BUILDING) {
        terrain.addBuilding(building);
      } else {
        terrain.removeBuilding(coords);
      }
    }
    if (balance < 0) {
      bank.pay(-balance);
    }
    if (balance > 0) {
      bank.receive(balance);
    }
    if (borrowed < 0) {
      bank.takeLoan(-borrowed);
    }
    if (borrowed > 0) {
      bank.repayLoan(borrowed);
    }
  }

  public void redo(Terrain terrain, Bank bank) {
    if (to != null) {
      terrain.setCell(to, coords.x, coords.y);
      if (to == TerrainType.BUILDING) {
        terrain.addBuilding(building);
      } else {
        terrain.removeBuilding(coords);
      }
    }
    if (balance < 0) {
      bank.receive(-balance);
    }
    if (balance > 0) {
      bank.pay(balance);
    }
    if (borrowed < 0) {
      bank.repayLoan(-borrowed);
    }
    if (borrowed > 0) {
      bank.takeLoan(borrowed);
    }
  }
}

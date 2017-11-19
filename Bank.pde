/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.io.Serializable;
import java.text.NumberFormat;
import java.util.Collection;

class Bank {
  private transient final String BALANCE_LABEL = "Balance: ";
  private transient final String LOANED_LABEL = "Loaned: ";
  private transient final int WIN_PADDING = 4;
  private transient final int FONT_SIZE = 16;
  private transient final int BORROW_AMOUNT = 500000;
  public transient final NumberFormat currency = NumberFormat.getCurrencyInstance();

  private int balance;
  private int loaned;
  private transient History history;

  public transient PVector dimensions;
  private transient final BackgroundButton takeButton;
  private transient final BackgroundButton payButton;

  public Bank(final int loaned, final History history) {
    currency.setMaximumFractionDigits(0);
    balance = loaned;
    this.loaned = loaned;
    this.history = history;
    takeButton = new BackgroundButton("Borrow " + currency.format(BORROW_AMOUNT), FONT_SIZE);
    payButton = new BackgroundButton("Repay " + currency.format(BORROW_AMOUNT), FONT_SIZE);
    if (konami) {
      balance = 1000000000;
      this.loaned = 0;
    }
  }

  public Bank(final BankModel model, final History history) {
    currency.setMaximumFractionDigits(0);
    balance = model.balance;
    loaned = model.loaned;
    this.history = history;
    takeButton = new BackgroundButton("Borrow " + currency.format(BORROW_AMOUNT), FONT_SIZE);
    payButton = new BackgroundButton("Repay " + currency.format(BORROW_AMOUNT), FONT_SIZE);
  }

  public int viewBalance() {
    return balance;
  }

  public int viewLoaned() {
    return loaned;
  }

  public void income(final Collection<Building> buildings) {
    for (final Building building : buildings) {
      switch (building.provides) {
        case WORK:
        case GOODS:
          balance += building.occupied >= building.capacity / 10
            ? building.income
            : 0;
          break;
        case ACCOMMODATION:
          balance += building.occupied / 2 * building.income;
          break;
        case ENTERTAINMENT:
          balance += building.occupied * building.income;
          break;
      }
    }
  }

  public void receive(final int amount) {
    if (amount > 0) {
      balance += amount;
    }
  }

  public boolean pay(final int amount) {
    if (amount > 0 && amount <= balance) {
      balance -= amount;
      return true;
    }
    return false;
  }

  public void takeLoan(final int amount) {
    if (amount > 0) {
      balance += amount;
      loaned += amount;
    }
  }

  public void repayLoan(final int amount) {
    if (amount > 0 && balance >= amount && loaned >= amount) {
      balance -= amount;
      loaned -= amount;
    }
  }

  public void setDimensions() {
    dimensions = new PVector(
        WIN_PADDING * 2 + (int) max(new float[] {
          textWidth(BALANCE_LABEL + currency.format(balance)),
          textWidth(LOANED_LABEL + currency.format(loaned)),
          textWidth(takeButton.label),
          textWidth(payButton.label)
        }),
        WIN_PADDING * 2 + FONT_SIZE * 2 + 12);
  }

  public boolean over(final float x, final float y) {
    return takeButton.over(x, y) || payButton.over(x, y);
  }

  public boolean click(final float x, final float y) {
    if (takeButton.over(x, y)) {
      takeLoan(BORROW_AMOUNT);
      history.accept(new HistoryState(BORROW_AMOUNT));
      return true;
    }
    if (payButton.over(x, y)) {
      repayLoan(BORROW_AMOUNT);
      history.accept(new HistoryState(-BORROW_AMOUNT));
      return true;
    }
    return false;
  }

  public void draw(final PVector position) {
    textSize(FONT_SIZE);

    final String balanceLabel = BALANCE_LABEL + currency.format(balance);
    final String loanedLabel = LOANED_LABEL + currency.format(loaned);

    fill(255);
    rect(position.x, position.y, dimensions.x, dimensions.y);
    fill(0);
    position.x += WIN_PADDING;
    position.y += WIN_PADDING;
    text(balanceLabel, position.x, position.y);
    position.y += FONT_SIZE + WIN_PADDING * 2;
    text(loanedLabel, position.x, position.y);
    position.y += FONT_SIZE + WIN_PADDING * 2;

    if (takeButton.dimensions != null) {
      position.x = width - takeButton.dimensions.x - 12 + takeButton.PADDING;
    }
    position.y += WIN_PADDING + 12;
    takeButton.draw(position, 0, 255);
    if (payButton.dimensions != null) {
      position.x = width - payButton.dimensions.x - 12 + payButton.PADDING;
    }
    position.y += takeButton.dimensions.y + 12;
    payButton.draw(position, 0, 255);
  }
}

static class BankModel implements Serializable {
  public int balance;
  public int loaned;

  public BankModel(final Bank bank) {
    balance = bank.balance;
    loaned = bank.loaned;
  }
}

/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.io.*;

class Persistor {
  public final String home = System.getProperty("user.home");
  public final String dir = home + File.separator + "Desktop";

  public boolean save(int num, Terrain terrain, Bank bank, Population pop) {
    FileOutputStream tfout = null;
    ObjectOutputStream toout = null;
    FileOutputStream bfout = null;
    ObjectOutputStream boout = null;
    FileOutputStream pfout = null;
    ObjectOutputStream poout = null;

    try {
      tfout = new FileOutputStream(makeTerrainName(num));
      toout = new ObjectOutputStream(tfout);
      bfout = new FileOutputStream(makeBankName(num));
      boout = new ObjectOutputStream(bfout);
      pfout = new FileOutputStream(makePopName(num));
      poout = new ObjectOutputStream(pfout);

      toout.writeObject(new TerrainModel(terrain));
      boout.writeObject(new BankModel(bank));
      poout.writeObject(new PopulationModel(pop));

    } catch (IOException e) {
      System.err.println(e.getMessage());
      return false;

    } finally {
      try {
        poout.close();
        pfout.close();
        boout.close();
        bfout.close();
        toout.close();
        tfout.close();
      } catch (Exception e) {
        // Nothing can be done
        System.err.println("IO not working");
        System.exit(1);
      }
    }
    return true;
  }

  private Object loadObject(final String filename) {
    FileInputStream fin = null;
    ObjectInputStream oin = null;

    try {
      fin = new FileInputStream(filename);
      oin = new ObjectInputStream(fin);

      return oin.readObject();

    } catch (Exception e) {
      System.err.println("error loading " + filename);
      System.err.println(e.getMessage());
      return null;

    } finally {
      try {
        oin.close();
        fin.close();
      } catch (Exception e) {
        // Nothing can be done
        System.err.println("IO not working");
        System.exit(1);
      }
    }
  }

  public Terrain loadTerrain(int num) {
    return new Terrain((TerrainModel) loadObject(makeTerrainName(num)));
  }

  public Bank loadBank(int num, History history) {
    return new Bank((BankModel) loadObject(makeBankName(num)), history);
  }

  public Population loadPopulation(int num) {
    return new Population((PopulationModel) loadObject(makePopName(num)));
  }

  private String makeTerrainName(int num) {
    return dir + File.separator + num + "-terrain.ser";
  }

  private String makeBankName(int num) {
    return dir + File.separator + num + "-bank.ser";
  }

  private String makePopName(int num) {
    return dir + File.separator + num + "-population.ser";
  }
}

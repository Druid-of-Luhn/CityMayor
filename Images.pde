/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.util.HashMap;
import java.util.Map;

class Images {
  private final Map<String, PImage> images = new HashMap<String, PImage>();

  public void addImage(final String name, final PImage image) {
    images.put(name, image);
  }

  public PImage getImage(final String name) {
    PImage img = images.get(name);
    // If an image is not present, try fetching it first
    if (img == null && name != null) {
      img = loadImage(name);
      if (img == null) {
        return null;
      }
      addImage(name, img);
    }
    return img;
  }
}

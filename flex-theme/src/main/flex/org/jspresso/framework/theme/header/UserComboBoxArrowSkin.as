/*
 * Copyright (c) 2005-2015 Vincent Vandenschrick. All rights reserved.
 *
 *  This file is part of the Jspresso framework.
 *
 *  Jspresso is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Jspresso is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with Jspresso.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.jspresso.framework.theme.header {

import flash.display.Graphics;

import mx.skins.halo.ComboBoxArrowSkin;

public class UserComboBoxArrowSkin extends ComboBoxArrowSkin {
  private static const ARROW_WIDTH:uint = 6;
  private static const ARROW_HEIGHT:uint = 4;

  public function UserComboBoxArrowSkin() {
    super();
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    super.updateDisplayList(w, h);

    var alphaValue:Number = (name.indexOf("over") != -1) ? 0.60 : 0.25;

    var g:Graphics = this.graphics;

    g.clear();
    // background
    g.beginFill(0x000000, alphaValue);
    g.drawRoundRect(0, 0, w, h, 2, 2);

    var startX:Number = w - 15;
    var startY:Number = (h - ARROW_HEIGHT) * 0.5;
    // arrow
    g.beginFill(getStyle("color"), 1.0);
    g.moveTo(startX, startY);
    g.lineTo(startX + ARROW_WIDTH, startY);
    g.lineTo(startX + (ARROW_WIDTH * 0.5), startY + ARROW_HEIGHT);
    g.lineTo(startX, startY);

    g.endFill();
  }
}
}

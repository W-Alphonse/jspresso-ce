/*
 * Copyright (c) 2005-2008 Vincent Vandenschrick. All rights reserved.
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
package org.jspresso.framework.gui.remote;

import java.util.List;

/**
 * A container with stacked children views.
 * <p>
 * Copyright (c) 2005-2008 Vincent Vandenschrick. All rights reserved.
 * <p>
 * This file is part of the Jspresso framework. Jspresso is free software: you
 * can redistribute it and/or modify it under the terms of the GNU Lesser
 * General Public License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version. Jspresso is
 * distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details. You should have received a copy of the GNU Lesser General Public
 * License along with Jspresso. If not, see <http://www.gnu.org/licenses/>.
 * <p>
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public class RCardContainer extends RContainer {

  private List<String> cardNames;
  private List<RComponent> cards;

  /**
   * Constructs a new <code>RCardContainer</code> instance.
   * 
   * @param guid
   *          the guid
   */
  public RCardContainer(String guid) {
    super(guid);
  }

  
  /**
   * Gets the cardNames.
   * 
   * @return the cardNames.
   */
  public List<String> getCardNames() {
    return cardNames;
  }

  
  /**
   * Sets the cardNames.
   * 
   * @param cardNames the cardNames to set.
   */
  public void setCardNames(List<String> cardNames) {
    this.cardNames = cardNames;
  }

  
  /**
   * Gets the cards.
   * 
   * @return the cards.
   */
  public List<RComponent> getCards() {
    return cards;
  }

  
  /**
   * Sets the cards.
   * 
   * @param cards the cards to set.
   */
  public void setCards(List<RComponent> cards) {
    this.cards = cards;
  }
}

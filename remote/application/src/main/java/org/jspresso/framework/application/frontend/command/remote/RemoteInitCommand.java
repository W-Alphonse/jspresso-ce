/*
 * Copyright (c) 2005-2013 Vincent Vandenschrick. All rights reserved.
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
package org.jspresso.framework.application.frontend.command.remote;

import org.jspresso.framework.gui.remote.RAction;
import org.jspresso.framework.gui.remote.RActionList;
import org.jspresso.framework.util.gui.Dimension;

/**
 * Displays the application frame on the client peer.
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public class RemoteInitCommand extends RemoteCommand {

  private static final long serialVersionUID = -5984969345298629961L;

  private RActionList[]     actions;
  private RActionList[]     secondaryActions;
  private RActionList[]     navigationActions;
  private RActionList[]     helpActions;
  private RActionList       workspaceActions;
  private RAction           exitAction;
  private String[]          workspaceNames;
  private Dimension         size;

  /**
   * Gets the actions.
   * 
   * @return the actions.
   */
  public RActionList[] getActions() {
    return actions;
  }

  /**
   * Gets the helpActions.
   * 
   * @return the helpActions.
   */
  public RActionList[] getHelpActions() {
    return helpActions;
  }

  /**
   * Gets the workspaceActions.
   * 
   * @return the workspaceActions.
   */
  public RActionList getWorkspaceActions() {
    return workspaceActions;
  }

  /**
   * Gets the workspaceNames.
   * 
   * @return the workspaceNames.
   */
  public String[] getWorkspaceNames() {
    return workspaceNames;
  }

  /**
   * Sets the actions.
   * 
   * @param actions
   *          the actions to set.
   */
  public void setActions(RActionList... actions) {
    this.actions = actions;
  }

  /**
   * Sets the helpActions.
   * 
   * @param helpActions
   *          the helpActions to set.
   */
  public void setHelpActions(RActionList... helpActions) {
    this.helpActions = helpActions;
  }

  /**
   * Sets the workspaceActions.
   * 
   * @param workspaceActions
   *          the workspaceActions to set.
   */
  public void setWorkspaceActions(RActionList workspaceActions) {
    this.workspaceActions = workspaceActions;
  }

  /**
   * Sets the workspaceNames.
   * 
   * @param workspaceNames
   *          the workspaceNames to set.
   */
  public void setWorkspaceNames(String... workspaceNames) {
    this.workspaceNames = workspaceNames;
  }

  /**
   * Gets the navigationActions.
   * 
   * @return the navigationActions.
   */
  public RActionList[] getNavigationActions() {
    return navigationActions;
  }

  /**
   * Sets the navigationActions.
   * 
   * @param navigationActions
   *          the navigationActions to set.
   */
  public void setNavigationActions(RActionList... navigationActions) {
    this.navigationActions = navigationActions;
  }

  /**
   * Gets the exitAction.
   * 
   * @return the exitAction.
   */
  public RAction getExitAction() {
    return exitAction;
  }

  /**
   * Sets the exitAction.
   * 
   * @param exitAction
   *          the exitAction to set.
   */
  public void setExitAction(RAction exitAction) {
    this.exitAction = exitAction;
  }

  /**
   * Gets the secondaryActions.
   * 
   * @return the secondaryActions.
   */
  public RActionList[] getSecondaryActions() {
    return secondaryActions;
  }

  /**
   * Sets the secondaryActions.
   * 
   * @param secondaryActions
   *          the secondaryActions to set.
   */
  public void setSecondaryActions(RActionList... secondaryActions) {
    this.secondaryActions = secondaryActions;
  }

  /**
   * Gets the size.
   * 
   * @return the size.
   */
  public Dimension getSize() {
    return size;
  }

  /**
   * Sets the size.
   * 
   * @param size
   *          the size to set.
   */
  public void setSize(Dimension size) {
    this.size = size;
  }
}

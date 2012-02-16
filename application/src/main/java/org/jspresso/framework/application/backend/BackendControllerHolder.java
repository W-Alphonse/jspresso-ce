/*
 * Copyright (c) 2005-2012 Vincent Vandenschrick. All rights reserved.
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
package org.jspresso.framework.application.backend;

import javax.servlet.http.HttpSession;

import org.jspresso.framework.util.http.HttpRequestHolder;

/**
 * Holds the current thread backend controller.
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public final class BackendControllerHolder {

  private static boolean                               isWebContext                   = false;
  /**
   * <code>CURRENT_BACKEND_CONTROLLER_KEY</code>.
   */
  public static final String                           CURRENT_BACKEND_CONTROLLER_KEY = "CURRENT_BACKEND_CONTROLLER";
  private static final ThreadLocal<IBackendController> THREADBOUND_BACKEND_CONTROLLER = new ThreadLocal<IBackendController>();
  static {
    try {
      Class.forName("org.jspresso.framework.util.http.HttpRequestHolder");
      isWebContext = true;
    } catch (Throwable ex) {
      isWebContext = false;
    }
  }

  private BackendControllerHolder() {
    // Helper constructor.
  }

  /**
   * Sets the tread-bound backend controller.
   * 
   * @param controller
   *          the tread-bound backend controller.
   */
  public static void setCurrentBackendController(IBackendController controller) {
    // First try to bind to the HttpSession
    if (isWebContext && HttpRequestHolder.isAvailable()) {
      HttpSession session = HttpRequestHolder.getServletRequest().getSession();
      if (session != null) {
        session.setAttribute(CURRENT_BACKEND_CONTROLLER_KEY, controller);
      }
    } else {
      THREADBOUND_BACKEND_CONTROLLER.set(controller);
    }
  }

  /**
   * Gets the tread-bound backend controller.
   * 
   * @return the tread-bound backend controller.
   */
  public static IBackendController getCurrentBackendController() {
    IBackendController controller = null;
    // First lookup into the HTTP session
    if (isWebContext && HttpRequestHolder.isAvailable()) {
      HttpSession session = HttpRequestHolder.getServletRequest().getSession();
      if (session != null) {
        controller = (IBackendController) session
            .getAttribute(CURRENT_BACKEND_CONTROLLER_KEY);
      }
    } else {
      controller = THREADBOUND_BACKEND_CONTROLLER.get();
    }
    return controller;
  }
}
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
package org.jspresso.framework.model.component;

import org.jspresso.framework.util.exception.NestedRuntimeException;

/**
 * This exception is thrown whenever an unexpected exception occurs on an
 * entity.
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public class ComponentException extends NestedRuntimeException {

  private static final long serialVersionUID = -3659844614276359719L;

  /**
   * Constructs a new <code>ComponentException</code> instance.
   * 
   * @param message
   *            the exception message.
   */
  public ComponentException(String message) {
    super(message);
  }

  /**
   * Constructs a new <code>ComponentException</code> instance.
   * 
   * @param nestedException
   *            the nested exception.
   */
  public ComponentException(Throwable nestedException) {
    super(nestedException);
  }

  /**
   * Constructs a new <code>ComponentException</code> instance.
   * 
   * @param nestedException
   *            the nested exception.
   * @param message
   *            the exception message.
   */
  public ComponentException(Throwable nestedException, String message) {
    super(nestedException, message);
  }
}

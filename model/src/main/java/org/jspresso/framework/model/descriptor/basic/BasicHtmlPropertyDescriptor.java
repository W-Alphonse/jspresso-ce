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
package org.jspresso.framework.model.descriptor.basic;

import org.jspresso.framework.model.descriptor.IHtmlPropertyDescriptor;

/**
 * Describes a property as handing HTML content. This instructs Jspresso to
 * display the property value as HTML instead of raw text content.
 * 
 * @author Vincent Vandenschrick
 */
public class BasicHtmlPropertyDescriptor extends BasicTextPropertyDescriptor
    implements IHtmlPropertyDescriptor {

  /**
   * Overridden to disable sorting by default.
   * <p>
   * {@inheritDoc}
   */
  @Override
  protected boolean getDefaultSortablility() {
    return false;
  }
}

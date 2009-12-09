/*
 * Copyright (c) 2005-2009 Vincent Vandenschrick. All rights reserved.
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
package org.jspresso.framework.application.frontend.action.module;

import java.util.Collections;
import java.util.Map;

import org.jspresso.framework.action.IActionHandler;
import org.jspresso.framework.application.frontend.action.FrontendAction;
import org.jspresso.framework.application.model.Module;
import org.jspresso.framework.binding.ConnectorHelper;
import org.jspresso.framework.binding.ICollectionConnector;
import org.jspresso.framework.binding.ICollectionConnectorProvider;
import org.jspresso.framework.binding.IValueConnector;

/**
 * A simple action that selects the module parent in the module navigator.
 * 
 * @version $LastChangedRevision: 2097 $
 * @author Vincent Vandenschrick
 * @param <E>
 *          the actual gui component type used.
 * @param <F>
 *          the actual icon type used.
 * @param <G>
 *          the actual action type used.
 */
public class ParentModuleConnectorSelectionAction<E, F, G> extends
    FrontendAction<E, F, G> {

  /**
   * Retrieves the parent connector and selects it.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public boolean execute(IActionHandler actionHandler,
      Map<String, Object> context) {
    Module parentModule = ((Module) getModuleConnector(context)
        .getConnectorValue()).getParent();
    IValueConnector parentConnector = getModuleConnector(context)
        .getParentConnector();
    if (parentModule != null) {
      ICollectionConnector parentCollectionConnector = ((ICollectionConnectorProvider) parentConnector)
          .getCollectionConnector();
      parentCollectionConnector.setSelectedIndices(new int[0]);
      ICollectionConnector grandParentModuleCollectionConnector = ((ICollectionConnectorProvider) parentConnector
          .getParentConnector().getParentConnector()).getCollectionConnector();
      grandParentModuleCollectionConnector.setSelectedIndices(ConnectorHelper
          .getIndicesOf(grandParentModuleCollectionConnector, Collections
              .singleton(parentModule)));
    }
    return super.execute(actionHandler, context);
  }
}

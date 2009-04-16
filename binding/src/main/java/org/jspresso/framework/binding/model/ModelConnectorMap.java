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
package org.jspresso.framework.binding.model;

import org.jspresso.framework.binding.ConnectorMap;
import org.jspresso.framework.binding.IValueConnector;
import org.jspresso.framework.model.descriptor.IComponentDescriptor;

/**
 * Serves as an auto-generating ConnectorMap for bean models. It may also be
 * used to hold a map model in a MVC pattern.
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
public class ModelConnectorMap extends ConnectorMap {

  private IModelConnectorFactory modelConnectorFactory;

  /**
   * Constructs a new instance based on the model class passed as parameter.
   * 
   * @param parentConnector
   *          the model connector holding the connector map.
   * @param modelConnectorFactory
   *          the factory used to create the model connectors.
   */
  ModelConnectorMap(ModelRefPropertyConnector parentConnector,
      IModelConnectorFactory modelConnectorFactory) {
    super(parentConnector);
    this.modelConnectorFactory = modelConnectorFactory;
  }

  /**
   * This method implements connector auto creation. If a connector with the
   * <code>connectorId</code> doesn't already exist, a new one is created using
   * the <code>IModelConnectorFactory</code> and register it as
   * <code>IModelChangeListener</code>.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public IValueConnector getConnector(String connectorId) {
    IValueConnector connector = super.getConnector(connectorId);
    if (connector == null) {
      IComponentDescriptor<?> componentDescriptor = getParentConnector()
          .getModelDescriptor().getComponentDescriptor();
      if (componentDescriptor != null) {
        connector = modelConnectorFactory.createModelConnector(connectorId,
            componentDescriptor.getPropertyDescriptor(connectorId));
        super.addConnector(connectorId, connector);
      }
    }
    return connector;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected ModelRefPropertyConnector getParentConnector() {
    return (ModelRefPropertyConnector) super.getParentConnector();
  }
}

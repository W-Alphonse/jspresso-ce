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
package org.jspresso.framework.binding.remote;

import java.util.ArrayList;

import org.jspresso.framework.binding.ICollectionConnector;
import org.jspresso.framework.binding.basic.BasicCollectionConnectorProvider;
import org.jspresso.framework.gui.remote.RIcon;
import org.jspresso.framework.state.remote.IRemoteStateOwner;
import org.jspresso.framework.state.remote.RemoteCompositeValueState;
import org.jspresso.framework.state.remote.RemoteValueState;
import org.jspresso.framework.util.automation.IPermIdSource;
import org.jspresso.framework.util.remote.IRemotePeer;
import org.jspresso.framework.util.resources.server.ResourceProviderServlet;

/**
 * The server peer of a remote collection connector provider.
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public class RemoteCollectionConnectorProvider extends
    BasicCollectionConnectorProvider implements IRemotePeer, IRemoteStateOwner,
    IPermIdSource {

  private String                    permId;
  private final RemoteConnectorFactory    connectorFactory;
  private String                    guid;
  private RemoteCompositeValueState state;

  /**
   * Constructs a new <code>RemoteCollectionConnectorProvider</code> instance.
   * 
   * @param id
   *          the connector id.
   * @param connectorFactory
   *          the remote connector factory.
   */
  public RemoteCollectionConnectorProvider(String id,
      RemoteConnectorFactory connectorFactory) {
    super(id);
    this.guid = connectorFactory.generateGUID();
    this.connectorFactory = connectorFactory;
    connectorFactory.register(this);
  }

  /**
   * Returns the actual connector value.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public Object actualValue() {
    return getConnectorValue();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public RemoteCollectionConnectorProvider clone() {
    return clone(getId());
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public RemoteCollectionConnectorProvider clone(String newConnectorId) {
    RemoteCollectionConnectorProvider clonedConnector = (RemoteCollectionConnectorProvider) super
        .clone(newConnectorId);
    clonedConnector.guid = connectorFactory.generateGUID();
    clonedConnector.state = null;
    connectorFactory.attachListeners(clonedConnector);
    connectorFactory.register(clonedConnector);
    return clonedConnector;
  }

  /**
   * Gets the permId.
   * 
   * @return the permId.
   */
  @Override
  public String getPermId() {
    if (permId != null) {
      return permId;
    }
    return getId();
  }

  /**
   * Gets the guid.
   * 
   * @return the guid.
   */
  @Override
  public String getGuid() {
    return guid;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public RemoteCompositeValueState getState() {
    if (state == null) {
      state = createState();
      synchRemoteState();
    }
    return state;
  }

  /**
   * Sets the permanent identifier to this application element. Permanent
   * identifiers are used by different framework parts, like dynamic security or
   * record/replay controllers to uniquely identify an application element.
   * Permanent identifiers are generated by the SJS build based on the element
   * id but must be explicitely set if Spring XML is used.
   * 
   * @param permId
   *          the permId to set.
   */
  @Override
  public void setPermId(String permId) {
    this.permId = permId;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void synchRemoteState() {
    RemoteCompositeValueState currentState = getState();
    currentState.setValue(getDisplayValue());
    currentState.setReadable(isReadable());
    currentState.setWritable(isWritable());
    currentState.setDescription(getDisplayDescription());
    currentState.setIconImageUrl(ResourceProviderServlet
        .computeImageResourceDownloadUrl(getDisplayIcon(), RIcon.DEFAULT_DIM));
  }

  /**
   * Creates a new state instance rerpesenting this connector.
   * 
   * @return the newly created state.
   */
  protected RemoteCompositeValueState createState() {
    RemoteCompositeValueState createdState = connectorFactory
        .createRemoteCompositeValueState(getGuid(), getPermId());
    ICollectionConnector collectionConnector = getCollectionConnector();
    if (collectionConnector instanceof RemoteCollectionConnector) {
      createdState.setChildren(new ArrayList<RemoteValueState>(
          ((RemoteCollectionConnector) collectionConnector).getState()
              .getChildren()));
    }
    return createdState;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void setValueFromState(Object stateValue) {
    setConnectorValue(stateValue);
  }
}

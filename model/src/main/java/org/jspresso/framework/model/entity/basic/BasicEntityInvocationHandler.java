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
package org.jspresso.framework.model.entity.basic;

import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.jspresso.framework.model.component.IComponent;
import org.jspresso.framework.model.component.IComponentCollectionFactory;
import org.jspresso.framework.model.component.IComponentExtensionFactory;
import org.jspresso.framework.model.component.IComponentFactory;
import org.jspresso.framework.model.component.basic.AbstractComponentInvocationHandler;
import org.jspresso.framework.model.descriptor.IComponentDescriptor;
import org.jspresso.framework.model.entity.IEntity;
import org.jspresso.framework.util.accessor.IAccessorFactory;

/**
 * This is the core implementation of all entities in the application. Instances
 * of this class serve as handlers for proxies representing the entities.
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public class BasicEntityInvocationHandler extends
    AbstractComponentInvocationHandler {

  private static final long   serialVersionUID = 6078989823404409653L;

  private final Map<String, Object> properties;
  private int                 hashCode;

  /**
   * Constructs a new <code>BasicEntityInvocationHandler</code> instance.
   * 
   * @param entityDescriptor
   *          The descriptor of the proxy entity.
   * @param inlineComponentFactory
   *          the factory used to create inline components.
   * @param collectionFactory
   *          The factory used to create empty entity collections from
   *          collection getters.
   * @param accessorFactory
   *          The factory used to access proxy properties.
   * @param extensionFactory
   *          The factory used to create entity extensions based on their
   *          classes.
   */
  protected BasicEntityInvocationHandler(
      IComponentDescriptor<IEntity> entityDescriptor,
      IComponentFactory inlineComponentFactory,
      IComponentCollectionFactory collectionFactory,
      IAccessorFactory accessorFactory,
      IComponentExtensionFactory extensionFactory) {
    super(entityDescriptor, inlineComponentFactory, collectionFactory,
        accessorFactory, extensionFactory);
    this.properties = createPropertyMap();
    this.hashCode = -1;
  }

  /**
   * Handles methods invocations on the entity proxy. Either : <li>delegates to
   * one of its extension if the accessed property is registered as being part
   * of an extension <li>handles property access internally
   * <p>
   * {@inheritDoc}
   */
  @Override
  public synchronized Object invoke(Object proxy, Method method, Object[] args)
      throws Throwable {
    String methodName = method.getName();
    if ("isPersistent".equals(methodName)) {
      Integer version = ((IEntity) proxy).getVersion();
      return version != null
          && !IEntity.DELETED_VERSION.equals(version);
    }
    return super.invoke(proxy, method, args);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected boolean computeEquals(IComponent proxy, Object another) {
    if (proxy == another) {
      return true;
    }
    Object id = straightGetProperty(proxy, IEntity.ID);
    if (id == null) {
      return false;
    }
    if (another instanceof IEntity) {
      Object otherId;
      Class<?> otherContract;

      if (Proxy.isProxyClass(another.getClass())
          && Proxy.getInvocationHandler(another) instanceof BasicEntityInvocationHandler) {
        BasicEntityInvocationHandler otherInvocationHandler = (BasicEntityInvocationHandler) Proxy
            .getInvocationHandler(another);
        otherContract = otherInvocationHandler.getComponentContract();
        otherId = otherInvocationHandler.straightGetProperty(proxy, IEntity.ID);
      } else {
        otherContract = ((IEntity) another).getComponentContract();
        otherId = ((IEntity) another).getId();
      }
      return new EqualsBuilder().append(getComponentContract(), otherContract)
          .append(id, otherId).isEquals();
    }
    return false;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected int computeHashCode(IComponent proxy) {
    if (hashCode == -1) {
      Object id = straightGetProperty(proxy, IEntity.ID);
      if (id == null) {
        throw new NullPointerException(
            "Id must be assigned on the entity before its hashcode can be used.");
      }
      hashCode = new HashCodeBuilder(3, 17).append(id).toHashCode();
    }
    return hashCode;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected IComponent decorateReferent(IComponent referent,
      IComponentDescriptor<? extends IComponent> referentDescriptor) {
    return referent;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected Object retrievePropertyValue(String propertyName) {
    return properties.get(propertyName);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected void storeProperty(String propertyName, Object propertyValue) {
    properties.put(propertyName, propertyValue);
  }

  private Map<String, Object> createPropertyMap() {
    return new HashMap<String, Object>();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected void markDeleted(Object proxy) {
    ((IEntity) proxy).straightSetProperty(IEntity.VERSION,
        IEntity.DELETED_VERSION);
    super.markDeleted(proxy);
  }
}

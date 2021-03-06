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
package org.jspresso.framework.application.backend.persistence.hibernate;

import java.io.Serializable;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

import org.hibernate.collection.spi.PersistentCollection;
import org.hibernate.proxy.HibernateProxy;
import org.hibernate.proxy.LazyInitializer;
import org.hibernate.type.Type;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.jspresso.framework.application.backend.BackendControllerHolder;
import org.jspresso.framework.application.backend.IBackendController;
import org.jspresso.framework.model.component.ILifecycleCapable;
import org.jspresso.framework.model.entity.IEntity;
import org.jspresso.framework.model.entity.IEntityLifecycleHandler;
import org.jspresso.framework.model.persistence.hibernate.EntityProxyInterceptor;
import org.jspresso.framework.model.persistence.hibernate.entity.HibernateEntityRegistry;
import org.jspresso.framework.security.UserPrincipal;
import org.jspresso.framework.util.bean.PropertyHelper;

/**
 * Hibernate session interceptor aware of a backend controller to deal with
 * uniqueness of entity instances across the JVM.
 *
 * @author Vincent Vandenschrick
 */
@SuppressWarnings("rawtypes")
public class ControllerAwareEntityProxyInterceptor extends EntityProxyInterceptor {

  private static final long serialVersionUID = -6834992000307471098L;

  private static final Logger LOG = LoggerFactory.getLogger(ControllerAwareEntityProxyInterceptor.class);

  /**
   * Uses the backend controller to retrieve the dirty properties of the entity.
   * <p/>
   * {@inheritDoc}
   */
  @Override
  public int[] findDirty(Object entity, Serializable id, Object[] currentState, Object[] previousState,
                         String[] propertyNames, Type[] types) {
    if (entity instanceof IEntity) {
      Map<String, Object> dirtyProperties = getBackendController().getDirtyProperties((IEntity) entity, false);
      boolean hasJustBeenSaved = false;
      if (dirtyProperties != null) {
        hasJustBeenSaved = dirtyProperties.containsKey(IEntity.VERSION) && dirtyProperties.get(IEntity.VERSION) == null;
        dirtyProperties.remove(IEntity.VERSION);
      }
      if (dirtyProperties == null) {
        return null;
      }
      if (dirtyProperties.isEmpty()) {
        return new int[0];
      }
      if (hasJustBeenSaved) {
        // whenever an entity has just been saved, its state is in the dirty
        // store. Hibernate might ask to check dirtiness especially for
        // collection members. Those just saved entities must not be considered
        // dirty but there might be some reference properties to update, so let
        // Hibernate default dirty checking happen.
        return null;
      }
      int[] indices = new int[propertyNames.length];
      int n = 0;
      for (int i = 0; i < propertyNames.length; i++) {
        String propertyName = PropertyHelper.fromJavaBeanPropertyName(propertyNames[i]);
        if (dirtyProperties.containsKey(propertyName)) {
          indices[n] = i;
          n++;
          if (currentState[i] instanceof PersistentCollection) {
            ((PersistentCollection) currentState[i]).dirty();
          }
        }
      }
      int[] shrinkedArray = new int[n];
      System.arraycopy(indices, 0, shrinkedArray, 0, n);
      return shrinkedArray;
    }
    return super.findDirty(entity, id, currentState, previousState, propertyNames, types);
  }

  /**
   * {@inheritDoc}
   */
  @SuppressWarnings("unchecked")
  @Override
  public Object getEntity(String entityName, Serializable id) {
    IEntity registeredEntity = null;
    try {
      if (getBackendController().isUnitOfWorkActive()) {
        registeredEntity = getBackendController().getUnitOfWorkEntity((Class<? extends IEntity>) Class.forName(
            entityName), id);
      } else {
        registeredEntity = getBackendController().getRegisteredEntity((Class<? extends IEntity>) Class.forName(
            entityName), id);
        if (registeredEntity instanceof HibernateProxy) {
          HibernateProxy proxy = (HibernateProxy) registeredEntity;
          LazyInitializer li = proxy.getHibernateLazyInitializer();
          registeredEntity = (IEntity) li.getImplementation();
        }
      }
    } catch (ClassNotFoundException ex) {
      LOG.error("Class for entity {} was not found", entityName, ex);
    }
    // getEntity should never return transient instances, see #1244
    if (registeredEntity != null && !registeredEntity.isPersistent()) {
      registeredEntity = null;
    }
    ((HibernateBackendController) getBackendController()).detachFromHibernateInDepth(registeredEntity,
        ((HibernateBackendController) getBackendController()).getHibernateSession(), new HibernateEntityRegistry(
        "detachFromHibernateInDepth"));
    return registeredEntity;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean onLoad(Object entity, Serializable id, Object[] state, String[] propertyNames, Type[] types) {
    boolean updated = super.onLoad(entity, id, state, propertyNames, types);
    if (entity instanceof IEntity) {
      IBackendController backendController = getBackendController();
      if (backendController.isUnitOfWorkActive()) {
        Map<String, Object> properties = new HashMap<>();
        for (int i = 0; i < propertyNames.length; i++) {
          String propertyName = PropertyHelper.fromJavaBeanPropertyName(propertyNames[i]);
          if (!isHibernateInternal(propertyName)) {
            properties.put(propertyName, state[i]);
          }
        }
        ((IEntity) entity).straightSetProperties(properties);
        // So that dirty tracking is started on the entity.
        // See bug #1018
        backendController.registerEntity((IEntity) entity);
      } else {
        if (backendController.getRegisteredEntity(((IEntity) entity).getComponentContract(), id) == null) {
          Map<String, Object> properties = new HashMap<>();
          for (int i = 0; i < propertyNames.length; i++) {
            if (state[i] != null) {
              String propertyName = PropertyHelper.fromJavaBeanPropertyName(propertyNames[i]);
              if (!isHibernateInternal(propertyName)) {
                if (state[i] instanceof IEntity) {
                  IEntity refEntity = (IEntity) state[i];
                  IEntity mergedEntity = backendController.getRegisteredEntity(HibernateHelper.getComponentContract(
                      refEntity), refEntity.getId());
                  if (mergedEntity != null && mergedEntity != refEntity) {
                    state[i] = mergedEntity;
                    updated = true;
                  }
                }
                properties.put(propertyName, state[i]);
              }
            }
          }
          ((IEntity) entity).straightSetProperties(properties);
          backendController.registerEntity((IEntity) entity);
        }
      }
    }
    return updated;
  }

  /**
   * Registers Entities to be merged back from the uow to the session on
   * commit.
   * <p/>
   * {@inheritDoc}
   */
  @Override
  public void postFlush(Iterator entities) {
    while (entities.hasNext()) {
      Object entity = entities.next();
      if (entity instanceof IEntity) {
        getBackendController().recordAsSynchronized((IEntity) entity);
      }
    }
    super.postFlush(entities);
  }

  /**
   * This is the place to trigger the update lifecycle handler. onFlushDirty is
   * not the right place since it cannot deal with transient new instances that
   * might be added to the object tree. It also registers Entities to be merged
   * back from the uow to the session on commit. This last action is done here
   * instead of postFlush. See http://www.jspresso.org/mantis/view.php?id=455.
   * <p/>
   * {@inheritDoc}
   */
  @Override
  public void preFlush(Iterator entities) {

    if (!getBackendController().isUnitOfWorkActive() && entities.hasNext()) {
      // throw new BackendException(
      // "A save has been attempted outside of any transactional context. Jspresso disallows this bad practice.");
      LOG.warn(
          "A flush has been attempted outside of any transactional context. Jspresso disallows this bad practice.");
    }

    // To avoid concurrent access modifications
    Set<Object> preFlushedEntities = new LinkedHashSet<>();
    while (entities.hasNext()) {
      preFlushedEntities.add(entities.next());
    }
    Set<Object> onUpdatedEntities = new HashSet<>();
    boolean onUpdateTriggered = triggerOnUpdate(preFlushedEntities, onUpdatedEntities);
    while (onUpdateTriggered) {
      // Until the state is stable.
      onUpdateTriggered = triggerOnUpdate(preFlushedEntities, onUpdatedEntities);
    }
  }

  private boolean triggerOnUpdate(Set<Object> preFlushedEntities, Set<Object> onUpdatedEntities) {
    boolean onUpdateTriggered = false;
    for (Object entity : preFlushedEntities) {
      if (entity instanceof ILifecycleCapable && !onUpdatedEntities.contains(entity)) {
        if (entity instanceof IEntity) {
          if (((IEntity) entity).isPersistent()) {
            boolean isClean = false;
            Map<String, Object> dirtyProperties = getBackendController().getDirtyProperties((IEntity) entity, false);
            boolean hasJustBeenSaved = false;
            if (dirtyProperties != null) {
              hasJustBeenSaved = dirtyProperties.containsKey(IEntity.VERSION) && dirtyProperties.get(IEntity.VERSION)
                  == null;
              dirtyProperties.remove(IEntity.VERSION);
            }
            if (dirtyProperties == null) {
              isClean = true;
            } else if (dirtyProperties.isEmpty()) {
              isClean = true;
            } else if (hasJustBeenSaved) {
              // whenever an entity has just been saved, its state is in the
              // dirty store. Hibernate might ask to check dirtiness especially
              // for collection members. Those just saved entities must not be
              // considered dirty.
              isClean = true;
            }
            if (!onUpdatedEntities.contains(entity) && !isClean && !getBackendController()
                .isEntityRegisteredForDeletion((IEntity) entity)) {
              // the entity is dirty and is going to be flushed.
              ((ILifecycleCapable) entity).onUpdate(getEntityFactory(), getPrincipal(), getEntityLifecycleHandler());
              onUpdatedEntities.add(entity);
              onUpdateTriggered = true;
            }
          }
        }
      }
    }
    return onUpdateTriggered;
  }

  /**
   * Gets the getBackendController().
   *
   * @return the backendController.
   */
  protected IBackendController getBackendController() {
    return BackendControllerHolder.getCurrentBackendController();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected IEntityLifecycleHandler getEntityLifecycleHandler() {
    return getBackendController();
  }

  /**
   * Gets the principal of the application session.
   * <p/>
   * {@inheritDoc}
   */
  @Override
  protected UserPrincipal getPrincipal() {
    return getBackendController().getApplicationSession().getPrincipal();
  }
}

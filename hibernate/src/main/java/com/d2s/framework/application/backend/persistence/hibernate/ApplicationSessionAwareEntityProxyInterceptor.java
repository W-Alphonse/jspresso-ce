/*
 * Copyright (c) 2005 Design2see. All rights reserved.
 */
package com.d2s.framework.application.backend.persistence.hibernate;

import java.io.Serializable;
import java.util.Iterator;
import java.util.Map;

import org.hibernate.Transaction;
import org.hibernate.type.Type;

import com.d2s.framework.application.backend.session.IApplicationSession;
import com.d2s.framework.model.entity.IEntity;
import com.d2s.framework.model.persistence.hibernate.EntityProxyInterceptor;

/**
 * Hibernate session interceptor aware of an application session to deal with
 * uniqueness of entity instances across the JVM.
 * <p>
 * Copyright 2005 Design2See. All rights reserved.
 * <p>
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public class ApplicationSessionAwareEntityProxyInterceptor extends
    EntityProxyInterceptor {

  private static final long   serialVersionUID = -6834992000307471098L;

  private IApplicationSession applicationSession;

  /**
   * Sets the applicationSession.
   * 
   * @param applicationSession
   *          the applicationSession to set.
   */
  public void setApplicationSession(IApplicationSession applicationSession) {
    this.applicationSession = applicationSession;
  }

  /**
   * Uses the application session to retrieve the dirty properties of the
   * entity.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public int[] findDirty(Object entity, Serializable id, Object[] currentState,
      Object[] previousState, String[] propertyNames, Type[] types) {
    if (previousState == null && entity instanceof IEntity) {
      Map<String, Object> dirtyProperties = applicationSession
          .getDirtyProperties((IEntity) entity);
      if (dirtyProperties == null) {
        return null;
      } else if (dirtyProperties.isEmpty()) {
        return new int[0];
      }
      int[] indices = new int[dirtyProperties.size()];
      int n = 0;
      for (int i = 0; i < propertyNames.length; i++) {
        if (dirtyProperties.containsKey(propertyNames[i])) {
          indices[n] = i;
          n++;
        }
      }
      return indices;
    }
    return super.findDirty(entity, id, currentState, previousState,
        propertyNames, types);
  }

  /**
   * Begins the application session current unit of work. {@inheritDoc}
   * <p>
   * {@inheritDoc}
   */
  @Override
  public void afterTransactionBegin(Transaction tx) {
    applicationSession.beginUnitOfWork();
    super.afterTransactionBegin(tx);
  }

  /**
   * Either commits or rollbacks the application session current unit of work.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public void afterTransactionCompletion(Transaction tx) {
    if (tx.wasCommitted()) {
      applicationSession.commitUnitOfWork();
    } else {
      applicationSession.rollbackUnitOfWork();
    }
  }

  /**
   * Notifies the application session of the entity flush.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public void postFlush(Iterator entities) {
    while (entities.hasNext()) {
      Object entity = entities.next();
      if (entity instanceof IEntity
          && applicationSession.isDirty((IEntity) entity)) {
        applicationSession.recordAsSynchronized((IEntity) entity);
      }
    }
    super.postFlush(entities);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public Object getEntity(String entityName, Serializable id) {
    if (!applicationSession.isUnitOfWorkActive()) {
      try {
        return applicationSession.getRegisteredEntity(
            Class.forName(entityName), id);
      } catch (ClassNotFoundException ex) {
        ex.printStackTrace();
      }
    }
    return super.getEntity(entityName, id);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean onLoad(Object entity, Serializable id, Object[] state,
      String[] propertyNames, Type[] types) {
    if (!applicationSession.isUnitOfWorkActive()) {
      if (entity instanceof IEntity
          && applicationSession.getRegisteredEntity(((IEntity) entity)
              .getContract(), id) == null) {
        applicationSession.registerEntity((IEntity) entity);
      }
    }
    return super.onLoad(entity, id, state, propertyNames, types);
  }

}

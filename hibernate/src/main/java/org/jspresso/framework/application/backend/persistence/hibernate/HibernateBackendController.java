/*
 * Copyright (c) 2005-2011 Vincent Vandenschrick. All rights reserved.
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

import java.beans.PropertyDescriptor;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.hibernate.Hibernate;
import org.hibernate.LockOptions;
import org.hibernate.ObjectNotFoundException;
import org.hibernate.Session;
import org.hibernate.collection.AbstractPersistentCollection;
import org.hibernate.collection.PersistentCollection;
import org.hibernate.collection.PersistentList;
import org.hibernate.collection.PersistentSet;
import org.hibernate.criterion.DetachedCriteria;
import org.hibernate.proxy.HibernateProxy;
import org.jspresso.framework.application.backend.AbstractBackendController;
import org.jspresso.framework.application.backend.session.EMergeMode;
import org.jspresso.framework.model.component.IComponent;
import org.jspresso.framework.model.descriptor.ICollectionPropertyDescriptor;
import org.jspresso.framework.model.descriptor.IComponentDescriptor;
import org.jspresso.framework.model.descriptor.IPropertyDescriptor;
import org.jspresso.framework.model.descriptor.IRelationshipEndPropertyDescriptor;
import org.jspresso.framework.model.entity.IEntity;
import org.jspresso.framework.model.entity.IEntityFactory;
import org.jspresso.framework.util.bean.MissingPropertyException;
import org.jspresso.framework.util.bean.PropertyHelper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.ConcurrencyFailureException;
import org.springframework.orm.hibernate3.HibernateAccessor;
import org.springframework.orm.hibernate3.HibernateCallback;
import org.springframework.orm.hibernate3.HibernateTemplate;
import org.springframework.orm.hibernate3.HibernateTransactionManager;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.TransactionCallback;
import org.springframework.transaction.support.TransactionCallbackWithoutResult;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * This is the default Jspresso implementation of Hibernate-based backend
 * controller.
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public class HibernateBackendController extends AbstractBackendController {

  private HibernateTemplate   hibernateTemplate;
  private Set<IEntity>        updatedEntities;
  private Set<IEntity>        deletedEntities;
  private boolean             traversedPendingOperations = false;

  private static final Logger LOG                        = LoggerFactory
                                                             .getLogger(HibernateBackendController.class);

  /**
   * Whenever the entity has dirty persistent collection, make them clean to
   * workaround a "bug" with hibernate since hibernate cannot re-attach a
   * "dirty" detached collection.
   * 
   * @param componentOrEntity
   *          the entity to clean the collections dirty state of.
   */
  static void clearPersistentCollectionDirtyState(IComponent componentOrEntity) {
    if (componentOrEntity != null) {
      // Whenever the entity has dirty persistent collection, make them
      // clean to workaround a "bug" with hibernate since hibernate cannot
      // re-attach a "dirty" detached collection.
      for (Map.Entry<String, Object> registeredPropertyEntry : componentOrEntity
          .straightGetProperties().entrySet()) {
        if (registeredPropertyEntry.getValue() instanceof PersistentCollection) {
          if (Hibernate.isInitialized(registeredPropertyEntry.getValue())) {
            ((PersistentCollection) registeredPropertyEntry.getValue())
                .clearDirty();
          }
          try {
            // The folowing is to avoid to avoid Hibernate exceptions due to
            // reassociating a
            // collection that is already associated with the session.
            ((PersistentCollection) registeredPropertyEntry.getValue())
                .setCurrentSession(null);
          } catch (Exception ex) {
            // ignored
          }
        }
      }
    }
  }

  private static String getHibernateRoleName(Class<?> entityContract,
      String property) {
    // have to find the highest entity class declaring the collection role.
    PropertyDescriptor roleDescriptor;
    try {
      roleDescriptor = PropertyHelper.getPropertyDescriptor(entityContract,
          property);
    } catch (MissingPropertyException ex) {
      return null;
    }
    Class<?> propertyDeclaringClass = roleDescriptor.getReadMethod()
        .getDeclaringClass();
    Class<?> roleClass;
    if (IEntity.class.isAssignableFrom(propertyDeclaringClass)) {
      roleClass = propertyDeclaringClass;
    } else {
      roleClass = getHighestEntityClassInRole(entityContract,
          propertyDeclaringClass);
    }
    return roleClass.getName() + "." + property;
  }

  private static Class<?> getHighestEntityClassInRole(Class<?> entityContract,
      Class<?> propertyDeclaringClass) {
    for (Class<?> superInterface : entityContract.getInterfaces()) {
      if (IEntity.class.isAssignableFrom(superInterface)
          && propertyDeclaringClass.isAssignableFrom(superInterface)) {
        return getHighestEntityClassInRole(superInterface,
            propertyDeclaringClass);
      }
    }
    return entityContract;
  }

  /**
   * Allows for a new run of performPendingOperations.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public void clearPendingOperations() {
    super.clearPendingOperations();
    traversedPendingOperations = false;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public <E extends IEntity> List<E> cloneInUnitOfWork(List<E> entities) {
    final List<E> uowEntities = super.cloneInUnitOfWork(entities);
    hibernateTemplate.execute(new HibernateCallback<Object>() {

      @Override
      public Object doInHibernate(Session session) {
        Set<IEntity> alreadyLocked = new HashSet<IEntity>();
        for (IEntity mergedEntity : uowEntities) {
          lockInHibernateInDepth(mergedEntity, session, alreadyLocked);
        }
        return null;
      }

    });
    return uowEntities;
  }

  /**
   * Look-ups the entity in the session 1st. If it is there, return it so that
   * it avoids an unnecessary deep carbon copy.
   * 
   * @param <E>
   *          the actual entity type.
   * @param entity
   *          the source entity.
   * @return the cloned entity.
   */
  @Override
  protected <E extends IEntity> E performUowEntityCloning(final E entity) {
    E sessionEntity = hibernateTemplate.execute(new HibernateCallback<E>() {

      @Override
      public E doInHibernate(Session session) {
        if (session.contains(entity)) {
          return entity;
        }
        return null;
      }

    });
    if (sessionEntity != null) {
      return sessionEntity;
    }
    // fall-back to default cloning.
    return super.performUowEntityCloning(entity);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void beginUnitOfWork() {
    updatedEntities = new HashSet<IEntity>();
    deletedEntities = new HashSet<IEntity>();
    super.beginUnitOfWork();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void commitUnitOfWork() {
    updatedEntities = null;
    deletedEntities = null;
    if (traversedPendingOperations) {
      // We must get rid of the pending operations only in the case of a
      // successful commit.
      clearPendingOperations();
    }
    super.commitUnitOfWork();
  }

  /**
   * Gets the hibernateTemplate.
   * 
   * @return the hibernateTemplate.
   */
  public HibernateTemplate getHibernateTemplate() {
    return hibernateTemplate;
  }

  /**
   * {@inheritDoc}
   */
  @SuppressWarnings("unchecked")
  @Override
  public void initializePropertyIfNeeded(final IComponent componentOrEntity,
      final String propertyName) {
    boolean dirtRecorderWasEnabled = getDirtRecorder().isEnabled();
    try {
      getDirtRecorder().setEnabled(false);
      final Object initializedProperty = componentOrEntity
          .straightGetProperty(propertyName);
      if (!Hibernate.isInitialized(initializedProperty)) {
        if (initializedProperty instanceof AbstractPersistentCollection) {
          if (((AbstractPersistentCollection) initializedProperty).getSession() != null
              && ((AbstractPersistentCollection) initializedProperty)
                  .getSession().isOpen()) {
            try {
              Hibernate.initialize(initializedProperty);
              if (initializedProperty instanceof Collection<?>) {
                relinkAfterInitialization(
                    (Collection<IEntity>) initializedProperty,
                    componentOrEntity);
              }
              return;
            } catch (Exception ex) {
              LOG.error(
                  "An internal error occurred when forcing {} collection initialization.",
                  propertyName);
              LOG.error("Source exception", ex);
            }
          }
        }

        int oldFlushMode = hibernateTemplate.getFlushMode();
        try {
          // Temporary switch to a read-only session.
          hibernateTemplate.setFlushMode(HibernateAccessor.FLUSH_NEVER);
          hibernateTemplate.execute(new HibernateCallback<Object>() {

            /**
             * {@inheritDoc}
             */
            @Override
            public Object doInHibernate(Session session) {
              // cleanPersistentCollectionDirtyState(componentOrEntity);
              if (componentOrEntity instanceof IEntity) {
                if (((IEntity) componentOrEntity).isPersistent()) {
                  lockInHibernate((IEntity) componentOrEntity, session);
                } else if (initializedProperty instanceof IEntity) {
                  lockInHibernate((IEntity) componentOrEntity, session);
                }
              } else if (initializedProperty instanceof IEntity) {
                // to handle initialization of component properties.
                lockInHibernate((IEntity) initializedProperty, session);
              }

              Hibernate.initialize(initializedProperty);
              if (initializedProperty instanceof Collection<?>) {
                relinkAfterInitialization(
                    (Collection<IEntity>) initializedProperty,
                    componentOrEntity);
              } else {
                relinkAfterInitialization(
                    Collections.singleton((IEntity) initializedProperty),
                    componentOrEntity);
              }
              return null;
            }
          });
        } finally {
          hibernateTemplate.setFlushMode(oldFlushMode);
        }
        super.initializePropertyIfNeeded(componentOrEntity, propertyName);
        clearPropertyDirtyState(initializedProperty);
      }
    } finally {
      getDirtRecorder().setEnabled(dirtRecorderWasEnabled);
    }
  }

  private void relinkAfterInitialization(Collection<IEntity> entities,
      Object owner) {
    for (IEntity entity : entities) {
      // Should always be the case but there might be problems with lists
      // containing holes.
      if (entity != null) {
        for (Map.Entry<String, Object> property : entity
            .straightGetProperties().entrySet()) {
          if (property.getValue() instanceof IEntity) {
            if (owner.equals(property.getValue())
                && owner != property.getValue()) {
              entity.straightSetProperty(property.getKey(), owner);
            }
          }
        }
      }
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean isInitialized(Object objectOrProxy) {
    return Hibernate.isInitialized(objectOrProxy);
  }

  private boolean hasBeenProcessed(IEntity entity) {
    return updatedEntities != null && updatedEntities.contains(entity)
        || deletedEntities != null && deletedEntities.contains(entity);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void performPendingOperations() {
    if (!traversedPendingOperations) {
      traversedPendingOperations = true;
      hibernateTemplate.execute(new HibernateCallback<Object>() {

        /**
         * {@inheritDoc}
         */
        @Override
        public Object doInHibernate(Session session) {
          boolean flushIsNecessary = false;
          Collection<IEntity> entitiesToUpdate = getEntitiesRegisteredForUpdate();
          Collection<IEntity> entitiesToDelete = getEntitiesRegisteredForDeletion();
          List<IEntity> entitiesToClone = new ArrayList<IEntity>();
          if (entitiesToUpdate != null) {
            entitiesToClone.addAll(entitiesToUpdate);
          }
          if (entitiesToDelete != null) {
            entitiesToClone.addAll(entitiesToDelete);
          }
          List<IEntity> sessionEntities = cloneInUnitOfWork(entitiesToClone);
          Map<IEntity, IEntity> entityMap = new HashMap<IEntity, IEntity>();
          for (int i = 0; i < entitiesToClone.size(); i++) {
            entityMap.put(entitiesToClone.get(i), sessionEntities.get(i));
          }
          if (entitiesToUpdate != null) {
            for (IEntity entityToUpdate : entitiesToUpdate) {
              IEntity sessionEntity = entityMap.get(entityToUpdate);
              if (sessionEntity == null) {
                sessionEntity = entityToUpdate;
              }
              if (!hasBeenProcessed(sessionEntity)) {
                updatedEntities.add(sessionEntity);
                session.saveOrUpdate(sessionEntity);
                flushIsNecessary = true;
              }
            }
          }
          if (flushIsNecessary) {
            session.flush();
          }
          flushIsNecessary = false;
          // there might have been new entities to delete
          entitiesToDelete = getEntitiesRegisteredForDeletion();
          if (entitiesToDelete != null) {
            for (IEntity entityToDelete : entitiesToDelete) {
              IEntity sessionEntity = entityMap.get(entityToDelete);
              if (sessionEntity == null) {
                sessionEntity = entityToDelete;
              }
              if (!hasBeenProcessed(sessionEntity)) {
                deletedEntities.add(sessionEntity);
                session.delete(sessionEntity);
                flushIsNecessary = true;
              }
            }
          }
          if (flushIsNecessary) {
            session.flush();
          }
          return null;
        }
      });
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void registerForDeletion(IEntity entity) {
    if (isUnitOfWorkActive()) {
      if (!hasBeenProcessed(entity)) {
        try {
          deletedEntities.add(entity);
          getHibernateTemplate().delete(entity);
        } catch (RuntimeException re) {
          deletedEntities.remove(entity);
          getHibernateTemplate().evict(entity);
          throw re;
        }
      }
    } else {
      super.registerForDeletion(entity);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean isEntityRegisteredForDeletion(IEntity entity) {
    return deletedEntities != null && deletedEntities.contains(entity)
        || super.isEntityRegisteredForDeletion(entity);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void registerForUpdate(IEntity entity) {
    if (isUnitOfWorkActive()) {
      if (!hasBeenProcessed(entity)) {
        try {
          updatedEntities.add(entity);
          getHibernateTemplate().saveOrUpdate(entity);
        } catch (RuntimeException re) {
          updatedEntities.remove(entity);
          getHibernateTemplate().evict(entity);
          throw re;
        }
      }
    } else {
      super.registerForUpdate(entity);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean isEntityRegisteredForUpdate(IEntity entity) {
    return updatedEntities != null && updatedEntities.contains(entity)
        || super.isEntityRegisteredForUpdate(entity);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void rollbackUnitOfWork() {
    updatedEntities = null;
    deletedEntities = null;
    try {
      super.rollbackUnitOfWork();
    } finally {
      traversedPendingOperations = false;
    }
  }

  /**
   * The configured entity factory will be configured with the necessary
   * interceptors so that the controller can be notified of entity creations.
   * <p>
   * {@inheritDoc}
   * 
   * @internal
   */
  @Override
  public void setEntityFactory(IEntityFactory entityFactory) {
    super.setEntityFactory(entityFactory);
    linkHibernateArtifacts();
  }

  /**
   * Assigns the Spring hibernate template to this backend controller. This
   * property can only be set once and should only be used by the DI container.
   * It will rarely be changed from built-in defaults unless you need to specify
   * a custom implementation instance to be used.
   * <p>
   * The configured instance is the one that will be returned by the
   * controller's <code>getHibernateTemplate()</code> method that should be used
   * by the service layer to access Hibernate.
   * 
   * @param hibernateTemplate
   *          the hibernateTemplate to set.
   */
  public void setHibernateTemplate(HibernateTemplate hibernateTemplate) {
    if (this.hibernateTemplate != null) {
      throw new IllegalArgumentException(
          "Spring hibernate template can only be configured once.");
    }
    this.hibernateTemplate = hibernateTemplate;
    linkHibernateArtifacts();
  }

  /**
   * The configured transaction template will be configured with the necessary
   * interceptors so that the controller can be notified of transactions.
   * <p>
   * {@inheritDoc}
   * 
   * @internal
   */
  @Override
  public void setTransactionTemplate(TransactionTemplate transactionTemplate) {
    super.setTransactionTemplate(transactionTemplate);
    linkHibernateArtifacts();
  }

  /**
   * This method wraps transient collections in the equivalent hibernate ones.
   * {@inheritDoc}
   */
  @SuppressWarnings("unchecked")
  @Override
  protected Collection<IComponent> wrapDetachedCollection(IEntity owner,
      Collection<IComponent> transientCollection,
      Collection<IComponent> snapshotCollection, String role) {
    Collection<IComponent> varSnapshotCollection = snapshotCollection;
    if (!(transientCollection instanceof PersistentCollection)) {
      String collectionRoleName = getHibernateRoleName(
          owner.getComponentContract(), role);
      if (collectionRoleName == null) {
        // it is not an hibernate managed collection (e.g. "detachedEntities")
        return super.wrapDetachedCollection(owner, transientCollection,
            snapshotCollection, role);
      }
      if (owner.isPersistent()) {
        if (transientCollection instanceof Set) {
          PersistentSet persistentSet = new PersistentSet(null,
              (Set<?>) transientCollection);
          changeCollectionOwner(persistentSet, owner);
          HashMap<Object, Object> snapshot = new HashMap<Object, Object>();
          if (varSnapshotCollection == null) {
            persistentSet.clearDirty();
            varSnapshotCollection = transientCollection;
          }
          for (Object snapshotCollectionElement : varSnapshotCollection) {
            snapshot.put(snapshotCollectionElement, snapshotCollectionElement);
          }
          persistentSet
              .setSnapshot(owner.getId(), collectionRoleName, snapshot);
          return persistentSet;
        } else if (transientCollection instanceof List) {
          PersistentList persistentList = new PersistentList(null,
              (List<?>) transientCollection);
          changeCollectionOwner(persistentList, owner);
          ArrayList<Object> snapshot = new ArrayList<Object>();
          if (varSnapshotCollection == null) {
            persistentList.clearDirty();
            varSnapshotCollection = transientCollection;
          }
          for (Object snapshotCollectionElement : varSnapshotCollection) {
            snapshot.add(snapshotCollectionElement);
          }
          persistentList.setSnapshot(owner.getId(), collectionRoleName,
              snapshot);
          return persistentList;
        }
      }
    } else {
      if (varSnapshotCollection == null) {
        ((PersistentCollection) transientCollection).clearDirty();
      } else {
        ((PersistentCollection) transientCollection).dirty();
      }
    }
    return super.wrapDetachedCollection(owner, transientCollection,
        varSnapshotCollection, role);
  }

  private void linkHibernateArtifacts() {
    if (getHibernateTemplate() != null && getTransactionTemplate() != null
        && getEntityFactory() != null) {
      ControllerAwareEntityProxyInterceptor entityInterceptor = new ControllerAwareEntityProxyInterceptor();
      entityInterceptor.setBackendController(this);
      entityInterceptor.setEntityFactory(getEntityFactory());
      getHibernateTemplate().setEntityInterceptor(entityInterceptor);
      if (getTransactionTemplate().getTransactionManager() instanceof HibernateTransactionManager) {
        ((HibernateTransactionManager) getTransactionTemplate()
            .getTransactionManager()).setEntityInterceptor(entityInterceptor);
      }
    }
  }

  /**
   * Locks an entity (LockMode.NONE) in current hibernate session.
   * 
   * @param entity
   *          the entity to lock.
   * @param hibernateSession
   *          the hibernate session.
   */
  private void lockInHibernate(IEntity entity, Session hibernateSession) {
    if (!hibernateSession.contains(entity)) {
      // Do not use get before trying to lock.
      // Get performs a DB query.
      try {
        clearPersistentCollectionDirtyState(entity);
        hibernateSession.buildLockRequest(LockOptions.NONE).lock(entity);
      } catch (Exception ex) {
        IComponent sessionEntity = (IComponent) hibernateSession.get(
            entity.getComponentContract(), entity.getId());
        evictFromHibernateInDepth(sessionEntity, hibernateSession,
            new HashSet<IEntity>());
        hibernateSession.buildLockRequest(LockOptions.NONE).lock(entity);
      }
    }
  }

  @SuppressWarnings("unchecked")
  private void lockInHibernateInDepth(IComponent component,
      Session hibernateSession, Set<IEntity> alreadyLocked) {
    boolean isEntity = component instanceof IEntity;
    if (!isEntity || alreadyLocked.add((IEntity) component)) {
      if (isEntity) {
        if (((IEntity) component).isPersistent()) {
          lockInHibernate((IEntity) component, hibernateSession);
        } else {
          // Cannot simply re-attach the transient entity, so we have to
          // saveOrUpdate it.

          // This is a bad evolution since we don't know if we want to actually
          // create the new entity. If we want to delete it, all checks will be
          // trigerred.
          // if (!isEntityRegisteredForDeletion((IEntity) component)) {
          // registerForUpdate((IEntity) component);
          // }
        }
      }
      Map<String, Object> entityProperties = component.straightGetProperties();
      IComponentDescriptor<?> componentDescriptor = getEntityFactory()
          .getComponentDescriptor(component.getComponentContract());
      for (Map.Entry<String, Object> property : entityProperties.entrySet()) {
        String propertyName = property.getKey();
        Object propertyValue = property.getValue();
        IPropertyDescriptor propertyDescriptor = componentDescriptor
            .getPropertyDescriptor(propertyName);
        if (Hibernate.isInitialized(propertyValue)) {
          if (propertyValue instanceof IEntity) {
            lockInHibernateInDepth((IEntity) propertyValue, hibernateSession,
                alreadyLocked);
          } else if (propertyValue instanceof Collection
              && propertyDescriptor instanceof ICollectionPropertyDescriptor<?>) {
            for (IComponent element : ((Collection<IComponent>) property
                .getValue())) {
              lockInHibernateInDepth(element, hibernateSession, alreadyLocked);
            }
            if (propertyValue instanceof PersistentCollection) {
              Collection<IComponent> snapshot = null;
              Object storedSnapshot = ((PersistentCollection) propertyValue)
                  .getStoredSnapshot();
              if (storedSnapshot instanceof Map<?, ?>) {
                snapshot = ((Map<IComponent, IComponent>) storedSnapshot)
                    .keySet();
              } else if (storedSnapshot instanceof Collection<?>) {
                snapshot = (Collection<IComponent>) storedSnapshot;
              }
              if (snapshot != null) {
                for (IComponent element : snapshot) {
                  lockInHibernateInDepth(element, hibernateSession,
                      alreadyLocked);
                }
              }
            }
          }
        }
      }
    }
  }

  @SuppressWarnings("unchecked")
  private void evictFromHibernateInDepth(IComponent component,
      Session hibernateSession, Set<IEntity> alreadyEvicted) {
    boolean isEntity = component instanceof IEntity;
    if (!isEntity || alreadyEvicted.add((IEntity) component)) {
      if (!isEntity || ((IEntity) component).isPersistent()) {
        if (isEntity) {
          hibernateSession.evict(component);
        }
        Map<String, Object> entityProperties = component
            .straightGetProperties();
        for (Map.Entry<String, Object> property : entityProperties.entrySet()) {
          if (Hibernate.isInitialized(property.getValue())) {
            if (property.getValue() instanceof IEntity) {
              evictFromHibernateInDepth((IEntity) property.getValue(),
                  hibernateSession, alreadyEvicted);
            } else if (property.getValue() instanceof Collection) {
              for (IComponent element : ((Collection<IComponent>) property
                  .getValue())) {
                evictFromHibernateInDepth(element, hibernateSession,
                    alreadyEvicted);
              }
            }
          }
        }
      }
    }
  }

  /**
   * Search Hibernate using criteria. The result is then merged into session.
   * 
   * @param <T>
   *          the entity type to return
   * @param criteria
   *          the detached criteria.
   * @param mergeMode
   *          the merge mode to use when merging back retrieved entities or null
   *          if no merge is requested.
   * @param clazz
   *          the type of the entity.
   * @return the first found entity or null;
   */
  public <T extends IEntity> T findFirstByCriteria(DetachedCriteria criteria,
      EMergeMode mergeMode, Class<? extends T> clazz) {
    List<T> ret = findByCriteria(criteria, 0, 1, mergeMode, clazz);
    if (ret != null && !ret.isEmpty()) {
      return ret.get(0);
    }
    return null;
  }

  /**
   * Search Hibernate using criteria. The result is then merged into session.
   * 
   * @param <T>
   *          the entity type to return
   * @param criteria
   *          the detached criteria.
   * @param mergeMode
   *          the merge mode to use when merging back retrieved entities or null
   *          if no merge is requested.
   * @param clazz
   *          the type of the entity.
   * @return the first found entity or null;
   */
  public <T extends IEntity> List<T> findByCriteria(
      final DetachedCriteria criteria, EMergeMode mergeMode,
      Class<? extends T> clazz) {
    return findByCriteria(criteria, -1, -1, mergeMode, clazz);
  }

  /**
   * Search Hibernate using criteria. The result is then merged into session.
   * 
   * @param <T>
   *          the entity type to return
   * @param criteria
   *          the detached criteria.
   * @param firstResult
   *          the first result rank to retrieve.
   * @param maxResults
   *          the max number of results to retrieve.
   * @param mergeMode
   *          the merge mode to use when merging back retrieved entities or null
   *          if no merge is requested.
   * @param clazz
   *          the type of the entity.
   * @return the first found entity or null;
   */
  public <T extends IEntity> List<T> findByCriteria(
      final DetachedCriteria criteria, int firstResult, int maxResults,
      EMergeMode mergeMode, Class<? extends T> clazz) {
    List<T> res = findByCriteria(criteria, firstResult, maxResults);
    if (res != null) {
      if (isUnitOfWorkActive()) {
        return cloneInUnitOfWork(res);
      } else if (mergeMode != null) {
        return merge(res, mergeMode);
      }
      return res;
    }
    return null;
  }

  @SuppressWarnings("unchecked")
  private <T extends IEntity> List<T> findByCriteria(
      final DetachedCriteria criteria, final int firstResult,
      final int maxResults) {
    List<T> res = getTransactionTemplate().execute(
        new TransactionCallback<List<T>>() {

          @Override
          public List<T> doInTransaction(@SuppressWarnings("unused")
          TransactionStatus status) {
            int oldFlushMode = getHibernateTemplate().getFlushMode();
            try {
              getHibernateTemplate()
                  .setFlushMode(HibernateAccessor.FLUSH_NEVER);
              return getHibernateTemplate().findByCriteria(criteria,
                  firstResult, maxResults);
            } finally {
              getHibernateTemplate().setFlushMode(oldFlushMode);
            }
          }
        });
    return res;
  }

  /**
   * Unwrap hibernate proxy if needed.
   * 
   * @param componentOrProxy
   *          the component or proxy.
   * @return the proxy implementation if it's an hibernate proxy.
   */
  @Override
  protected Object unwrapProxy(Object componentOrProxy) {
    Object component;
    if (componentOrProxy instanceof HibernateProxy) {
      // we must unwrap the proxy to avoid class cast exceptions.
      // see
      // http://forum.hibernate.org/viewtopic.php?p=2323464&sid=cb4ba3a4418276e5d2fbdd6c906ba734
      component = ((HibernateProxy) componentOrProxy)
          .getHibernateLazyInitializer().getImplementation();
    } else {
      component = componentOrProxy;
    }
    return component;
  }

  /**
   * Reloads an entity in hibernate.
   * 
   * @param entity
   *          the entity to reload.
   */
  @Override
  public void reload(final IEntity entity) {
    // builds a collection of entities to reload.
    Set<IEntity> dirtyReachableEntities = buildReachableDirtyEntitySet(entity);

    if (entity.isPersistent()) {
      getTransactionTemplate().execute(new TransactionCallbackWithoutResult() {

        @Override
        protected void doInTransactionWithoutResult(TransactionStatus status) {
          HibernateTemplate ht = getHibernateTemplate();
          int oldFlushMode = ht.getFlushMode();
          try {
            // Temporary switch to a read-only session.
            ht.setFlushMode(HibernateAccessor.FLUSH_NEVER);

            Exception deletedObjectEx = null;
            try {
              merge((IEntity) ht.load(entity.getComponentContract().getName(),
                  entity.getId()), EMergeMode.MERGE_CLEAN_EAGER);
            } catch (ObjectNotFoundException ex) {
              deletedObjectEx = ex;
            }
            status.setRollbackOnly();
            if (deletedObjectEx != null) {
              throw new ConcurrencyFailureException(deletedObjectEx
                  .getMessage(), deletedObjectEx);
            }
          } finally {
            ht.setFlushMode(oldFlushMode);
          }
        }
      });
    }

    // traverse the reachable dirty entities to explicitely reload the
    // ones that were not reloaded by the previous pass.
    for (IEntity reachableEntity : dirtyReachableEntities) {
      if (reachableEntity.isPersistent() && isDirty(reachableEntity)) {
        reload(reachableEntity);
      }
    }
  }

  private Set<IEntity> buildReachableDirtyEntitySet(IEntity entity) {
    Set<IEntity> reachableDirtyEntities = new HashSet<IEntity>();
    completeReachableDirtyEntities(entity, reachableDirtyEntities,
        new HashSet<IEntity>());
    return reachableDirtyEntities;
  }

  private void completeReachableDirtyEntities(IEntity entity,
      Set<IEntity> reachableDirtyEntities, Set<IEntity> alreadyTraversed) {
    if (alreadyTraversed.contains(entity)) {
      return;
    }
    alreadyTraversed.add(entity);
    if (isDirty(entity)) {
      reachableDirtyEntities.add(entity);
    }
    Map<String, Object> entityProps = entity.straightGetProperties();
    IComponentDescriptor<?> entityDescriptor = getEntityFactory()
        .getComponentDescriptor(entity.getComponentContract());
    for (Map.Entry<String, Object> property : entityProps.entrySet()) {
      Object propertyValue = property.getValue();
      if (propertyValue instanceof IEntity) {
        IPropertyDescriptor propertyDescriptor = entityDescriptor
            .getPropertyDescriptor(property.getKey());
        if (isInitialized(propertyValue)
            && propertyDescriptor instanceof IRelationshipEndPropertyDescriptor
            // It's not a master data relationship.
            && ((IRelationshipEndPropertyDescriptor) propertyDescriptor)
                .getReverseRelationEnd() != null) {
          completeReachableDirtyEntities((IEntity) propertyValue,
              reachableDirtyEntities, alreadyTraversed);
        }
      } else if (propertyValue instanceof Collection<?>) {
        if (isInitialized(propertyValue)) {
          for (Object elt : ((Collection<?>) propertyValue)) {
            if (elt instanceof IEntity) {
              completeReachableDirtyEntities((IEntity) elt,
                  reachableDirtyEntities, alreadyTraversed);
            }
          }
        }
      }
    }
  }

  private void changeCollectionOwner(Collection<?> persistentCollection,
      Object newOwner) {
    if (persistentCollection instanceof PersistentCollection) {
      ((PersistentCollection) persistentCollection).setOwner(newOwner);
    }
  }

  /**
   * Hibernate related cloning.
   * <p>
   * {@inheritDoc}
   */
  @Override
  protected Object cloneUninitializedProperty(Object owner, Object propertyValue) {
    Object clonedPropertyValue = propertyValue;
    if (Hibernate.isInitialized(owner)) {
      if (propertyValue instanceof PersistentCollection) {
        if (unwrapProxy((((PersistentCollection) propertyValue).getOwner())) != unwrapProxy(owner)) {
          if (propertyValue instanceof PersistentSet) {
            clonedPropertyValue = new PersistentSet(
                ((PersistentSet) propertyValue).getSession());
          } else if (propertyValue instanceof PersistentList) {
            clonedPropertyValue = new PersistentList(
                ((PersistentList) propertyValue).getSession());
          }
          changeCollectionOwner((Collection<?>) clonedPropertyValue, owner);
          ((PersistentCollection) clonedPropertyValue).setSnapshot(
              ((PersistentCollection) propertyValue).getKey(),
              ((PersistentCollection) propertyValue).getRole(), null);
        }
      } else {
        if (propertyValue instanceof HibernateProxy) {
          // Unfortunately there is actually no mean of performing a shallow
          // copy
          // of it.
        }
      }
    }
    return clonedPropertyValue;
  }

  /**
   * Clears dirty state of persistent collections.
   * <p>
   * {@inheritDoc}
   */
  @Override
  protected void clearPropertyDirtyState(Object property) {
    if (property instanceof PersistentCollection) {
      ((PersistentCollection) property).clearDirty();
    }
  }

}

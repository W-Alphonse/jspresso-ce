/*
 * Copyright (c) 2005 Design2see. All rights reserved.
 */
package com.d2s.framework.model.descriptor.basic;


/**
 * Default implementation of an inlined component descriptor.
 * <p>
 * Copyright 2005 Design2See. All rights reserved.
 * <p>
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 * @param <E>
 *            the concrete type of components.
 */
public class BasicComponentDescriptor<E> extends AbstractComponentDescriptor<E> {

  /**
   * Constructs a new <code>BasicComponentDescriptor</code> instance.
   */
  public BasicComponentDescriptor() {
    this(null);
  }

  /**
   * Constructs a new <code>BasicComponentDescriptor</code> instance.
   * 
   * @param name
   *            the name of the descriptor which has to be the fully-qualified
   *            class name of its contract.
   */
  public BasicComponentDescriptor(String name) {
    super(name);
  }

  /**
   * {@inheritDoc}
   */
  public boolean isComputed() {
    return false;
  }

  /**
   * Gets the entity.
   * 
   * @return the entity.
   */
  public boolean isEntity() {
    return false;
  }

  /**
   * {@inheritDoc}
   */
  public boolean isPurelyAbstract() {
    return false;
  }
}

/*
 * Copyright (c) 2005-2010 Vincent Vandenschrick. All rights reserved.
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
package org.jspresso.framework.model.entity;

import java.io.Serializable;

import org.jspresso.framework.model.component.IComponent;


/**
 * This interface must be implemented by all persistent entities in the
 * application domain. It establishes the minimal contract of an entity which is
 * providing id accessors.
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public interface IEntity extends IComponent {

  /**
   * constant for identifier property <code>ID</code>.
   */
  String ID      = "id";

  /**
   * constant for version property <code>VERSION</code>.
   */
  String VERSION = "version";

  /**
   * It is important to declare here so that ORM (hibernate for instance)
   * detects it has to delegate to the underlying instance when proxiing.
   * 
   * @param o
   *            the instance to compare to.
   * @return true if both instances are equal.
   */
  boolean equals(Object o);

  /**
   * Gets the interface or class establishing the entity contract.
   * 
   * @return the entity contract.
   */
  Class<? extends IEntity> getComponentContract();

  /**
   * Gets the id used to uniquely identify an entity (surrogate key). The id is
   * assigned to the entity instance as soon as the entity is created in memory
   * an is afterwards made immutable so that <code>equals()</code> and
   * <code>hashCode()</code> can safely rely on it whenever they are transient
   * or not. It also establishes the minimal contract of a versionable entity
   * which is providing version accessors to handle access concurrency.
   * 
   * @return The id of the entity.
   */
  Serializable getId();

  /**
   * Gets the version of this entity.
   * 
   * @return the entity version.
   */
  Integer getVersion();

  /**
   * It is important to declare here so that ORM (hibernate for instance)
   * detects it has to delegate to the underlying instance when proxiing.
   * 
   * @return the hashcode.
   */
  int hashCode();

  /**
   * Gets wether this entity has already been saved in the backing store.
   * 
   * @return true if the entity is not transient.
   */
  boolean isPersistent();
}

/*
 * Copyright (c) 2005-2014 Vincent Vandenschrick. All rights reserved.
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
package org.jspresso.framework.util.collection;

import java.lang.ref.ReferenceQueue;
import java.lang.ref.WeakReference;
import java.util.AbstractSet;
import java.util.Iterator;

import gnu.trove.set.hash.THashSet;

/**
 * A weak Set implementation based on GNU THashSet.
 * An element stored in the WeakHashSet might be
 * garbage collected, if there is no strong reference to this element.
 *
 * @author Vincent Vandenschrick
 * @version $LastChangedRevision$
 *
 * @param <E> the type of stored element
 */

public class TWeakHashSet<E> extends AbstractSet<E> {

  /**
   * The delegate that stores the weak references.
   */
  private THashSet<WeakElement<E>> delegate;
  /**
   * Helps to detect garbage collected values.
   */
  private ReferenceQueue<E> queue;

  /**
   * Instantiates a new T weak hash set.
   */
  public TWeakHashSet() {
    this.delegate = new THashSet<>();
    this.queue = new ReferenceQueue<>();
  }

  /**
   * Returns an iterator over the elements in this set.  The elements
   * are returned in no particular order.
   *
   * @return an Iterator over the elements in this set.
   */
  @Override
  public Iterator<E> iterator() {
    // remove garbage collected elements
    processQueue();

    // get an iterator of the superclass
    final Iterator<WeakElement<E>> i = delegate.iterator();

    return new Iterator<E>() {

      @Override
      public boolean hasNext() {
        return i.hasNext();
      }

      @Override
      public E next() {
        // unwrap the element
        return getReferenceObject(i.next());
      }

      @Override
      public void remove() {
        // remove the element from the HashSet
        i.remove();
      }
    };
  }

  /**
   * Returns {@code true} if this set contains the specified element.
   *
   * @param o element whose presence in this set is to be tested.
   * @return {@code true} if this set contains the specified element.
   */
  @Override
  public boolean contains(Object o) {
    return delegate.contains(WeakElement.create(o));
  }

  /**
   * Adds the specified element to this set if it is not already
   * present.
   *
   * @param o element to be added to this set.
   * @return {@code true} if the set did not already contain the specified
   * element.
   */
  @Override
  public boolean add(E o) {
    processQueue();
    return delegate.add(WeakElement.create(o, this.queue));
  }

  /**
   * Removes the given element from this set if it is present.
   *
   * @param o object to be removed from this set, if present.
   * @return {@code true} if the set contained the specified element.
   */
  @Override
  public boolean remove(Object o) {
    boolean ret = delegate.remove(WeakElement.create(o));
    processQueue();
    return ret;
  }

  /**
   * A convenience method to return the object held by the
   * weak reference or {@code null} if it does not exist.
   */
  private E getReferenceObject(WeakReference<E> ref) {
    return (ref == null) ? null : ref.get();
  }

  /**
   * Removes all garbage collected values with their keys from the map.
   * Since we don't know how much the ReferenceQueue.poll() operation
   * costs, we should call it only in the add() method.
   */
  private void processQueue() {
    WeakElement<E> wv = null;

    while ((wv = (WeakElement<E>) this.queue.poll()) != null) {
      delegate.remove(wv);
    }
  }

  @Override
  public int size() {
    processQueue();
    return delegate.size();
  }

  /**
   * A WeakHashSet stores objects of class WeakElement.
   * A WeakElement wraps the element that should be stored in the WeakHashSet.
   * WeakElement inherits from java.lang.ref.WeakReference.
   * It redefines equals and hashCode which delegate to the corresponding methods
   * of the wrapped element.
   */
  private static class WeakElement<F> extends WeakReference<F> {
    private int hash; /* Hashcode of key, stored here since the key
                               may be tossed by the GC */

    private WeakElement(F o) {
      super(o);
      hash = o.hashCode();
    }

    private WeakElement(F o, ReferenceQueue<F> q) {
      super(o, q);
      hash = o.hashCode();
    }

    private static <G> WeakElement<G> create(G o) {
      return (o == null) ? null : new WeakElement<>(o);
    }

    private static <G> WeakElement<G> create(G o, ReferenceQueue<G> q) {
      return (o == null) ? null : new WeakElement<>(o, q);
    }

    /* A WeakElement is equal to another WeakElement iff they both refer to objects
           that are, in turn, equal according to their own equals methods */
    public boolean equals(Object o) {
      if (this == o) {
        return true;
      }
      if (!(o instanceof WeakElement)) {
        return false;
      }
      Object t = this.get();
      Object u = ((WeakElement) o).get();
      if ((t == null) || (u == null)) {
        return false;
      }
      if (t == u) {
        return true;
      }
      return t.equals(u);
    }

    public int hashCode() {
      return hash;
    }
  }

}
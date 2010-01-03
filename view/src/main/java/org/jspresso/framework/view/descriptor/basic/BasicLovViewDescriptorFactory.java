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
package org.jspresso.framework.view.descriptor.basic;

import org.jspresso.framework.model.component.IQueryComponent;
import org.jspresso.framework.model.descriptor.IComponentDescriptor;
import org.jspresso.framework.model.descriptor.IReferencePropertyDescriptor;
import org.jspresso.framework.model.descriptor.basic.BasicCollectionPropertyDescriptor;
import org.jspresso.framework.model.descriptor.basic.BasicListDescriptor;
import org.jspresso.framework.view.action.ActionMap;
import org.jspresso.framework.view.action.IDisplayableAction;
import org.jspresso.framework.view.descriptor.ILovViewDescriptorFactory;
import org.jspresso.framework.view.descriptor.IQueryViewDescriptorFactory;
import org.jspresso.framework.view.descriptor.IViewDescriptor;

/**
 * A default implementation for lov view factories.
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public class BasicLovViewDescriptorFactory implements ILovViewDescriptorFactory {

  private IQueryViewDescriptorFactory queryViewDescriptorFactory;
  private ActionMap                   resultViewActionMap;
  private IViewDescriptor             pagingStatusViewDescriptor;
  private IDisplayableAction          sortingAction;
  private IDisplayableAction          previousPageAction;
  private IDisplayableAction          nextPageAction;

  /**
   * {@inheritDoc}
   */
  @SuppressWarnings("unchecked")
  public IViewDescriptor createLovViewDescriptor(
      IReferencePropertyDescriptor entityRefDescriptor,
      IDisplayableAction okAction) {
    BasicBorderViewDescriptor lovViewDescriptor = new BasicBorderViewDescriptor();
    lovViewDescriptor
        .setNorthViewDescriptor(queryViewDescriptorFactory
            .createQueryViewDescriptor(entityRefDescriptor
                .getComponentDescriptor()));
    lovViewDescriptor.setCenterViewDescriptor(createResultViewDescriptor(
        entityRefDescriptor.getComponentDescriptor(), okAction));
    if (pagingStatusViewDescriptor != null) {
      BasicBorderViewDescriptor pagingViewDescriptor = new BasicBorderViewDescriptor();
      pagingViewDescriptor.setWestViewDescriptor(pagingStatusViewDescriptor);
      if (previousPageAction != null || nextPageAction != null) {
        BasicBorderViewDescriptor pageNavigationViewDescriptor = new BasicBorderViewDescriptor();
        pageNavigationViewDescriptor
            .setCenterViewDescriptor(pagingViewDescriptor);

        if (previousPageAction != null) {
          BasicActionViewDescriptor previousActionViewDescriptor = new BasicActionViewDescriptor();
          previousActionViewDescriptor.setAction(previousPageAction);
          pageNavigationViewDescriptor
              .setWestViewDescriptor(previousActionViewDescriptor);
        }

        if (nextPageAction != null) {
          BasicActionViewDescriptor nextActionViewDescriptor = new BasicActionViewDescriptor();
          nextActionViewDescriptor.setAction(nextPageAction);
          pageNavigationViewDescriptor
              .setEastViewDescriptor(nextActionViewDescriptor);
        }
        lovViewDescriptor.setSouthViewDescriptor(pageNavigationViewDescriptor);
      } else {
        lovViewDescriptor.setSouthViewDescriptor(pagingViewDescriptor);
      }
    }
    return lovViewDescriptor;

  }

  /**
   * Sets the queryViewDescriptorFactory.
   * 
   * @param queryViewDescriptorFactory
   *          the queryViewDescriptorFactory to set.
   */
  public void setQueryViewDescriptorFactory(
      IQueryViewDescriptorFactory queryViewDescriptorFactory) {
    this.queryViewDescriptorFactory = queryViewDescriptorFactory;
  }

  private IViewDescriptor createResultViewDescriptor(
      IComponentDescriptor<Object> entityDescriptor, IDisplayableAction okAction) {
    BasicTableViewDescriptor resultViewDescriptor = new BasicTableViewDescriptor();

    BasicListDescriptor<Object> queriedEntitiesListDescriptor = new BasicListDescriptor<Object>();
    queriedEntitiesListDescriptor.setElementDescriptor(entityDescriptor);

    BasicCollectionPropertyDescriptor<Object> queriedEntitiesDescriptor = new BasicCollectionPropertyDescriptor<Object>();
    queriedEntitiesDescriptor
        .setReferencedDescriptor(queriedEntitiesListDescriptor);
    queriedEntitiesDescriptor.setName(IQueryComponent.QUERIED_COMPONENTS);
    if (resultViewActionMap != null) {
      resultViewDescriptor.setActionMap(resultViewActionMap);
    }
    resultViewDescriptor.setSortingAction(sortingAction);
    resultViewDescriptor.setRowAction(okAction);

    resultViewDescriptor.setModelDescriptor(queriedEntitiesDescriptor);
    resultViewDescriptor.setReadOnly(true);
    return resultViewDescriptor;
  }

  /**
   * Sets the resultViewActionMap.
   * 
   * @param resultViewActionMap
   *          the resultViewActionMap to set.
   */
  public void setResultViewActionMap(ActionMap resultViewActionMap) {
    this.resultViewActionMap = resultViewActionMap;
  }

  /**
   * Sets the pagingStatusViewDescriptor.
   * 
   * @param pagingStatusViewDescriptor
   *          the pagingStatusViewDescriptor to set.
   */
  public void setPagingStatusViewDescriptor(
      IViewDescriptor pagingStatusViewDescriptor) {
    this.pagingStatusViewDescriptor = pagingStatusViewDescriptor;
  }

  /**
   * Sets the sortingAction.
   * 
   * @param sortingAction
   *          the sortingAction to set.
   */
  public void setSortingAction(IDisplayableAction sortingAction) {
    this.sortingAction = sortingAction;
  }

  /**
   * Sets the previousPageAction.
   * 
   * @param previousPageAction
   *          the previousPageAction to set.
   */
  public void setPreviousPageAction(IDisplayableAction previousPageAction) {
    this.previousPageAction = previousPageAction;
  }

  /**
   * Sets the nextPageAction.
   * 
   * @param nextPageAction
   *          the nextPageAction to set.
   */
  public void setNextPageAction(IDisplayableAction nextPageAction) {
    this.nextPageAction = nextPageAction;
  }
}

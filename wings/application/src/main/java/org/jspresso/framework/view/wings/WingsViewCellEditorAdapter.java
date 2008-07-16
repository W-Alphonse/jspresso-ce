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
package org.jspresso.framework.view.wings;

import java.awt.event.MouseEvent;
import java.util.EventObject;

import javax.swing.event.CellEditorListener;
import javax.swing.event.ChangeEvent;
import javax.swing.event.EventListenerList;

import org.jspresso.framework.binding.ConnectorValueChangeEvent;
import org.jspresso.framework.binding.IConnectorValueChangeListener;
import org.jspresso.framework.binding.IValueConnector;
import org.jspresso.framework.binding.basic.BasicValueConnector;
import org.jspresso.framework.gui.wings.components.SActionField;
import org.jspresso.framework.view.IView;
import org.wings.SAbstractButton;
import org.wings.SCheckBox;
import org.wings.SComponent;
import org.wings.SConstants;
import org.wings.STable;
import org.wings.table.STableCellEditor;


/**
 * This class is an adapter around a WingsView to be able to use it as a cell
 * editor.
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
public class WingsViewCellEditorAdapter implements STableCellEditor,
    IConnectorValueChangeListener {

  private static final long serialVersionUID = 8182961519931949735L;
  private ChangeEvent       changeEvent      = null;
  private IView<SComponent> editorView;
  private EventListenerList listenerList;

  private IValueConnector   modelConnector;

  /**
   * Constructs a new <code>WingsViewCellEditorAdapter</code> instance.
   * 
   * @param editorView
   *            the swing view used as editor.
   */
  public WingsViewCellEditorAdapter(IView<SComponent> editorView) {
    this.listenerList = new EventListenerList();
    this.editorView = editorView;
    if (editorView.getPeer() instanceof SAbstractButton) {
      ((SAbstractButton) editorView.getPeer())
          .setHorizontalAlignment(SConstants.CENTER);
    }

    modelConnector = new BasicValueConnector(editorView.getConnector().getId());
    // To prevent the editor from being read-only.
    editorView.getConnector().setModelConnector(modelConnector);
  }

  /**
   * {@inheritDoc}
   */
  public void addCellEditorListener(CellEditorListener l) {
    listenerList.add(CellEditorListener.class, l);
  }

  /**
   * Calls <code>fireEditingCanceled</code>.
   */
  public void cancelCellEditing() {
    fireEditingCanceled();
  }

  /**
   * {@inheritDoc}
   */
  public void connectorValueChange(@SuppressWarnings("unused")
  ConnectorValueChangeEvent evt) {
    stopCellEditing();
  }

  /**
   * Returns the value of the swing view's connector.
   * <p>
   * {@inheritDoc}
   */
  public Object getCellEditorValue() {
    return editorView.getConnector().getConnectorValue();
  }

  /**
   * Returns the SComponent peer of the wings view.
   * <p>
   * {@inheritDoc}
   */
  @SuppressWarnings("unused")
  public SComponent getTableCellEditorComponent(STable table, Object value,
      boolean isSelected, int row, int column) {
    modelConnector.removeConnectorValueChangeListener(this);
    if (value instanceof IValueConnector) {
      modelConnector.setConnectorValue(((IValueConnector) value)
          .getConnectorValue());
    } else {
      modelConnector.setConnectorValue(value);
    }
    modelConnector.addConnectorValueChangeListener(this);
    if (editorView.getPeer() instanceof SCheckBox) {
      ((SCheckBox) editorView.getPeer()).setSelected(!((SCheckBox) editorView
          .getPeer()).isSelected());
    }
    return editorView.getPeer();
  }

  /**
   * Returns false if the event object is a single mouse click.
   * <p>
   * {@inheritDoc}
   */
  public boolean isCellEditable(EventObject anEvent) {
    if (anEvent instanceof MouseEvent) {
      if (editorView.getPeer() instanceof SAbstractButton
          || (editorView.getPeer() instanceof SActionField && !((SActionField) editorView
              .getPeer()).isShowingTextField())) {
        return ((MouseEvent) anEvent).getClickCount() >= 1;
      }
      return ((MouseEvent) anEvent).getClickCount() >= 2;
    }
    return true;
  }

  /**
   * {@inheritDoc}
   */
  public void removeCellEditorListener(CellEditorListener l) {
    listenerList.remove(CellEditorListener.class, l);
  }

  /**
   * Returns true.
   * 
   * @param anEvent
   *            an event object
   * @return true
   */
  public boolean shouldSelectCell(EventObject anEvent) {
    return true;
  }

  /**
   * Calls <code>fireEditingStopped</code> and returns true.
   * 
   * @return true
   */
  public boolean stopCellEditing() {
    fireEditingStopped();
    return true;
  }

  /**
   * Notify all listeners that have registered interest for notification on this
   * event type. The event instance is lazily created using the parameters
   * passed into the fire method.
   * 
   * @see EventListenerList
   */
  protected void fireEditingCanceled() {
    Object[] listeners = listenerList.getListenerList();
    for (int i = listeners.length - 2; i >= 0; i -= 2) {
      if (listeners[i] == CellEditorListener.class) {
        if (changeEvent == null) {
          changeEvent = new ChangeEvent(this);
        }
        ((CellEditorListener) listeners[i + 1]).editingCanceled(changeEvent);
      }
    }
  }

  /**
   * Notify all listeners that have registered interest for notification on this
   * event type. The event instance is lazily created using the parameters
   * passed into the fire method.
   * 
   * @see EventListenerList
   */
  protected void fireEditingStopped() {
    Object[] listeners = listenerList.getListenerList();
    for (int i = listeners.length - 2; i >= 0; i -= 2) {
      if (listeners[i] == CellEditorListener.class) {
        if (changeEvent == null) {
          changeEvent = new ChangeEvent(this);
        }
        ((CellEditorListener) listeners[i + 1]).editingStopped(changeEvent);
      }
    }
  }

  /**
   * Gets the editorView.
   * 
   * @return the editorView.
   */
  protected IView<SComponent> getEditorView() {
    return editorView;
  }
}

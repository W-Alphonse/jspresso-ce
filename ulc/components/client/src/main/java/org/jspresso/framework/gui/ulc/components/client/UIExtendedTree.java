/*
 * Copyright (c) 2005-2008 Vincent Vandenschrick. All rights reserved.
 */
package org.jspresso.framework.gui.ulc.components.client;

import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import javax.swing.JTree;
import javax.swing.event.TreeExpansionEvent;
import javax.swing.event.TreeWillExpandListener;
import javax.swing.tree.TreePath;

import org.jspresso.framework.gui.ulc.components.shared.ExtendedTreeConstants;

import com.ulcjava.base.client.UITree;
import com.ulcjava.base.shared.internal.Anything;

/**
 * UI tree extended to take care of will events
 * <p>
 * Copyright (c) 2005-2008 Vincent Vandenschrick. All rights reserved.
 * <p>
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public class UIExtendedTree extends UITree {

  /**
   * {@inheritDoc}
   */
  @Override
  public void restoreState(Anything args) {
    super.restoreState(args);

    JTree basicTree = (JTree) getBasicComponent();
    basicTree.addTreeWillExpandListener(new TreeWillExpandListener() {

      /**
       * {@inheritDoc}
       */
      public void treeWillCollapse(TreeExpansionEvent event) {
        sendOptionalEventULC(
            ExtendedTreeConstants.EXTENDED_TREE_EXPANSION_EVENT,
            ExtendedTreeConstants.EXTENDED_TREE_WILL_COLLAPSE,
            treePathToAnything(event.getPath()));
      }

      /**
       * {@inheritDoc}
       */
      public void treeWillExpand(TreeExpansionEvent event) {
        sendOptionalEventULC(
            ExtendedTreeConstants.EXTENDED_TREE_EXPANSION_EVENT,
            ExtendedTreeConstants.EXTENDED_TREE_WILL_EXPAND,
            treePathToAnything(event.getPath()));
      }
    });
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected Object createBasicObject(Anything a) {
    JTree tree = (JTree) super.createBasicObject(a);
    tree.addMouseListener(new PreparePopupListener());
    return tree;
  }

  private Anything treePathToAnything(TreePath treePath) {
    Anything anything = new Anything();
    anything.put(ExtendedTreeConstants.ROW_KEY, getBasicTree().getRowForPath(
        treePath));
    return anything;
  }

  private final class PreparePopupListener extends MouseAdapter {

    /**
     * {@inheritDoc}
     */
    @Override
    public void mousePressed(MouseEvent evt) {
      maybePreparePopup(evt);
    }

    private void maybePreparePopup(MouseEvent evt) {
      if (evt.getButton() != MouseEvent.BUTTON1) {
        JTree tree = (JTree) evt.getSource();
        int row = tree.getRowForLocation(evt.getX(), evt.getY());
        Anything rowAnything = new Anything();
        rowAnything.put(ExtendedTreeConstants.ROW_KEY, row);
        sendULC(ExtendedTreeConstants.PREPARE_POPUP_REQUEST, rowAnything);
      }
    }
  }
}

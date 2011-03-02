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
package org.jspresso.framework.application.frontend.controller.swing;

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.Frame;
import java.awt.Insets;
import java.awt.Toolkit;
import java.awt.Window;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyAdapter;
import java.awt.event.MouseAdapter;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.beans.PropertyVetoException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.swing.Action;
import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.Icon;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JDesktopPane;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JInternalFrame;
import javax.swing.JLabel;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JPopupMenu;
import javax.swing.JSplitPane;
import javax.swing.JToolBar;
import javax.swing.SwingUtilities;
import javax.swing.WindowConstants;
import javax.swing.border.EmptyBorder;
import javax.swing.border.EtchedBorder;
import javax.swing.event.InternalFrameAdapter;
import javax.swing.event.InternalFrameEvent;

import org.jspresso.framework.action.ActionContextConstants;
import org.jspresso.framework.action.ActionException;
import org.jspresso.framework.action.IAction;
import org.jspresso.framework.application.ControllerException;
import org.jspresso.framework.application.backend.IBackendController;
import org.jspresso.framework.application.frontend.controller.AbstractFrontendController;
import org.jspresso.framework.binding.IValueConnector;
import org.jspresso.framework.gui.swing.components.JErrorDialog;
import org.jspresso.framework.util.exception.BusinessException;
import org.jspresso.framework.util.gui.Dimension;
import org.jspresso.framework.util.html.HtmlHelper;
import org.jspresso.framework.util.lang.ObjectUtils;
import org.jspresso.framework.util.preferences.IPreferencesStore;
import org.jspresso.framework.util.preferences.JavaPreferencesStore;
import org.jspresso.framework.util.security.LoginUtils;
import org.jspresso.framework.util.swing.BrowserControl;
import org.jspresso.framework.util.swing.SwingUtil;
import org.jspresso.framework.util.swing.WaitCursorEventQueue;
import org.jspresso.framework.util.swing.WaitCursorTimer;
import org.jspresso.framework.util.url.UrlHelper;
import org.jspresso.framework.view.IActionFactory;
import org.jspresso.framework.view.IView;
import org.jspresso.framework.view.action.ActionList;
import org.jspresso.framework.view.action.ActionMap;
import org.jspresso.framework.view.action.IDisplayableAction;
import org.jspresso.framework.view.descriptor.IViewDescriptor;
import org.springframework.dao.ConcurrencyFailureException;
import org.springframework.dao.DataIntegrityViolationException;

import chrriis.dj.nativeswing.swtimpl.NativeInterface;
import chrriis.dj.nativeswing.swtimpl.components.FlashPluginOptions;
import chrriis.dj.nativeswing.swtimpl.components.JFlashPlayer;
import chrriis.dj.swingsuite.JComboButton;

/**
 * This is is the default implementation of the <b>Swing</b> frontend
 * controller. It will implement a 2-tier architecture that is particularly
 * useful for the development/debugging phases. Workspaces are displayed using
 * an MDI UI using internal frames.
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public class DefaultSwingController extends
    AbstractFrontendController<JComponent, Icon, Action> {

  private JFrame                      controllerFrame;
  private JDesktopPane                desktopPane;
  private JLabel                      statusBar;
  private WaitCursorTimer             waitTimer;

  private Map<String, JInternalFrame> workspaceInternalFrames;

  /**
   * {@inheritDoc}
   */
  public void displayFlashObject(String swfUrl,
      Map<String, String> flashContext, List<Action> actions, String title,
      JComponent sourceComponent, Map<String, Object> context,
      Dimension dimension, boolean reuseCurrent) {

    JFlashPlayer flashPlayer = new JFlashPlayer();
    FlashPluginOptions options = new FlashPluginOptions();
    options.setVariables(flashContext);
    flashPlayer.load(getClass(), UrlHelper.getResourcePathOrUrl(swfUrl, true),
        options);

    displayModalDialog(flashPlayer, actions, title, sourceComponent, context,
        dimension, reuseCurrent);
  }

  /**
   * {@inheritDoc}
   */
  public void displayModalDialog(final JComponent mainView,
      final List<Action> actions, final String title,
      final JComponent sourceComponent, final Map<String, Object> context,
      final Dimension dimension, final boolean reuseCurrent) {
    super.displayModalDialog(context, reuseCurrent);
    SwingUtilities.invokeLater(new Runnable() {

      public void run() {
        JDialog dialog;
        Window window;
        if (sourceComponent != null) {
          window = SwingUtil.getVisibleWindow(sourceComponent);
        } else {
          window = controllerFrame;
        }
        boolean newDialog = true;
        if (window instanceof JDialog) {
          if (reuseCurrent) {
            dialog = (JDialog) window;
            dialog.getContentPane().removeAll();
            newDialog = false;
          } else {
            dialog = new JDialog((JDialog) window, title, true);
          }
        } else {
          dialog = new JDialog((Frame) window, title, true);
        }

        Box buttonBox = new Box(BoxLayout.LINE_AXIS);
        buttonBox.setBorder(new EmptyBorder(new Insets(5, 10, 5, 10)));

        JButton defaultButton = null;
        for (Action action : actions) {
          JButton actionButton = new JButton();
          SwingUtil.configureButton(actionButton);
          actionButton.setAction(action);
          buttonBox.add(actionButton);
          buttonBox.add(Box.createHorizontalStrut(10));
          if (defaultButton == null) {
            defaultButton = actionButton;
          }
        }
        JPanel actionPanel = new JPanel();
        actionPanel.setLayout(new BorderLayout());
        actionPanel.add(buttonBox, BorderLayout.EAST);

        if (dimension != null) {
          mainView.setPreferredSize(new java.awt.Dimension(
              dimension.getWidth(), dimension.getHeight()));
        }
        JPanel mainPanel = new JPanel();
        mainPanel.setLayout(new BorderLayout());
        mainPanel.add(mainView, BorderLayout.CENTER);
        mainPanel.add(actionPanel, BorderLayout.SOUTH);
        dialog.getContentPane().add(mainPanel);
        dialog.setDefaultCloseOperation(WindowConstants.DO_NOTHING_ON_CLOSE);
        if (defaultButton != null) {
          dialog.getRootPane().setDefaultButton(defaultButton);
        }
        dialog.pack();
        if (newDialog) {
          SwingUtil.centerInParent(dialog);
        }
        dialog.setVisible(true);
      }
    });
  }

  /**
   * {@inheritDoc}
   */
  public void displayUrl(String urlSpec) {
    try {
      BrowserControl.displayURL(urlSpec);
    } catch (IOException ex) {
      throw new ActionException(ex);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void displayWorkspace(String workspaceName) {
    if (!ObjectUtils.equals(workspaceName, getSelectedWorkspaceName())) {
      super.displayWorkspace(workspaceName);
      if (workspaceName != null) {
        if (workspaceInternalFrames == null) {
          workspaceInternalFrames = new HashMap<String, JInternalFrame>();
        }
        JInternalFrame workspaceInternalFrame = workspaceInternalFrames
            .get(workspaceName);
        if (workspaceInternalFrame == null) {
          IViewDescriptor workspaceNavigatorViewDescriptor = getWorkspace(
              workspaceName).getViewDescriptor();
          IValueConnector workspaceConnector = getBackendController()
              .getWorkspaceConnector(workspaceName);
          IView<JComponent> workspaceNavigator = createWorkspaceNavigator(
              workspaceName, workspaceNavigatorViewDescriptor);
          IView<JComponent> moduleAreaView = createModuleAreaView(workspaceName);
          JSplitPane workspaceView = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT);
          workspaceView.setOneTouchExpandable(true);
          workspaceView.add(workspaceNavigator.getPeer());
          workspaceView.add(moduleAreaView.getPeer());
          workspaceInternalFrame = createJInternalFrame(
              workspaceView,
              workspaceNavigatorViewDescriptor.getI18nName(
                  getTranslationProvider(), getLocale()),
              getIconFactory().getIcon(
                  workspaceNavigatorViewDescriptor.getIconImageURL(),
                  getIconFactory().getSmallIconSize()));
          workspaceInternalFrame
              .addInternalFrameListener(new WorkspaceInternalFrameListener(
                  workspaceName));
          workspaceInternalFrames.put(workspaceName, workspaceInternalFrame);
          desktopPane.add(workspaceInternalFrame);
          getMvcBinder().bind(workspaceNavigator.getConnector(),
              workspaceConnector);
          workspaceInternalFrame.pack();
          workspaceInternalFrame.setSize(controllerFrame.getWidth() - 50,
              controllerFrame.getHeight() - 50);
          try {
            workspaceInternalFrame.setMaximum(true);
          } catch (PropertyVetoException ex) {
            throw new ControllerException(ex);
          }
        }
        workspaceInternalFrame.setVisible(true);
        if (workspaceInternalFrame.isIcon()) {
          try {
            workspaceInternalFrame.setIcon(false);
          } catch (PropertyVetoException ex) {
            throw new ControllerException(ex);
          }
        }
        workspaceInternalFrame.toFront();
      }
    }
    updateFrameTitle();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void disposeModalDialog(JComponent sourceWidget,
      Map<String, Object> context) {
    super.disposeModalDialog(sourceWidget, context);
    Window actionWindow = SwingUtil.getVisibleWindow(sourceWidget);
    if (actionWindow instanceof JDialog) {
      actionWindow.dispose();
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean execute(IAction action, Map<String, Object> context) {
    if (action == null) {
      return true;
    }
    JComponent sourceComponent = (JComponent) context
        .get(ActionContextConstants.SOURCE_COMPONENT);
    Component windowOrInternalFrame = null;
    if (sourceComponent != null) {
      windowOrInternalFrame = SwingUtil
          .getWindowOrInternalFrame(sourceComponent);
    }
    if (windowOrInternalFrame instanceof JFrame) {
      ((JFrame) windowOrInternalFrame).getGlassPane().setVisible(true);
    } else if (windowOrInternalFrame instanceof JInternalFrame) {
      ((JInternalFrame) windowOrInternalFrame).getGlassPane().setVisible(true);
    } else if (windowOrInternalFrame instanceof JDialog) {
      ((JDialog) windowOrInternalFrame).getGlassPane().setVisible(true);
    }
    waitTimer.startTimer(sourceComponent);
    try {
      return super.execute(action, context);
    } finally {
      if (windowOrInternalFrame instanceof JFrame) {
        ((JFrame) windowOrInternalFrame).getGlassPane().setVisible(false);
      } else if (windowOrInternalFrame instanceof JInternalFrame) {
        ((JInternalFrame) windowOrInternalFrame).getGlassPane().setVisible(
            false);
      } else if (windowOrInternalFrame instanceof JDialog) {
        ((JDialog) windowOrInternalFrame).getGlassPane().setVisible(false);
      }
      waitTimer.stopTimer();
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean handleException(Throwable ex, Map<String, Object> context) {
    if (super.handleException(ex, context)) {
      return true;
    }
    Component sourceComponent = controllerFrame;
    if (ex instanceof SecurityException) {
      JOptionPane.showMessageDialog(sourceComponent,
          HtmlHelper.toHtml(HtmlHelper.emphasis(HtmlHelper.escapeForHTML(ex
              .getMessage()))),
          getTranslationProvider().getTranslation("error", getLocale()),
          JOptionPane.ERROR_MESSAGE,
          getIconFactory().getErrorIcon(getIconFactory().getLargeIconSize()));
    } else if (ex instanceof BusinessException) {
      JOptionPane.showMessageDialog(sourceComponent, HtmlHelper
          .toHtml(HtmlHelper.emphasis(HtmlHelper
              .escapeForHTML(((BusinessException) ex).getI18nMessage(
                  getTranslationProvider(), getLocale())))),
          getTranslationProvider().getTranslation("error", getLocale()),
          JOptionPane.ERROR_MESSAGE,
          getIconFactory().getErrorIcon(getIconFactory().getLargeIconSize()));
    } else if (ex instanceof DataIntegrityViolationException) {
      JOptionPane
          .showMessageDialog(
              sourceComponent,
              HtmlHelper.toHtml(HtmlHelper.emphasis(HtmlHelper
                  .escapeForHTML(getTranslationProvider()
                      .getTranslation(
                          refineIntegrityViolationTranslationKey((DataIntegrityViolationException) ex),
                          getLocale())))), getTranslationProvider()
                  .getTranslation("error", getLocale()),
              JOptionPane.ERROR_MESSAGE,
              getIconFactory()
                  .getErrorIcon(getIconFactory().getLargeIconSize()));
    } else if (ex instanceof ConcurrencyFailureException) {
      JOptionPane.showMessageDialog(sourceComponent, HtmlHelper
          .toHtml(HtmlHelper.emphasis(HtmlHelper
              .escapeForHTML(getTranslationProvider().getTranslation(
                  "concurrency.error.description", getLocale())))),
          getTranslationProvider().getTranslation("error", getLocale()),
          JOptionPane.ERROR_MESSAGE,
          getIconFactory().getErrorIcon(getIconFactory().getLargeIconSize()));
    } else {
      ex.printStackTrace();
      JErrorDialog dialog = JErrorDialog.createInstance(sourceComponent,
          getTranslationProvider(), getLocale());
      dialog.setMessageIcon(getIconFactory().getErrorIcon(
          getIconFactory().getMediumIconSize()));
      dialog.setTitle(getTranslationProvider().getTranslation("error",
          getLocale()));
      dialog.setMessage(HtmlHelper.toHtml(HtmlHelper.emphasis(HtmlHelper
          .escapeForHTML(ex.getLocalizedMessage()))));
      dialog.setDetails(ex);
      int screenRes = Toolkit.getDefaultToolkit().getScreenResolution();
      dialog.pack();
      dialog.setSize(8 * screenRes, 3 * screenRes);
      SwingUtil.centerOnScreen(dialog);
      dialog.setVisible(true);
    }
    return true;
  }

  /**
   * {@inheritDoc}
   */
  public void popupInfo(final JComponent sourceComponent, final String title,
      final String iconImageUrl, final String message) {
    // To have the same threading model than the other UI channels
    SwingUtilities.invokeLater(new Runnable() {

      public void run() {
        JOptionPane.showMessageDialog(
            SwingUtil.getWindowOrInternalFrame(sourceComponent),
            message,
            title,
            JOptionPane.INFORMATION_MESSAGE,
            getIconFactory().getIcon(iconImageUrl,
                getIconFactory().getLargeIconSize()));
      }
    });
  }

  // /**
  // * This method has been overriden to take care of long-running operations
  // not
  // * to have the swing gui blocked. It uses the foxtrot library to achieve
  // this.
  // * <p>
  // * {@inheritDoc}
  // */
  // @Override
  // protected final boolean executeBackend(final IAction action,
  // final Map<String, Object> context) {
  // if (action.isLongOperation()) {
  // Boolean success = (Boolean) SwingUtil.performLongOperation(new Job() {
  //
  // /**
  // * Decorates the super implementation with the foxtrot job.
  // * <p>
  // * {@inheritDoc}
  // */
  // @Override
  // public Object run() {
  // return new Boolean(protectedExecuteBackend(action, context));
  // }
  // });
  // return success.booleanValue();
  // }
  // return protectedExecuteBackend(action, context);
  // }

  // /**
  // * {@inheritDoc}
  // */
  // @Override
  // protected final boolean executeFrontend(final IAction action,
  // final Map<String, Object> context) {
  // return protectedExecuteFrontend(action, context);
  // }

  /**
   * {@inheritDoc}
   */
  public void popupOkCancel(final JComponent sourceComponent,
      final String title, final String iconImageUrl, final String message,
      final IAction okAction, final IAction cancelAction,
      final Map<String, Object> context) {
    // To have the same threading model than the other UI channels
    SwingUtilities.invokeLater(new Runnable() {

      public void run() {
        int selectedOption = JOptionPane.showConfirmDialog(
            SwingUtil.getWindowOrInternalFrame(sourceComponent),
            message,
            title,
            JOptionPane.OK_CANCEL_OPTION,
            JOptionPane.WARNING_MESSAGE,
            getIconFactory().getIcon(iconImageUrl,
                getIconFactory().getLargeIconSize()));
        IAction nextAction = null;
        if (selectedOption == JOptionPane.OK_OPTION) {
          nextAction = okAction;
        } else {
          nextAction = cancelAction;
        }
        if (nextAction != null) {
          execute(nextAction, context);
        }
      }
    });
  }

  /**
   * {@inheritDoc}
   */
  public void popupYesNo(final JComponent sourceComponent, final String title,
      final String iconImageUrl, final String message, final IAction yesAction,
      final IAction noAction, final Map<String, Object> context) {
    // To have the same threading model than the other UI channels
    SwingUtilities.invokeLater(new Runnable() {

      public void run() {
        int selectedOption = JOptionPane.showConfirmDialog(
            SwingUtil.getWindowOrInternalFrame(sourceComponent),
            message,
            title,
            JOptionPane.YES_NO_OPTION,
            JOptionPane.QUESTION_MESSAGE,
            getIconFactory().getIcon(iconImageUrl,
                getIconFactory().getLargeIconSize()));
        IAction nextAction = null;
        if (selectedOption == JOptionPane.YES_OPTION) {
          nextAction = yesAction;
        } else {
          nextAction = noAction;
        }
        if (nextAction != null) {
          execute(nextAction, context);
        }
      }
    });
  }

  /**
   * {@inheritDoc}
   */
  public void popupYesNoCancel(final JComponent sourceComponent,
      final String title, final String iconImageUrl, final String message,
      final IAction yesAction, final IAction noAction,
      final IAction cancelAction, final Map<String, Object> context) {
    // To have the same threading model than the other UI channels
    SwingUtilities.invokeLater(new Runnable() {

      public void run() {
        int selectedOption = JOptionPane.showConfirmDialog(
            SwingUtil.getWindowOrInternalFrame(sourceComponent),
            message,
            title,
            JOptionPane.YES_NO_CANCEL_OPTION,
            JOptionPane.QUESTION_MESSAGE,
            getIconFactory().getIcon(iconImageUrl,
                getIconFactory().getLargeIconSize()));
        IAction nextAction = null;
        if (selectedOption == JOptionPane.YES_OPTION) {
          nextAction = yesAction;
        } else if (selectedOption == JOptionPane.NO_OPTION) {
          nextAction = noAction;
        } else {
          nextAction = cancelAction;
        }
        if (nextAction != null) {
          execute(nextAction, context);
        }
      }
    });
  }

  /**
   * Creates the initial view from the root view descriptor, then a SFrame
   * containing this view and presents it to the user.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public boolean start(IBackendController backendController, Locale clientLocale) {
    if (super.start(backendController, clientLocale)) {
      waitTimer = new WaitCursorTimer(500);
      waitTimer.setDaemon(true);
      waitTimer.start();
      Toolkit.getDefaultToolkit().getSystemEventQueue()
          .push(new WaitCursorEventQueue(500));
      Toolkit.getDefaultToolkit().setDynamicLayout(true);
      NativeInterface.open();
      SwingUtilities.invokeLater(new Runnable() {

        public void run() {
          initLoginProcess();
        }
      });
      NativeInterface.runEventPump();
      return true;
    }
    return false;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean stop() {
    if (super.stop()) {
      if (controllerFrame != null) {
        controllerFrame.dispose();
      }
      System.exit(0);
      return true;
    }
    return false;
  }

  private JToolBar createApplicationToolBar() {
    JToolBar applicationToolBar = new JToolBar();
    applicationToolBar.setRollover(true);
    applicationToolBar.setFloatable(false);

    if (getWorkspaceNames() != null && !getWorkspaceNames().isEmpty()) {
      applicationToolBar.add(createComboButton(createWorkspaceActionList()));
    }
    applicationToolBar.addSeparator();
    if (getNavigationActions() != null
        && isAccessGranted(getNavigationActions())) {
      for (ActionList actionList : getNavigationActions().getActionLists(this)) {
        completeApplicationToolBar(applicationToolBar, actionList);
      }
    }
    if (getActionMap() != null && isAccessGranted(getActionMap())) {
      for (ActionList actionList : getActionMap().getActionLists(this)) {
        completeApplicationToolBar(applicationToolBar, actionList);
      }
    }
    applicationToolBar.add(Box.createHorizontalGlue());
    if (getHelpActions() != null && isAccessGranted(getHelpActions())) {
      for (ActionList actionList : getHelpActions().getActionLists(this)) {
        completeApplicationToolBar(applicationToolBar, actionList);
      }
    }
    JButton exitButton = new JButton();
    exitButton.setAction(getViewFactory().getActionFactory().createAction(
        getExitAction(), this, null, getLocale()));
    applicationToolBar.add(exitButton);
    return applicationToolBar;
  }

  private JToolBar createSecondaryApplicationToolBar() {
    JToolBar applicationToolBar = new JToolBar();
    applicationToolBar.setRollover(true);
    applicationToolBar.setFloatable(false);

    if (getSecondaryActionMap() != null) {
      for (ActionList actionList : getSecondaryActionMap().getActionLists(this)) {
        completeApplicationToolBar(applicationToolBar, actionList);
      }
    }
    return applicationToolBar;
  }

  private void completeApplicationToolBar(JToolBar applicationToolBar,
      ActionList actionList) {
    if (isAccessGranted(actionList)) {
      if (actionList.isCollapsable()) {
        applicationToolBar.add(createComboButton(actionList));
      } else {
        for (IDisplayableAction da : actionList.getActions()) {
          JButton b = new JButton();
          b.setAction(getViewFactory().getActionFactory().createAction(da,
              this, null, getLocale()));
          applicationToolBar.add(b);
        }
      }
      applicationToolBar.addSeparator();
    }
  }

  @SuppressWarnings("unused")
  private JMenuBar createApplicationMenuBar() {
    JMenuBar applicationMenuBar = new JMenuBar();
    List<JMenu> workspaceMenus = createMenus(createWorkspaceActionMap(), true);
    if (workspaceMenus != null) {
      for (JMenu workspaceMenu : workspaceMenus) {
        applicationMenuBar.add(workspaceMenu);
      }
    }
    List<JMenu> navigationMenus = createMenus(getNavigationActions(), true);
    if (navigationMenus != null) {
      for (JMenu navigationMenu : navigationMenus) {
        applicationMenuBar.add(navigationMenu);
      }
    }
    List<JMenu> actionMenus = createMenus(getActionMap(), false);
    if (actionMenus != null) {
      for (JMenu actionMenu : actionMenus) {
        applicationMenuBar.add(actionMenu);
      }
    }
    applicationMenuBar.add(Box.createHorizontalGlue());
    List<JMenu> helpActionMenus = createMenus(getHelpActions(), true);
    if (helpActionMenus != null) {
      for (JMenu helpActionMenu : helpActionMenus) {
        applicationMenuBar.add(helpActionMenu);
      }
    }
    return applicationMenuBar;
  }

  private void createControllerFrame() {
    controllerFrame = new JFrame();
    desktopPane = new JDesktopPane();
    controllerFrame.getContentPane().add(desktopPane, BorderLayout.CENTER);

    statusBar = new JLabel();
    statusBar.setBorder(BorderFactory.createEtchedBorder(EtchedBorder.LOWERED));
    statusBar.setVisible(false);
    controllerFrame.getContentPane().add(statusBar, BorderLayout.SOUTH);

    controllerFrame
        .setDefaultCloseOperation(WindowConstants.DO_NOTHING_ON_CLOSE);
    controllerFrame.setGlassPane(createHermeticGlassPane());
    controllerFrame.addWindowListener(new WindowAdapter() {

      /**
       * {@inheritDoc}
       */
      @Override
      public void windowClosing(@SuppressWarnings("unused") WindowEvent e) {
        execute(getExitAction(), createEmptyContext());
      }
    });
    controllerFrame.pack();
    int screenRes = Toolkit.getDefaultToolkit().getScreenResolution();
    int w = 12 * screenRes;
    int h = 8 * screenRes;
    if (getFrameWidth() != null) {
      w = getFrameWidth().intValue();
    }
    if (getFrameHeight() != null) {
      h = getFrameHeight().intValue();
    }
    controllerFrame.setSize(w, h);
    // controllerFrame.setSize(1100, 800);
    ImageIcon frameIcon = ((ImageIcon) getIconFactory().getIcon(
        getIconImageURL(), getIconFactory().getSmallIconSize()));
    if (frameIcon != null) {
      controllerFrame.setIconImage(frameIcon.getImage());
    }
    SwingUtil.centerOnScreen(controllerFrame);
    updateFrameTitle();
    controllerFrame.setVisible(true);
  }

  private JComponent createHermeticGlassPane() {
    JPanel glassPane = new JPanel();
    glassPane.setOpaque(false);
    glassPane.addMouseListener(new MouseAdapter() {
      // No-op
    });
    glassPane.addKeyListener(new KeyAdapter() {
      // No-op
    });
    return glassPane;
  }

  /**
   * Creates a new JInternalFrame and populates it with a view.
   * 
   * @param view
   *          the view to be set into the internal frame.
   * @return the constructed internal frame.
   */
  private JInternalFrame createJInternalFrame(JComponent view, String title,
      Icon frameIcon) {
    JInternalFrame internalFrame = new JInternalFrame(title);
    internalFrame.setFrameIcon(frameIcon);
    internalFrame.setResizable(true);
    internalFrame.setClosable(true);
    internalFrame.setMaximizable(true);
    internalFrame.setIconifiable(true);
    internalFrame.getContentPane().add(view, BorderLayout.CENTER);
    internalFrame.setDefaultCloseOperation(WindowConstants.HIDE_ON_CLOSE);
    internalFrame.setGlassPane(createHermeticGlassPane());
    return internalFrame;
  }

  // private boolean protectedExecuteBackend(IAction action,
  // Map<String, Object> context) {
  // return super.executeBackend(action, context);
  // }

  // private boolean protectedExecuteFrontend(IAction action,
  // Map<String, Object> context) {
  // return super.executeFrontend(action, context);
  // }

  private JMenu createMenu(ActionList actionList) {
    JMenu menu = new JMenu(actionList.getI18nName(getTranslationProvider(),
        getLocale()));
    if (actionList.getDescription() != null) {
      menu.setToolTipText(actionList.getI18nDescription(
          getTranslationProvider(), getLocale())
          + IActionFactory.TOOLTIP_ELLIPSIS);
    }
    menu.setIcon(getIconFactory().getIcon(actionList.getIconImageURL(),
        getIconFactory().getSmallIconSize()));
    for (JMenuItem menuItem : createMenuItems(actionList)) {
      menu.add(menuItem);
    }
    return menu;
  }

  private JMenuItem createMenuItem(IDisplayableAction action) {
    return new JMenuItem(getViewFactory().getActionFactory().createAction(
        action, this, null, getLocale()));
  }

  private JButton createComboButton(ActionList actionList) {
    JButton button;
    List<IDisplayableAction> actions = new ArrayList<IDisplayableAction>();
    for (IDisplayableAction action : actionList.getActions()) {
      if (isAccessGranted(action)) {
        actions.add(action);
      }
    }

    if (actions.isEmpty()) {
      return null;
    }
    if (actions.size() > 1) {
      button = new JComboButton(true);
    } else {
      button = new JButton();
    }
    Action action = getViewFactory().getActionFactory().createAction(
        actionList.getActions().get(0), this, null, getLocale());
    button.setAction(action);
    if (actions.size() > 1) {
      JPopupMenu popupMenu = new JPopupMenu();
      for (IDisplayableAction menuAction : actions) {
        popupMenu.add(createMenuItem(menuAction));
      }
      ((JComboButton) button).setArrowPopupMenu(popupMenu);
    }
    return button;
  }

  private List<JMenuItem> createMenuItems(ActionList actionList) {
    List<JMenuItem> menuItems = new ArrayList<JMenuItem>();
    for (IDisplayableAction action : actionList.getActions()) {
      if (isAccessGranted(action)) {
        menuItems.add(createMenuItem(action));
      }
    }
    return menuItems;
  }

  @SuppressWarnings("null")
  private List<JMenu> createMenus(ActionMap actionMap, boolean useSeparator) {
    List<JMenu> menus = new ArrayList<JMenu>();
    if (actionMap != null && isAccessGranted(actionMap)) {
      JMenu menu = null;
      for (ActionList actionList : actionMap.getActionLists(this)) {
        if (isAccessGranted(actionList)) {
          if (!useSeparator || menus.isEmpty()) {
            menu = createMenu(actionList);
            menus.add(menu);
          } else {
            menu.addSeparator();
            for (JMenuItem menuItem : createMenuItems(actionList)) {
              menu.add(menuItem);
            }
          }
        }
      }
    }
    return menus;
  }

  private void initLoginProcess() {
    createControllerFrame();
    if (getLoginContextName() == null) {
      performLogin();
      updateControllerFrame();
      execute(getStartupAction(), getInitialActionContext());
      return;
    }

    IView<JComponent> loginView = createLoginView();

    // Login dialog
    final JDialog dialog = new JDialog(controllerFrame,
        getLoginViewDescriptor().getI18nName(getTranslationProvider(),
            getLocale()), true);
    dialog.setDefaultCloseOperation(WindowConstants.DO_NOTHING_ON_CLOSE);

    JPanel buttonBox = new JPanel();
    buttonBox.setLayout(new BoxLayout(buttonBox, BoxLayout.X_AXIS));
    buttonBox.setBorder(new EmptyBorder(new Insets(5, 10, 5, 10)));

    JButton loginButton = new JButton(getTranslationProvider().getTranslation(
        "ok", getLocale()));
    loginButton.setIcon(getIconFactory().getOkYesIcon(
        getIconFactory().getSmallIconSize()));
    loginButton.addActionListener(new ActionListener() {

      public void actionPerformed(@SuppressWarnings("unused") ActionEvent e) {
        if (performLogin()) {
          dialog.dispose();
          updateControllerFrame();
          execute(getStartupAction(), getInitialActionContext());
        } else {
          JOptionPane.showMessageDialog(dialog, getTranslationProvider()
              .getTranslation(LoginUtils.LOGIN_FAILED, getLocale()),
              getTranslationProvider().getTranslation("error", getLocale()),
              JOptionPane.ERROR_MESSAGE);
        }
      }
    });
    buttonBox.add(loginButton);
    dialog.getRootPane().setDefaultButton(loginButton);

    JButton exitButton = new JButton();
    exitButton.setAction(getViewFactory().getActionFactory().createAction(
        getExitAction(), this, null, getLocale()));
    exitButton.setIcon(getIconFactory().getCancelIcon(
        getIconFactory().getSmallIconSize()));
    buttonBox.add(exitButton);

    JPanel actionPanel = new JPanel(new BorderLayout());
    actionPanel.add(buttonBox, BorderLayout.EAST);

    JPanel mainPanel = new JPanel(new BorderLayout());
    mainPanel.add(
        new JLabel(getTranslationProvider().getTranslation(
            LoginUtils.CRED_MESSAGE, getLocale())), BorderLayout.NORTH);
    mainPanel.add(loginView.getPeer(), BorderLayout.CENTER);
    mainPanel.add(actionPanel, BorderLayout.SOUTH);
    dialog.add(mainPanel);

    dialog.pack();
    SwingUtil.centerInParent(dialog);
    dialog.setVisible(true);
  }

  private void updateControllerFrame() {
    // controllerFrame.setJMenuBar(createApplicationMenuBar());
    controllerFrame.getContentPane().add(createApplicationToolBar(),
        BorderLayout.NORTH);
    if (getSecondaryActionMap() != null
        && isAccessGranted(getSecondaryActionMap())) {
      controllerFrame.getContentPane().add(createSecondaryApplicationToolBar(),
          BorderLayout.SOUTH);
    }
    controllerFrame.invalidate();
    controllerFrame.validate();
    updateFrameTitle();
  }

  private void updateFrameTitle() {
    String workspaceName = getSelectedWorkspaceName();
    if (workspaceName != null) {
      controllerFrame.setTitle(getWorkspace(getSelectedWorkspaceName())
          .getViewDescriptor().getI18nDescription(getTranslationProvider(),
              getLocale())
          + " - " + getI18nName(getTranslationProvider(), getLocale()));
    } else {
      controllerFrame.setTitle(getI18nName(getTranslationProvider(),
          getLocale()));
    }
  }

  private final class WorkspaceInternalFrameListener extends
      InternalFrameAdapter {

    private String workspaceName;

    /**
     * Constructs a new <code>WorkspaceInternalFrameListener</code> instance.
     * 
     * @param workspaceName
     *          the workspace identifier this listener is attached to.
     */
    public WorkspaceInternalFrameListener(String workspaceName) {
      this.workspaceName = workspaceName;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void internalFrameActivated(
        @SuppressWarnings("unused") InternalFrameEvent e) {
      displayWorkspace(workspaceName);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void internalFrameClosed(
        @SuppressWarnings("unused") InternalFrameEvent e) {
      displayWorkspace(null);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void internalFrameClosing(
        @SuppressWarnings("unused") InternalFrameEvent e) {
      displayWorkspace(null);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void internalFrameDeactivated(
        @SuppressWarnings("unused") InternalFrameEvent e) {
      // displayWorkspace(null);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void internalFrameDeiconified(
        @SuppressWarnings("unused") InternalFrameEvent e) {
      displayWorkspace(workspaceName);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void internalFrameIconified(
        @SuppressWarnings("unused") InternalFrameEvent e) {
      // displayWorkspace(null);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void internalFrameOpened(
        @SuppressWarnings("unused") InternalFrameEvent e) {
      displayWorkspace(workspaceName);
    }
  }

  /**
   * {@inheritDoc}
   */
  public void setStatusInfo(String statusInfo) {
    if (statusInfo != null && statusInfo.length() > 0) {
      statusBar.setText(statusInfo);
      statusBar.setVisible(true);
    } else {
      statusBar.setVisible(false);
    }
  }

  /**
   * Returns a preference store based pon Java preferences API.
   * <p>
   * {@inheritDoc}
   */
  @Override
  protected IPreferencesStore createClientPreferenceStore() {
    return new JavaPreferencesStore();
  }
}

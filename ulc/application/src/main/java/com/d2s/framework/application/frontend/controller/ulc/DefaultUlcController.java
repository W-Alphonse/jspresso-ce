/*
 * Copyright (c) 2005 Design2see. All rights reserved.
 */
package com.d2s.framework.application.frontend.controller.ulc;

import java.io.IOException;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import javax.security.auth.callback.Callback;
import javax.security.auth.callback.CallbackHandler;
import javax.security.auth.callback.UnsupportedCallbackException;
import javax.security.auth.login.LoginContext;
import javax.security.auth.login.LoginException;

import com.d2s.framework.action.ActionContextConstants;
import com.d2s.framework.application.backend.IBackendController;
import com.d2s.framework.application.frontend.controller.AbstractFrontendController;
import com.d2s.framework.application.view.descriptor.IModuleDescriptor;
import com.d2s.framework.gui.ulc.components.server.ULCErrorDialog;
import com.d2s.framework.security.SecurityHelper;
import com.d2s.framework.security.ulc.DialogCallbackHandler;
import com.d2s.framework.security.ulc.ICallbackHandlerListener;
import com.d2s.framework.util.ulc.UlcUtil;
import com.d2s.framework.view.IIconFactory;
import com.d2s.framework.view.IView;
import com.d2s.framework.view.IViewFactory;
import com.ulcjava.base.application.AbstractAction;
import com.ulcjava.base.application.ApplicationContext;
import com.ulcjava.base.application.ClientContext;
import com.ulcjava.base.application.IAction;
import com.ulcjava.base.application.ULCAlert;
import com.ulcjava.base.application.ULCComponent;
import com.ulcjava.base.application.ULCDesktopPane;
import com.ulcjava.base.application.ULCFrame;
import com.ulcjava.base.application.ULCInternalFrame;
import com.ulcjava.base.application.ULCMenu;
import com.ulcjava.base.application.ULCMenuBar;
import com.ulcjava.base.application.ULCMenuItem;
import com.ulcjava.base.application.ULCPollingTimer;
import com.ulcjava.base.application.event.ActionEvent;
import com.ulcjava.base.application.event.WindowEvent;
import com.ulcjava.base.application.event.serializable.IActionListener;
import com.ulcjava.base.application.event.serializable.IWindowListener;
import com.ulcjava.base.application.util.ULCIcon;
import com.ulcjava.base.shared.IWindowConstants;

/**
 * Default implementation of a swing frontend controller. This implementation is
 * usable "as-is".
 * <p>
 * Copyright 2005 Design2See. All rights reserved.
 * <p>
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public class DefaultUlcController extends
    AbstractFrontendController<ULCComponent, ULCIcon, IAction> implements
    ICallbackHandlerListener {

  private ULCFrame                      controllerFrame;
  private Map<String, ULCInternalFrame> moduleInternalFrames;
  private Callback[]                    loginCallbacks;
  private ULCPollingTimer               loginTimer;
  private int                           loginRetries;
  private boolean                       loginSuccessful;
  private boolean                       loginComplete;

  /**
   * Creates the initial view from the root view descriptor, then a JFrame
   * containing this view and presents it to the user.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public boolean start(IBackendController backendController, Locale locale) {
    if (super.start(backendController, locale)) {
      loginRetries = 0;
      loginSuccessful = false;
      loginComplete = false;
      CallbackHandler callbackHandler = getLoginCallbackHandler();
      if (callbackHandler instanceof DialogCallbackHandler) {
        ((DialogCallbackHandler) callbackHandler)
            .setParentComponent(controllerFrame);
        ((DialogCallbackHandler) callbackHandler)
            .setCallbackHandlerListener(this);
      }
      performLogin();
      return true;
    }
    return false;
  }

  private void performLogin() {
    new LoginThread().start();
    loginTimer = new ULCPollingTimer(2000, new IActionListener() {

      private static final long serialVersionUID = 5630061795918376362L;

      public void actionPerformed(@SuppressWarnings("unused")
      ActionEvent event) {
        if (loginCallbacks != null) {
          Callback[] loginCallbacksCopy = loginCallbacks;
          loginCallbacks = null;
          try {
            getLoginCallbackHandler().handle(loginCallbacksCopy);
          } catch (IOException ex) {
            // NO-OP
          } catch (UnsupportedCallbackException ex) {
            // NO-OP
          }
        }
        if (loginComplete) {
          loginTimer.stop();
          loginTimer = null;
          ClientContext.sendMessage("appStarted");
          if (loginSuccessful) {
            displayControllerFrame();
          } else {
            stop();
          }
        }
      }
    });
    loginTimer.setInitialDelay(100);
    loginTimer.start();
  }

  private void displayControllerFrame() {
    controllerFrame = createControllerFrame();
    controllerFrame.pack();
    int screenRes = ClientContext.getScreenResolution();
    controllerFrame.setSize(12 * screenRes, 8 * screenRes);
    UlcUtil.centerOnScreen(controllerFrame);
    controllerFrame.setVisible(true);
  }

  /**
   * {@inheritDoc}
   */
  public void callbackHandlingComplete() {
    notifyWaiters();
  }

  private synchronized void waitForNotification() {
    try {
      wait();
    } catch (InterruptedException ex) {
      // NO-OP.
    }
  }

  private synchronized void notifyWaiters() {
    notifyAll();
  }

  private class ThreadBlockingCallbackHandler implements CallbackHandler {

    /**
     * {@inheritDoc}
     */
    public void handle(Callback[] callbacks) {
      loginCallbacks = callbacks;
      waitForNotification();
    }
  }

  private class LoginThread extends Thread {

    /**
     * {@inheritDoc}
     */
    @Override
    public void run() {
      while (!loginSuccessful && loginRetries < MAX_LOGIN_RETRIES) {
        LoginContext lc = null;
        try {
          lc = new LoginContext(getLoginContextName(),
              new ThreadBlockingCallbackHandler());
        } catch (LoginException le) {
          System.err.println("Cannot create LoginContext. " + le.getMessage());
        } catch (SecurityException se) {
          System.err.println("Cannot create LoginContext. " + se.getMessage());
        }
        try {
          lc.login();
          loginSuccess(lc.getSubject());
          loginSuccessful = true;
        } catch (LoginException le) {
          loginRetries++;
          System.err.println("Authentication failed:");
          System.err.println("  " + le.getMessage());
        }
      }
      loginComplete = true;
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean stop() {
    if (controllerFrame != null) {
      controllerFrame.setVisible(false);
    }
    ApplicationContext.terminate();
    return true;
  }

  private void displayModule(String moduleId) {
    if (moduleInternalFrames == null) {
      moduleInternalFrames = new HashMap<String, ULCInternalFrame>();
    }
    ULCInternalFrame moduleInternalFrame = moduleInternalFrames.get(moduleId);
    if (moduleInternalFrame == null) {
      IModuleDescriptor moduleDescriptor = getModuleDescriptor(moduleId);
      IView<ULCComponent> moduleView = createModuleView(moduleId,
          moduleDescriptor);
      moduleInternalFrame = createULCInternalFrame(moduleView);
      moduleInternalFrame.setFrameIcon(getIconFactory().getIcon(
          moduleDescriptor.getIconImageURL(), IIconFactory.SMALL_ICON_SIZE));
      moduleInternalFrames.put(moduleId, moduleInternalFrame);
      controllerFrame.getContentPane().add(moduleInternalFrame);
      getMvcBinder().bind(moduleView.getConnector(),
          getBackendController().getModuleConnector(moduleId));
      if (moduleDescriptor.getStartupAction() != null) {
        Map<String, Object> context = createEmptyContext();
        context.put(ActionContextConstants.MODULE_ROOT_CONNECTOR, moduleView
            .getConnector());
        execute(moduleDescriptor.getStartupAction(), context);
      }
      moduleInternalFrame.pack();
    }
    moduleInternalFrame.setVisible(true);
    if (moduleInternalFrame.isIcon()) {
      moduleInternalFrame.setIcon(false);
    }
    moduleInternalFrame.setMaximum(true);
    moduleInternalFrame.moveToFront();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected String getSelectedModuleId() {
    for (Map.Entry<String, ULCInternalFrame> moduleIdAndFrame : moduleInternalFrames
        .entrySet()) {
      if (moduleIdAndFrame.getValue() != null
          && moduleIdAndFrame.getValue().isSelected()) {
        return moduleIdAndFrame.getKey();
      }
    }
    return null;
  }

  private ULCFrame createControllerFrame() {
    ULCFrame frame = new ULCFrame(getI18nName(getTranslationProvider(),
        getLocale()));
    frame.setContentPane(new ULCDesktopPane());
    frame.setIconImage(getIconFactory().getIcon(getIconImageURL(),
        IIconFactory.SMALL_ICON_SIZE));
    frame.setDefaultCloseOperation(IWindowConstants.DO_NOTHING_ON_CLOSE);
    frame.setMenuBar(getApplicationMenuBar());
    frame.addWindowListener(new IWindowListener() {

      private static final long serialVersionUID = -7845554617417316256L;

      public void windowClosing(@SuppressWarnings("unused")
      WindowEvent event) {
        stop();
      }
    });
    return frame;
  }

  private ULCMenuBar getApplicationMenuBar() {
    ULCMenuBar applicationMenuBar = new ULCMenuBar();
    applicationMenuBar.add(getModulesMenu());
    return applicationMenuBar;
  }

  private ULCMenu getModulesMenu() {
    ULCMenu modulesMenu = new ULCMenu(getTranslationProvider().getTranslation(
        "modules", getLocale()));
    modulesMenu.setIcon(getIconFactory().getIcon(getModulesMenuIconImageUrl(),
        IIconFactory.SMALL_ICON_SIZE));
    for (String moduleId : getModuleIds()) {
      IModuleDescriptor moduleDescriptor = getModuleDescriptor(moduleId);
      ULCMenuItem moduleMenuItem = new ULCMenuItem(new ModuleSelectionAction(
          moduleId, moduleDescriptor));
      modulesMenu.add(moduleMenuItem);
    }
    modulesMenu.addSeparator();
    modulesMenu.add(new ULCMenuItem(new QuitAction()));
    return modulesMenu;
  }

  private final class ModuleSelectionAction extends AbstractAction {

    private static final long serialVersionUID = 3469745193806038352L;
    private String            moduleId;

    /**
     * Constructs a new <code>ModuleSelectionAction</code> instance.
     * 
     * @param moduleId
     * @param moduleDescriptor
     */
    public ModuleSelectionAction(String moduleId,
        IModuleDescriptor moduleDescriptor) {
      this.moduleId = moduleId;
      putValue(com.ulcjava.base.application.IAction.NAME, moduleDescriptor
          .getI18nName(getTranslationProvider(), getLocale()));
      putValue(com.ulcjava.base.application.IAction.SHORT_DESCRIPTION,
          moduleDescriptor.getI18nDescription(getTranslationProvider(),
              getLocale())
              + IViewFactory.TOOLTIP_ELLIPSIS);
      putValue(com.ulcjava.base.application.IAction.SMALL_ICON,
          getIconFactory().getIcon(moduleDescriptor.getIconImageURL(),
              IIconFactory.TINY_ICON_SIZE));
    }

    /**
     * displays the selected module.
     * <p>
     * {@inheritDoc}
     */
    @Override
    public void actionPerformed(@SuppressWarnings("unused")
    ActionEvent e) {
      try {
        SecurityHelper.checkAccess(getBackendController()
            .getApplicationSession().getSubject(),
            getModuleDescriptor(moduleId), getTranslationProvider(),
            getLocale());
        displayModule(moduleId);
      } catch (SecurityException ex) {
        handleException(ex, null);
      }
    }
  }

  private final class QuitAction extends AbstractAction {

    private static final long serialVersionUID = -1476651758085260422L;

    /**
     * Constructs a new <code>ModuleSelectionAction</code> instance.
     */
    public QuitAction() {
      putValue(com.ulcjava.base.application.IAction.NAME,
          getTranslationProvider().getTranslation("quit.name", getLocale()));
      putValue(com.ulcjava.base.application.IAction.SHORT_DESCRIPTION,
          getTranslationProvider().getTranslation("quit.description",
              getLocale()));
    }

    /**
     * displays the selected module.
     * <p>
     * {@inheritDoc}
     */
    @Override
    public void actionPerformed(@SuppressWarnings("unused")
    ActionEvent e) {
      stop();
    }
  }

  /**
   * Creates a new ULCInternalFrame and populates it with a view.
   * 
   * @param view
   *          the view to be set into the internal frame.
   * @return the constructed internal frame.
   */
  private ULCInternalFrame createULCInternalFrame(IView<ULCComponent> view) {
    ULCInternalFrame internalFrame = new ULCInternalFrame(view.getDescriptor()
        .getI18nName(getTranslationProvider(), getLocale()), true, false, true,
        true);
    internalFrame.getContentPane().add(view.getPeer());
    internalFrame.setDefaultCloseOperation(IWindowConstants.HIDE_ON_CLOSE);
    return internalFrame;
  }

  /**
   * {@inheritDoc}
   */
  public void handleException(Throwable ex, Map<String, Object> context) {
    if (ex instanceof SecurityException) {
      ULCAlert alert = new ULCAlert(controllerFrame, getTranslationProvider()
          .getTranslation("error", getLocale()), ex.getMessage(),
          getTranslationProvider().getTranslation("ok", getLocale()), null,
          null, getIconFactory().getErrorIcon(IIconFactory.LARGE_ICON_SIZE));
      alert.show();
    } else {
      ex.printStackTrace();
      ULCErrorDialog dialog = ULCErrorDialog.createInstance(
          (ULCComponent) context.get(ActionContextConstants.SOURCE_COMPONENT),
          getTranslationProvider(), getLocale());
      dialog.setMessageIcon(getIconFactory().getErrorIcon(
          IIconFactory.MEDIUM_ICON_SIZE));
      dialog.setTitle(getTranslationProvider().getTranslation("error",
          getLocale()));
      dialog.setMessage(ex.getLocalizedMessage());
      dialog.setDetails(ex);
      dialog.pack();
      dialog.setVisible(true);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected CallbackHandler createLoginCallbackHandler() {
    DialogCallbackHandler callbackHandler = new DialogCallbackHandler();
    callbackHandler.setLocale(getLocale());
    callbackHandler.setTranslationProvider(getTranslationProvider());
    callbackHandler.setIconFactory(getIconFactory());
    return callbackHandler;
  }
}

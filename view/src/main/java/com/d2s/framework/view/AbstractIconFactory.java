/*
 * Copyright (c) 2005 Design2see. All rights reserved.
 */
package com.d2s.framework.view;

import java.awt.Dimension;
import java.util.HashMap;
import java.util.Map;

/**
 * A factory for icons.
 * <p>
 * Copyright 2005 Design2See. All rights reserved.
 * <p>
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 * @param <E>
 *          the actual icon class created.
 */
public abstract class AbstractIconFactory<E> implements IIconFactory<E> {

  private Map<String, Map<Dimension, E>> iconStore;

  private String                         okYesIconImageURL;
  private String                         noIconImageURL;
  private String                         cancelIconImageURL;

  private String                         infoIconImageURL;
  private String                         warningIconImageURL;
  private String                         errorIconImageURL;

  /**
   * Constructs a new <code>AbstractIconFactory</code> instance.
   */
  protected AbstractIconFactory() {
    iconStore = new HashMap<String, Map<Dimension, E>>();
  }

  /**
   * Creates a swing icon from an image url.
   * 
   * @param urlSpec
   *          the url of the image to be used on the icon.
   * @param iconSize
   *          the size of the constructed icon. The image will be resized if
   *          nacessary to match the requested size.
   * @return the constructed icon.
   */
  protected abstract E createIcon(String urlSpec, Dimension iconSize);

  /**
   * {@inheritDoc}
   */
  public E getIcon(String urlSpec, Dimension iconSize) {
    Map<Dimension, E> multiDimStore = iconStore.get(urlSpec);
    if (multiDimStore == null) {
      multiDimStore = new HashMap<Dimension, E>();
      iconStore.put(urlSpec, multiDimStore);
    }
    E cachedIcon = multiDimStore.get(iconSize);
    if (cachedIcon == null) {
      cachedIcon = createIcon(urlSpec, iconSize);
      multiDimStore.put(iconSize, cachedIcon);
    }
    return cachedIcon;
  }

  /**
   * Sets the cancelIconImageURL.
   * 
   * @param cancelIconImageURL
   *          the cancelIconImageURL to set.
   */
  public void setCancelIconImageURL(String cancelIconImageURL) {
    this.cancelIconImageURL = cancelIconImageURL;
  }

  /**
   * Sets the errorIconImageURL.
   * 
   * @param errorIconImageURL
   *          the errorIconImageURL to set.
   */
  public void setErrorIconImageURL(String errorIconImageURL) {
    this.errorIconImageURL = errorIconImageURL;
  }

  /**
   * Sets the infoIconImageURL.
   * 
   * @param infoIconImageURL
   *          the infoIconImageURL to set.
   */
  public void setInfoIconImageURL(String infoIconImageURL) {
    this.infoIconImageURL = infoIconImageURL;
  }

  /**
   * Sets the noIconImageURL.
   * 
   * @param noIconImageURL
   *          the noIconImageURL to set.
   */
  public void setNoIconImageURL(String noIconImageURL) {
    this.noIconImageURL = noIconImageURL;
  }

  /**
   * Sets the okYesIconImageURL.
   * 
   * @param okYesIconImageURL
   *          the okYesIconImageURL to set.
   */
  public void setOkYesIconImageURL(String okYesIconImageURL) {
    this.okYesIconImageURL = okYesIconImageURL;
  }

  /**
   * Sets the warningIconImageURL.
   * 
   * @param warningIconImageURL
   *          the warningIconImageURL to set.
   */
  public void setWarningIconImageURL(String warningIconImageURL) {
    this.warningIconImageURL = warningIconImageURL;
  }

  /**
   * {@inheritDoc}
   */
  public E getCancelIcon(Dimension iconSize) {
    return getIcon(cancelIconImageURL, iconSize);
  }

  /**
   * {@inheritDoc}
   */
  public E getErrorIcon(Dimension iconSize) {
    return getIcon(errorIconImageURL, iconSize);
  }

  /**
   * {@inheritDoc}
   */
  public E getInfoIcon(Dimension iconSize) {
    return getIcon(infoIconImageURL, iconSize);
  }

  /**
   * {@inheritDoc}
   */
  public E getNoIcon(Dimension iconSize) {
    return getIcon(noIconImageURL, iconSize);
  }

  /**
   * {@inheritDoc}
   */
  public E getOkYesIcon(Dimension iconSize) {
    return getIcon(okYesIconImageURL, iconSize);
  }

  /**
   * {@inheritDoc}
   */
  public E getWarningIcon(Dimension iconSize) {
    return getIcon(warningIconImageURL, iconSize);
  }
}

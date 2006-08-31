/*
 * Copyright (c) 2005 Design2see. All rights reserved.
 */
package com.d2s.framework.util.url;

import java.net.MalformedURLException;
import java.net.URL;

import com.d2s.framework.util.exception.NestedRuntimeException;

/**
 * This is a simple helper class to be able to cope with "classpath:" urls.
 * <p>
 * Copyright 2005 Design2See. All rights reserved.
 * <p>
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public final class UrlHelper {

  private static final String CLASSPATH_URL     = "classpath:";
  private static final String JAR_URL           = "jar:";
  private static final String JAR_URL_SEPARATOR = "!/";

  private UrlHelper() {
    // private constructor for helper class.
  }

  /**
   * Creates a URL object.
   * 
   * @param urlSpec
   *          the string representation of the URL. In case of a classpath url
   *          the thread context classloader will be used.
   * @return the constructed URL or null.
   */
  public static URL createURL(String urlSpec) {
    return createURL(urlSpec, Thread.currentThread().getContextClassLoader());
  }

  /**
   * Creates a URL object.
   * 
   * @param urlSpec
   *          the string representation of the URL.
   * @param cl
   *          the class loader used to get the resource URL in case of a
   *          "classpath:" URL.
   * @return the constructed URL or null.
   */
  public static URL createURL(String urlSpec, ClassLoader cl) {
    if (urlSpec == null) {
      return null;
    }
    URL returnedURL = null;
    if (urlSpec.startsWith(JAR_URL) && urlSpec.indexOf(CLASSPATH_URL) > 0) {
      String entryPath = urlSpec.split(JAR_URL_SEPARATOR)[1];
      URL jarFileUrl = createURL(urlSpec.substring(JAR_URL.length(), urlSpec
          .indexOf(JAR_URL_SEPARATOR)), cl);
      try {
        returnedURL = new URL(JAR_URL + jarFileUrl.toString()
            + JAR_URL_SEPARATOR + entryPath);
      } catch (MalformedURLException ex) {
        throw new NestedRuntimeException(ex);
      }
    } else if (urlSpec.startsWith(CLASSPATH_URL)) {
      returnedURL = cl.getResource(urlSpec.substring(CLASSPATH_URL.length()));
    } else {
      try {
        returnedURL = new URL(urlSpec);
      } catch (MalformedURLException ex) {
        throw new NestedRuntimeException(ex);
      }
    }
    return returnedURL;
  }
}

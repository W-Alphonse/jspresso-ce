/*
 * Copyright (c) 2005 Design2see. All rights reserved.
 */
package com.d2s.framework.util.resources.server;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.d2s.framework.util.io.IoHelper;
import com.d2s.framework.util.resources.IResource;

/**
 * This servlet class returns the web resource which matches the specified id
 * request parameter requesting it to the resource manager.
 * <p>
 * Copyright 2005 Design2See. All rights reserved.
 * <p>
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public class ResourceProviderServlet extends HttpServlet {

  /**
   * the url pattern to activate a resource download.
   */
  public static final String DOWNLOAD_SERVLET_URL_PATTERN = "/download";

  /**
   * id.
   */
  public static final String ID_PARAMETER                 = "id";

  private static final long  serialVersionUID             = 5253634459280974738L;

  /**
   * {@inheritDoc}
   */
  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws IOException {
    String id = request.getParameter(ID_PARAMETER);

    if (id == null) {
      response.sendError(HttpServletResponse.SC_BAD_REQUEST,
          "No resource id specified.");
      return;
    }

    IResource resource = ResourceManager.getInstance().getRegistered(id);
    if (resource == null) {
      response.sendError(HttpServletResponse.SC_BAD_REQUEST,
          "Could not find specified resource id.");
      return;
    }

    response.setContentType(resource.getMimeType());
    int resourceLength = resource.getLength();
    if (resourceLength > 0) {
      response.setContentLength(resourceLength);
    }

    BufferedInputStream inputStream = new BufferedInputStream(resource
        .getContent());
    BufferedOutputStream outputStream = new BufferedOutputStream(response
        .getOutputStream());

    IoHelper.copyStream(inputStream, outputStream);

    inputStream.close();
    outputStream.close();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws IOException {
    doGet(request, response);
  }

  /**
   * Computes the url where the resource is available for download. .
   * 
   * @param request the incomming HTTP request.
   * @param id the resource id.
   * @return the rsource url.
   */
  public static String computeUrl(HttpServletRequest request, String id) {
    String baseUrl = request.getScheme() + "://" + request.getServerName()
        + ":" + request.getServerPort() + request.getContextPath()
        + DOWNLOAD_SERVLET_URL_PATTERN;
    return baseUrl + "?" + ResourceProviderServlet.ID_PARAMETER + "=" + id;
  }

}

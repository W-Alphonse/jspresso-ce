/*
 * Copyright (c) 2005-2012 Vincent Vandenschrick. All rights reserved.
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
package org.jspresso.framework.mockups;

import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;

import javax.sql.DataSource;

/**
 * Mock for DataSource.
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public class DataSourceMock implements DataSource {

  /**
   * Mock method.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public PrintWriter getLogWriter() throws SQLException {
    return null;
  }

  /**
   * Mock method.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public void setLogWriter(PrintWriter out) throws SQLException {
    // NO-OP
  }

  /**
   * Mock method.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public void setLoginTimeout(int seconds) throws SQLException {
    // NO-OP
  }

  /**
   * Mock method.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public int getLoginTimeout() throws SQLException {
    return 0;
  }

  /**
   * Mock method.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public <T> T unwrap(Class<T> iface) throws SQLException {
    return null;
  }

  /**
   * Mock method.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public boolean isWrapperFor(Class<?> iface) throws SQLException {
    return false;
  }

  /**
   * Mock method.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public Connection getConnection() throws SQLException {
    return null;
  }

  /**
   * Mock method.
   * <p>
   * {@inheritDoc}
   */
  @Override
  public Connection getConnection(String username, String password)
      throws SQLException {
    return null;
  }

}

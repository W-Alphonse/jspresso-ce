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
package org.jspresso.framework.util.i18n;

import java.text.MessageFormat;
import java.util.Locale;

import org.springframework.context.MessageSource;
import org.springframework.context.support.ResourceBundleMessageSource;

/**
 * Improves the default Spring RB message source to handle nested property like
 * keys. Before falling back to the default, the
 * EnhancedResourceBundleMessageSource will try to follow the property chain to
 * find a translation, e.g. : to translate address.city.zip, it will try, in
 * order : <li>address.city.zip <li>city.zip <li>zip
 * 
 * @version $LastChangedRevision$
 * @author Vincent Vandenschrick
 */
public class EnhancedResourceBundleMessageSource extends
    ResourceBundleMessageSource {

  private static final char DOT           = '.';
  private boolean           resolveNested = true;

  /**
   * Sets the resolveNested.
   * 
   * @param resolveNested
   *          the resolveNested to set.
   */
  public void setResolveNested(boolean resolveNested) {
    this.resolveNested = resolveNested;
  }

  /**
   * Delegates to super implementation (do not search for nested translations).
   * 
   * @param code
   *          the translation code.
   * @param locale
   *          the locale.
   * @return the translation.
   */
  protected final MessageFormat baseResolveCode(String code, Locale locale) {
    return super.resolveCode(code, locale);
  }

  /**
   * Delegates to super implementation (do not search for nested translations).
   * 
   * @param code
   *          the translation code.
   * @param locale
   *          the locale.
   * @return the translation.
   */
  protected final String baseResolveCodeWithoutArguments(String code,
      Locale locale) {
    return super.resolveCodeWithoutArguments(code, locale);
  }

  /**
   * Overriden so that we can explore the nested key chain for a translation
   * before actually going to the parent.
   * <p>
   * {@inheritDoc}
   */
  @Override
  protected MessageFormat resolveCode(String code, Locale locale) {
    String codePart = code;
    MessageFormat res = super.resolveCode(codePart, locale);
    if (res == null) {
      MessageSource parent = getParentMessageSource();
      if (parent instanceof EnhancedResourceBundleMessageSource) {
        res = ((EnhancedResourceBundleMessageSource) parent).baseResolveCode(
            code, locale);
      }
    }
    int dotIndex = codePart.indexOf(DOT);

    while (resolveNested && res == null && dotIndex > 0) {
      codePart = codePart.substring(dotIndex + 1);
      res = super.resolveCode(codePart, locale);
      if (res == null) {
        MessageSource parent = getParentMessageSource();
        if (parent instanceof EnhancedResourceBundleMessageSource) {
          res = ((EnhancedResourceBundleMessageSource) parent).baseResolveCode(
              code, locale);
        }
      }
      dotIndex = codePart.indexOf(DOT);
    }
    return res;
  }

  /**
   * Overriden so that we can explore the nested key chain for a translation
   * before actually going to the parent.
   * <p>
   * {@inheritDoc}
   */
  @Override
  protected String resolveCodeWithoutArguments(String code, Locale locale) {
    String codePart = code;
    String res = super.resolveCodeWithoutArguments(codePart, locale);
    if (res == null) {
      MessageSource parent = getParentMessageSource();
      if (parent instanceof EnhancedResourceBundleMessageSource) {
        res = ((EnhancedResourceBundleMessageSource) parent)
            .baseResolveCodeWithoutArguments(code, locale);
      }
    }
    int dotIndex = codePart.indexOf(DOT);

    while (resolveNested && res == null && dotIndex > 0) {
      codePart = codePart.substring(dotIndex + 1);
      res = super.resolveCodeWithoutArguments(codePart, locale);
      if (res == null) {
        MessageSource parent = getParentMessageSource();
        if (parent instanceof EnhancedResourceBundleMessageSource) {
          res = ((EnhancedResourceBundleMessageSource) parent)
              .baseResolveCodeWithoutArguments(code, locale);
        }
      }
      dotIndex = codePart.indexOf(DOT);
    }
    return res;
  }
}

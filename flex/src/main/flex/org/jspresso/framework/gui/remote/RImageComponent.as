/**
 * Copyright (c) 2005-2013 Vincent Vandenschrick. All rights reserved.
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
 */


package org.jspresso.framework.gui.remote {


[RemoteClass(alias="org.jspresso.framework.gui.remote.RImageComponent")]
public class RImageComponent extends RComponent {

  private var _scrollable:Boolean;
  private var _action:RAction;

  public function RImageComponent() {
    //default constructor.
  }

  public function set scrollable(value:Boolean):void {
    _scrollable = value;
  }

  public function get scrollable():Boolean {
    return _scrollable;
  }

  public function get action():RAction {
    return _action;
  }

  public function set action(value:RAction):void {
    _action = value;
  }

}
}

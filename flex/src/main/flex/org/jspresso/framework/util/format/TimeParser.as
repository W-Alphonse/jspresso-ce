/**
 * Copyright (c) 2005-2011 Vincent Vandenschrick. All rights reserved.
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

package org.jspresso.framework.util.format {
  import flexlib.scheduling.util.DateUtil;
  
  import org.jspresso.framework.util.lang.DateDto;
  
  public class TimeParser extends Parser {

    public function TimeParser() {
      //default constructor.
    }

    override public function parse(value:String, existingValue:Object = null):Object	{
      if(value == null || value.length == 0) {
        return null;
      }
      var parsedDate:Date = DateUtils.parseTime(value);
      if(parsedDate == null) {
        return existingValue;
      } else if(existingValue != null) {
        if(existingValue is Date) {
          var existingDate:Date = existingValue as Date;
          parsedDate.setFullYear(existingDate.fullYear, existingDate.month, existingDate.date);
        } else if(existingValue is DateDto) {
          var existingDateDto:DateDto = existingValue as DateDto;
          parsedDate.setFullYear(existingDateDto.year, existingDateDto.month, existingDateDto.date);
        }
      }
      if(existingValue is Date) {
        return parsedDate;
      } else {
        var parsedDateDto:DateDto = new DateDto();
        parsedDateDto.year = parsedDate.fullYear;
        parsedDateDto.month = parsedDate.month;
        parsedDateDto.date = parsedDate.date;
        parsedDateDto.hour = parsedDate.hours;
        parsedDateDto.minute = parsedDate.minutes;
        parsedDateDto.second = parsedDate.seconds;
        return parsedDateDto;
      }
    }
  }
}
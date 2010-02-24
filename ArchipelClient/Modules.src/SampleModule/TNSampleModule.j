/*  
 * TNViewHypervisorControl.j
 *    
 * Copyright (C) 2010 Antoine Mercadal <antoine.mercadal@inframonde.eu>
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
 
@import "../../TNModule.j";

@implementation TNSampleModule : TNModule 
{
    
}

- (void)willBeDisplayed
{
    // message sent when view will be added from superview;
    // MUST be declared
}

- (void)willBeUnDisplayed
{
   // message sent when view will be removed from superview;
   // MUST be declared
}

- (void)initializeWithContact:(TNStropheContact)aContact andRoster:(TNStropheRoster)aRoster
{
    [super initializeWithContact:aContact andRoster:aRoster]
    
    console.log("Module SAMPLE : " + self + " class " + [self className]);
    // do killers stuff
}
@end




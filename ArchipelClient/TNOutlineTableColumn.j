/*
 * TNOutlineTableColumn.j
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


/*! @ingroup archipelcore
    Subclass of CPView that represent a entry of level two in TNOutlineViewRoster (TNStropheContact, not groups)
*/
@implementation TNViewOutlineViewContact : CPView
{
    CPImageView statusIcon  @accessors;
    CPTextField events      @accessors;
    CPTextField name        @accessors;
    CPTextField show        @accessors;
    CPImageView avatar      @accessors;

    CPImage     _unknownUserImage;
    CPImage     _syncImage;
    CPImage     _syncingImage;
    CPImage     _normalStateCartoucheColor;
    CPImage     _selectedStateCartoucheColor;
    CPButton    _syncButton;
    
    TNStropheContact    _contact;
}

/*! initialize the class
    @return a initialized instance of TNViewOutlineViewContact
*/
- (id)init
{
    if (self = [super init])
    {
        var bundle = [CPBundle mainBundle];
        
        statusIcon  = [[CPImageView alloc] initWithFrame:CGRectMake(33, 3, 16, 16)];
        name        = [[CPTextField alloc] initWithFrame:CGRectMake(48, 2, 170, 100)];
        show        = [[CPTextField alloc] initWithFrame:CGRectMake(33, 18, 170, 100)];
        events      = [[CPTextField alloc] initWithFrame:CGRectMake(170, 10, 23, 14)];
        avatar      = [[CPImageView alloc] initWithFrame:CGRectMake(0, 3, 29, 29)];
        
        _syncImage      = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"sync.png"] size:CGSizeMake(16, 16)];
        _syncingImage   = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"syncing.gif"] size:CGSizeMake(14, 14)];
        _syncButton     = [[CPButton alloc] initWithFrame:CGRectMake(170, 8, 16, 16)];

        _normalStateCartoucheColor = [CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"cartouche.png"]]];
        _selectedStateCartoucheColor = [CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"cartouche-selected.png"]]];
        
        [_syncButton setImage:_syncImage];
        [_syncButton setBordered:NO];
        [_syncButton setHidden:YES];
        [_syncButton setTarget:self];
        [_syncButton setAction:@selector(askVCard:)];

        [self addSubview:statusIcon];
        [self addSubview:name];
        [self addSubview:events];
        [self addSubview:show];
        [self addSubview:avatar];
        [self addSubview:_syncButton];

        
        [events setBackgroundColor:_normalStateCartoucheColor];
        [events setAlignment:CPCenterTextAlignment];
        [events setVerticalAlignment:CPCenterVerticalTextAlignment];
        [events setFont:[CPFont boldSystemFontOfSize:11]];
        [events setTextColor:[CPColor whiteColor]];

        [name setValue:[CPColor colorWithHexString:@"f2f0e4"] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateNormal];
        [name setValue:[CPColor whiteColor] forThemeAttribute:@"text-color" inState:CPThemeStateSelected];
        [name setValue:[CPFont boldSystemFontOfSize:12] forThemeAttribute:@"font" inState:CPThemeStateSelected];
        
        
        [show setValue:[CPColor colorWithHexString:@"f2f0e4"] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateNormal];
        [show setValue:[CPFont systemFontOfSize:9.0] forThemeAttribute:@"font" inState:CPThemeStateNormal];
        [show setValue:[CPColor colorWithHexString:@"808080"] forThemeAttribute:@"text-color" inState:CPThemeStateNormal];
        [show setValue:[CPColor whiteColor] forThemeAttribute:@"text-color" inState:CPThemeStateSelected];
        
        [events setValue:[CPFont boldSystemFontOfSize:12] forThemeAttribute:@"font" inState:CPThemeStateSelected];
        
        _unknownUserImage = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"user-unknown.png"]];
        
        [events setHidden:YES];
    }
    return self;
}

/*! Message used by CPOutlineView to set the value of the object
    @param aContact TNStropheContact to represent
*/
- (void)setObjectValue:(id)aContact
{
    _contact = aContact;
    var mainBounds = [self bounds];
    
    var boundsEvents        = [events frame];
    boundsEvents.origin.x   = mainBounds.size.width - 25;
    [events setFrame:boundsEvents];
    [events setAutoresizingMask:CPViewMinXMargin];
    
    var boundsSync          = [_syncButton frame];
    boundsSync.origin.x     = mainBounds.size.width - 20;
    [_syncButton setFrame:boundsSync];
    [_syncButton setAutoresizingMask:CPViewMinXMargin];
    
    if ([aContact status] == TNStropheContactStatusOffline)
    {
        [_syncButton setHidden:YES];
    }
    
    [name setStringValue:[aContact nickname]];
    [name sizeToFit];
    
    [show setStringValue:[aContact show]];
    [show sizeToFit];
    
    [[self statusIcon] setImage:[aContact statusIcon]];
    
    if ([aContact avatar]) 
        [[self avatar] setImage:[aContact avatar]];
    else
        [[self avatar] setImage:_unknownUserImage];
    
    var boundsName = [name frame];
    boundsName.size.width += 10;
    [name setFrame:boundsName];
    
    var boundsShow = [show frame];
    boundsShow.size.width += 10;
    [show setFrame:boundsShow];
    
    if ([aContact numberOfEvents] > 0)
    {
        [[self events] setHidden:NO];
        [[self events] setStringValue:[aContact numberOfEvents]];
    }
    else
    {
        [[self events] setHidden:YES];
        [_syncButton setHidden:YES];
    }

}

- (IBAction)askVCard:(id)sender
{
    var center  = [CPNotificationCenter defaultCenter];
    
    [_syncButton setImage:_syncingImage];
    [_contact getVCard];
    
    [center addObserver:self selector:@selector(didReceivedVCard:) name:TNStropheContactVCardReceivedNotification object:_contact];
}

- (void)didReceivedVCard:(CPNotification)aNotification
{
    var bundle  = [CPBundle mainBundle];
    var center  = [CPNotificationCenter defaultCenter];
    
    [_syncButton setImage:_syncImage];
    
    [center removeObserver:self name:TNStropheContactVCardReceivedNotification object:_contact]
}


/*! implement theming in order to allow change color of selected item
*/
- (void)setThemeState:(id)aState
{
    [super setThemeState:aState];
    [name setThemeState:aState];
    [show setThemeState:aState];
    [events setThemeState:aState];
    
    if (aState == CPThemeStateSelected)
    {
           [events setBackgroundColor:_selectedStateCartoucheColor];
    }
    if (aState == CPThemeStateNormal)
    {
           [events setBackgroundColor:_normalStateCartoucheColor];
    }
       
    if ((aState == CPThemeStateSelected) && ([_contact status] != TNStropheContactStatusOffline) && ([events isHidden] == YES))
        [_syncButton setHidden:NO];
    else
        [_syncButton setHidden:YES];
}

/*! implement theming in order to allow change color of selected item
*/
- (void)unsetThemeState:(id)aState
{
    [super unsetThemeState:aState];
    [name unsetThemeState:aState];
    [show unsetThemeState:aState];
    [events unsetThemeState:aState];
    
    if (aState == CPThemeStateSelected)
    {
        [_syncButton setHidden:YES];
        [events setBackgroundColor:_normalStateCartoucheColor];
    }
    else
    {
        [_syncButton setHidden:NO];
        [events setBackgroundColor:_selectedStateCartoucheColor];
    }
        
}

/*! CPCoder compliance
*/
- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];

    if (self)
    {
        _normalStateCartoucheColor = [aCoder decodeObjectForKey:@"_normalStateCartoucheColor"];
        _selectedStateCartoucheColor = [aCoder decodeObjectForKey:@"_selectedStateCartoucheColor"];
        
        _unknownUserImage   = [aCoder decodeObjectForKey:@"_unknownUserImage"];
        _syncButton         = [aCoder decodeObjectForKey:@"_syncButton"];
        _syncImage          = [aCoder decodeObjectForKey:@"_syncImage"];
        _syncingImage       = [aCoder decodeObjectForKey:@"_syncingImage"];
        name                = [aCoder decodeObjectForKey:@"name"];
        show                = [aCoder decodeObjectForKey:@"show"];
        statusIcon          = [aCoder decodeObjectForKey:@"statusIcon"];
        events              = [aCoder decodeObjectForKey:@"events"];
        avatar              = [aCoder decodeObjectForKey:@"avatar"];
    }

    return self;
}

/*! CPCoder compliance
*/
- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:_syncButton forKey:@"_syncButton"];
    [aCoder encodeObject:_syncImage forKey:@"_syncImage"];
    [aCoder encodeObject:_syncingImage forKey:@"_syncingImage"];
    [aCoder encodeObject:_unknownUserImage forKey:@"_unknownUserImage"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:show forKey:@"show"];
    [aCoder encodeObject:statusIcon forKey:@"statusIcon"];
    [aCoder encodeObject:events forKey:@"events"];
    [aCoder encodeObject:avatar forKey:@"avatar"];
    
    [aCoder encodeObject:_normalStateCartoucheColor forKey:@"_normalStateCartoucheColor"];
    [aCoder encodeObject:_selectedStateCartoucheColor forKey:@"_selectedStateCartoucheColor"];
}

@end


/*! @ingroup archipelcore
    Subclass of CPTableColumn. This is used to define the content of the TNOutlineViewRoster
*/
@implementation TNOutlineTableColumnLabel  : CPTableColumn
{
    CPOutlineView       _outlineView;
    CPView              _dataViewForOther;
    CPView              _dataViewForRoot;
}

/*! init the class
    @param anIdentifier CPString containing the CPTableColumn identifier
    @param anOutlineView CPOutlineView the outlineView where the column will be insered. This is used to know the level
*/
- (id)initWithIdentifier:(CPString)anIdentifier outlineView:(CPOutlineView)anOutlineView
{
    if (self = [super initWithIdentifier:anIdentifier])
    {
        _outlineView = anOutlineView;
        
        _dataViewForRoot = [[CPTextField alloc] init];
        
        [_dataViewForRoot setFont:[CPFont boldSystemFontOfSize:12]];
        [_dataViewForRoot setTextColor:[CPColor colorWithHexString:@"5F676F"]];
        [_dataViewForRoot setValue:[CPColor whiteColor] forThemeAttribute:@"text-color" inState:CPThemeStateSelected];
        [_dataViewForRoot setValue:[CPFont boldSystemFontOfSize:12] forThemeAttribute:@"font" inState:CPThemeStateSelected];

        [_dataViewForRoot setAutoresizingMask: CPViewWidthSizable];
        [_dataViewForRoot setTextShadowOffset:CGSizeMake(0.0, 1.0)];

        [_dataViewForRoot setValue:[CPColor colorWithHexString:@"f4f4f4"] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateNormal];
        [_dataViewForRoot setValue:[CPColor colorWithHexString:@"7485a0"] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateSelected];

        [_dataViewForRoot setVerticalAlignment:CPCenterVerticalTextAlignment];

        _dataViewForOther = [[TNViewOutlineViewContact alloc] init];
    }

    return self;
}

/*! Return a dataview for item can be a CPTextField for groups or TNViewOutlineViewContact for TNStropheContact
    @return the dataview
*/
- (id)dataViewForRow:(int)aRowIndex
{
    var outlineViewItem = [_outlineView itemAtRow:aRowIndex];
    var itemLevel       = [_outlineView levelForItem:outlineViewItem];
    
    if (itemLevel == 0)
    {
        return _dataViewForRoot;
    }
    else
    {
        var bounds = [_dataViewForOther bounds];
        bounds.size.width = [_outlineView bounds].size.width;
        [_dataViewForOther setBounds:bounds];
        
        return _dataViewForOther;
    }

}
@end
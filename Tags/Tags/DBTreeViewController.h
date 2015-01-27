//
//  DBTreeViewController.h
//  Tags
//
//  Created by DB on 1/26/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

// NOTE: the bizarre gotcha here is that if you subclass this and overwrite
// treeView:shouldHighlightRowForItem: and don't call the super method,
// the treeview will stop adjusting properly when the keyboard pops up
//	-EDIT: nevermind, removed this functionality

#import <UIKit/UIKit.h>

#import <RATreeView.h>

@interface DBTreeViewController : UIViewController <RATreeViewDelegate>
@property (weak, nonatomic) RATreeView *treeView;

// this is a hack to let this know where to scroll to when the keyboard
// shows up...it really should be an internal var in a subclass that
// needs it; the reason it's necessary is this this class is agnostic
// of what makes keyboards pop up, so subclasses have to make sure that
// they set this for this class to automagically shrink the treeview
// and scroll to the right place. Wow, that was rambling.
@property(weak, nonatomic) UITableViewCell* cellInQuestion;
@end

//
//  LUActionRegistry.m
//  LunarConsole
//
//  Created by Alex Lementuev on 2/24/16.
//  Copyright © 2016 Space Madness. All rights reserved.
//

#import "Lunar.h"

#import "LUActionRegistry.h"

@interface LUActionRegistry()
{
    LUSortedList * _actions;
    LUSortedList * _variables;
}
@end

@implementation LUActionRegistry

+ (instancetype)registry
{
    return LU_AUTORELEASE([[self alloc] init]);
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _actions = [LUSortedList new];
        _variables = [LUSortedList new];
    }
    return self;
}

- (void)dealloc
{
    LU_RELEASE(_actions);
    LU_RELEASE(_variables);
    LU_SUPER_DEALLOC
}

#pragma mark -
#pragma mark Actions

- (LUAction *)registerActionWithId:(int)actionId name:(NSString *)actionName
{
    NSUInteger actionIndex = [self indexOfActionWithName:actionName];
    if (actionIndex == NSNotFound)
    {
        LUAction *action = [LUAction actionWithId:actionId name:actionName];
        actionIndex = [_actions addObject:action];
        [_delegate actionRegistry:self didAddAction:action atIndex:actionIndex];
    }
    
    return _actions[actionIndex];
}

- (BOOL)unregisterActionWithId:(int)actionId
{
    for (NSInteger actionIndex = _actions.count - 1; actionIndex >= 0; --actionIndex)
    {
        LUAction *action = _actions[actionIndex];
        if (action.actionId == actionId)
        {
            action = LU_AUTORELEASE(LU_RETAIN(action)); // no matter what they say, I still love you, MRC!
            [_actions removeObjectAtIndex:actionIndex];
            
            [_delegate actionRegistry:self didRemoveAction:action atIndex:actionIndex];
            
            return YES;
        }
    }
    
    return NO;
}

- (NSUInteger)indexOfActionWithName:(NSString *)actionName
{
    // TODO: more optimized search
    for (NSUInteger index = 0; index < _actions.count; ++index)
    {
        LUAction *action = _actions[index];
        if ([action.name isEqualToString:actionName])
        {
            return index;
        }
    }
    
    return NSNotFound;
}

#pragma mark -
#pragma mark Variables

- (LUCVar *)registerVariableWithId:(int)variableId name:(NSString *)name typeName:(NSString *)typeName value:(NSString *)value
{
    LUCVarType type = [LUCVar typeForName:typeName];
    if (type == LUCVarTypeUnknown)
    {
        NSLog(@"Unknown variable type: %@", typeName);
        return nil;
    }
    
    LUCVar *variable = [LUCVarFactory variableWithId:variableId name:name value:value type:type];
    NSInteger index = [_variables addObject:variable];
    [_delegate actionRegistry:self didRegisterVariable:variable atIndex:index];
    
    return variable;
}

- (LUCVar *)variableWithId:(int)variableId
{
    for (LUCVar *cvar in _variables)
    {
        if (cvar.actionId == variableId)
        {
            return cvar;
        }
    }
    
    return nil;
}

#pragma mark -
#pragma mark Properties

- (NSArray *)actions
{
    return _actions.innerArray;
}

- (NSArray *)variables
{
    return _variables.innerArray;
}

@end
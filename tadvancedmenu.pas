unit TAdvancedMenu;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls, ExtCtrls,
  dataTypes;

const
  MenuBackColor  = clWhite;//clSilver;//clWhite;           //menu背景颜色
  MenuItemTextColor  = clBlack;// menu文字颜色
  MenuHighlightColor =clInactiveCaption;// clMenuHighlight;//clInactiveCaption// clActiveCaption;   //激活时的颜色
  MenuItemHighlightTextColor = clBlack;       //激活时文字颜色

type

  TProcType      = procedure(const AParm: Integer) of object; //------------------// Method type
  TProcArray     = array of TProcType; //-----------------------------------------// Dynamic array
  TProc          = procedure(AParm: TObject) of object; //------------------------// also a procedure, but NOT a const param

  TNodePtr       = ^dataTypes.stringNodeStruct; //--------------------------------// Pointer to a menu struct

  { TAdvancedMainMenu }

  TAdvancedMainMenu = Class
  public
    MenuTree    : dataTypes.tree_ofStrings; //------------------------------------// Object tree
    MenuItemIDs : Array of Integer; //--------------------------------------------// IDs
    mainMenuRenderItems : Array of TPanel; //-----------------------------------// Panels used to render main Menu
    subMenuRenderItems  : Array of TPanel; //-----------------------------------// Panels used to render submenu of the main Menu
    subsubMenuRenderItems:Array of TPanel; //-----------------------------------// Panels used to render sub Menu of any further level(s)

    currentID   : Integer; //-----------------------------------------------------// the ID of the menu item currently being dealt with
    widthPadding: Integer;
    heightPadding : Integer;

    has_somethingOpen : Boolean;
    mPanels     : Array of TPanel;

    constructor Create();
    procedure create_mainMenu (var mainMenuItems : Array of String; var mainMenuNames : Array of String); // supply the Main Menu item labels and names
    procedure update_mainMenu_renderItemList(ii: Integer);
    procedure update_mainMenu_actionList(ii: Integer);

    procedure mainMenuItem_mouseEnter (Sender: TObject);
    procedure mainMenuItem_mouseExit(Sender: TObject);
    procedure toggleSubMenu (Sender: TObject);
    procedure paintDivider(Sender : TObject);

    procedure set_BGColor(nm: String; cl : TColor);
    procedure set_FGColor(nm: String; cl : TColor);


    procedure render(parent: TPanel);

    procedure add_mainMenuSubMenu_byName(targetName: String; var items: array of String; var itemNames: array of String);
    procedure update_subMenu_renderItemList(nm: String);
    procedure update_subMenu_renderItemActionList(name : String);

    procedure subMenuItem_mouseEnter (Sender: TObject);
    procedure subMenuItem_mouseExit (Sender: TObject);
    procedure subMenuChildItem_mouseEnter(Sender: TObject);
    procedure subMenuChildItem_mouseExit (Sender: TObject);

    procedure add_subMenuCheckBox(name: String; state: Boolean);
    procedure add_subMenuPicture(name: String; path: String);
    procedure assign_subMenuShortCut(name : String; shortCut : String);



    procedure add_subMenuSubMenu_byName(targetName: String; var items: array of String; var itemNames: array of String);
    // procedure update_subSubMenu_renderItemList(nm: String);

    procedure add_clickAction_byName(name: String; action: TProc);


    procedure hello(Sender : TObject);

    function get_uniqueID() : Integer;
    function check_existingMainMenu() : Integer;
    procedure update_IDArray(ii_id : Integer);
    function locate_menuNode_byID(ii_id: Integer): TNodePtr;
    function locate_renderItemPanel_byName(nm : String) : TPanel;
    function locate_menuNode_fromPanelName(name : String) : TNodePtr;
    function locate_menuNode_byName(nm: String): TNodePtr;
    function locate_subMenuItemPanel_inParentsExtendedSubMenuPanel_byName(nm: String) : TNodePtr;
    function locate_subMenuPanel_byName(nm : String) : TPanel;



  end;
  function locate_integerItem(needle: Integer; haystack : Array of Integer ) : Integer;

implementation

{ TAdvancedMainMenu }

constructor TAdvancedMainMenu.Create;
begin
  //----------------------------   INITIALIZE VALUES    --------------------------//
  currentID     := 0;                                                             // SET ID COUNTER to ZERO.
                                                                                  // EVERY time a menu item (regardless main menu or submenu)
                                                                                  // the counter will be incremented,guaranteeing an unique ID.
                                                                                  // This id will be inserted to the newly created menu Object.
                                                                                  // The Menu Object is also created with an unique name
                                                                                  // (the programmer ensures that the name is unique),
                                                                                  // So when referring to the Menu Object by name, we can
                                                                                  // look up the unique ID.


  //----------------------------   INITIALIZE CONTAINERS  ------------------------//

  MenuTree      := Nil;                                                           // PROBABLY unnecessary.
  MenuTree      := dataTypes.tree_ofStrings.Create();                             // Create a new Menu Tree.

  SetLength(MenuItemIds,0);                                                       // PROBABLY unnecessary.
  SetLength(mainMenuRenderItems, 0);                                              // PROBABLY unnecessary.
  SetLength(subMenuRenderItems, 0);                                               // PROBABLY unnecessary.
  SetLength(subsubMenuRenderItems, 0);                                            // PROBABLY unnecessary.


  //----------------------------   INITIALIZE DRAWING PARAMS ---------------------//

  heightPadding := 0;//lbz 8                                                             // These values are used.
  widthPadding  := 8;

  has_somethingOpen := False;                                                     // Indicate if some submenu is open or not
  mPanels       := [];

end;

procedure TAdvancedMainMenu.create_mainMenu(var mainMenuItems: array of String; var mainMenuNames: array of String);
var
  i             : Integer;                                                        // Here we have some dummy variables.
  ii            : Integer;
  ii_id         : Integer;
begin
  //-----------------------    If main menu exists, then exit       --------------// To create a new main menu, overwrite the existing or add items one by one
  if ( check_existingMainMenu() = 1 ) then
  begin
    Exit;
  end;
  //------    Otherwise Loop over everything that is being inserted       --------//
  for ii := 0 to length(mainMenuItems) -1 do  // ---------------------------------// Loop over everything that is being inserted.
  begin
    ii_id       :=      get_uniqueID();  //---------------------------------------// Get new unique ID
                                                                                  // This automatically updates all the necessary the ID flags
    //-- Each string packed in a record, and appended to the doubly linked list --//
    menuTree.AppendString_asNode(mainMenuItems[ii], mainMenuNames[ii], ii_id);    // Inserts a Menu Item in the main double linked list with an Unique ID
    //---------------------    Main ID list populated       ----------------------//
    update_IDArray(ii_id) ; //----------------------------------------------------// Append to Item ID
    //-----------------    Render Item list populated       ----------------------// Create the Label/Panel etc, but DONT render
    update_mainMenu_renderItemList(ii_id);
    //-----------------    Action Item list populated       ----------------------// Insert Default Actions
    update_mainMenu_actionList(ii_id);
  end;
end;

procedure TAdvancedMainMenu.update_mainMenu_renderItemList(ii: Integer);
var
  currNode      : TNodePtr;

  mPanel        : TPanel;
  mLabel        : TLabel;
  c             : TBitMap;
begin
  //-------------------    get the Node, given the ID        ---------------------// TPanel
  currNode      := locate_menuNode_byID(ii);
  //-------------------    Create menuItem container Panel   ---------------------// TPanel
  mPanel        := TPanel.Create(nil); //---------------------------------------// The main Panel (so that we can also add checkboxes and radios)
                                                                                // ALTHOUGH the main menu should not contain any of that
  mPanel.Parent := nil;
  mPanel.Top    := heightPadding  ; //--------------------------------------------// Constant padding on the top. this is not user controllable
  //mPanel.Border.Style:=bboNone;
  mPanel.BevelOuter:=bvNone; //---------------------------------------------------// Otherwise, a border will be drawn
  mPanel.Name   := currNode^.name + 'panel'; //-----------------------------------// The name
  mPanel.Caption:= ''; //---------------------------------------------------------// Otherwise this will render the internal name on top of the text label

  if ( length(mainMenuRenderItems) = 0) then //-----------------------------------// If no other main Menu items so far
  begin
    mPanel.Left := 0; //----------------------------------------------------------// Left = 0
  end
  else
  begin
    mPanel.Left := mainMenuRenderItems[length(mainMenuRenderItems) - 1].Left + mainMenuRenderItems[length(mainMenuRenderItems) - 1].Width + 0; // left = right of the last containing panel
  end;

  //-------------------    Create menuItem Display Label     ---------------------// TLabel
  mLabel        := TLabel.Create(mPanel); //------------------------------------// The label to contain the text of the menu item
  mLabel.Parent := mPanel;
  //mLabel.Top:=1;
  mLabel.Caption:= '  ' + currNode^.stringVal + '  '; //--------------------------// Caption
  mLabel.Name   := currNode^.name ; //--------------------------------------------// The name of the label remains as the internal identifier
  //mLabel.Font.Name := Screen.SystemFont.Name; //--------------------------------// Font is related to the label
  mLabel.Font := Screen.SystemFont; //--------------------------------// Font is related to the label
  //mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4; //----------------------// Label height
  //mPanel.Height := mLabel.Height; //----------------------------------------------// Panel height same as label height
  mLabel.Font.Color:= clWindowText; //------------------------------------------// Font color
  mLabel.Color:=MenuBackColor;///lbz .Background.Color  := clMenuBar;
  mLabel.Transparent:=true;//lbz
  mPanel.Color  :=MenuBackColor;//clWhite;// clMenuBar;--lbz
  //mLabel.Top    := (mLabel.Height) div 2;
  //mLabel.Top := (mPanel.Height - mLabel.Height) div 2;
  //lbz
  mLabel.AutoSize:=false;
  mLabel.Layout:=tlCenter;
  mLabel.Height:=mPanel.Height;
  //lbz

  c := TBitmap.Create;
  c.Canvas.Font.Assign(Screen.SystemFont);
  mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4; //---------------------// Label width
  mPanel.Width  := mLabel.Width; //-----------------------------------------------// panel width set to be the same
  c.Free;

  currNode^.BGColorOriginal:=MenuBackColor;//lbz clMenuBar;

  //-------------------    Insert menuItem container Panel   ---------------------// Insert to Array

  SetLength(MainMenuRenderItems, length(MainMenuRenderItems) +1);
  MainMenuRenderItems[length(MainMenuRenderItems) - 1] := mPanel;

end;

procedure TAdvancedMainMenu.update_mainMenu_actionList(ii: Integer);
var
  procMEnter    : TProc;
  procMExit     : TProc;
  procMClick    : TProc;
  mPanel        : TPanel;
  mLabel        : TLabel;
begin

  mPanel        := MainMenuRenderItems[ii]; //------------------------------------// The current main menu item
  mLabel        := mPanel.Controls[0] as TLabel; //-----------------------------// The current main menu item text label

  procMEnter    := @mainMenuItem_mouseEnter ; //----------------------------------// ON MOUSE ENTER
  mLabel.OnMouseEnter:= procMEnter; //--------------------------------------------// do this

  procMExit     := @mainMenuItem_mouseExit; //--------------------------------------------// ON MOUSE LEAVE
  mLabel.OnMouseLeave:= procMExit ; //--------------------------------------------// do this

  procMClick    := @toggleSubMenu; //---------------------------------------------// ON MOUSE CLICK
  mLabel.OnClick:= procMClick; //-------------------------------------------------// do this

end; //###########################################################################// End of Function

procedure TAdvancedMainMenu.mainMenuItem_mouseEnter(Sender: TObject);
var
  i             : Integer;
  j             : Integer;
  k             : Integer;

  currNode      : TNodePtr;
  otherNode     : TNodePtr;
  mustOpenCurr  : Boolean;

  otherLabel    : TLabel;
  mPanel        : TPanel;
begin

  //-------   Given the Sender (MainMenu TLabel) find the associated node ------// THIS APPLIES ONLY FOR THE MAIN MENU
  mPanel        := locate_renderItemPanel_byName((Sender as TLabel).Name); //---// Locate the container panel from mainmenu panel array
                                                                                  // The mainmenu panel array is global
  currNode      := locate_menuNode_byName((Sender as TLabel).Name); //----------// Get the Node that contains the menu
  //--------------------- Find the colors and other flags ------------------------//
  //-------------------------- Highlight the colors ------------------------------//
  (Sender as TLabel).Transparent:=false; //lbz
  (Sender as TLabel).Color :=MenuHighlightColor;// clActiveCaption; //--------------------// Set the highlight color
  mPanel.Color:= MenuHighlightColor;//lbz
  //(Sender as TLabel).Background.Style := bbsColor; //---------------------------// Otherwise color is not updated
  //------------- close submenus ONLY if enters another main menu  ---------------//
  otherNode     := MenuTree.root; //----------------------------------------------// Placeholder for all other nodes that we will check
                                                                                  // If any other node has a open submenu,
                                                                                  // then on mouseentry to this menu, the open submenu will be closed
                                                                                  // and the current main menu submenu will be opened up.
                                                                                  // Start searching at the main meni route.
  otherNode^.isSubMenuDrawn := False; //------------------------------------------// Update the relevant flags.
  (otherNode^.subMenuContainer as TPanel).Visible:=False; //--------------------// Close open menu. Generally, only one will be open

  if otherNode^.subMenuContainer <> Nil then
  begin
    for j := 0 to (otherNode^.subMenuContainer as TPanel).ControlCount - 1 do
    begin
      ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Color:=MenuBackColor;// clBackground ;
      for k := 0 to ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).ControlCount - 1 do
      begin
        if ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] is TLabel then
        begin
          (((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] as TLabel).Color:=MenuBackColor;//clBackground ;
        end;
      end;
    end;
  end;

  if (otherNode^.Parent = Nil) and (otherNode <> currNode) then
  begin
    otherLabel    := locate_renderItemPanel_byName(otherNode^.Name).Controls[0] as TLabel;
    otherLabel.Color := otherNode^.BGColorOriginal; //-----------------// Since mouse entered a specific menu, turn off highligh color of all other menus
  end;

  while(true) do //---------------------------------------------------------------// Search whether any Child Menu is open
  begin
    if Length(otherNode^.Children)<> 0 then //------------------------------------// If has children
    begin
      otherNode := otherNode^.Children[0]; //-------------------------------------// Pick the child
      if otherNode^.isSubMenuDrawn then //----------------------------------------// Submenu container could be nil. but
                                                                                  // If this flag is set,
                                                                                  // then submenu container was created
                                                                                  // And THUS Can't be nil
      begin
        (otherNode^.subMenuContainer as TPanel).Visible:=False; //--------------// Force off
        otherNode^.isSubMenuDrawn := False; //------------------------------------// Turn off flag
        if otherNode^.subMenuContainer <> Nil then
        begin
          for j := 0 to (otherNode^.subMenuContainer as TPanel).ControlCount - 1 do
          begin
            ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Color:=MenuBackColor;//clBackground ;
            for k := 0 to ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).ControlCount - 1 do
            begin
              if ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] is TLabel then
              begin
                (((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] as TLabel).Color:=MenuBackColor;//clBackground ;
              end;
            end;
          end;
        end;
      end;

      if (otherNode^.Parent = Nil) and (otherNode <> currNode) then
      begin
        otherLabel    := locate_renderItemPanel_byName(otherNode^.Name).Controls[0] as TLabel;
        otherLabel.Color := otherNode^.BGColorOriginal; //-------------// Since mouse entered a specific menu, turn off highligh color of all other menus
      end;
      Continue; //----------------------------------------------------------------// Continue to see if any other level of submenu is open
    end;
    //----------------------------------------------------------------------------// IF AT THIS POINT, THEN THERE'S NO CHILD
                                                                                  // BUT POSSIBLY, CONTROL IS AT A DEEPER SUBMENU LEVEL,
                                                                                  // WHERE A NON-ZERO INDEX CHILD WAS OPENED.
                                                                                  // HOWEVER, THE DFS ABOVE SO FAR LOOKED AT THE
                                                                                  // CHILD MENU INDEX 0 ONLY. SO SCAN OTHER INDICES ALSO

    if otherNode^.next <> Nil then  //--------------------------------------------// If there's a 'next' item, take it
    begin
      otherNode := otherNode^.next;
      if otherNode^.isSubMenuDrawn then //----------------------------------------// again, if the flag is set = menu container is created
      begin
        (otherNode^.subMenuContainer as TPanel).Visible:=False; //--------------// Turn off
        otherNode^.isSubMenuDrawn := False;
        if otherNode^.subMenuContainer <> Nil then
        begin
          for j := 0 to (otherNode^.subMenuContainer as TPanel).ControlCount - 1 do
          begin
            ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Color:=MenuBackColor;//clBackground ;
            for k := 0 to ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).ControlCount - 1 do
            begin
              if ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] is TLabel then
              begin
                (((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] as TLabel).Color:=MenuBackColor;//clBackground ;
              end;
            end;
          end;
        end;
      end;
      if (otherNode^.Parent = Nil) and (otherNode <> currNode) then
      begin
        otherLabel    := locate_renderItemPanel_byName(otherNode^.Name).Controls[0] as TLabel;
        otherLabel.Color := otherNode^.BGColorOriginal; //-------------// Since mouse entered a specific menu, turn off highligh color of all other menus
      end;
      Continue;
    end;
    //----------------------------------------------------------------------------// IF AT THIS POINT, THE DFS HAS LOOKED AT A LEVEL
                                                                                  // WITHOUT A CHILD OR A NEXT
                                                                                  // BUT MAY BE DFS FOLLOWED THE WRONG BRACH UNTIL NOW
                                                                                  // SO GO ONE STEP BACK  AND TRY TO FIND THE NEXT BRANCH
    if otherNode^.Parent <> Nil then //-------------------------------------------// If possible
    begin
      otherNode := otherNode^.Parent; //------------------------------------------// Go one step back
      if otherNode^.next <> Nil then  //------------------------------------------// If possible
      begin
        otherNode := otherNode^.next; //------------------------------------------// Take next item
        if otherNode^.isSubMenuDrawn then
        begin
          (otherNode^.subMenuContainer as TPanel).Visible:=False;
          otherNode^.isSubMenuDrawn := False;
        end;
        if (otherNode^.Parent = Nil) and (otherNode <> currNode) then
        begin
          otherLabel    := locate_renderItemPanel_byName(otherNode^.Name).Controls[0] as TLabel;
          otherLabel.Color := otherNode^.BGColorOriginal; //-----------// Since mouse entered a specific menu, turn off highligh color of all other menus
          if otherNode^.subMenuContainer <> Nil then
          begin
            for j := 0 to (otherNode^.subMenuContainer as TPanel).ControlCount - 1 do
            begin
              ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Color:=MenuBackColor;//clBackground ;
              for k := 0 to ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).ControlCount - 1 do
              begin
                if ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] is TLabel then
                begin
                  (((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] as TLabel).Color:=MenuBackColor;//clBackground ;
                end;
              end;
            end;
          end;
        end;
        Continue;
      end;
    end;
    Break; //---------------------------------------------------------------------// If nothing is possible, then break.
  end;
  //-------------------- if flag is set, open it ---------------------------------//
  if (has_somethingOpen) then //--------------------------------------------------// If need to open the current menu
  begin
    if (currNode^.subMenuContainer <> nil) then //--------------------------------// If there is a submenu in the first place
    begin
      (currNode^.subMenuContainer as TPanel).Parent  := (Sender as TLabel).Parent.Parent.Parent; // reparent
      (currNode^.subMenuContainer as TPanel).Visible:=True; //------------------// Show
      currNode^.isSubMenuDrawn:= True; //-----------------------------------------// Update flags
    end;
  end;

end;

procedure TAdvancedMainMenu.mainMenuItem_mouseExit(Sender: TObject);
var
  otherLabel    : TLabel;
  otherNode     : TNodePtr;
  mPanel:TPanel;
begin
  otherLabel    := Sender as TLabel;
  otherNode     := locate_menuNode_byName((Sender as TLabel).Name); //----------// Get the Node that contains the menu
  //lbz
  mPanel:= locate_renderItemPanel_byName((Sender as TLabel).Name);
  mPanel.Color:=otherNode^.BGColorOriginal;
  otherLabel.Transparent:=true;
  //lbz
  if (otherNode^.isSubMenuDrawn ) then
  begin
    Exit;
  end;

  otherLabel.Color := otherNode^.BGColorOriginal; //-------------------// Since mouse entered a specific menu, turn off highligh color of all other menus
end;

procedure TAdvancedMainMenu.toggleSubMenu(Sender: TObject);
var
  currNode      : TNodePtr;
  nm            : String;
  i             : Integer;
  padding       : Integer;
  y             : Integer;
  x             : Integer;
  targetPanel   : TPanel;
begin
  currNode      := locate_menuNode_byName((Sender as TLabel).Name); //----------// After clicking on a display label to render a menu
                                                                                  // Get the corresponding node, using the name of the label
                                                                                  // label used to display a menu always has the same name
                                                                                  // as the menu node

  if (currNode^.subMenuContainer <> nil) then //----------------------------------// If there IS a submenu container (the initial valu of which
                                                                                  // is nil, to be overwritten in when a submenu is added)
  begin
    if ( ( currNode^.subMenuContainer as TPanel).Visible = false) then //-------// If not visible
    begin
      ( currNode^.subMenuContainer as TPanel).Parent  := (Sender as TLabel).Parent.Parent.Parent;  // REPARENT. doing it once is sufficient
      ( currNode^.subMenuContainer as TPanel).Visible := True; //---------------// make it visible
      currNode^.isSubMenuDrawn := True; //----------------------------------------// Set the flag
      has_somethingOpen := True;

      for i := 0 to ( currNode^.subMenuContainer as TPanel).ControlCount - 1 do // Check if there is a divider line
      begin
        padding := 2;
        if (( currNode^.subMenuContainer as TPanel).Controls[i].Width = 0) then // If width is zero, then a divider line.
        begin
          (currNode^.subMenuContainer as TPanel).Controls[i].Width:=( currNode^.subMenuContainer as TPanel).Width - 2*padding;
                                                //--------------------------------// Outer container of all submenu items
                                                                                  // has got the proper width
                                                                                  // which is adjusted to the largest of submenu label
                                                                                  // but the divider submenu items with original width
                                                                                  // = 0 need to be adjusted to have uniform width
          targetPanel := ((currNode^.subMenuContainer as TPanel).Controls[i] as TPanel);
          targetPanel.OnPaint:=@paintDivider;
        end;
      end; //---------------------------------------------------------------------// This part would have sufficed to run once
      //############# REFACTOR THIS PART #########################################
      //## SEE if this can be modified to run ONLY ONCE ##########################
    end
    else //-----------------------------------------------------------------------// Otherwise if already visible :
    begin
      ( currNode^.subMenuContainer as TPanel).Visible := False; //--------------// TURN OFF
      currNode^.isSubMenuDrawn := False; //---------------------------------------// Remove the flag
      has_somethingOpen := False;
      //----- TODO : IF CONSTANT REPARENTING CAUSED A PROBLEM, UNPARENT HERE -----//
    end;
  end;

end;

procedure TAdvancedMainMenu.paintDivider(Sender: TObject);
var
  targetPanel : TPanel;
begin
  targetPanel := (Sender as TPanel);
  targetPanel.Canvas.Pen.Color := clGrayText;
  //targetPanel.Height           := 18;
  targetPanel.Canvas.Line(0, targetPanel.Height div 2, targetPanel.Width, targetPanel.Height div 2);;
end;

procedure TAdvancedMainMenu.set_BGColor(nm: String; cl: TColor); //---------------// Overwrite default BG Color of main menu
var
  mPanel        : TPanel;
  currNode      : TNodePtr;
begin
  mPanel        := locate_renderItemPanel_byName(nm);
  mPanel.Color:= cl;//lbz
  //mPanel.Background.Color:= cl;
  currNode      := locate_menuNode_byName(nm);
  currNode^.BGColorOriginal := cl;
  //(mPanel.Controls[0] as TLabel).Background.Color:=cl;
end;

procedure TAdvancedMainMenu.set_FGColor(nm: String; cl: TColor); //---------------// Overwrite default FG Color of main menu
var
  mPanel        : TPanel;
  currNode      : TNodePtr;
begin
  mPanel        := locate_renderItemPanel_byName(nm);
  if (mPanel = nil) then Exit;
  currNode      := locate_menuNode_byName(nm);
  currNode^.FGColorOriginal := cl;
  (mPanel.Controls[0] as TLabel).Font.Color:=cl;
end;

procedure TAdvancedMainMenu.render(parent: TPanel);
var
  mPanel        : TPanel;
  i             : Integer;
  j             : Integer;
  nm            : String;
  currNode      : TNodePtr;

  chldNode      : TNodePtr;
begin
  for i := 0 to length(MainMenuRenderItems) -1 do
  begin
    mPanel      := MainMenuRenderItems[i];  //------------------------------------// The current main menu item
    mPanel.Height:=parent.Height;//lbz
    nm          :=  (mPanel.Controls[0] as TLabel).Name; //---------------------// Get the unique name that is associated with the label
    currNode    :=  locate_menuNode_byName(nm);

    if (currNode^.Parent <> nil) then //------------------------------------------// If it has a parent, it can't be main menu
    begin
      Continue; //----------------------------------------------------------------// Thus continue with the next one
    end;
    mPanel.Parent := parent; //---------------------------------------------------// Set the parent where it will be drawn
  end;
end;

procedure TAdvancedMainMenu.add_mainMenuSubMenu_byName(targetName: String; var items: array of String; var itemNames: array of String);
var
  ii            : Integer;
  currNode      : ^dataTypes.stringNodeStruct;
  ii_id         : Integer;
begin

  //--------------------   Locate the Menu Item by name       --------------------//

  currNode      := locate_menuNode_byName(targetName); //-------------------------// We can use the function we wrote


  if currNode = nil then Exit; //-------------------------------------------------// Did not Find it

  for ii := 0 to length(items) -1 do
  begin
    ii_id       := get_uniqueID(); //---------------------------------------------// Again, use a functionin stead

    menuTree.AppendString_asSubNode_byName(targetName, items[ii], itemNames[ii], ii_id);



    //---------------------    Main ID list populated       ----------------------//

    update_IDArray(ii_id) ; //----------------------------------------------------// Append to Item ID

  end;

  //-----------------    Render Item list populated       ------------------------// Do it once for ALL The submenus

  update_subMenu_renderItemList(targetName);

  //------------------    Action Item list populated       -----------------------// Insert Default Actions

  update_subMenu_renderItemActionList(targetName);

end;

procedure TAdvancedMainMenu.update_subMenu_renderItemList(nm: String);
var
  currNode      : TNodePtr;
  chldNode      : TNodePtr;
  ii_id         : Integer;
  i             : Integer;
  j             : Integer;
  k             : Integer;

  mPanel        : TPanel;
  cPanel        : TPanel;
  cPanels       : Array of TPanel;

  cLabel        : TLabel;
  maxCLabelWidth: Integer;
  sLabel        : TLabel;

  cImage        : TImage;
  cText         : TStaticText;
  cCheckBox     : TCheckBox;

  c             : TBitMap;
  cl            : TColor;

  willDrawDiv   : Boolean;

  ii            : Integer;
  tHeight       : Integer;
  lHeight       : Integer;
  padding       : Integer;
  maxWidth      : Integer;
begin
  //-----------    Get the name of the origin and the origin itself      ---------//
  currNode      :=  nil;
  currNode      :=  locate_menuNode_byName(nm); //--------------------------------// The menu node corresponding to the sender found
  willDrawDiv   := False;
  //--------------    Get the container of the click event sender    -------------//
  ii_id         := -1; //---------------------------------------------------------// Not found yet
  for ii := 0 to Length(MainMenuRenderItems) - 1 do //----------------------------// Loop over all the possible Items
  begin
     if (MainMenuRenderItems[ii].NAME = currNode^.name+'panel' ) then //----------// Container Panel found
     begin
       ii_id    := ii; //---------------------------------------------------------// record the index
       Break; //------------------------------------------------------------------// No need to continue searching..
     end;
  end;
  //-----------------    Check that submenu can be rendered    -------------------//
  if (ii_id = -1 ) and (currNode = nil) then //-----------------------------------// If did not find, then
  begin
    Exit; //----------------------------------------------------------------------// Exit
  end;
  if ( length(currNode^.Children) = 0) then //------------------------------------// If no renderable children...
  begin
    Exit; //----------------------------------------------------------------------// Exit as well
  end;
  //-------    Create the Main panel that would hold all the submenus    ---------//
  mPanel        := TPanel.create(Application.MainForm); //----------------------// Even if the main menu is drawn on a panel,
                                                                                  // submenu will be rendered on the main form anyway.
  //############# REFACTOR THIS PART ###########################################
  //## THIS WILL CAUSE A PROBLEM, IF FORM HEIGHT IS SMALLER THAN SUBMENU PANEL #

  mPanel.Parent := Application.MainForm; //---------------------------------------// Same as above
  mPanel.Color:=MenuBackColor;//lbz
  mPanel.Name   := currNode^.name + 'submenuPanel'; //----------------------------// Categorically assigning a unique name, but keeping
  if ( ii_id <> -1) then   //-----------------------------------------------------// it was found in the main menu
  begin
    mPanel.Left := MainMenuRenderItems[ii_id].Left;  //---------------------------// Set the left to be at the same place as the origin
    mPanel.Top  := MainMenuRenderItems[ii_id].Top + MainMenuRenderItems[ii_id].Height;   // Same logic
  end
  else
  begin
    // showMessage('For menu item : ' + currNode^.name + ' found id: ' + IntToStr(ii_id));
    mPanel.Left := ((currNode^.Parent)^.subMenuContainer as TPanel).Left+ ((currNode^.Parent)^.subMenuContainer as TPanel).Width;
                                                                             //---// Set the left to be at the right of

    { NOTE : Implement this Priority: 10 }
    mPanel.Top  := -10;//(locate_subMenuItemPanel_inParentsExtendedSubMenuPanel_byName(currNode^.name)).Top;
                                                                             //---// locate the subMenu Item Panel that corresponds to the
                                                                                  // current subMenu in the extended submenu container panel
                                                                                  // Of the parent. This is precomputed anyways.
                                                                                  // Then match the top.
    mPanel.Parent := Application.MainForm; // This one often does not work.
    willDrawDiv := True;
    // showMessage('For menu item : ' + currNode^.name + ' fwill Draw: ' + BoolToStr(willDrawDiv));
  end;




  tHeight       := 0; //----------------------------------------------------------// Currently no height
  mPanel.Height :=  tHeight; //---------------------------------------------------// pretend no height
  lHeight       := 0; //----------------------------------------------------------// Last height : Has there been anything rendered before?
  padding       := 2; //----------------------------------------------------------// Constant Padding
  maxWidth      := 150; //--------------------------------------------------------// minimum value of maximum width
  mPanel.Width  := maxWidth; //---------------------------------------------------// set initial Width of container panel

  cl            := MenuBackColor; //lbz clBackground; //-----------------------------------------------// get initial color
  //--------------------    Cycle through the Children      ----------------------//
  cPanels       := []; //---------------------------------------------------------// Save all child panels in this.
                                                                                  // Child container panel contains
                                                                                  // Checkbox
                                                                                  // Picture
                                                                                  // The menu text
                                                                                  // The keyboard shortcut
  for i := 0 to length(currNode^.Children) - 1 do
  begin
    chldNode    := currNode^.Children[i]; //--------------------------------------// Find the next child
    ii_id       := locate_integerItem(chldNode^.ID, MenuItemIds); //--------------// Find the suitable ID
    //------------------    Create the Container panel      ----------------------//
    cPanel      := TPanel.Create(mPanel); //------------------------------------// initialize panel
    cPanel.Parent:= mPanel; //----------------------------------------------------// we set the parent to be the new container panel

    cPanel.Left := 0 + padding; //------------------------------------------------// set left
    cPanel.Top  := lHeight + padding; //------------------------------------------// top = height of all previous children + padding
    cPanel.Height:= 40; //lbz--------------------------------------------------------// set current child height
    cPanel.Color:= cl; //----------------------------------------------// Set color
    cPanel.Name := chldNode^.name+'itemCont'; //----------------------------------// Give them a Name anyways
    cPanel.Caption:=''; //--------------------------------------------------------// Dont show the name
    cPanel.BevelOuter:=bvNone; //-------------------------------------------------// Force no bevel
    cPanel.BevelWidth:=0; //------------------------------------------------------// Force 0 width

    if (chldNode^.stringVal = '-') then //----------------------------------------// it is a DIVIDER
    begin
      cPanel.Width:=0; //---------------------------------------------------------// Force panel width to be zero
      cPanel.Height:= 20;
      cPanel.Color:=clSilver;//lbz
      lHeight     := cPanel.Top + cPanel.Height; //-------------------------------// Last Submenu item height
      tHeight     := tHeight + cPanel.Height + padding; //------------------------// Total container height
      mPanel.Height:=2;//lbz tHeight ;  //------------------------------------------------// update container height itself

      if ( (cPanel.Width +2 * padding) > maxWidth) then //------------------------// If needed, update the width
      begin
        maxWidth  := cPanel.Width +2 * padding;
        mPanel.Width:= maxWidth;
      end;

      SetLength(cPanels, length(cPanels) + 1); //---------------------------------// ADD to the list of submenus
      cPanels[length(cPanels) - 1] := cPanel;

      Continue;  //---------------------------------------------------------------// No further need to add anything in the child container
    end;
    //-----------------------    Render a Checkbox      --------------------------//
    if (chldNode^.hasCheckBox) then //--------------------------------------------// If there was a checkbox
    begin
      cCheckBox := TCheckBox.Create(cPanel); //-----------------------------------// create check box
      cCheckBox.Parent := cPanel; //----------------------------------------------// Set parent (these checkboxes themselves aren't saved, but their state will be)
      cCheckBox.Left:=padding; //-------------------------------------------------// Same idea as with cPanel
      cCheckBox.Width:=25; //-----------------------------------------------------// Set width height.
      cCheckBox.Height:=25;


      //############# REFACTOR THIS PART #########################################
      //## SEE if this can be modified to take any width/height ##################


      cCheckBox.Top:= (cPanel.Height - cCheckBox.Height) div 2; //----------------// Center vertically
      cCheckBox.Color:=cl; //-----------------------------------------------------// Set color



      //############# REFACTOR THIS PART #########################################
      //## TODO NEED TO ADD a onstatechange function   ###########################



      if (chldNode^.checkBoxStatus) then //---------------------------------------// Looking at the saved state
      begin
        cCheckBox.State:=TCheckBoxState.cbChecked; //-----------------------------// And setting the state
      end
      else
      begin
        cCheckBox.State:=TCheckBoxState.cbUnchecked;
      end;

    end;

    //----------------------    Render a ImageIcon      --------------------------//

    if (chldNode^.hasPicture) then
    begin

      cImage    := TImage.Create(cPanel);  //-------------------------------------// Create Image. The image is just for show. No function added.
      cImage.Parent:= cPanel; //--------------------------------------------------// Same stuff as cCheckBox
      cImage.Picture.LoadFromFile(chldNode^.picturePath);
      cImage.Height:=20; //-------------------------------------------------------// setting width and height
      cImage.Width:=20;

      //############# REFACTOR THIS PART #########################################
      //## SEE if this can be modified to take any width/height ##################

      cImage.Stretch:=true; //----------------------------------------------------// Scale picture in image Icon container
      cImage.Center:=true;  //----------------------------------------------------// Center vertically and horizontally
      cImage.Left:=26;  //--------------------------------------------------------// move to the left of the check box
      cImage.Top:= (cPanel.Height - cImage.Height) div 2; //----------------------// center vertically
    end;
    //------------------    Render the menu Text Label      ----------------------//
    cLabel      := TLabel.Create(cPanel); //------------------------------------// TODO Why ddo I have a problem here
    cLabel.Parent := cPanel; //---------------------------------------------------// Parent set
    cLabel.Caption:= '  ' + chldNode^.stringVal + '  '; //------------------------// Text
    cLabel.Name := chldNode^.name; //---------------------------------------------// name
    cLabel.Left := 50; //---------------------------------------------------------// set to the Right of Image Icon
    cLabel.Font.Name := Screen.SystemFont.Name; //------------------------------// Set font
    cLabel.Height := cLabel.Font.GetTextHeight('AyTg') + 4; //--------------------// height, with both up and down strokes of a letter
    cLabel.Width  := cLabel.Font.GetTextWidth(cLabel.Caption) + 4; //-------------// width. This one does not really work
    cLabel.Font.Color:=clWindowText; //-----------------------------------------// Color

    cLabel.OnMouseEnter:= nil; //-------------------------------------------------// When these were initially created, these were set to be the same as main menu
    cLabel.OnMouseLeave:= nil;

    c           := TBitmap.Create;
    c.Canvas.Font.Assign(Screen.SystemFont);
    cLabel.Width:= c.Canvas.TextWidth(cLabel.Caption) + 4; //---------------------// Label width is really set here.
    c.Free;

    cLabel.Color:= cl; //----------------------------------------------// Make sure that it is matching everything else
    //cLabel.Background.Style:=bbsColor;

    if (cPanel.Width < cLabel.Left + cLabel.Width + padding) then //--------------// If text label right edge is overflowing
    begin
      cPanel.Width :=  cLabel.Left + cLabel.Width + padding; //-------------------// adjust width. This was not needed so far.
    end;

    //lbz
    cLabel.AutoSize:=false;
    cLabel.Layout:=tlCenter;
    cLabel.Height:=cPanel.Height;
    //lbz
//    cLabel.Top  := cLabel.Height div 2;//lbz(cPanel.Height - cLabel.Height) div 2; //----------------------// Center


    {
    if willDrawDiv then
    begin
      showMessage(IntToStr(cPanel.Left) + ' ; ' + IntToStr(cPanel.Width) + ' ; ' +  IntToStr(cPanel.Top) + ' ; ' +  IntToStr(cPanel.Height) );
      showMessage(chldNode^.name);
    end;
    }

    //----------------    Render the shortcut Text Label      --------------------//
                                                                                  // Tricks are same as above
    if (chldNode^.hasShortCut) then
    begin

      sLabel      := TLabel.Create(cPanel);
      sLabel.Parent := cPanel;
      sLabel.Caption:= '  ' + chldNode^.shortCut + '  ';
      sLabel.Name := chldNode^.name + 'shortCut';
      sLabel.Left := cLabel.Left + cLabel.Width + padding;
      sLabel.Font.Name := Screen.SystemFont.Name;
      sLabel.Height := sLabel.Font.GetTextHeight('AyTg') + 4;
      sLabel.Width  := sLabel.Font.GetTextWidth(sLabel.Caption) + 4;
      sLabel.Font.Color:=clWindowText;
      //sLabel.Font.TextAlignment:=bcaRightCenter; //-----------------------------// Only this is needed extra to align the stuff to the right


      sLabel.OnMouseEnter:= nil; //-----------------------------------------------// When these were initially created, these were set to be the same as main menu
      sLabel.OnMouseLeave:= nil;

      c           := TBitmap.Create;
      c.Canvas.Font.Assign(Screen.SystemFont);
      sLabel.Width:= c.Canvas.TextWidth(sLabel.Caption) + 4; //-------------------// Label width
      c.Free;

      //sLabel.Background.Color:= cl; //--------------------------------------------// Make sure that it is matching everything else


      if (cPanel.Width < sLabel.Left + sLabel.Width + padding) then
      begin
        cPanel.Width :=  sLabel.Left + sLabel.Width + padding;
      end;

      //lbz
      sLabel.AutoSize:=false;
      sLabel.Layout:=tlCenter;
      sLabel.Height:=cPanel.Height;
      //lbz
      //sLabel.Top  := sLabel.Height div 2;//lbz (cPanel.Height - sLabel.Height) div 2;
    end;
    //--------------    Update the variables with the loop     -------------------//
    lHeight     := cPanel.Top + cPanel.Height; //---------------------------------// Last Submenu item height
    tHeight     := tHeight + cPanel.Height + padding; //--------------------------// Total container height
    mPanel.Height:=tHeight ;  //--------------------------------------------------// update container height itself
    if ( (cPanel.Width +2 * padding) > maxWidth) then //--------------------------// If needed, update the width
    begin
      maxWidth  := cPanel.Width +2 * padding;
      mPanel.Width:= maxWidth;
    end;

    SetLength(cPanels, length(cPanels) + 1); //-----------------------------------// ADD to the list of submenus
    cPanels[length(cPanels) - 1] := cPanel;

    setLength(mPanels, length(mPanels) + 1);
    mPanels[length(mPanels) - 1] := cPanel;

  end;
  //-------------    Draw the full submenu container correctly      --------------//
  mPanel.Height:=mPanel.Height + padding; //--------------------------------------// Increase height to add a bottom Margin
  mPanel.BevelOuter:=bvNone;
  mPanel.BevelWidth:=0;
  //mPanel.Background.Color  := cl; //----------------------------------------------// Background color has set

  mPanel.Caption:= ''; //---------------------------------------------------------// Ensure we will not see a caption of the container



  for i := 0 to length(cPanels) - 1 do //-----------------------------------------// Width readjustment : loop again
  begin

    if  ( cPanels[i].Width = 0 ) then Continue; //--------------------------------// If the divider, dont adjust now.

    cPanels[i].Width:=mPanel.Width - 2*padding; //--------------------------------// Outer contain of all submenu items has got the proper width
                                                                                  // which is adjusted to the largest of submenu label
                                                                                  // but all other submenu items need to be adjusted 7
                                                                                  // to have uniform width
    for j := 0 to cPanels[i].ControlCount -1 do
    begin
      if ( rightStr(cPanels[i].Controls[j].Name, 8) = 'shortCut') then //---------// If a shortcut label was added
      begin
         cPanels[i].Controls[j].Left:= cPanels[i].Width - cPanels[i].Controls[j].Width; // Move the label to the very right so that irregular size
                                                                                  // of the menu text label does not imact the left placement
                                                                                  // of the shortcut label
      end;
    end;

  end;

  //if not (willDrawDiv) then
  //begin
  mPanel.Visible:= False; //------------------------------------------------------// NotVisible
  currNode^.isSubMenuDrawn:= False;
  //end;

  {
  if willDrawDiv then
  begin
    mPanel.Visible:= True;
    showMessage(BoolToStr(mPanel.Visible) + ' <--- visible');
    mPanel.Parent := Application.MainForm;
    mPanel.Background.Color:=clRed;
    showMessage(IntToStr(mPanel.Left) + ' ; ' + IntToStr(mPanel.Width) + ' ; ' +  IntToStr(mPanel.Top) + ' ; ' +  IntToStr(mPanel.Height) );
  end;
  }

  currNode^.subMenuContainer:=mPanel; //------------------------------------------// Registered the open submenu container


end;

procedure TAdvancedMainMenu.update_subMenu_renderItemActionList(name: String);
var
  procMEnter    : TProc;
  procMExit     : TProc;
  procCMEnter   : TProc;
  procMClick    : TProc;
  mPanel        : TPanel;
  mLabel        : TLabel;

  currNode      : TNodePtr;
  i             : Integer;
  j             : Integer;

  c             : TColor;
begin

  //-----------    Get the name of the origin and the origin itself      ---------//

  currNode      :=  nil;
  currNode      :=  locate_menuNode_byName(name); //------------------------------// The menu node corresponding to the sender found


  for i := 0 to (currNode^.subMenuContainer as TPanel).ControlCount - 1 do
  begin

    procMEnter  := @subMenuItem_mouseEnter;
    ((currNode^.subMenuContainer as TPanel).Controls[i] as TPanel).OnMouseEnter:=procMEnter;  // assign method to each child
                                                                                  // Which are bcpanels containing everything ...


    procMExit   := @subMenuItem_mouseExit;
    ((currNode^.subMenuContainer as TPanel).Controls[i] as TPanel).OnMouseLeave:=procMExit;


    for j := 0 to ((currNode^.subMenuContainer as TPanel).Controls[i] as TPanel).ControlCount - 1 do
    begin
      if not (((currNode^.subMenuContainer as TPanel).Controls[i] as TPanel).Controls[j] is TLabel) then
      begin
        Continue;
      end;
      procCMEnter:= @subMenuChildItem_mouseEnter;
      (((currNode^.subMenuContainer as TPanel).Controls[i] as TPanel).Controls[j] as TLabel).OnMouseEnter:= procCMEnter;
      (((currNode^.subMenuContainer as TPanel).Controls[i] as TPanel).Controls[j] as TLabel).OnMouseLeave:= @subMenuChildItem_mouseExit;
    end;

  end;


end;

procedure TAdvancedMainMenu.subMenuItem_mouseEnter(Sender: TObject);
var
  mPanel        : TPanel;
  parPanel      : TPanel;
  currNode      : TNodePtr;
  parNode       : TNodePtr;
  otherNode     : TNodePtr;
  mustOpenCurr  : Boolean;

  i             : Integer;
  j             : Integer;
  k             : Integer;
begin

  //--------------------   Get the source and node      --------------------------//

  mPanel        := Sender as TPanel;
  currNode      := locate_menuNode_fromPanelName((Sender  as TPanel).Name);

  parPanel      := mPanel.Parent as TPanel; //----------------------------------// This is the LARGE submenu container

  //--------------------   Turn Off Sibling HighLights  --------------------------//

  for i := 0 to parPanel.ControlCount - 1 do
  begin

    (parPanel.Controls[i] as TPanel).Color:=MenuBackColor;// clBackground;

    for j := 0 to (parPanel.Controls[i] as TPanel).ControlCount - 1 do
    begin
      if ( (parPanel.Controls[i] as TPanel).Controls[j] is TLabel ) then
      begin
        ((parPanel.Controls[i] as TPanel).Controls[j] as TLabel).Color:=MenuBackColor;//clBackground ;
      end;
    end;



  end;

  //--------------------   Turn off sibling submenu panels -----------------------//

  otherNode     := locate_menuNode_fromPanelName((parPanel.Controls[0] as TPanel).Name);
  if (otherNode^.isSubMenuDrawn) then
  begin
    mPanel        := otherNode^.subMenuContainer as TPanel;
    mPanel.Visible:= False;
    otherNode^.isSubMenuDrawn:=False;

    for j := 0 to (otherNode^.subMenuContainer as TPanel).ControlCount - 1 do
    begin
      ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Color:=MenuBackColor;//clBackground ;
      for k := 0 to ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).ControlCount - 1 do
      begin
        if ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] is TLabel then
        begin
          (((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] as TLabel).Color:=MenuBackColor;//clBackground ;
        end;
      end;
    end;
  end;
  while(True) do
  begin
    if Length(otherNode^.Children)<> 0 then //------------------------------------// If has children
    begin

      otherNode := otherNode^.Children[0]; //-------------------------------------// Pick the child

      if otherNode^.isSubMenuDrawn then //----------------------------------------// Submenu container could be nil. but
                                                                                  // If this flag is set,
                                                                                  // then submenu container was created
                                                                                  // And THUS Can't be nil
      begin
        (otherNode^.subMenuContainer as TPanel).Visible:=False; //--------------// Force off
        otherNode^.isSubMenuDrawn := False; //------------------------------------// Turn off flag

        for j := 0 to (otherNode^.subMenuContainer as TPanel).ControlCount - 1 do
        begin
          ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Color:=MenuBackColor;//clBackground ;

          for k := 0 to ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).ControlCount - 1 do
          begin
            if ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] is TLabel then
            begin
              (((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] as TLabel).Color:=MenuBackColor;//clBackground ;
             end;
          end;

        end;

      end;


      // ############### if needed turn off sibling highlight here

      Continue; //----------------------------------------------------------------// Continue to see if any other level of submenu is open
    end;

    //----------------------------------------------------------------------------// IF AT THIS POINT, THEN THERE'S NO CHILD
                                                                                  // BUT POSSIBLY, CONTROL IS AT A DEEPER SUBMENU LEVEL,
                                                                                  // WHERE A NON-ZERO INDEX CHILD WAS OPENED.
                                                                                  // HOWEVER, THE DFS ABOVE SO FAR LOOKED AT THE
                                                                                  // CHILD MENU INDEX 0 ONLY. SO SCAN OTHER INDICES ALSO

    if otherNode^.next <> Nil then  //--------------------------------------------// If there's a 'next' item, take it
    begin

      otherNode := otherNode^.next;

      if otherNode^.isSubMenuDrawn then //----------------------------------------// again, if the flag is set = menu container is created
      begin

        (otherNode^.subMenuContainer as TPanel).Visible:=False; //--------------// Turn off
        otherNode^.isSubMenuDrawn := False;

        for j := 0 to (otherNode^.subMenuContainer as TPanel).ControlCount - 1 do
        begin
          ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Color:=MenuBackColor;//clBackground ;
          for k := 0 to ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).ControlCount - 1 do
          begin
            if ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] is TLabel then
            begin
              (((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] as TLabel).Color:=MenuBackColor;//clBackground ;

            end;
          end;

        end;
       end;
      Continue;
    end;
    //----------------------------------------------------------------------------// IF AT THIS POINT, THE DFS HAS LOOKED AT A LEVEL
                                                                                  // WITHOUT A CHILD OR A NEXT
                                                                                  // BUT MAY BE DFS FOLLOWED THE WRONG BRACH UNTIL NOW
                                                                                  // SO GO ONE STEP BACK  AND TRY TO FIND THE NEXT BRANCH

    if otherNode^.Parent <> Nil then //-------------------------------------------// If possible
    begin

      otherNode := otherNode^.Parent; //------------------------------------------// Go one step back
      if otherNode^.next <> Nil then  //------------------------------------------// If possible
      begin

        otherNode := otherNode^.next; //------------------------------------------// Take next item

        if otherNode^.isSubMenuDrawn then
        begin
          (otherNode^.subMenuContainer as TPanel).Visible:=False;
          otherNode^.isSubMenuDrawn := False;

          for j := 0 to (otherNode^.subMenuContainer as TPanel).ControlCount - 1 do
          begin
            ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Color:=MenuBackColor;//clBackground ;

            for k := 0 to ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).ControlCount - 1 do
            begin
              if ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] is TLabel then
              begin
                (((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] as TLabel).Color:=MenuBackColor;//clBackground ;
               end;
            end;

          end;

        end;

        Continue;
      end;
    end;

    Break; //---------------------------------------------------------------------// If nothing is possible, then break.
  end;
  //---- If there is a parent, which is a submenu itself then keep highlight  ----//

  //-----------------------        highlight itself        -----------------------//



  (Sender as TPanel).Color:=MenuHighlightColor;//lbz clInactiveCaption;

  for i := 0 to (Sender as TPanel).ControlCount - 1 do
  begin
    if ( (Sender as TPanel).Controls[i] is TLabel ) then
    begin
      ((Sender as TPanel).Controls[i] as TLabel).Color:=MenuHighlightColor;//lbz clInactiveCaption ;
    end;
  end;



  //-----------------------     show submnu of itself      -----------------------//

  if ( Length(currNode^.Children) <> 0 ) and ( currNode^.subMenuContainer <> Nil ) then
  begin
    mPanel      := currNode^.subMenuContainer as TPanel;
    mPanel.Parent:= (Sender as TPanel).Parent.Parent;
    mPanel.Top  := (Sender as TPanel).Parent.Top  + (Sender as TPanel).Top;
    mPanel.Left := (Sender as TPanel).Parent.Left + (Sender as TPanel).Width;
    mPanel.Visible:= True;
    currNode^.isSubMenuDrawn := True;
  end;


end;

procedure TAdvancedMainMenu.subMenuItem_mouseExit(Sender: TObject);
var
  mPanel        : TPanel;
  currNode      : TNodePtr;
  otherNode     : TNodePtr;
  mustOpenCurr  : Boolean;

  i             : Integer;
begin


end;

procedure TAdvancedMainMenu.subMenuChildItem_mouseEnter(Sender: TObject);
var
  mPanel        : TPanel;
  parPanel      : TPanel;
  currNode      : TNodePtr;
  parNode       : TNodePtr;
  otherNode     : TNodePtr;
  mustOpenCurr  : Boolean;

  i             : Integer;
  j             : Integer;
  k             : Integer;
begin

  //--------------------   Get the source and node      --------------------------//

  mPanel        := (Sender as TLabel).Parent as TPanel;
  currNode      := locate_menuNode_fromPanelName(((Sender as TLabel).Parent  as TPanel).Name);

  parPanel      := mPanel.Parent as TPanel; //----------------------------------// This is the LARGE submenu container

  //--------------------   Turn Off Sibling HighLights  --------------------------//

  for i := 0 to parPanel.ControlCount - 1 do
  begin

    (parPanel.Controls[i] as TPanel).Color:=MenuBackColor;// clBackground;

    for j := 0 to (parPanel.Controls[i] as TPanel).ControlCount - 1 do
    begin
      if ( (parPanel.Controls[i] as TPanel).Controls[j] is TLabel ) then
      begin
        ((parPanel.Controls[i] as TPanel).Controls[j] as TLabel).Color:=MenuBackColor;//clBackground ;
       end;
    end;
  end;

  //--------------------   Turn off sibling submenu panels -----------------------//

  otherNode     := locate_menuNode_fromPanelName((parPanel.Controls[0] as TPanel).Name);
  if (otherNode^.isSubMenuDrawn) then
  begin
    mPanel        := otherNode^.subMenuContainer as TPanel;
    mPanel.Visible:= False;
    otherNode^.isSubMenuDrawn:=False;

    for j := 0 to (otherNode^.subMenuContainer as TPanel).ControlCount - 1 do
    begin
      ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Color:=MenuBackColor;//clBackground ;

      for k := 0 to ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).ControlCount - 1 do
      begin
        if ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] is TLabel then
        begin
          (((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] as TLabel).Color:=MenuBackColor;//clBackground ;
        end;
      end;

    end;
  end;

  while(True) do
  begin
    if Length(otherNode^.Children)<> 0 then //------------------------------------// If has children
    begin
      otherNode := otherNode^.Children[0]; //-------------------------------------// Pick the child
      if otherNode^.isSubMenuDrawn then //----------------------------------------// Submenu container could be nil. but
                                                                                  // If this flag is set,
                                                                                  // then submenu container was created
                                                                                  // And THUS Can't be nil
      begin
        (otherNode^.subMenuContainer as TPanel).Visible:=False; //--------------// Force off
        otherNode^.isSubMenuDrawn := False; //------------------------------------// Turn off flag

        for j := 0 to (otherNode^.subMenuContainer as TPanel).ControlCount - 1 do
        begin
          ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Color:=MenuBackColor;//clBackground ;

          for k := 0 to ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).ControlCount - 1 do
          begin
            if ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] is TLabel then
            begin
              (((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] as TLabel).Color:=MenuBackColor;//clBackground ;
            end;
          end;
        end;
      end;


      // ############### if needed turn off sibling highlight here

      Continue; //----------------------------------------------------------------// Continue to see if any other level of submenu is open
    end;

    //----------------------------------------------------------------------------// IF AT THIS POINT, THEN THERE'S NO CHILD
                                                                                  // BUT POSSIBLY, CONTROL IS AT A DEEPER SUBMENU LEVEL,
                                                                                  // WHERE A NON-ZERO INDEX CHILD WAS OPENED.
                                                                                  // HOWEVER, THE DFS ABOVE SO FAR LOOKED AT THE
                                                                                  // CHILD MENU INDEX 0 ONLY. SO SCAN OTHER INDICES ALSO

    if otherNode^.next <> Nil then  //--------------------------------------------// If there's a 'next' item, take it
    begin
      otherNode := otherNode^.next;
      if otherNode^.isSubMenuDrawn then //----------------------------------------// again, if the flag is set = menu container is created
      begin
        (otherNode^.subMenuContainer as TPanel).Visible:=False; //--------------// Turn off
        otherNode^.isSubMenuDrawn := False;

        for j := 0 to (otherNode^.subMenuContainer as TPanel).ControlCount - 1 do
        begin
          ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Color:=MenuBackColor;//clBackground ;

          for k := 0 to ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).ControlCount - 1 do
          begin
            if ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] is TLabel then
            begin
              (((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] as TLabel).Color:=MenuBackColor;//clBackground ;
            end;
          end;


        end;

      end;

      Continue;
    end;
    //----------------------------------------------------------------------------// IF AT THIS POINT, THE DFS HAS LOOKED AT A LEVEL
                                                                                  // WITHOUT A CHILD OR A NEXT
                                                                                  // BUT MAY BE DFS FOLLOWED THE WRONG BRACH UNTIL NOW
                                                                                  // SO GO ONE STEP BACK  AND TRY TO FIND THE NEXT BRANCH

    if otherNode^.Parent <> Nil then //-------------------------------------------// If possible
    begin

      otherNode := otherNode^.Parent; //------------------------------------------// Go one step back
      if otherNode^.next <> Nil then  //------------------------------------------// If possible
      begin

        otherNode := otherNode^.next; //------------------------------------------// Take next item

        if otherNode^.isSubMenuDrawn then
        begin
          (otherNode^.subMenuContainer as TPanel).Visible:=False;
          otherNode^.isSubMenuDrawn := False;

          for j := 0 to (otherNode^.subMenuContainer as TPanel).ControlCount - 1 do
          begin
            ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Color:=MenuBackColor;//clBackground ;

            for k := 0 to ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).ControlCount - 1 do
            begin
              if ((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] is TLabel then
              begin
                (((otherNode^.subMenuContainer as TPanel).Controls[j] as TPanel).Controls[k] as TLabel).Color:=MenuBackColor;//clBackground ;
              end;
            end;
          end;
        end;
        Continue;
      end;
    end;

    Break; //---------------------------------------------------------------------// If nothing is possible, then break.
  end;
  //---- If there is a parent, which is a submenu itself then keep highlight  ----//

  //-----------------------        highlight itself        -----------------------//
  ((Sender as TLabel).Parent as TPanel).Color:= MenuHighlightColor;//lbz clInactiveCaption;

  for i := 0 to ((Sender as TLabel).Parent as TPanel).ControlCount - 1 do
  begin
    if ( ((Sender as TLabel).Parent as TPanel).Controls[i] is TLabel ) then
    begin
      (((Sender as TLabel).Parent as TPanel).Controls[i] as TLabel).Color:=MenuHighlightColor;//lbz clInactiveCaption ;
    end;
  end;
  //-----------------------     show submnu of itself      -----------------------//

  if ( Length(currNode^.Children) <> 0 ) and ( currNode^.subMenuContainer <> Nil ) then
  begin
    mPanel      := currNode^.subMenuContainer as TPanel;
    mPanel.Parent:= ((Sender as TLabel).Parent as TPanel).Parent.Parent;
    mPanel.Top  := ((Sender as TLabel).Parent as TPanel).Parent.Top  + ((Sender as TLabel).Parent as TPanel).Top;
    mPanel.Left := ((Sender as TLabel).Parent as TPanel).Parent.Left + ((Sender as TLabel).Parent as TPanel).Width;
    mPanel.Visible:= True;
    currNode^.isSubMenuDrawn := True;
  end;
end;

procedure TAdvancedMainMenu.subMenuChildItem_mouseExit (Sender: TObject);
var
  mPanel        : TPanel;
  currNode      : TNodePtr;
  otherNode     : TNodePtr;
  mustOpenCurr  : Boolean;
  i             : Integer;
begin

end;

procedure TAdvancedMainMenu.add_subMenuCheckBox(name: String; state: Boolean);
var
  currNode      : TNodePtr;
begin
  //--------------------   Locate the Menu Item by name       --------------------//
  currNode      := locate_menuNode_byName(name); //-------------------------------// We can use the function we wrote

  currNode^.hasCheckBox:=True; //-------------------------------------------------// add info to menu node
  currNode^.checkBoxStatus:=state;

  update_subMenu_renderItemList((currNode^.Parent)^.name);
  update_subMenu_renderItemActionList((currNode^.Parent)^.name);
end;

procedure TAdvancedMainMenu.add_subMenuPicture(name: String; path: String);
var
  currNode      : TNodePtr;
begin
  //--------------------   Locate the Menu Item by name       --------------------//
  currNode      := locate_menuNode_byName(name); //-------------------------------// We can use the function we wrote
  currNode^.hasPicture:=True;  //-------------------------------------------------// add info to menu node
  currNode^.picturePath:=path;

  update_subMenu_renderItemList((currNode^.Parent)^.name);
  update_subMenu_renderItemActionList((currNode^.Parent)^.name);
end;

procedure TAdvancedMainMenu.assign_subMenuShortCut(name: String; shortCut: String);
var
  currNode      : TNodePtr;
begin
  //--------------------   Locate the Menu Item by name       --------------------//
  currNode      := locate_menuNode_byName(name); //-------------------------------// We can use the function we wrote
  //----------------------   Set the shortcut and flags      ---------------------//
  currNode^.hasShortCut:=True; //-------------------------------------------------// add info to menu node
  currNode^.shortCut:=shortCut;
  //----------------   Update the render items and actions       -----------------//

  update_subMenu_renderItemList((currNode^.Parent)^.name);
  update_subMenu_renderItemActionList((currNode^.Parent)^.name);
end;

procedure TAdvancedMainMenu.add_subMenuSubMenu_byName(targetName: String; var items: array of String; var itemNames: array of String);
var
  ii            : Integer;
  currNode      : ^dataTypes.stringNodeStruct;
  ii_id         : Integer;

begin
  //--------------------   Locate the Menu Item by name       --------------------//
  currNode      := locate_menuNode_byName(targetName); //-------------------------// We can use the function we wrote
  if currNode = nil then Exit; //-------------------------------------------------// Did not Find it
  for ii := 0 to length(items) -1 do
  begin
    ii_id       := get_uniqueID(); //---------------------------------------------// Again, use a function instead

    menuTree.AppendString_asSubSubNode_byName(targetName, items[ii], itemNames[ii], ii_id);
    //---------------------    Main ID list populated       ----------------------//
    update_IDArray(ii_id) ; //----------------------------------------------------// Append to Item ID
    //-----------------    Action Item list populated       ----------------------// Insert Default Actions

    // update_RenderItemActionList(ii_id);
  end;
  //--------    Add the little arrow to show further submenu exists       --------//
  if ( length(currNode^.Children) <> 0) and (currNode^.hasShortCut = False) and (currNode^.Parent <> nil)  then
  begin
    currNode^.hasShortCut:=True;
    currNode^.shortCut:= ' > ' ;
    update_subMenu_renderItemList((currNode^.Parent)^.name);
    update_subMenu_renderItemActionList((currNode^.Parent)^.name);
  end;

  //-----------------    Render Item list populated       ------------------------// Do it once for ALL The submenus

  update_subMenu_renderItemList(targetName);
  update_subMenu_renderItemActionList(targetName);

end;

procedure TAdvancedMainMenu.add_clickAction_byName(name: String; action: TProc);
var
  mPanel        : TPanel;
  mLabel        : TLabel;
  i             : Integer;
  j             : Integer;
  currNode      : TNodePtr;
  parNode       : TNodePtr;
begin
  currNode      := MenuTree.root;
  while( true) do
  begin

    if ( currNode^.name = name) then
    begin
      parNode   := currNode^.Parent;
      mPanel    := parNode^.subMenuContainer as TPanel;

      for i := 0 to mPanel.ControlCount - 1 do
      begin
        if ( mPanel.Controls[i] as TPanel).Name = name+ 'itemCont' then
        begin
           ( mPanel.Controls[i] as TPanel).OnClick:=action;

            for j := 0 to ( mPanel.Controls[i] as TPanel).ControlCount - 1 do
            begin
              if ( mPanel.Controls[i] as TPanel).Controls[j] is TLabel then
              begin
                ( ( mPanel.Controls[i] as TPanel).Controls[j] as TLabel).OnClick:= action;
              end;
            end;

        end;
      end;

    end;

    if Length( currNode^.Children ) <> 0 then
    begin
      currNode  := currNode^.Children[0];
      Continue;
    end;

    if currNode^.next <> Nil then
    begin
      currNode  := currNode^.next;
      Continue;
    end;

    if currNode^.Parent <> Nil then
    begin
      currNode  := currNode^.Parent;
      if currNode^.next <> Nil then
      begin
        currNode  := currNode^.next;
        Continue;
      end;
    end;

    Break;
  end;


end;

procedure TAdvancedMainMenu.hello(Sender: TObject);
begin
  showMessage('helllllo');
end;



{{{{{ HELPER FUNCTIONS }}}}}

function TAdvancedMainMenu.get_uniqueID: Integer;
begin
  currentID    := currentID + 1; //-----------------------------------------------// increment current ID
  Result       := currentID - 1; //-----------------------------------------------// new id is one more than the current ID
                                                                                  // We have to increment the current ID first, because
                                                                                  // the last line of the function should contain
                                                                                  // the special variable Result
                                                                                  // -1. because we want to return the value that was
                                                                                  // previously in it

end; //###########################################################################// End of Function




procedure TAdvancedMainMenu.update_IDArray(ii_id: Integer); //--------------------// Just insert in the ID array
begin
  SetLength(MenuItemIDs, length(MenuItemIds)+1); //-------------------------------// Increase the container length by 1 : this creates one empty space at the end
  MenuItemIDs[length(MenuItemIds) - 1] := ii_id; //-------------------------------// Insewrt new item at the end, in the newly created space.
end; //###########################################################################// End of Function




function TAdvancedMainMenu.check_existingMainMenu: Integer;
var
  res           : Integer; //-----------------------------------------------------// Track whether found
begin
  res           := 0; //----------------------------------------------------------// Is not found
  if ( MenuTree.root <> nil) then //----------------------------------------------// if root is not nil, then
  begin
    res         := 1; //----------------------------------------------------------// the menu tree must have created already
  end;
  Result        := res; //--------------------------------------------------------// return via result keyword
end; //###########################################################################// End of Function





function TAdvancedMainMenu.locate_menuNode_byID(ii_id: Integer): TNodePtr; //-----// given an ID, do a DFS.
var
  currNode      : ^dataTypes.stringNodeStruct; //---------------------------------// Node under test
  resNode       : ^dataTypes.stringNodeStruct; //---------------------------------// Node to return
begin

  currNode      :=  menuTree.root; //---------------------------------------------// Start at root
  resNode       :=  nil; //-------------------------------------------------------// Return value = Null

  while (True) do //--------------------------------------------------------------// Search indefinitely, unless break command
  begin

    if (currNode^.ID = ii_id) then //---------------------------------------------// id match
    begin
      resNode   := currNode; //---------------------------------------------------// Set Return value
      Break; //-------------------------------------------------------------------// break while loop
    end;


    //----------------------------------------------------------------------------// if at this point, then did not find a match

    if ( length(currNode^.Children) <> 0) then //---------------------------------// if there is a child, DFS: CAN GO DEEPER
    begin
      currNode  := currNode^.Children[0]; //--------------------------------------// DFS: GO DEEPER, take the child
      Continue; //----------------------------------------------------------------// and loop back
    end;



    //----------------------------------------------------------------------------// if at this point, then no child.
                                                                                  // DFS can't go deeper here
                                                                                  // Must take the horizontal nextnode

    if (currNode^.next <> nil) then //--------------------------------------------// if can take the next, DFS: Plan B: CAN MOVE HORIZONTALLY
    begin
      currNode  := currNode^.next; //---------------------------------------------// Move Horizontally, take the next
      Continue; //----------------------------------------------------------------// Loop back
    end;


    //----------------------------------------------------------------------------// if at this point, then no next either
                                                                                  // DFS Can neighter go deeper, nor horizontal
                                                                                  // DFS Can try to move back one level, and then
                                                                                  // move horizontal.
                                                                                  // All options of siblings and parent have been expended;
                                                                                  // thus, try next sibling of parent.

    if (currNode^.Parent <> nil) then //------------------------------------------// If has a parent
    begin
      currNode  := currNode^.Parent; //-------------------------------------------// Take the parent
      if (currNode^.next <> nil) then //------------------------------------------// If the taken node (=parent of previously taken node)
                                                                                  // has a sibling
      begin
        currNode:= currNode^.next; //---------------------------------------------// Take the sibling
        Continue; //--------------------------------------------------------------// Loop back
      end;
    end;



    //----------------------------------------------------------------------------// if at this point, then nothing worked

    Break; //---------------------------------------------------------------------// Break Loop

  end;


  Result        := resNode; //----------------------------------------------------// If loop search was successful,
                                                                                  // resNode will contain the correct value
                                                                                  // Otherwise, nil.

end;

function TAdvancedMainMenu.locate_renderItemPanel_byName(nm: String): TPanel;
var
  mPanel        : TPanel;
  i             : Integer;
  currName      : String;
begin
  mPanel        := nil;

  for i:= 0 to length(MainMenuRenderItems) - 1 do
  begin
    currName    := MainMenuRenderItems[i].Name;
    if ( currName = nm + 'panel') then
    begin
      mPanel    := MainMenuRenderItems[i];
      Break;
    end;
  end;

  Result        := mPanel;
end; //###########################################################################// End of Function

function TAdvancedMainMenu.locate_menuNode_fromPanelName(name: String ): TNodePtr;
var
  currNode      : TNodePtr;
  resNode       : TNodePtr;
begin
  resNode       := Nil;
  name          := Copy(name, 1, Length(name)-8);
  currNode      := locate_menuNode_byName(name);

  if(currNode <> nil) then
  begin
    resNode     := currNode;
  end;
  Result        := resNode;
end;

function TAdvancedMainMenu.locate_menuNode_byName(nm: String): TNodePtr;
var
  i             : Integer;
  currNode      : ^dataTypes.stringNodeStruct;
  resNode       : ^dataTypes.stringNodeStruct;
begin
  i             := -1;
  currNode      :=  menuTree.root;
  resNode       :=  nil;
  while (True) do
  begin
    if (currNode^.name = nm) then
    begin
      resNode   := currNode;                                                    // name found
      Break;                                                                      // break while loop
    end;
                                                                                  // if at this point, then did not find a match

    if ( length(currNode^.Children) <> 0) then                                    // if there is a child
    begin
      currNode  := currNode^.Children[0];                                       // take the child and loop back
      Continue;
    end;
                                                                                  // if at this point, then no child

    if (currNode^.next <> nil) then                                               // if can take the next, take the next
    begin
      currNode  := currNode^.next;
      Continue;
    end;
                                                                                  // if at this point, then no next either

    if (currNode^.Parent <> nil) then
    begin
      currNode  := currNode^.Parent;
      if (currNode^.next <> nil) then
      begin
        currNode:= currNode^.next;
        Continue;
      end;
    end;

    Break;

  end;
  Result := resNode;
end;

function TAdvancedMainMenu.locate_subMenuItemPanel_inParentsExtendedSubMenuPanel_byName
  (nm: String): TNodePtr;
var
  currNode : TNodePtr;
begin
  Result := currNode;
end;

function TAdvancedMainMenu.locate_subMenuPanel_byName(nm: String): TPanel;
var
  mPanel  : TPanel;
  currNode: TNodePtr;
  i       : Integer;
begin
  // itemCont
  mPanel        := Nil;
  currNode      := MenuTree.root;

  for i := 0 to Length(mPanels) - 1 do
  begin
     if mPanels[i].Name = nm+ 'itemCont' then
    begin
      mPanel := mPanels[i];
      break;
    end;
  end;
   Result := mPanel;
end;

function locate_integerItem(needle: Integer; haystack : Array of Integer ) : Integer;
var
  i :  Integer;
  j :  Integer;
begin
  j := -1;
  for i := 0 to length(haystack) -1 do
  begin
    if ( haystack[i] = needle) then
    begin
      j:= i;
      Break;
    end;
  end;
  Result:= j;
end;

end.


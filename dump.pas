 procedure create_mainMenu (var mainMenuItems : Array of String; var mainMenuNames : Array of String);

    function get_uniqueID() : Integer;
    function check_existingMainMenu() : Integer;
    procedure update_IDArray(ii_id : Integer);
    procedure update_RenderItemFormatList(ii_id : Integer);
    procedure update_RenderItemList(ii_id : Integer);
    function locate_menuNode_byID(ii_id : Integer) : TNodePtr;
    function locate_menuNode_byName(nm: String): TNodePtr;
    procedure update_RenderItemActionList(ii_id : Integer);

    procedure add_subMenuCheckBox(name: String; state: Boolean);
    procedure add_subMenuPicture(name: String; path: String);

    procedure toggleSubMenu(Sender: TObject);
    procedure changeBGColor(Sender:TObject);
    procedure restoreBGColor(Sender:TObject);
    procedure changePanel(Sender: TObject);
    procedure restorePanel(Sender: TObject);
    procedure changeLabelParentPanel(Sender: TObject);
procedure restoreLabelParentPanel(Sender: TObject);




MenuItemIds   :  Array of Integer;

    MenuItemFonts :  Array of TFont;                                              // Item Fonts
    MenuBorderThicknesses:Array of Integer;
    MenuBorderRadii: Array of Integer;                                            // Border rounding
    MenuBGColors  :  Array of TColor;                                             // Background color for BCL Label
    MenuFGColors  :  Array of TColor;                                             // Foreground color for BCL Label
    MenuFontSizes :  Array of Integer;
    MenuFontWeigths: Array of Integer;



    MenuAutoDraw  :  Array of Boolean;

    currentID     : Integer;

    widthPadding  : Integer;
    heightPadding : Integer;

    mLabels       : Array of TBCLabel;
    mPanels       : Array of TBCPanel;









unit TAdvancedMenu;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls, ExtCtrls, dataTypes,BCLabel, bgraControls,BCTypes, BCPanel;
type

  TProcType     = procedure(const AParm: Integer) of object; // Method type
  TProcArray    = array of TProcType; // Dynamic array
  TProc         = procedure(AParm: TObject) of object;
  TNodePtr      = ^dataTypes.stringNodeStruct;
  // tadvancedmenu.pas(281,24) Error: Incompatible types: got "Variant" expected "<;Register>"

  { TAdvancedMainMenu }

  TAdvancedMainMenu = Class

  public

    MenuItemIds   :  Array of Integer;

    MenuItemFonts :  Array of TFont;                                              // Item Fonts
    MenuBorderThicknesses:Array of Integer;
    MenuBorderRadii: Array of Integer;                                            // Border rounding
    MenuBGColors  :  Array of TColor;                                             // Background color for BCL Label
    MenuFGColors  :  Array of TColor;                                             // Foreground color for BCL Label
    MenuFontSizes :  Array of Integer;
    MenuFontWeigths: Array of Integer;

    MenuTree      :  dataTypes.tree_ofStrings;

    MenuAutoDraw  :  Array of Boolean;

    currentID     : Integer;

    widthPadding  : Integer;
    heightPadding : Integer;

    mLabels       : Array of TBCLabel;
    mPanels       : Array of TBCPanel;



    constructor Create();



    function get_uniqueID() : Integer;
    function check_existingMainMenu() : Integer;
    procedure update_IDArray(ii_id : Integer);
    procedure update_RenderItemFormatList(ii_id : Integer);
    procedure update_RenderItemList(ii_id : Integer);
    function locate_menuNode_byID(ii_id : Integer) : TNodePtr;
    function locate_menuNode_byName(nm: String): TNodePtr;
    procedure update_RenderItemActionList(ii_id : Integer);

    procedure add_subMenuCheckBox(name: String; state: Boolean);
    procedure add_subMenuPicture(name: String; path: String);

    procedure toggleSubMenu(Sender: TObject);
    procedure changeBGColor(Sender:TObject);
    procedure restoreBGColor(Sender:TObject);
    procedure changePanel(Sender: TObject);
    procedure restorePanel(Sender: TObject);
    procedure changeLabelParentPanel(Sender: TObject);
    procedure restoreLabelParentPanel(Sender: TObject);



    procedure render({var} parent : TPanel);

    procedure add_mainMenuSubMenu_byName(targetName : String; var items : Array of String; var itemNames : Array of String);


    {
    procedure render_onPanel({var} parent: TPanel);
    procedure add_mainMenuActions(var actions : TProcArray);
    procedure add_mainMenuClickAction(var i: Integer; var action: TProc);

    procedure set_mainMenuItemClickAction_fromTemplate(menuName : String; actionName : String);

    procedure render_subMenu_ofMainMenu(Sender : TObject);
    function extractMenuID(name : String): Integer;

    }


  end;
  function generate_randomNumber() : Integer  ;
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

  SetLength(MenuBGColors,0);                                                      // PROBABLY unnecessary.
  SetLength(MenuFGColors,0);                                                      // PROBABLY unnecessary.
  SetLength(MenuItemFonts,0);                                                     // PROBABLY unnecessary.
  SetLength(MenuBorderRadii,0);                                                   // PROBABLY unnecessary.
  SetLength(MenuBorderThicknesses,0);                                             // PROBABLY unnecessary.
  SetLength(MenuFontSizes,0);                                                     // PROBABLY unnecessary.
  SetLength(MenuFontWeigths,0);                                                   // PROBABLY unnecessary.

  SetLength(MenuAutoDraw,0);                                                      // PROBABLY unnecessary.


  //----------------------------   INITIALIZE DRAWING PARAMS ---------------------//

  heightPadding := 8;                                                             // These values are used.
  widthPadding  := 8;
end; //###########################################################################// End of Function



procedure TAdvancedMainMenu.update_IDArray(ii_id: Integer); //--------------------// Just insert in the ID array
begin
  SetLength(MenuItemIDs, length(MenuItemIds)+1); //-------------------------------// Increase the container length by 1 : this creates one empty space at the end
  MenuItemIDs[length(MenuItemIds) - 1] := ii_id; //-------------------------------// Insewrt new item at the end, in the newly created space.
end; //###########################################################################// End of Function

procedure TAdvancedMainMenu.update_RenderItemFormatList(ii_id: Integer);
begin

  //-----------------     Append to Array of Fonts      --------------------------//

  SetLength(MenuItemFonts, length(MenuItemFonts) + 1);
  MenuItemFonts[length(MenuItemFonts) -1]    := Screen.SystemFont; //-------------// Added the SystemFont


  //-----------------     Append to Border Thickness    --------------------------//

  SetLength(MenuBorderThicknesses, length(MenuBorderThicknesses) + 1);
  MenuBorderThicknesses[length(MenuBorderThicknesses) -1]:= 0; //-----------------// Added the Border Thickness


  //-----------------     Append to Border Radius       --------------------------//

  SetLength(MenuBorderRadii, length(MenuBorderRadii) + 1);
  MenuBorderRadii[length(MenuBorderRadii) -1]:= 5; //-----------------------------// Added the border radius


  //-----------------     Append to BG Colors           --------------------------//

  SetLength(MenuBGColors, length(MenuBGColors) + 1);
  MenuBGColors[length(MenuBGColors) -1]:= clMenuBar; //---------------------------// Added the Form Background color (will also pick up the default)


  //-----------------     Append to FG Colors           --------------------------//

  SetLength(MenuFGColors, length(MenuFGColors) + 1);
  MenuFGColors[length(MenuFGColors) -1]:= clWindowText; //------------------------// Added the Form Background color (will also pick up the default)


  //-----------------     Append to Font Sizes          --------------------------//

  SetLength(MenuFontSizes, length(MenuFontSizes) + 1);
  MenuFontSizes[length(MenuFontSizes) -1]:= 10; //--------------------------------// Added the SystemFont Size


  //-----------------     Append to Font Weight         --------------------------//

  SetLength(MenuFontWeigths, length(MenuFontWeigths) + 1);
  MenuFontWeigths[length(MenuFontWeigths) -1]:= 0; //-----------------------------// Added the SystemFont Weight ->
                                                                                // 0 = normal,
                                                                                // 1 = Bold,                   2^0
                                                                                // 2 = Italic,                 2^1
                                                                                // 3 = Bold Italic,
                                                                                // 4 = UnderLine               2^2
                                                                                // 5 = Bold UnderLine
                                                                                // 6 = Italic Underline
                                                                                // 7 = Bold Italic UnderLine
                                                                                // 8 = Thin                    2^3
                                                                                // ETC

end; //###########################################################################// End of Function

procedure TAdvancedMainMenu.update_RenderItemList(ii_id: Integer);
var
  mPanel        : TBCPanel;
  mLabel        : TBCLabel;
  c             : TBitMap;

  currNode      : ^dataTypes.stringNodeStruct;

begin

  //---------------------    Create the Display Items       ----------------------//

  mPanel        := TBCPanel.create(nil); //---------------------------------------// The main Panel (so that we can also add checkboxes and radios)
  mPanel.Parent := nil;
  mLabel        := TBCLabel.Create(mPanel); //------------------------------------// The label to contain the text of the menu item
  mLabel.Parent := mPanel;

  currNode      := locate_menuNode_byID(ii_id); //--------------------------------// Found the entire node

  //---------------------    Format the Display Items       ----------------------// Insert Default Actions

  mLabel.Caption:= '  ' + currNode^.stringVal + '  '; //--------------------------// Caption
  mPanel.Name   := currNode^.name + 'panel'; //-----------------------------------// The name
  mLabel.Name   := currNode^.name ; //--------------------------------------------// The name of the label remains as the internal identifier
  mPanel.Caption:= ''; //---------------------------------------------------------// Otherwise this will render the internal name on top of the text label
  mPanel.Top    := heightPadding  ; //--------------------------------------------// Constant padding on the top. this is not user controllable
  mPanel.Border.Style:=bboNone;
  mPanel.BevelOuter:=bvNone; //---------------------------------------------------// Otherwise, a border will be drawn

  if ( length(mPanels) = 0) then
  begin
    mPanel.Left := 0;
  end
  else
  begin
    mPanel.Left := mPanels[length(mPanels) - 1].Left + mPanels[length(mPanels) - 1].Width + 0; // left of the entire containing panel
  end;


  mLabel.FontEx.Name := MenuItemFonts[ii_id].Name; //-----------------------------// Font is related to the label
  mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4; //----------------------// Label height
  mPanel.Height := mLabel.Height; //----------------------------------------------// Panel height same as label height
  mLabel.Rounding.RoundX:=MenuBorderRadii[ii_id]; //------------------------------// Rounding...
  mLabel.Rounding.RoundY:=MenuBorderRadii[ii_id];
  mLabel.FontEx.Color:=MenuFGColors[ii_id]; //------------------------------------// Font color
  mLabel.Color  := MenuBGColors[ii_id];
  mPanel.Color  := MenuBGColors[ii_id];
  mLabel.Top    := (mPanel.Height - mLabel.Height) div 2; ;

  c := TBitmap.Create;
  c.Canvas.Font.Assign(Screen.SystemFont);
  mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4; //---------------------// Label width
  mPanel.Width  := mLabel.Width; //-----------------------------------------------// panel width set to be the same
  c.Free;



  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
  //--------------- EXPANSION. IF checkbos/radio ... ADD THEM HERE ---------------//
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//


  //---------------------    Insert into the array(s)       ----------------------// Insert into the arrays

  SetLength(mLabels, length(mLabels) +1);
  mLabels[length(mLabels) - 1] := mLabel;

  SetLength(mPanels, length(mPanels) +1);
  mPanels[length(mPanels) - 1] := mPanel;

end; //###########################################################################// End of Function

procedure TAdvancedMainMenu.update_RenderItemActionList(ii_id: Integer);
var
  currNode      : ^dataTypes.stringNodeStruct;
  mLabel        : TBCLabel;
  procMEnter    : TProc;
  procMExit     : TProc;
  procMClick    : TProc;
begin

  //------------------------    Extract the target       -------------------------//

  mLabel        := mLabels[ii_id];


  //----------------    Attach mouseEnter and exit procs       -------------------//

  procMEnter    := @changeBGColor;
  mLabel.OnMouseEnter:= procMEnter ;

  procMExit     := @restoreBGColor;
  mLabel.OnMouseLeave:= procMExit ;

  procMClick    := @toggleSubMenu;
  mLabel.OnClick:= procMClick;



end; //###########################################################################// End of Function

procedure TAdvancedMainMenu.add_subMenuCheckBox(name: String; state: Boolean);
var
  currNode      : TNodePtr;
begin

  //--------------------   Locate the Menu Item by name       --------------------//

  currNode      := locate_menuNode_byName(name); //-------------------------------// We can use the function we wrote

  currNode^.hasCheckBox:=True;
  currNode^.checkBoxStatus:=state;


end;

procedure TAdvancedMainMenu.add_subMenuPicture(name: String; path: String);
var
  currNode      : TNodePtr;
begin

  //--------------------   Locate the Menu Item by name       --------------------//

  currNode      := locate_menuNode_byName(name); //-------------------------------// We can use the function we wrote

  currNode^.hasPicture:=True;
  currNode^.picturePath:=path;

end;




procedure TAdvancedMainMenu.render(parent: TPanel);
var
  mPanel        : TBCPanel;
  i             : Integer;
  j             : Integer;
  nm            : String;
  currNode      : TNodePtr;

  chldNode      : TNodePtr;
begin

  for i := 0 to length(mPanels) -1 do
  begin

    nm          :=  mLabels[i].Name;
    currNode    :=  locate_menuNode_byName(nm);

    if (currNode^.Parent <> nil) then //------------------------------------------// If it has a parent, it can't be main menu
    begin
      continue; //----------------------------------------------------------------// Thus continue with the next one
    end;

    mPanel      := mPanels[i];
    mPanel.Parent:=parent;


  end;





end; //###########################################################################// End of Function


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



    //--------------    Render Item Format list populated       ------------------// Supply info such as color to Format the panels, the labels etc...

    update_RenderItemFormatList(ii_id);



    //-----------------    Render Item list populated       ----------------------// Create the Label/Panel etc, but DONT render

    update_RenderItemList(ii_id);



    //-----------------    Action Item list populated       ----------------------// Insert Default Actions

    update_RenderItemActionList(ii_id);


  end;


end; //###########################################################################// End of Function


procedure TAdvancedMainMenu.changeBGColor(Sender: TObject);
begin

  (Sender as TBCLabel).Background.Color := clActiveCaption;
  (Sender as TBCLabel).Background.Style := bbsColor;
end;

procedure TAdvancedMainMenu.restoreBGColor(Sender: TObject);
begin
  (Sender as TBCLabel).Background.Color := clMenuBar;
  (Sender as TBCLabel).Background.Style := bbsColor;
end;

procedure TAdvancedMainMenu.changePanel(Sender: TObject);
begin
  (Sender as TBCPanel).Background.Color := TColor($1F3310);
  (Sender as TBCPanel).Border.Color :=  TColor($207A00);
  (Sender as TBCPanel).Border.Width:=1;
  (Sender as TBCPanel).BevelOuter:=bvNone;
  (Sender as TBCPanel).BevelWidth:=0;
  (Sender as TBCPanel).Border.LightWidth:=0;
  (Sender as TBCPanel).Border.Style:=bboSolid;
  (Sender as TBCPanel).BorderBCStyle:=bpsBorder;
  (Sender as TBCPanel).Rounding.RoundX:=5;
  (Sender as TBCPanel).Rounding.RoundY:=5;


  // clInactiveCaption;
end;

procedure TAdvancedMainMenu.restorePanel(Sender: TObject);
begin
  (Sender as TBCPanel).Background.Color := clBackground;
  (Sender as TBCPanel).Border.Width:=0;
  (Sender as TBCPanel).Border.Style:=bboNone;

end;


procedure TAdvancedMainMenu.changeLabelParentPanel(Sender: TObject);
begin
  ((Sender as TBCLabel).Parent as TBCPanel).Background.Color :=  TColor($1F3310);
  ((Sender as TBCLabel).Parent as TBCPanel).Border.Color :=  TColor($207A00);
  ((Sender as TBCLabel).Parent as TBCPanel).Border.Width:=1;
  ((Sender as TBCLabel).Parent as TBCPanel).BevelOuter:=bvNone;
  ((Sender as TBCLabel).Parent as TBCPanel).BevelWidth:=0;
  ((Sender as TBCLabel).Parent as TBCPanel).Border.LightWidth:=0;
  ((Sender as TBCLabel).Parent as TBCPanel).Border.Style:=bboSolid;
  ((Sender as TBCLabel).Parent as TBCPanel).BorderBCStyle:=bpsBorder;
  ((Sender as TBCLabel).Parent as TBCPanel).Rounding.RoundX:=5;
  ((Sender as TBCLabel).Parent as TBCPanel).Rounding.RoundY:=5;


  // clInactiveCaption;
end;

procedure TAdvancedMainMenu.restoreLabelParentPanel(Sender: TObject);
begin
  ((Sender as TBCLabel).Parent as TBCPanel).Background.Color := clBackground;
  ((Sender as TBCLabel).Parent as TBCPanel).Border.Width:=0;
  ((Sender as TBCLabel).Parent as TBCPanel).Border.Style:=bboNone;

end;

procedure TAdvancedMainMenu.toggleSubMenu(Sender: TObject);
var
  i             : Integer;
  nm            : String;
  currNode      : TNodePtr;
  chldNode      : TNodePtr;
  currSblNode   : TNodePtr;
  lst           : String;

  mPanel        : TBCPanel;
  mPanelSbl     : TBCPanel;
  cPanel        : TBCPanel;
  mLabel        : TBCLabel;
  cLabel        : TBCLabel;

  cImage        : TImage;
  cText         : TStaticText;
  cCheckBox     : TCheckBox;

  c             : TBitMap;
  cl            : TColor;

  ii_id         : Integer;
  tHeight       : Integer;
  lHeight       : Integer;
  padding       : Integer;
  maxWidth      : Integer;

  cPanels       : Array of TBCPanel;

begin


  // ###############      TODO NEED TO SET SHOW/HIDE Conditions

  //-----------    Get the name of the sender and the sender itself      ---------//

  nm            :=  (Sender as TBCLabel).Name;
  currNode      :=  locate_menuNode_byName(nm);




  //----------------    Turn Off Other Open Submenus              ----------------//

  //------------------- FIND the first of siblings -------------------------------//
  currSblNode   := currNode;

  while (true) do
  begin
    if (currSblNode^.prev = nil) then
    begin
      break;
    end;
    currSblNode := currSblNode^.prev;
  end;

  //---------------------- Loop over every sibling -------------------------------//
  while (true) do
  begin
    mPanelSbl   := currSblNode^.subMenuContainer;
    break;
  end;



  //--------------    Ensure that there will be no Index Error      --------------//
  end;

  if ( length(currNode^.Children) = 0) then
  begin
    Exit;
  end;


  //------------------   Add a Panel to hold the subMenus      -------------------//

  mPanel        := ;    // The holding panel, will be a child of the great-grandparent
                                                                                  // of the  event sender label
                                                                                  // The parent of the sender is another container panel.
                                                                                  // The grandparent is the big panel that emulates a complete menu bar
                                                                                  // The great grandparent is correct target, where the grandparent is attached.
                                                                                  // The great grandparent is the application form
  mPanel.Parent := (Sender as TBCLabel).Parent.Parent.Parent;

  mPanel.Left   := (Sender as TBCLabel).Parent.Left;  //--------------------------// Set the left to be at the same place as the origin
  mPanel.Top    := (Sender as TBCLabel).Parent.Parent.Top + (Sender as TBCLabel).Parent.Parent.Height;   // Same logic


  tHeight       := 0; //----------------------------------------------------------// Currently no height
  mPanel.Height :=  tHeight; //---------------------------------------------------// pretend no height
  lHeight       := 0; //----------------------------------------------------------// Last height : Has there been anything rendered before?
  padding       := 2; //----------------------------------------------------------// Constant Padding
  maxWidth      := 150; //--------------------------------------------------------// minimum value of maximum width
  mPanel.Width  := maxWidth; //---------------------------------------------------// set initial Width of container panel

  cl            := clBackground; //-----------------------------------------------// get initial color


  //--------------------    Cycle through the Children      ----------------------//

  for i := 0 to length(currNode^.Children) - 1 do
  begin

    chldNode    := currNode^.Children[i]; //--------------------------------------// Find the next child

    ii_id       := locate_integerItem(chldNode^.ID, MenuItemIds); //--------------// Find the suitable ID
    cPanel      := mPanels[ii_id]; //---------------------------------------------// Find the suitable panel. This panel ONLY contains the text label

    cPanel.Parent:= mPanel; //----------------------------------------------------// originally, the panel with the label did not have a parent
                                                                                  // Here, we set the parent to be the new container panel

    cPanel.Left := 0 + padding; //------------------------------------------------// set left
    cPanel.Top:= lHeight + padding; //--------------------------------------------// top = height of all previous children + padding
    cPanel.Height:= 25; //--------------------------------------------------------// set current child height
    cPanel.Background.Color:= cl; //----------------------------------------------// Set color



    //-----------------------    Render a Checkbox      --------------------------//

    if (chldNode^.hasCheckBox) then //--------------------------------------------// If there was a checkbox
    begin

      cCheckBox := TCheckBox.Create(cPanel); //-----------------------------------// create check box
      cCheckBox.Parent := cPanel; //----------------------------------------------// Set parent (these checkboxes themselves aren't saved, but their state will be)
      cCheckBox.Left:=padding; //-------------------------------------------------// Same idea as with cPanel
      cCheckBox.Width:=25;
      cCheckBox.Height:=25;
      cCheckBox.Top:= (cPanel.Height - cCheckBox.Height) div 2;
      cCheckBox.Color:=cl;

      // ###############      TODO NEED TO ADD a onstatechange function

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
      cImage.Height:=20;
      cImage.Width:=20;
      cImage.Stretch:=true;
      cImage.Center:=true;
      cImage.Left:=26;
      cImage.Top:= (cPanel.Height - cImage.Height) div 2;

    end;


    //------------------    Render the menu Text Label      ----------------------//

    cLabel      := mLabels[ii_id];
    cLabel.OnMouseEnter:= nil; //-------------------------------------------------// When these were initially created, these were set to be the same as main menu
    cLabel.OnMouseLeave:= nil;

    // ###############      TODO NEED TO UPDATE SUBMENU MouseIN MouseOUT functions
    cLabel.Left := 50;
    cLabel.Top:= (cPanel.Height - cLabel.Height) div 2;
    cLabel.Color:= cl;

    //############# REFACTOR THIS PART #########################################


    ///// correct the colors

    cPanel.OnMouseEnter:=@changePanel;
    cPanel.OnMouseLeave:=@restorePanel;

    cLabel.OnMouseEnter:=@changeLabelParentPanel; //------------------------------// These will have to change.
    cLabel.OnMouseLeave:=@restoreLabelParentPanel;


    // ###############      TODO NEED TO IMPLEMENT these parts

    //cImage.OnMouseEnter:=@changeParentPanel;    //------------------------------// These will have to be implemented
    //cImage.OnMouseLeave:=@restoreParentPanel;

    //cCheckBox.OnMouseEnter:=@changeParentPanel;
    //cCheckBox.OnMouseLeave:=@restoreParentPanel;

    //############# END REFACTOR THIS PART #####################################




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

  end;

  // ###############      TODO NEED TO ADD A Panel for keyboard  shortcuts

  //-------------    Draw the full submenu container correctly      --------------//

  mPanel.Height:=mPanel.Height + padding; //--------------------------------------// Increase height to add a bottom Margin
  mPanel.Border.Color :=clGrayText; //--------------------------------------------// the submenu container has a border, using a system color
  mPanel.Border.Width:=1;
  mPanel.BevelOuter:=bvNone;
  mPanel.BevelWidth:=0;
  mPanel.Border.LightWidth:=0;
  mPanel.Border.Style:=bboSolid;
  mPanel.BorderBCStyle:=bpsBorder; //---------------------------------------------// Border and bevel is set correctly
  mPanel.Background.Color  := clBackground; //------------------------------------// Background color has set
  mPanel.Rounding.RoundX:=5; //---------------------------------------------------// Constant rounding
  mPanel.Rounding.RoundY:=5;

  for i := 0 to length(cPanels) - 1 do
  begin
    cPanels[i].Width:=mPanel.Width - 2*padding; //--------------------------------// Outer contain of all submenu items has got the proper width
                                                                                  // which is adjusted to the largest of submenu label
                                                                                  // but all other submenu items need to be adjusted 7
                                                                                  // to have uniform width

  end;


  (chldNode^.Parent)^.isSubMenuDrawn:= True;
  (chldNode^.Parent)^.subMenuContainer:=mPanel; //--------------------------------// Registered the open submenu container



  // TODO CHANGE MAIN MENU BACKGROUND
  // TODO ADD A SINGLE LINE UNDER MAIN MENU
  // TODO ADD SUBMENU SHORTCUT PALCEHOLDER

  // TODO ADD Keyboard shortcuts
  // TODO
end;










 {
procedure TAdvancedMainMenu.render({var} parent: TForm);                          // Only draw the main menu. so do not consider children of any node of the menu tree
var
  mLabel        : TBCLabel;
  i             : Integer;
  ii            : Integer;
  ii_id         : Integer;
  mPanel        : TPanel;
  c             : TBitMap;
  currNode      : ^dataTypes.stringNodeStruct;

  procA         : TProc;
  procB         : TProc;

  j             : Integer;
  j_idx         : Integer;
begin
  ii            := 0;


  // first one

  mLabel        := TBCLabel.Create(parent);
  mLabel.Parent := parent;
  mLabel.Caption:= '  ' + menuTree.root^.stringVal + '  ';
  mLabel.Name   := menuTree.root^.name;

  // Extract the menu Item via a DFS search
  j             := extractMenuID(mLabel.Name);

  // find where in the master menu id list j matches an element
  j             := locateItem(j, MenuItemIds);

  // use that index to
  // extract the drawing params

  mLabel.Top    := widthPadding;
  mLabel.Left   := heightPadding;
  mLabel.Font   := MenuItemFonts[j];
  mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4;
  mLabel.Width  := mLabel.Font.GetTextWidth(mLabel.Caption) + 4;
  mLabel.Rounding.RoundX:=MenuBorderRadii[j];
  mLabel.Rounding.RoundY:=MenuBorderRadii[j];
  mLabel.FontEx.Color:=MenuFGColors[j];




  c := TBitmap.Create;
  c.Canvas.Font.Assign(Screen.SystemFont);
  mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4;
  c.Free;

  procA          := @changeBGColor;
  mLabel.OnMouseEnter:= procA ;

  procB          := @restoreBGColor;
  mLabel.OnMouseLeave:= procB ;

  SetLength(mLabels, length(mLabels) +1);
  mLabels[length(mLabels) - 1] := mLabel;

  currNode := menuTree.root;

  while not (currNode^.next = nil) do
  begin
    ii_id         := ii;

    // Extract the menu Item via a DFS search
    j             := extractMenuID(mLabel.Name);

    // find where in the master menu id list j matches an element
    j             := locateItem(j, MenuItemIds);

    currNode      := currNode^.next;
    mLabel        := TBCLabel.Create(parent);
    mLabel.Parent := parent;
    mLabel.Caption:= '  ' + currNode^.stringVal + '  ';
    mLabel.Name   := currNode^.name;
    mLabel.Top    := heightPadding  ;
    mLabel.Left   := mLabels[length(mLabels) - 1].Left + mLabels[length(mLabels) - 1].Width + 0;
    mLabel.Font   := MenuItemFonts[j];
    mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4;
    mLabel.Width  := mLabel.Font.GetTextWidth(mLabel.Caption) + 4;
    mLabel.Rounding.RoundX:=MenuBorderRadii[j];
    mLabel.Rounding.RoundY:=MenuBorderRadii[j];
    mLabel.FontEx.Color:=MenuFGColors[j];


    c := TBitmap.Create;
    c.Canvas.Font.Assign(Screen.SystemFont);
    mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4;
    c.Free;

    procA         := @changeBGColor;
    mLabel.OnMouseEnter:= procA ;

    procB         := @restoreBGColor;
    mLabel.OnMouseLeave:= procB ;

    SetLength(mLabels, length(mLabels) +1);
    mLabels[length(mLabels) - 1] := mLabel;
  end;

  // render every submenu



  // ### TODO ###
  // add font size
  // ADD font color

end;

}

{



procedure TAdvancedMainMenu.showSubMenu(Sender: TObject);
var
  i               : Integer;
  currNode        : ^dataTypes.stringNodeStruct;
begin
  i               := -1;

  currNode        :=  menuTree.root;

  while (True) do
  begin

    // showMessage('checking item : ' + currNode^.name + ' vs ' + name);
    if (currNode^.name = name) then
    begin
      i           := currNode^.ID;                                                // name found
      break;                                                                      // break while loop
    end;
                                                                                  // if at this point, then did not find a match

    if ( length(currNode^.Children) <> 0) then                                    // if there is a child
    begin
      currNode    := currNode^.Children[0];                                       // take the child and loop back
      continue;
    end;
                                                                                  // if at this point, then no child

    if (currNode^.next <> nil) then                                               // if can take the next, take the next
    begin
      currNode    := currNode^.next;
      continue;
    end;
                                                                                  // if at this point, then no next either

    if (currNode^.Parent <> nil) then
    begin
      currNode    := currNode^.Parent;
      if (currNode^.next <> nil) then
      begin
        currNode  := currNode^.next;
        continue;
      end;
    end;

    break;

  end;


  Result          := i;
end;




procedure TAdvancedMainMenu.render_subMenu_ofMainMenu(Sender: TObject);
var
  j                             : Integer;
  menuName                      : String;
  currNode                      : ^dataTypes.stringNodeStruct;
begin

  menuName        := (Sender as TBCLabel).name;                                   // Searching for a
  // currNode        := dataTypes.get_treeNode_byName(menuName);

  // subMenus        := currNode^.Children[0];
  // renderSubmenus(submenus)

  // showMessage((Sender as TBCLabel).name);
  // showMessage('default onclick action');


  //j               := extractMenuID(menuName);
  // find where in the master menu id list j matches an element
  // j               := locateItem(j, MenuItemIds);
end;

procedure TAdvancedMainMenu.render_onPanel({var} parent: TPanel);                 // Only draw the main menu. so do not consider children of any node of the menu tree
var
  mLabel        : TBCLabel;
  i             : Integer;
  ii            : Integer;
  ii_id         : Integer;
  mPanel        : TPanel;
  c             : TBitMap;
  currNode      : ^dataTypes.stringNodeStruct;

  procA         : TProc;
  procB         : TProc;

begin
  ii            := 0;
  // first one
  mLabel        := TBCLabel.Create(parent);
  mLabel.Parent := parent;
  mLabel.Caption:= '  ' + menuTree.root^.stringVal + '  ';
  mLabel.Top    := heightPadding;
  mLabel.Left   := widthPadding;
  mLabel.Font   := Screen.SystemFont;
  mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4;
  mLabel.Width  := mLabel.Font.GetTextWidth(mLabel.Caption) + 4;
  mLabel.Rounding.RoundX:=5;
  mLabel.Rounding.RoundY:=5;
  mLabel.FontEx.Color:=clWindowText;
  c := TBitmap.Create;
  c.Canvas.Font.Assign(Screen.SystemFont);
  mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4;
  c.Free;


  procA          := @changeBGColor;
  mLabel.OnMouseEnter:= procA ;

  procB          := @restoreBGColor;
  mLabel.OnMouseLeave:= procB ;


  SetLength(mLabels, length(mLabels) +1);
  mLabels[length(mLabels) - 1] := mLabel;

  currNode := menuTree.root;

  while not (currNode^.next = nil) do
  begin
    ii_id         := ii;

    currNode      := currNode^.next;
    mLabel        := TBCLabel.Create(parent);
    mLabel.Parent := parent;
    mLabel.Caption:= '  ' + currNode^.stringVal + '  ';
    mLabel.Top    := heightPadding  ;
    mLabel.Left   := mLabels[length(mLabels) - 1].Left + mLabels[length(mLabels) - 1].Width + 0;
    mLabel.Font   := Screen.SystemFont;
    mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4;
    mLabel.Width  := mLabel.Font.GetTextWidth(mLabel.Caption) + 4;
    mLabel.Rounding.RoundX:=5;
    mLabel.Rounding.RoundY:=5;
    mLabel.FontEx.Color:=clWindowText;
    c := TBitmap.Create;
    c.Canvas.Font.Assign(Screen.SystemFont);
    mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4;
    c.Free;

    procA          := @changeBGColor;
    mLabel.OnMouseEnter:= procA ;

    procB          := @restoreBGColor;
    mLabel.OnMouseLeave:= procB ;


    SetLength(mLabels, length(mLabels) +1);
    mLabels[length(mLabels) - 1] := mLabel;
  end;
end;

procedure TAdvancedMainMenu.add_mainMenuActions(var actions: TProcArray);
begin

end;

procedure TAdvancedMainMenu.add_mainMenuClickAction(var i: Integer; var action: TProc);
var
  ii            : Integer;
  idx           : Integer;
  currNode      : ^dataTypes.stringNodeStruct;
begin
  currNode := menuTree.root;


  while not (currNode^.next = nil) do
  begin
    if (currNode^.ID = i) then
    begin
      Break;
    end
    else
    begin
      currNode := currNode^.next;
    end;
  end;


  for idx := 0 to length(MenuItemIds)-1 do
  begin
    if MenuItemIds[idx] = currNode^.ID then
    begin
      ii := idx;
      Break;
    end;

  end;

  mLabels[ii].OnClick:=action;
end;



procedure TAdvancedMainMenu.set_mainMenuItemClickAction_fromTemplate(menuName: String; actionName: String);
var
  j                             : Integer;
begin
  case actionName of
       'show_subMenu':
         begin
           j      := extractMenuID(menuName);

           // find where in the master menu id list j matches an element
           j      := locate_integerItem(j, MenuItemIds);
           mLabels[j].OnClick:=@render_subMenu_ofMainMenu;
           mLabels[j].Name   :=menuName;

           // Extract the menu ID

           // extract the

         end;
  end;
end;

procedure TAdvancedMainMenu.showSubMenu(Sender: TObject);
var
  panel1        : TPanel;
  panel2        : TPanel;
  panel3        : TPanel;

  currlbl       : TBCLabel;
  pTop          : Integer;
  pLeft         : Integer;

  pTopPad       : Integer;
  pLeftPad      : Integer;

  currNode      : ^dataTypes.stringNodeStruct;
  currName      : String;
  nameFound     : Boolean;
  ii            : Integer;
  ii_id         : Integer;
  mLabel        : TBCLabel;
  c             : TBitMap;

  maxW          : Integer;
  totH          : Integer;


begin

                                                                                  // showMessage('1');

                                                                                  // showMessage( (Sender as TLabel).Name);
                                                                                  // showMessage( IntToStr((Sender as TLabel).Top));
                                                                                  // showMessage( IntToStr((Sender as TLabel).Left));

  currlbl       := Sender as TBCLabel;
  pTop          := currlbl.Top + currlbl.Height;
  pLeft         := currlbl.Left;

  pTopPad       := 4;
  pLeftPad      := 4;

  panel1        := TPanel.Create(application.MainForm);
  panel1.Parent := application.MainForm;
  panel1.Top    := pTop;
  panel1.Left   := PLeft;
  panel1.BevelColor:= clBtnText;
  panel1.BevelOuter:= bvSpace;



  currNode      := menuTree.root;
  currName      := currlbl.Name;

  nameFound     := False;

  while not (currNode^.next = nil) do
  begin
                                                                                  // showMessage(currNode^.name + ' --> ' + targetName);
    if (currNode^.name = currName) then
    begin
      nameFound := True;
      Break;
    end
    else
    begin
      currNode  := currNode^.next;
    end;
  end;

  if not nameFound then Exit;

  if length(currNode^.Children) < 1 then Exit;

  currNode      := currNode^.Children[0];

  maxW          := 0;

  mLabel        := TBCLabel.Create(panel1);
  mLabel.Parent := panel1;
  mLabel.Caption:= currNode^.stringVal;
  mLabel.Name   := currNode^.name;
  mLabel.Top    := widthPadding;
  mLabel.Left   := heightPadding;
  mLabel.Font   := Screen.SystemFont;
  mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4;
  mLabel.Width  := mLabel.Font.GetTextWidth(mLabel.Caption) + 4;
  c := TBitmap.Create;
  c.Canvas.Font.Assign(Screen.SystemFont);
  mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4;
  c.Free;

  if mLabel.Width > maxW then maxW := mLabel.Width;
  totH          := mLabel.Top + mLabel.Height;


  SetLength(mLabels, length(mLabels) +1);
  mLabels[length(mLabels) - 1] := mLabel;

  while not (currNode^.next = nil) do
  begin
    ii_id         := ii;

    currNode      := currNode^.next;
    mLabel        := TBCLabel.Create(panel1);
    mLabel.Parent := panel1;
    mLabel.Caption:= currNode^.stringVal;
    mLabel.Name   := currNode^.name;
    mLabel.Top    := heightPadding + mLabels[length(mLabels) - 1].Top + mLabels[length(mLabels) - 1].Height + 5  ;
    mLabel.Left   := widthPadding ;
    mLabel.Font   := Screen.SystemFont;
    mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4;
    mLabel.Width  := mLabel.Font.GetTextWidth(mLabel.Caption) + 4;
    c := TBitmap.Create;
    c.Canvas.Font.Assign(Screen.SystemFont);
    mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4;
    c.Free;

    if mLabel.Width > maxW then maxW := mLabel.Width;
    totH          := mLabel.Top + mLabel.Height;

    SetLength(mLabels, length(mLabels) +1);
    mLabels[length(mLabels) - 1] := mLabel;
  end;

                                                                                 // showMessage('2');


  panel1.Height   := totH + 5;
  panel1.Width    := maxW + 15;
end;



}






























function TAdvancedMainMenu.get_uniqueID: Integer;
begin
  currentID    := currentID + 1; //-----------------------------------------------// increment current ID
  Result       := currentID - 1; //-----------------------------------------------// new id is one more than the current ID
                                                                                  // We have to increment the current ID first, because
                                                                                  // the last line of the function should contain
                                                                                  // the special variable Result
                                                                                  // -1. because we want to return the value that was
                                                                                  // previously in it

end;

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
end;

function TAdvancedMainMenu.locate_menuNode_byID(ii_id: Integer): TNodePtr;
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

    // showMessage('checking item : ' + currNode^.name + ' vs ' + name);
    if (currNode^.ID = ii_id) then
    begin
      resNode   := currNode;                                                    // name found
      break;                                                                      // break while loop
    end;
                                                                                  // if at this point, then did not find a match

    if ( length(currNode^.Children) <> 0) then                                    // if there is a child
    begin
      currNode  := currNode^.Children[0];                                       // take the child and loop back
      continue;
    end;
                                                                                  // if at this point, then no child

    if (currNode^.next <> nil) then                                               // if can take the next, take the next
    begin
      currNode  := currNode^.next;
      continue;
    end;
                                                                                  // if at this point, then no next either

    if (currNode^.Parent <> nil) then
    begin
      currNode  := currNode^.Parent;
      if (currNode^.next <> nil) then
      begin
        currNode:= currNode^.next;
        continue;
      end;
    end;

    break;

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

    // showMessage('checking item : ' + currNode^.name + ' vs ' + name);
    if (currNode^.name = nm) then
    begin
      resNode   := currNode;                                                    // name found
      break;                                                                      // break while loop
    end;
                                                                                  // if at this point, then did not find a match

    if ( length(currNode^.Children) <> 0) then                                    // if there is a child
    begin
      currNode  := currNode^.Children[0];                                       // take the child and loop back
      continue;
    end;
                                                                                  // if at this point, then no child

    if (currNode^.next <> nil) then                                               // if can take the next, take the next
    begin
      currNode  := currNode^.next;
      continue;
    end;
                                                                                  // if at this point, then no next either

    if (currNode^.Parent <> nil) then
    begin
      currNode  := currNode^.Parent;
      if (currNode^.next <> nil) then
      begin
        currNode:= currNode^.next;
        continue;
      end;
    end;

    break;

  end;


  Result        := resNode;

end;



function generate_randomNumber() : Integer   ;
begin
  Result        := 0;
end;

function locate_integerItem(needle: Integer; haystack : Array of Integer ) : Integer;
var
  i                     :  Integer;
  j                     :  Integer;
begin
  j                     := -1;
  for i := 0 to length(haystack) -1 do
  begin
    if ( haystack[i] = needle) then
    begin
      j                 := i;
      break;
    end;

  end;
  Result                := j;
end;

end.

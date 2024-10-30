# LazarusMenu

What is going on : A new Lazarus Menu Widget to overcome limitations of the default Menu.

## Status
WIP - Do *NOT* use in production.

## Howto 

Include the files `datatypes.pas` and `TAdvancedMenu.pas` in your project.

Then, in your `mainForm.FormCreate`:

```
procedure TForm1.FormCreate(Sender: TObject);
var
  MainMenuItems : Array of String;
  MainMenuNames : Array of String;

  mForm         : TForm;
  mPanel        : TPanel;
  ta            : TAdvancedMenu.TProc;
  ids           : Integer;

  FileMenuItems : Array of String;
  FileMenuItemNames:Array of String;

  NewMenuItems  : Array of String;
  NewMenuItemNames:Array of String;

  OpenMenuItems : Array of String;

begin
  MainMenuItems := ['File', 'Edit', 'View', '[Select Mode]', 'Tools', 'Help'];
  MainMenuNames := ['fileMenu', 'editMenu', 'viewMenu', 'selectMenu', 'toolMenu', 'helpMenu'];
  MainMenu      := TAdvancedMenu.TAdvancedMainMenu.Create();
  MainMenu.create_mainMenu(MainMenuItems, MainMenuNames);

  mForm         := Form1;
  MainMenu.render(Form1);

  mPanel        := Panel1;
  MainMenu.render_onPanel(Panel1);

  FileMenuItems := ['New', 'Open', 'Save', 'Import', 'Export', 'Print', 'Send', 'Close', 'Quit'];
  FileMenuItemNames:=['newMenu', 'openMenu', 'saveMenu', 'importMenu', 'exportMenu', 'printMenu', 'sendMenu', 'closeMenu', 'quitMenu' ];

  NewMenuItems  := ['Blank Document', 'From Templates'];
  NewMenuItemNames:=['blankDocumentMenu', 'fromTemplateMenu'];

  OpenMenuItems := ['Open Recents', 'Open Existing Document'];


  
  ta            := @FileClick;
  ids           := 1;
  MainMenu.add_mainMenuClickAction(ids, ta);                      // <----- Worls
  

  // MainMenu.add_mainMenuClickAction_byName('File', ta);         // <----- TODO do it by name
  MainMenu.add_mainMenuSubMenu_byName('fileMenu', FileMenuItems, FileMenuItemNames);
  // MainMenu.add_subMenuSubMenu_byName('newMenu', NewMenuItems); // <---- TODO

end;



```

## Next Step :

- [`*`] Add Submenu of Arbitrary Depth
- [`x`] Add Actions
- [` `] Add Radio / Check / Images etc

Legends:

- `*` -> Working on it now
- `x` -> Finished
- ` ` -> planned

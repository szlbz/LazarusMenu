# LazarusMenu

What is going on : A new Lazarus Menu Widget to overcome limitations of the default Menu.  
原代码有很多Bug及使用了bgracontrols控件，我这个版本删除bgracontrols控件，修改后已可以正常使用。  
## 2024-11-15增加菜单阴影  
## 2024-11-12增加左边栏菜单功能  

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

## 在aarch64 for 银河麒麟运行截图：  
![image](https://github.com/user-attachments/assets/bc395d6d-9ea2-4c0d-89bb-5d068971b550)
## 在windows 11运行截图：  
![image](https://github.com/user-attachments/assets/f64d214b-8af2-4cd3-940a-0aa2ea04f6db)
## 新增加的左边栏菜单功能在windows 11运行截图：
![image](https://github.com/user-attachments/assets/6869bc44-d26c-4330-9459-ef3bb7c98fd4)
## 新增加的左边栏菜单功能在aarch64 for 银河麒麟运行截图：
![image](https://github.com/user-attachments/assets/3c1d3a94-b10d-43dc-994c-837bded5b561)
![image](https://github.com/user-attachments/assets/a5c765ff-45aa-4c53-bf69-90f2818abde2)




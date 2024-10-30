unit Unit1;

{$mode objfpc}{$H+}

interface



uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  TAdvancedMenu, Themes,ActnList, LCLProc;

type

  { TForm1 }

  TForm1 = class(TForm)
    Action1: TAction;
    ActionList1: TActionList;
    Panel2: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FileClick(Sender: TObject);
    procedure quitApplication(Sender: TObject);
    procedure printData(Sender: TObject);
    procedure sendData(Sender: TObject);
  private

  public

  end;

var
  Form1         : TForm1;
  MainMenu      : TAdvancedMenu.TAdvancedMainMenu;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  MainMenuItems : Array of String;
  MainMenuNames : Array of String;

  mForm         : TForm;
  mPanel        : TPanel;
  qa            : TAdvancedMenu.TProc;
  pa            : TAdvancedMenu.TProc;
  sa            : TAdvancedMenu.TProc;

  ids           : Integer;

  FileMenuItems : Array of String;
  FileMenuItemNames:Array of String;

  EditMenuItems : Array of String;
  EditMenuItemNames:Array of String;

  NewMenuItems  : Array of String;
  NewMenuItemNames:Array of String;

  ViewMenuItems:array of string;
  ViewMenuItemNames:array of string;


  OpenMenuItems : Array of String;
  OpenMenuItemNames:Array of String;

  recentMenuItems : Array of String;
  recentMenuItemNames:Array of String;

  closeMenuShortCut : String;
  quitMenuShortCut  : String;
  importMenuShortCut: String;

  blankDocumentMenuShortCut   :  String;
  fromTemplateMenuShortCut    :  String;

begin
  MainMenuItems := ['文件', 'Edit', 'View', '[Select Mode]', 'Tools', 'Help'];
  MainMenuNames := ['fileMenu', 'editMenu', 'viewMenu', 'selectMenu', 'toolMenu', 'helpMenu'];
  MainMenu      := TAdvancedMenu.TAdvancedMainMenu.Create();
  MainMenu.create_mainMenu(MainMenuItems, MainMenuNames);


  FileMenuItems := ['新建', '打开', '保存', '导入', '导出', '打印', 'Send', 'Close', 'Quit'];
  FileMenuItemNames:=['newMenu', 'openMenu', 'saveMenu', 'importMenu', 'exportMenu', 'printMenu', 'sendMenu', 'closeMenu', 'quitMenu' ];

  EditMenuItems := ['Undo', 'Redo', '-', 'Cut', 'Copy', 'Paste'];
  EditMenuItemNames:=['undoMenu', 'redoMenu','divider1' ,'cutMenu', 'copyMenu', 'pasteMenu'];

  ViewMenuItems:= ['view', 'Redo', '-', 'Cut1', 'Copy', 'Paste'];
  ViewMenuItemNames:=['viewMenu1', 'redoMenu1','divider11' ,'cutMenu1', 'copyMenu1', 'pasteMenu1'];

  MainMenu.set_BGColor('viewMenu', TColor($88DDBB));//$662244));
  MainMenu.set_FGColor('helpMenu', TColor($88DDBB));

  mForm         := Form1;

  MainMenu.add_mainMenuSubMenu_byName('fileMenu', FileMenuItems, FileMenuItemNames);  // SUBMENU ADDED BUT WILL NOT RENDER
  MainMenu.add_mainMenuSubMenu_byName('editMenu', EditMenuItems, EditMenuItemNames);  // SUBMENU ADDED BUT WILL NOT RENDER
  MainMenu.add_mainMenuSubMenu_byName('viewMenu', ViewMenuItems, ViewMenuItemNames);  // SUBMENU ADDED BUT WILL NOT RENDER


  MainMenu.add_subMenuCheckBox('newMenu', True);
  MainMenu.add_subMenuCheckBox('exportMenu', False);

  MainMenu.add_subMenuPicture('newMenu', 'new.png');
  MainMenu.add_subMenuPicture('openMenu', 'open.png');

  MainMenu.set_FGColor('closeMenu', TColor($88DDBB));


  NewMenuItems  := ['Blank Document', 'From Templates'];
  NewMenuItemNames:=['blankDocumentMenu', 'fromTemplateMenu'];

  OpenMenuItems := ['Open Recents', 'Open Existing Document', 'Open Remote'];
  OpenMenuItemNames:=['recentItemsMenu', 'existingItemMenu', 'RemoteItemMenu'];

  recentMenuItems := ['File A', 'File B', 'File C', 'File D'];
  recentMenuItemNames:=['fileA', 'fileB', 'fileC', 'fileD'];

  closeMenuShortCut := 'Strg + W';
  quitMenuShortCut  := ShortCutToText(Action1.ShortCut);
  importMenuShortCut:= 'Strg + Umschalt + I';

  fromTemplateMenuShortCut := 'Strg + Umschalt + N';
  blankDocumentMenuShortCut:= 'Strg + N' ;

  MainMenu.assign_subMenuShortCut('closeMenu', closeMenuShortCut);
  MainMenu.assign_subMenuShortCut('quitMenu', quitMenuShortCut);
  MainMenu.assign_subMenuShortCut('importMenu', importMenuShortCut);

  MainMenu.add_subMenuSubMenu_byName('newMenu', NewMenuItems, NewMenuItemNames);
  MainMenu.add_subMenuSubMenu_byName('openMenu', openMenuItems, openMenuItemNames);

  MainMenu.add_subMenuSubMenu_byName('recentItemsMenu', recentMenuItems, recentMenuItemNames);

  MainMenu.assign_subMenuShortCut('blankDocumentMenu', blankDocumentMenuShortCut); 
  MainMenu.assign_subMenuShortCut('fromTemplateMenu' , fromTemplateMenuShortCut);


  mPanel        := Panel2;
  MainMenu.render(mPanel);


  qa            := @quitApplication;
  MainMenu.add_clickAction_byName('quitMenu', qa);
  Action1.OnExecute:=@quitApplication;
  MainMenu.add_clickAction_byName('printMenu', @printData);
  MainMenu.add_clickAction_byName('sendMenu', @sendData);

end;

procedure TForm1.FileClick(Sender: TObject);
begin
  showMessage('file clicked');
end;

procedure TForm1.quitApplication(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.printData(Sender: TObject);
begin
  showMessage('print clicked');
end;

procedure TForm1.sendData(Sender: TObject);
begin
  showMessage('Sending data');
end;

end.


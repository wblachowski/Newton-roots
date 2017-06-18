unit Unit4;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  IntervalArithmetic32and64,uTExtendedX87, Vcl.ExtCtrls,Math;

type
  TForm4 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label3: TLabel;
    Button3: TButton;
    Label2: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    EditA: TEdit;
    Edit2: TEdit;
    EditB: TEdit;
    RadioGroup1: TRadioGroup;
    GroupBox1: TGroupBox;
    Edit1: TEdit;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;
  DLLPath: string;
type
  Tifunction = function(x: interval):interval;
  Tfunction=function(x: Extended):Extended;
implementation

{$R *.dfm}
function NewtonRaphson(x: Extended; f,df,d2f: Tfunction; mit:Integer; eps: Extended; out fatx: Extended; it: Integer; out st: Integer): Extended;
var
  next_x: Extended;
begin
   if it=mit then
   begin
   Result:=x;
   exit;
   end;
  next_x:=x-(df(x)+sqrt(df(x)*df(x)-2*f(x)*d2f(x)))/d2f(x);
  if abs(next_x-x)/Max(abs(next_x),abs(x))<eps then
  begin
    Result:=next_x;
    exit;
  end;


  Result:=NewtonRaphson(next_x,f,df,d2f,mit,eps,fatx,it+1,st);
end;
function iNewtonRaphson(x: interval; f, df, d2f: Tifunction; mit: Integer; eps: interval; out fatx: interval; it: Integer; out st: Integer) :interval ;
var
  next_x: interval;
  pom: interval;
  sto: Integer;
  dwa : interval;
  max : interval;
  roznica : interval;
  abso: interval;
  pomocniczy : Extended;
  iloraz : interval;
begin
   if it=mit then
   begin
   Result:=x;
   exit;
   end;

   dwa.a:=2;
   dwa.b:=2;
   pom:=imul(dwa,imul(f(x),d2f(x)));
   pom:=isub(imul(df(x),df(x)),pom);     //to nie moze byc ujemne, bedzie pierwiastkowane
   pom:=isqrt(pom,sto);
   pom:=iadd(df(x),pom);
   pom:=idiv(pom,d2f(x));
   next_x:=isub(x,pom);

   roznica:=idiv(next_x,x);
   if (roznica.a<0) and (roznica.b<0) then
   begin
      pomocniczy:=roznica.a;
      roznica.a:=roznica.b*-1;
      roznica.b:=pomocniczy*-1;
   end;
   if (roznica.a<0) and (roznica.b>=0) then
   begin
      pomocniczy:=roznica.a;
      roznica.a:=0;
      roznica.b:=Max(abs(pomocniczy),abs(roznica.b));
   end;
   if next_x.a<x.a then
   begin
   max:=x;
   end;
   if next_x.a>=x.a then
   begin
   max:=next_x;
   end;

   iloraz:=idiv(roznica,max);

   if iloraz.b<eps.b then
   begin
     Result:=next_x;
     exit;
   end;

   Result:=iNewtonRaphson(next_x,f,df,d2f,mit,eps,fatx,it+1,st);
end;
procedure TForm4.Button1Click(Sender: TObject);
var
  selectedFile: string;
  dlg: TOpenDialog;
begin
  selectedFile := '';
  dlg := TOpenDialog.Create(nil);
  try
    dlg.InitialDir := 'C:\Users\wblachowski\Documents\Embarcadero\Studio\Projects\Win64\Debug';
    dlg.Filter := 'All files (*.*)|*.*';
    if dlg.Execute(Handle) then
      selectedFile := dlg.FileName;
  finally
    dlg.Free;
  end;
  if selectedFile <> '' then
    DLLPath:=selectedFile;
    Label1.Caption:=Copy(selectedFile,LastDelimiter('\',selectedFile)+1,selectedFile.Length-LastDelimiter('\',selectedFile));
end;


procedure TForm4.Button3Click(Sender: TObject);
var
  DLL : THandle; // uchwyt biblioteki
  i_f : function(x: interval) : interval ;
  i_df : function(x: interval) : interval ;
  i_d2f : function(x: interval) : interval ;
  f : function(x: Extended) : Extended ;
  df : function(x: Extended) : Extended ;
  d2f : function(x: Extended) : Extended ;
  iwynik : interval;
  iargument : interval;
  wynik: Extended;
  argument: Extended;
  pomoc : Integer;
  ipomoc: interval;
begin
  Label3.Visible:=true;
  Label2.Visible:=true;
  DLL := LoadLibrary(PChar(DLLPath)); // laduj biblioteke
  if RadioGroup1.ItemIndex=0 then
  begin
  try
    @f := GetProcAddress(DLL, 'f'); // laduj procedure
    if @f=nil then raise Exception.Create('Bład - nie mogę znaleźć funkcji f w bibliotece!');
    @df := GetProcAddress(DLL, 'df'); // laduj procedure
    if @df=nil then raise Exception.Create('Bład - nie mogę znaleźć funkcji df w bibliotece!');
    @d2f := GetProcAddress(DLL, 'd2f'); // laduj procedure
    if @d2f=nil then raise Exception.Create('Bład - nie mogę znaleźć funkcji d2f w bibliotece!');

      argument:=StrToFloat(EditA.Text);
      wynik:=NewtonRaphson(argument,f,df,d2f,Trunc(StrToFloat(Edit2.Text)),StrToFloat(Edit1.Text),argument,0,pomoc);
      Label3.Caption:=FloatToStr(wynik);

    finally
      FreeLibrary(DLL); // wreszcie zwolnij pamiec
  end;
  end;
  if RadioGroup1.ItemIndex<>0 then
  begin
  try
    @i_f := GetProcAddress(DLL, 'f'); // laduj procedure
    if @i_f=nil then raise Exception.Create('Bład - nie mogę znaleźć funkcji f w bibliotece!');
    @i_df := GetProcAddress(DLL, 'df'); // laduj procedure
    if @i_df=nil then raise Exception.Create('Bład - nie mogę znaleźć funkcji df w bibliotece!');
    @i_d2f := GetProcAddress(DLL, 'd2f'); // laduj procedure
    if @i_d2f=nil then raise Exception.Create('Bład - nie mogę znaleźć funkcji d2f w bibliotece!');
    if RadioGroup1.ItemIndex=2 then
    begin
    iargument.a:=StrToFloat(EditA.Text);
    iargument.b:=StrToFloat(EditB.Text);
    end;
    if RadioGroup1.ItemIndex=1 then
    begin
      iargument:=int_read(EditA.Text);
    end;

    iwynik:=iNewtonRaphson(iargument,i_f,i_df,i_d2f,Trunc(StrToFloat(Edit2.Text)),int_read(Edit1.Text),ipomoc,0,pomoc);
    Label3.Caption:=FloatToStr(iwynik.a);
    Label2.Caption:=FLoatToStr(iwynik.b);

    finally
      FreeLibrary(DLL); // wreszcie zwolnij pamiec
  end;
  end;
end;
procedure TForm4.RadioGroup1Click(Sender: TObject);
begin
  if RadioGroup1.ItemIndex=2then EditB.Visible:=true
  else EditB.Visible:=false;

end;

end.

unit UI.Design.GridColumns;

interface

uses
  UI.Grid,
  System.Math,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Objects,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Layouts, UI.Base, UI.Standard,
  FMX.ListBox;

type
  TGridColumnsDesigner = class(TForm)
    Layout3: TLayout;
    Label1: TLabel;
    Label2: TLabel;
    edtOpacity: TEdit;
    Label3: TLabel;
    edtRowsPan: TEdit;
    Label4: TLabel;
    edtPaddingBottom: TEdit;
    GridView: TStringGridView;
    cbGravity: TComboBox;
    cbDataType: TComboBox;
    Label5: TLabel;
    Label6: TLabel;
    edtColsPan: TEdit;
    Label7: TLabel;
    edtPaddingLeft: TEdit;
    Label8: TLabel;
    edtPaddingTop: TEdit;
    Label9: TLabel;
    edtPaddingRight: TEdit;
    Label10: TLabel;
    edtTag: TEdit;
    ckLocked: TCheckBox;
    ckDataFilter: TCheckBox;
    ckReadOnly: TCheckBox;
    ckVisible: TCheckBox;
    ckEnabled: TCheckBox;
    ckWordWrap: TCheckBox;
    Label11: TLabel;
    edtTitle: TEdit;
    Layout1: TLayout;
    Button2: TButton;
    btnOk: TButton;
    btnUp: TButton;
    btnNext: TButton;
    tvIndex: TLabel;
    Label12: TLabel;
    edtRowCount: TEdit;
    tvColCount: TLabel;
    edtColCount: TEdit;
    Line1: TLine;
    edtFieldName: TEdit;
    tvField: TLabel;
    edtFixedColCount: TEdit;
    tvFixedColCount: TLabel;
    edtWidth: TEdit;
    Label13: TLabel;
    procedure btnOkClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure GridViewFixedCellClick(Sender: TObject; const ACol,
      ARow: Integer);
    procedure GridViewTitleClick(Sender: TObject; Item: TGridColumnItem);
    procedure edtRowCountKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure edtRowCountExit(Sender: TObject);
    procedure edtColCountExit(Sender: TObject);
    procedure edtTitleExit(Sender: TObject);
    procedure cbGravityClick(Sender: TObject);
    procedure cbDataTypeClick(Sender: TObject);
    procedure tvFieldExit(Sender: TObject);
    procedure edtOpacityExit(Sender: TObject);
    procedure edtPaddingLeftExit(Sender: TObject);
    procedure edtPaddingTopExit(Sender: TObject);
    procedure edtPaddingRightExit(Sender: TObject);
    procedure edtPaddingBottomExit(Sender: TObject);
    procedure edtTagExit(Sender: TObject);
    procedure edtRowsPanExit(Sender: TObject);
    procedure edtColsPanExit(Sender: TObject);
    procedure edtFixedColCountExit(Sender: TObject);
    procedure ckLockedClick(Sender: TObject);
    procedure ckDataFilterClick(Sender: TObject);
    procedure ckReadOnlyClick(Sender: TObject);
    procedure ckVisibleClick(Sender: TObject);
    procedure ckEnabledClick(Sender: TObject);
    procedure ckWordWrapClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure edtWidthExit(Sender: TObject);
  private
    { Private declarations }
    [Weak] SrcGridView: TGridBase;
    [Weak] CurItem: TGridColumnItem;
    FIsDBGrid: Boolean;
    FCol, FRow: Integer;

    FUpdateing: Boolean;

    procedure DoChange();


    procedure SetColumns(const Value: TGridColumns);
    function GetColumns: TGridColumns;

    procedure UpdateState;
  public
    { Public declarations }
    property Columns: TGridColumns read GetColumns write SetColumns;
  end;

var
  GridColumnsDesigner: TGridColumnsDesigner;

implementation

{$R *.fmx}

const
  CInvNo = -9999;

procedure TGridColumnsDesigner.btnNextClick(Sender: TObject);

  function SkipPanCol(const ACol: Integer): Integer;
  var
    Item: TGridColumnItem;
  begin
    if Columns.TryGetItem(ACol, FRow, Item) and (Assigned(Item)) and (Item.ColsPan > 0) then
      Result := ACol + Item.ColsPan
    else
      Result := ACol + 1;
  end;

var
  MCol, MRow: Integer;
begin
  MCol := Columns.ColsCount - 1;
  MRow := Columns.RowsCount - 1;

  if (FRow < MRow) or (FCol < MRow) then begin
    if FCol < MCol then begin
      FCol := SkipPanCol(FCol);
    end else begin
      if FRow < MRow then begin
        Inc(FRow);
        FCol := 0;
      end;
    end;
    GridView.ScrollToCell(TGridCell.Create(0, FCol));
    CurItem := Columns.Items[FCol, FRow];
    UpdateState;
  end;
end;

procedure TGridColumnsDesigner.btnOkClick(Sender: TObject);
begin
  if Assigned(SrcGridView) and (SrcGridView is TStringGridView) then begin
    TStringGridView(SrcGridView).ColCount := GridView.ColCount;
  end;
  ModalResult := mrOk;
end;

procedure TGridColumnsDesigner.btnUpClick(Sender: TObject);

  function SkipPanCol(const ACol: Integer): Integer;
  var
    I, J: Integer;
    Item: TGridColumnItem;
  begin
    I := 0;
    J := ACol;
    while I <= ACol do begin
      Item := nil;
      J := I;
      if Columns.TryGetItem(I, FRow, Item) and (Assigned(Item)) and (Item.ColsPan > 0) then
        I := I + Item.ColsPan
      else
        Inc(I);
    end;
    Result := J;
  end;

begin
  if (FRow > 0) or (FCol > 0) then begin
    if FCol > 0 then begin
      Dec(FCol);
      FCol := SkipPanCol(FCol);
    end else begin
      if FRow > 0 then begin
        Dec(FRow);
        FCol := SkipPanCol(Columns.ColsCount - 1);
      end;
    end;
    GridView.ScrollToCell(TGridCell.Create(0, FCol));
    CurItem := Columns.Items[FCol, FRow];
    UpdateState;
  end;
end;

procedure TGridColumnsDesigner.Button2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TGridColumnsDesigner.cbDataTypeClick(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.DataType := TGridDataType(cbDataType.ItemIndex);
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.cbGravityClick(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.Gravity := TLayoutGravity(cbGravity.ItemIndex);
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.ckDataFilterClick(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.DataFilter := TCheckBox(Sender).IsChecked;
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.ckEnabledClick(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.Enabled := TCheckBox(Sender).IsChecked;
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.ckLockedClick(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.Locked := TCheckBox(Sender).IsChecked;
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.ckReadOnlyClick(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.ReadOnly := TCheckBox(Sender).IsChecked;
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.ckVisibleClick(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.Visible := TCheckBox(Sender).IsChecked;
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.ckWordWrapClick(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.WordWrap := TCheckBox(Sender).IsChecked;
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.DoChange;
begin
  if not FUpdateing then
    Columns.Change;
end;

procedure TGridColumnsDesigner.edtColCountExit(Sender: TObject);
begin
  Columns.ColsCount := StrToIntDef(TEdit(Sender).Text, Columns.ColsCount);
end;

procedure TGridColumnsDesigner.edtColsPanExit(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.ColsPan := StrToIntDef(TEdit(Sender).Text, CurItem.ColsPan);
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.edtFixedColCountExit(Sender: TObject);
begin
  GridView.FixedCols := StrToIntDef(TEdit(Sender).Text, GridView.FixedCols);
end;

procedure TGridColumnsDesigner.edtOpacityExit(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.Opacity := StrToFloatDef(TEdit(Sender).Text, CurItem.Opacity);
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.edtPaddingBottomExit(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.Padding.Bottom := StrToFloatDef(TEdit(Sender).Text, CurItem.Padding.Bottom);
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.edtPaddingLeftExit(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.Padding.Left := StrToFloatDef(TEdit(Sender).Text, CurItem.Padding.Left);
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.edtPaddingRightExit(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.Padding.Right := StrToFloatDef(TEdit(Sender).Text, CurItem.Padding.Right);
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.edtPaddingTopExit(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.Padding.Top := StrToFloatDef(TEdit(Sender).Text, CurItem.Padding.Top);
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.edtRowCountExit(Sender: TObject);
begin
  Columns.RowsCount := StrToIntDef(TEdit(Sender).Text, Columns.RowsCount);
end;

procedure TGridColumnsDesigner.edtRowCountKeyDown(Sender: TObject;
  var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
    TControl(Sender).FocusToNext();
end;

procedure TGridColumnsDesigner.edtRowsPanExit(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.RowsPan := StrToIntDef(TEdit(Sender).Text, CurItem.RowsPan);
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.edtTagExit(Sender: TObject);
begin
  if Assigned(CurItem) then
    CurItem.Tag := StrToIntDef(TEdit(Sender).Text, CurItem.Tag);
end;

procedure TGridColumnsDesigner.edtTitleExit(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.Title := TEdit(Sender).Text;
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.edtWidthExit(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    CurItem.Width := StrToFloatDef(TEdit(Sender).Text, 0);
    DoChange;
  end;
end;

function TGridColumnsDesigner.GetColumns: TGridColumns;
begin
  Result := GridView.Columns;
end;

procedure TGridColumnsDesigner.GridViewFixedCellClick(Sender: TObject;
  const ACol, ARow: Integer);
begin
  FCol := ACol;
  FRow := ARow;
  UpdateState;
  ShowMessage(Format('GridViewFixedCellClick. Col: %d, Row: %d', [FCol, FRow]));
end;

procedure TGridColumnsDesigner.GridViewTitleClick(Sender: TObject;
  Item: TGridColumnItem);
begin
  FCol := Item.ColIndex;
  FRow := Item.RowIndex;
  CurItem := Item;
  UpdateState;
end;

procedure TGridColumnsDesigner.SetColumns(const Value: TGridColumns);
begin
  GridView.Columns.Assign(Value);
  FIsDBGrid := False;
  SrcGridView := nil;

  if Assigned(Value) and Assigned(Value.GridView) then begin
    SrcGridView := Value.GridView;
    FIsDBGrid := Value.GridView is TDBGridView;
    GridView.ColCount := Value.GridView.ColCount;
    edtFixedColCount.Enabled := SrcGridView is TStringGridView;
    GridView.FixedCols := SrcGridView.FixedCols;
  end else
    edtFixedColCount.Enabled := False;

  tvFixedColCount.Enabled := edtFixedColCount.Enabled;

  if not FIsDBGrid then begin
    tvField.Visible := False;
    edtFieldName.Visible := False;
    edtTitle.Width := edtFieldName.Position.X + edtFieldName.Width - edtTitle.Position.X;
  end;

  FCol := CInvNo;
  FRow := CInvNo;

  UpdateState;
end;

procedure TGridColumnsDesigner.tvFieldExit(Sender: TObject);
begin
  if Assigned(CurItem) then begin
    TGridDBColumnItem(CurItem).FieldName := TEdit(Sender).Text;
    DoChange();
  end;
end;

procedure TGridColumnsDesigner.UpdateState;
begin
  FUpdateing := True;

  try
    edtRowCount.Text := IntToStr(Columns.RowsCount);
    edtColCount.Text := IntToStr(Columns.ColsCount);

    btnUp.Enabled := (FRow > 0) or (FCol > 0);
    btnNext.Enabled := (FRow < Columns.RowsCount - 1) or (FCol < Columns.ColsCount - 1);

    if (CurItem = nil) or (FCol = CInvNo) or (FRow = CInvNo) then begin
      tvIndex.Text := '';
      Exit;
    end else
      tvIndex.Text := Format('Col: %d  Row: %d', [FCol, FRow]);

    cbGravity.ItemIndex := Ord(CurItem.Gravity);
    cbDataType.ItemIndex := Ord(CurItem.DataType);
    edtTitle.Text := CurItem.Title;

    edtFixedColCount.Text := IntToStr(GridView.FixedCols);

    if CurItem is TGridDBColumnItem then
      edtFieldName.Text := TGridDBColumnItem(CurItem).FieldName
    else
      edtFieldName.Text := '';

    edtOpacity.Text := FloatToStr(Round(CurItem.Opacity * 10000) / 10000);
    edtPaddingLeft.Text := FloatToStr(Round(CurItem.Padding.Left * 10000) / 10000);
    edtPaddingTop.Text := FloatToStr(Round(CurItem.Padding.Top * 10000) / 10000);
    edtPaddingRight.Text := FloatToStr(Round(CurItem.Padding.Right * 10000) / 10000);
    edtPaddingBottom.Text := FloatToStr(Round(CurItem.Padding.Bottom * 10000) / 10000);
    edtWidth.Text := FloatToStr(Round(CurItem.Width * 10000) / 10000);

    edtTag.Text := IntToStr(CurItem.Tag);
    edtRowsPan.Text := IntToStr(CurItem.RowsPan);
    edtColsPan.Text := IntToStr(CurItem.ColsPan);


    ckLocked.IsChecked := CurItem.Locked;
    ckEnabled.IsChecked := CurItem.Enabled;
    ckDataFilter.IsChecked := CurItem.DataFilter;
    ckReadOnly.IsChecked := CurItem.ReadOnly;
    ckVisible.IsChecked := CurItem.Visible;
    ckWordWrap.IsChecked := CurItem.WordWrap;

  finally
    FUpdateing := False;
  end;
end;

end.

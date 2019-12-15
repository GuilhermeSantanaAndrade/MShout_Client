object frmListVersoes: TfrmListVersoes
  Left = 460
  Top = 306
  BorderStyle = bsNone
  ClientHeight = 166
  ClientWidth = 175
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object pnlVersoes: TPanel
    Left = 0
    Top = 0
    Width = 175
    Height = 166
    Align = alClient
    BevelOuter = bvNone
    Color = clSilver
    TabOrder = 0
    object shp1: TShape
      Left = 0
      Top = 0
      Width = 175
      Height = 166
      Align = alClient
      Brush.Color = 14145495
    end
    object lbl6: TLabel
      Left = 0
      Top = 2
      Width = 175
      Height = 15
      Align = alCustom
      Alignment = taCenter
      AutoSize = False
      Caption = 'Vers'#245'es '#224' gerar'
      Color = 15187079
      ParentColor = False
      Transparent = True
      Layout = tlCenter
    end
    object shpClose: TShape
      Left = 158
      Top = 2
      Width = 13
      Height = 13
      Brush.Color = 15921906
      Visible = False
    end
    object lblClose: TLabel
      Left = 158
      Top = 1
      Width = 12
      Height = 14
      Cursor = crHandPoint
      Alignment = taCenter
      AutoSize = False
      Caption = 'x'
      Color = 16114637
      ParentColor = False
      Transparent = True
      Layout = tlCenter
      OnClick = lblCloseClick
      OnMouseEnter = lblCloseMouseEnter
      OnMouseLeave = lblCloseMouseLeave
    end
    object chkLst_ListaVersoes: TCheckListBox
      Left = 1
      Top = 17
      Width = 173
      Height = 120
      OnClickCheck = chkLst_ListaVersoesClickCheck
      ItemHeight = 13
      TabOrder = 0
    end
    object pnl1: TPanel
      Left = 1
      Top = 135
      Width = 173
      Height = 30
      BevelOuter = bvLowered
      TabOrder = 1
      object lblQtde: TLabel
        Left = 5
        Top = 9
        Width = 85
        Height = 13
        AutoSize = False
        Caption = 'Vers'#245'es: 0'
        Transparent = True
      end
      object btnConectarVersoes: TSpeedButton
        Left = 91
        Top = 4
        Width = 80
        Height = 24
        Caption = '&Conectar'
        Flat = True
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          1800000000000003000000000000000000000000000000000000FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFF9FBFADDE9E3DDE9E3F9FBFAFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFCADFD45CAE8424965C28
          9C601D94571C8851579977BED5C9FF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FBFCFC7CBB9B0F995253B7849ED3B8A5D7BD90CFAF31AA6C109B541A834D6AA4
          86FBFCFCFF00FFFF00FFFF00FFFF00FF77B99725A463C2E0D1EFF0F0F4F5F5F6
          F7F7F7F8F8F4F6F689CCAA0B9B511C8C5364A483FF00FFFF00FFFF00FFC0DBCD
          179C58CDE3D8F0F1F1A2A19FE3E4E3F9FAFAFAFBFBF9F9F9F6F7F786CAA7109D
          5412874BB2D2C2FF00FFFF00FF4CA97A80C6A3EDEFEFD9DAD942403B989794FB
          FBFBFDFDFDFAFAFAF7F7F7F1F3F32BA8681C9C5A3A9A69FF00FFEFF5F20D944F
          D5E5DECDCECD5D5C57767571504E49ECECEBFBFBFBFAFAFAF6F7F7F3F4F480C8
          A31CA25D048F48E9F1EDCCDFD51FA35FECEDEDA0A09DD5D6D5EBECEC63615D8C
          8B88F9F9F9F8F8F8F6F6F6F3F4F4ABD7C1139F570EA357C2DBCEC9DDD323A562
          EEF0F0EFF0F0F0F1F1F2F4F4D3D3D25B5954BEBEBCF5F6F6F4F5F5F2F3F3B5DB
          C8119E5610AE5DC0DBCDE7F0EB189C58E5EDE9EFF1F1EFF1F1F1F2F2F2F4F4C6
          C6C5666460D7D7D6F2F3F3F1F2F29FD4B920A66106AC57DFEBE5FF00FF40A773
          ACD9C2F0F1F1F0F1F1F0F1F1F1F2F2F1F3F3C9C9C8787773D9DADAF0F1F167BF
          921FAC642AAC6AFDFEFDFF00FFA6D0BA50B682E6EEEBF0F2F2F0F2F2F0F2F2F0
          F2F2F1F2F2DFE0DFC9CAC8BADECC35AD7019B46597CDB1FF00FFFF00FFFDFEFD
          62B38973C59BE5EEEAF1F3F3F1F3F3F1F3F3F1F3F3F1F3F3C6E3D550B8832AB3
          6D42B178FBFCFCFF00FFFF00FFFF00FFF2F6F469B68E61BE8EA8D8BFD1E7DCDA
          EAE3C5E3D48ECEAE51B88430B57140B177EDF4F0FF00FFFF00FFFF00FFFF00FF
          FF00FFFBFCFCA6D0BA5DB2875ABB895EBE8D5BBE8B44B87C37AC708FCAACF9FB
          FAFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFDFEFDD2E4DBB3
          D7C5AED5C1CEE1D7FBFCFCFF00FFFF00FFFF00FFFF00FFFF00FF}
        OnClick = btnConectarVersoesClick
      end
    end
  end
end

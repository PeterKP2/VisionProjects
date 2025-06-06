unit MainUnit;

{$MODE Delphi}

interface

uses
  TypInfo, LCLIntf, LCLType, LMessages, Math, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, CameraParamsUnit, ToolFunctionUnit;

type
  TForm1 = class(TForm)
    ENUM_BUTTON: TButton;
    OPEN_BUTTON: TButton;
    CLOSE_BUTTON: TButton;
    DEVICE_COMBO: TComboBox;
    INIT_GroupBox: TGroupBox;
    IMAGE_GRAB_GroupBox: TGroupBox;
    START_GRABBING_BUTTON: TButton;
    STOP_GRABBING_BUTTON: TButton;
    DISPLAY_Panel: TPanel;
    PARAMETER_GroupBox: TGroupBox;
    EXPOSURE_StaticText: TStaticText;
    GAIN_StaticText: TStaticText;
    EXPOSURE_Edit: TEdit;
    GAIN_Edit: TEdit;
    GET_PARAMETER_BUTTON: TButton;
    SET_PARAMETER_BUTTON: TButton;
    CONTINUS_MODE_RadioButton: TRadioButton;
    TRIGGER_MODE_RadioButton: TRadioButton;
    SOFTWARE_TRIGGER_CheckBox: TCheckBox;
    SOFTWARE_ONCE_BUTTON: TButton;
    SAVE_IMAGE_GroupBox: TGroupBox;
    SAVE_BMP_BUTTON: TButton;
    SAVE_JPG_BUTTON: TButton;
    procedure ENUM_BUTTONClick(Sender: TObject);
    procedure OPEN_BUTTONClick(Sender: TObject);
    procedure CLOSE_BUTTONClick(Sender: TObject);
    procedure START_GRABBING_BUTTONClick(Sender: TObject);
    procedure STOP_GRABBING_BUTTONClick(Sender: TObject);
    procedure GET_PARAMETER_BUTTONClick(Sender: TObject);
    procedure SET_PARAMETER_BUTTONClick(Sender: TObject);
    procedure OnClose(Sender: TObject; var Action: TCloseAction);
    procedure OnCreat(Sender: TObject);
    procedure OnBnClickedContinusModeRadio(Sender: TObject);
    procedure OnBnClickedTriggerModeRadio(Sender: TObject);
    procedure OnBnClickedSoftwareTriggerCheck(Sender: TObject);
    procedure OnBnClickedSoftwareOnceButton(Sender: TObject);
    procedure SAVE_BMP_BUTTONClick(Sender: TObject);
    procedure SAVE_JPG_BUTTONClick(Sender: TObject);

    procedure FormCreate(Sender: TObject); // добавено за коректно инициализиране на дисплея
  private
    { Private declarations }
    function UpdateVars(bUpdateDir: Bool): Integer;
    function EnableControls(bIsCameraReady: Bool): Integer;
    function GetTriggerMode(): Integer;
    function SetTriggerMode(): Integer;
    function GetExposureTime(): Integer;
    function SetExposureTime(): Integer;
    function GetGain(): Integer;
    function SetGain(): Integer;
    function GetTriggerSource(): Integer;
    function SetTriggerSource(): Integer;
    function SaveImage(): Integer;

    procedure UpdateDisplayHandle; // нова помощна процедура

  public
    { Public declarations }
  end;


var
  Form1: TForm1;


implementation

{$R *.lfm}

var
  m_nRet : Integer;
  m_stDevList: MV_CC_DEVICE_INFO_LIST;
  m_pstDevList: PMV_CC_DEVICE_INFO_LIST;
  m_hDevHandle: PPointer = Nil;
  m_bOpenDevice: Bool = False;
  m_bStartGrabbing: Bool = False;
  m_bSoftWareTriggerCheck: Bool = False;
  m_nTriggerMode: Integer = 0;
  m_nSaveImageType: MV_SAVE_IAMGE_TYPE;
  m_pBufForSaveImage: PAnsiChar = Nil;
  m_nBufSizeForSaveImage: Cardinal = 0;
  m_pBufForDriver: PAnsiChar = Nil;
  m_nBufSizeForDriver: Cardinal = 0;
  m_hwndDisplay: HWND = 0;

procedure TForm1.UpdateDisplayHandle;
begin
  // Винаги вземай актуалния handle на панела преди display!
  if Assigned(DISPLAY_Panel) and DISPLAY_Panel.HandleAllocated then
    m_hwndDisplay := DISPLAY_Panel.Handle
  else
    m_hwndDisplay := 0;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // За да е валиден handle-ът, трябва да се вземе след създаването на формата
  UpdateDisplayHandle;
end;

function TForm1.UpdateVars(bUpdateDir: Bool): Integer;
begin
    if bUpdateDir then
    begin
      if SOFTWARE_TRIGGER_CheckBox.Checked then
        m_bSoftWareTriggerCheck := true
      else
        m_bSoftWareTriggerCheck := false;
    end
    else
    begin
      if m_bSoftWareTriggerCheck then
        SOFTWARE_TRIGGER_CheckBox.Checked := true
      else
        SOFTWARE_TRIGGER_CheckBox.Checked := false;
    end;
end;

function TForm1.EnableControls( bIsCameraReady: Bool ): Integer;
begin
  if m_bOpenDevice then
  begin
    OPEN_BUTTON.Enabled := False;
    SOFTWARE_TRIGGER_CheckBox.Enabled := True;
    EXPOSURE_Edit.Enabled := True;
    GAIN_Edit.Enabled := True;
    GET_PARAMETER_BUTTON.Enabled := True;
    SET_PARAMETER_BUTTON.Enabled := True;
    CONTINUS_MODE_RadioButton.Enabled := True;
    TRIGGER_MODE_RadioButton.Enabled := True;
    if bIsCameraReady then
      CLOSE_BUTTON.Enabled := True
    else
      CLOSE_BUTTON.Enabled := False;
  end
  else
  begin
    CLOSE_BUTTON.Enabled := False;
    SOFTWARE_TRIGGER_CheckBox.Enabled := False;
    EXPOSURE_Edit.Enabled := False;
    GAIN_Edit.Enabled := False;
    GET_PARAMETER_BUTTON.Enabled := False;
    SET_PARAMETER_BUTTON.Enabled := False;
    CONTINUS_MODE_RadioButton.Enabled := False;
    TRIGGER_MODE_RadioButton.Enabled := False;
    if bIsCameraReady then
      OPEN_BUTTON.Enabled := True
    else
      OPEN_BUTTON.Enabled := False;
  end;

  if m_bStartGrabbing then
  begin
    STOP_GRABBING_BUTTON.Enabled := True;
    SAVE_BMP_BUTTON.Enabled := True;
    SAVE_JPG_BUTTON.Enabled := True;
    if bIsCameraReady then
      START_GRABBING_BUTTON.Enabled := False
    else if m_bOpenDevice then
      START_GRABBING_BUTTON.Enabled := True
    else
      START_GRABBING_BUTTON.Enabled := False;
    if m_bSoftWareTriggerCheck then
      SOFTWARE_ONCE_BUTTON.Enabled := True
    else
      SOFTWARE_ONCE_BUTTON.Enabled := False;
  end
  else
  begin
    STOP_GRABBING_BUTTON.Enabled := False;
    SAVE_BMP_BUTTON.Enabled := False;
    SAVE_JPG_BUTTON.Enabled := False;
    SOFTWARE_ONCE_BUTTON.Enabled := False;
    if m_bOpenDevice then
      START_GRABBING_BUTTON.Enabled := True
    else
      START_GRABBING_BUTTON.Enabled := False;
  end;

  Result := MV_OK;
end;

procedure TForm1.ENUM_BUTTONClick(Sender: TObject);
var
  pDeviceInfo : ^MV_CC_DEVICE_INFO;
  strInfoToShow : string;
  nLoopID : Integer;
begin
  DEVICE_COMBO.Clear();
  FillChar(m_stDevList, sizeof(MV_CC_DEVICE_INFO_LIST), 0);

  m_nRet := MV_CC_EnumDevices(MV_GIGE_DEVICE, m_stDevList);
  if m_nRet<>MV_OK then
  begin
    ShowMessage( 'Enum devices Failed.' + IntToHex(m_nRet,8) );
    exit
  end;

  for nLoopID:=0 to m_stDevList.nDeviceNum-1 do
  begin
    pDeviceInfo := @m_stDevList.pDeviceInfo[nLoopID].nMajorVer;
    if pDeviceInfo=nil then continue;
    if pDeviceInfo.nTLayerType = MV_GIGE_DEVICE then
      GigeDeviceInfoToShow(pDeviceInfo^, strInfoToShow)
    else if pDeviceInfo.nTLayerType = MV_USB_DEVICE then
      USB3DeviceInfoToShow(pDeviceInfo^, strInfoToShow)
    else
      ShowMessage( 'Unknown device enumerated.' );
    strInfoToShow := '[' + IntToStr(nLoopID) + '] ' + strInfoToShow;
    DEVICE_COMBO.Items.Add(strInfoToShow);
  end;

  if (m_stDevList.nDeviceNum=0) then
    ShowMessage( 'No device' );
  DEVICE_COMBO.ItemIndex := 0;
  EnableControls(True);
end;

procedure TForm1.OPEN_BUTTONClick(Sender: TObject);
var
  handle: Pointer;
  nIndex: Word;
  nPacketSize: Integer;
begin
  UpdateVars(TRUE);
  nIndex := DEVICE_COMBO.ItemIndex;

  if m_bOpenDevice then
  begin
    m_nRet := MV_E_CALLORDER;
    ShowMessage( 'Execution order error.' + IntToHex(m_nRet,8) );
  end;

  m_hDevHandle := @handle;
  if m_stDevList.pDeviceInfo[nIndex]=Nil then
  begin
    ShowMessage( 'Device does not exist.' );
    exit
  end;

  m_nRet := MV_CC_CreateHandle(m_hDevHandle, (m_stDevList.pDeviceInfo[nIndex])^);
  if m_nRet<>MV_OK then
  begin
    ShowMessage( 'Create handle Failed.' + IntToHex(m_nRet,8) );
    exit
  end;

  m_nRet := MV_CC_OpenDevice(m_hDevHandle^);
  if m_nRet<>MV_OK then
  begin
    ShowMessage( 'Open Fail.' + IntToHex(m_nRet,8) );
    exit
  end
  else
  begin
    m_bOpenDevice := True;
    GET_PARAMETER_BUTTONClick(Sender);
    EnableControls(TRUE);
    UpdateDisplayHandle; // при отваряне на устройството може handle-ът да се промени
  end;

  if m_stDevList.pDeviceInfo[nIndex].nTLayerType = MV_GIGE_DEVICE then
  begin
    nPacketSize := MV_CC_GetOptimalPacketSize(m_hDevHandle^);
    if nPacketSize > 0 then
    begin
      m_nRet := SetIntValue(m_hDevHandle, 'GevSCPSPacketSize', nPacketSize);
      if m_nRet<>MV_OK then
        ShowMessage( 'Warning: Set Packet Size fail!.' + IntToHex(m_nRet,8) );
    end
    else
      ShowMessage( 'Warning: Get Packet Size fail!' + IntToStr(nPacketSize) );
  end;
end;

procedure TForm1.CLOSE_BUTTONClick(Sender: TObject);
begin
  if Nil = m_hDevHandle then
    m_nRet := MV_E_PARAMETER;

  m_nRet := MV_CC_CloseDevice(m_hDevHandle^);
  m_nRet := MV_CC_DestroyHandle(m_hDevHandle^);
  m_hDevHandle := Nil;

  m_bOpenDevice := False;
  m_bStartGrabbing := False;

  if Assigned(m_pBufForDriver) then
    FreeMem(m_pBufForDriver);
  m_pBufForDriver := Nil;
  m_nBufSizeForDriver := 0;

  if Assigned(m_pBufForSaveImage) then
    FreeMem(m_pBufForSaveImage);
  m_pBufForSaveImage := Nil;
  m_nBufSizeForSaveImage := 0;

  EnableControls(TRUE);
end;

function TForm1.GetTriggerMode(): Integer;
Var
  nEnumValue: Cardinal;
begin
  Result := GetEnumValue(m_hDevHandle, 'TriggerMode', @nEnumValue);
  if Result<>MV_OK then exit;
  m_nTriggerMode := nEnumValue;
end;

function TForm1.SetTriggerMode(): Integer;
begin
  Result := SetEnumValue(m_hDevHandle, 'TriggerMode', m_nTriggerMode);
end;

function TForm1.GetExposureTime(): Integer;
Var
  fFloatValue: Single;
begin
  Result := GetFloatValue(m_hDevHandle, 'ExposureTime', @fFloatValue);
  if Result<>MV_OK then exit;
  EXPOSURE_Edit.Text := FloatToStr(fFloatValue);
end;

function TForm1.SetExposureTime(): Integer;
begin
  SetEnumValue(m_hDevHandle, 'ExposureMode', TypInfo.GetEnumValue(TypeInfo(MV_CAM_EXPOSURE_MODE),'MV_EXPOSURE_MODE_TIMED'));
  SetEnumValue(m_hDevHandle, 'ExposureAuto', TypInfo.GetEnumValue(TypeInfo(MV_CAM_EXPOSURE_AUTO_MODE),'MV_EXPOSURE_AUTO_MODE_OFF'));
  Result := SetFloatValue(m_hDevHandle, 'ExposureTime', StrToFloat(EXPOSURE_Edit.Text));
end;

function TForm1.GetGain(): Integer;
Var
  fFloatValue: Single;
begin
  Result := GetFloatValue(m_hDevHandle, 'Gain', @fFloatValue);
  if Result<>MV_OK then exit;
  GAIN_Edit.Text := FormatFloat('0.000',fFloatValue);
end;

function TForm1.SetGain(): Integer;
begin
  SetEnumValue(m_hDevHandle, 'GainAuto', 0);
  Result := SetFloatValue(m_hDevHandle, 'Gain', StrToFloat(GAIN_Edit.Text));
end;

function TForm1.GetTriggerSource(): Integer;
Var
  nEnumValue: Cardinal;
begin
  Result := GetEnumValue(m_hDevHandle, 'TriggerSource', @nEnumValue);
  if Result<>MV_OK then exit;

  if TypInfo.GetEnumValue(TypeInfo(MV_CAM_TRIGGER_SOURCE),'MV_TRIGGER_SOURCE_SOFTWARE') = nEnumValue then
    SOFTWARE_TRIGGER_CheckBox.Checked := True
  else
    SOFTWARE_TRIGGER_CheckBox.Checked := False;
end;

function TForm1.SetTriggerSource(): Integer;
begin
  if m_bSoftWareTriggerCheck then
  begin
    Result := SetEnumValue(m_hDevHandle, 'TriggerSource', TypInfo.GetEnumValue(TypeInfo(MV_CAM_TRIGGER_SOURCE),'MV_TRIGGER_SOURCE_SOFTWARE'));
    if Result<>MV_OK then exit;
    SOFTWARE_ONCE_BUTTON.Enabled := True;
  end
  else
  begin
    Result := SetEnumValue(m_hDevHandle, 'TriggerSource', TypInfo.GetEnumValue(TypeInfo(MV_CAM_TRIGGER_SOURCE),'MV_TRIGGER_SOURCE_LINE0'));
    if Result<>MV_OK then exit;
    SOFTWARE_ONCE_BUTTON.Enabled := False;
  end;
end;

procedure TForm1.OnBnClickedContinusModeRadio(Sender: TObject);
begin
    CONTINUS_MODE_RadioButton.Checked := True;
    TRIGGER_MODE_RadioButton.Checked := False;
    m_nTriggerMode := TypInfo.GetEnumValue(TypeInfo(MV_CAM_TRIGGER_MODE),'MV_TRIGGER_MODE_OFF');
    m_nRet := SetTriggerMode();
    if m_nRet<>MV_OK then
    begin
     ShowMessage( 'Set TriggerMode Fail.' + IntToHex(m_nRet,8) );
     exit
    end;
    SOFTWARE_ONCE_BUTTON.Enabled := False;
end;

procedure TForm1.OnBnClickedTriggerModeRadio(Sender: TObject);
begin
    CONTINUS_MODE_RadioButton.Checked := False;
    TRIGGER_MODE_RadioButton.Checked := True;
    m_nTriggerMode := TypInfo.GetEnumValue(TypeInfo(MV_CAM_TRIGGER_MODE),'MV_TRIGGER_MODE_ON');
    m_nRet := SetTriggerMode();
    if m_nRet<>MV_OK then
    begin
     ShowMessage( 'Set TriggerMode Fail.' + IntToHex(m_nRet,8) );
     exit
    end;
    if m_bStartGrabbing and SOFTWARE_TRIGGER_CheckBox.Checked then
      SOFTWARE_ONCE_BUTTON.Enabled := True;
end;

procedure TForm1.START_GRABBING_BUTTONClick(Sender: TObject);
begin
  if (m_bOpenDevice = False) or (m_bStartGrabbing = True) then exit;

  m_nRet := MV_CC_StartGrabbing(m_hDevHandle^);
  if m_nRet<>MV_OK then
    ShowMessage( 'Start grabbing Fail.' + IntToHex(m_nRet,8) )
  else
  begin
    UpdateDisplayHandle; // <-- Винаги актуализирай handle-а точно преди display!
    m_nRet := MV_CC_Display(m_hDevHandle^, m_hwndDisplay);
    if m_nRet<>MV_OK then
      ShowMessage( 'Display Fail.' + IntToHex(m_nRet,8) )
    else
    begin
      m_bStartGrabbing := True;
      EnableControls(TRUE);
    end;
  end;
end;

procedure TForm1.STOP_GRABBING_BUTTONClick(Sender: TObject);
begin
  if (m_bOpenDevice = False) or (m_bStartGrabbing = False) then exit;

  m_nRet := MV_CC_StopGrabbing(m_hDevHandle^);
  if m_nRet<>MV_OK then exit
  else
  begin
    m_bStartGrabbing := False;
    EnableControls(TRUE);
  end;
end;

procedure TForm1.GET_PARAMETER_BUTTONClick(Sender: TObject);
begin
  m_nRet := GetTriggerMode();
  if m_nRet<>MV_OK then
    ShowMessage( 'Get TriggerMode Fail.' + IntToHex(m_nRet,8) )
  else
  begin
    if m_nTriggerMode = TypInfo.GetEnumValue(TypeInfo(MV_CAM_TRIGGER_MODE),'MV_TRIGGER_MODE_ON') then
      OnBnClickedTriggerModeRadio(Sender)
    else if m_nTriggerMode = TypInfo.GetEnumValue(TypeInfo(MV_CAM_TRIGGER_MODE),'MV_TRIGGER_MODE_OFF') then
      OnBnClickedContinusModeRadio(Sender)
    else
      ShowMessage( 'Unsupport TriggerMode.' );
  end;

  m_nRet := GetExposureTime();
  if m_nRet<>MV_OK then
    ShowMessage( 'Get ExposureTime Fail.' + IntToHex(m_nRet,8) );

  m_nRet := GetGain();
  if m_nRet<>MV_OK then
    ShowMessage( 'Get Gain Fail.' + IntToHex(m_nRet,8) );

  m_nRet := GetTriggerSource();
  if m_nRet<>MV_OK then
    ShowMessage( 'Get Trigger Source Fail.' + IntToHex(m_nRet,8) );
end;

procedure TForm1.SET_PARAMETER_BUTTONClick(Sender: TObject);
Var
  bIsSetSucceed: Bool;
begin
  bIsSetSucceed := True;

  m_nRet := SetExposureTime();
  if m_nRet<>MV_OK then
  begin
    bIsSetSucceed := False;
    ShowMessage( 'Set Exposure Time Fail.' + IntToHex(m_nRet,8) );
  end;

  m_nRet := SetGain();
  if m_nRet<>MV_OK then
  begin
    bIsSetSucceed := False;
    ShowMessage( 'Set Gain Fail.' + IntToHex(m_nRet,8) );
  end;

  if bIsSetSucceed then
    ShowMessage( 'Set Parameter Succeed' );
end;

procedure TForm1.OnBnClickedSoftwareTriggerCheck(Sender: TObject);
begin
  if SOFTWARE_TRIGGER_CheckBox.Checked  then
    m_bSoftWareTriggerCheck := true
  else
    m_bSoftWareTriggerCheck := false;

  m_nRet := SetTriggerSource();
  if m_nRet<>MV_OK then
    ShowMessage( 'Set Trigger Source Fail.' + IntToHex(m_nRet,8) );
end;

procedure TForm1.OnBnClickedSoftwareOnceButton(Sender: TObject);
begin
  if m_bStartGrabbing then
    m_nRet := SetCommandValue(m_hDevHandle, 'TriggerSoftware');
end;

function TForm1.SaveImage(): Integer;
Var
  nRecvBufSize: Cardinal;
  stImageInfo: MV_FRAME_OUT_INFO_EX;
  stParam: MV_SAVE_IMAGE_PARAM_EX;
  chImageName: String;
  hFile: Integer;
begin
  if not m_bStartGrabbing then
  begin
    Result := MV_E_CALLORDER;
    exit
  end;

  if not ((MV_Image_Bmp=m_nSaveImageType) or (MV_Image_Jpeg=m_nSaveImageType)) then
  begin
    Result := MV_E_SUPPORT;
    exit
  end;

  nRecvBufSize := 0;
  if Nil = m_pBufForDriver then
  begin
     Result := GetIntValue(m_hDevHandle, 'PayloadSize', @nRecvBufSize);
     if Result<>MV_OK then
     begin
       ShowMessage( 'failed in get PayloadSize.' + IntToHex(Result,8) );
       exit
     end;
     m_nBufSizeForDriver := nRecvBufSize;
     GetMem(m_pBufForDriver, m_nBufSizeForDriver);
     if (Nil=m_pBufForDriver) or (m_nBufSizeForDriver=0) then
     begin
       ShowMessage( 'malloc m_pBufForDriver failed, run out of memory.' + IntToStr(m_nBufSizeForDriver) );
       exit
     end;
   end;

   FillChar(stImageInfo, sizeof(MV_FRAME_OUT_INFO_EX), 0);
   Result := MV_CC_GetOneFrameTimeout(m_hDevHandle^, m_pBufForDriver, m_nBufSizeForDriver, @stImageInfo, 1000);
   if Result=MV_OK then
   begin
     if Nil = m_pBufForSaveImage then
     begin
       m_nBufSizeForSaveImage := stImageInfo.nWidth * stImageInfo.nHeight * 3 + 2048;
       GetMem(m_pBufForSaveImage, m_nBufSizeForSaveImage);
       if (Nil=m_pBufForSaveImage) or (m_nBufSizeForSaveImage=0) then
       begin
         ShowMessage( 'malloc m_pBufForSaveImage failed, run out of memory.' + IntToStr(m_nBufSizeForSaveImage) );
         exit
       end;
     end;

     FillChar(stParam, sizeof(MV_SAVE_IMAGE_PARAM_EX), 0);
     stParam.enImageType := m_nSaveImageType;
     stParam.enPixelType := stImageInfo.enPixelType;
     stParam.nWidth := stImageInfo.nWidth;
     stParam.nHeight := stImageInfo.nHeight;
     stParam.nDataLen := stImageInfo.nFrameLen;
     stParam.pData := m_pBufForDriver;
     stParam.pImageBuffer := m_pBufForSaveImage;
     stParam.nBufferSize := m_nBufSizeForSaveImage;
     stParam.nJpgQuality := 80;

     Result := MV_CC_SaveImageEx2(m_hDevHandle^, @stParam);
     if Result<>MV_OK then exit;

     if MV_Image_Bmp=stParam.enImageType then
       chImageName := Format('Image_w%d_h%d_fn%.3d.bmp', [stImageInfo.nWidth, stImageInfo.nHeight, stImageInfo.nFrameNum])
     else if MV_Image_Jpeg=stParam.enImageType then
       chImageName := Format('Image_w%d_h%d_fn%.3d.jpg', [stImageInfo.nWidth, stImageInfo.nHeight, stImageInfo.nFrameNum])
     else
     begin
       Result := MV_E_SUPPORT;
       exit;
     end;

     hFile := FileCreate(chImageName);
     if hFile = -1 then exit;
     FileWrite(hFile, m_pBufForSaveImage^, stParam.nImageLen);
     FileClose(hFile);
   end;

  Result := MV_OK;
end;

procedure TForm1.SAVE_BMP_BUTTONClick(Sender: TObject);
begin
  m_nSaveImageType := MV_Image_Bmp;
  m_nRet := SaveImage();
  if m_nRet<>MV_OK then
  begin
    ShowMessage( 'Save bmp fail.' + IntToHex(m_nRet,8) );
    exit
  end;
  ShowMessage( 'Save bmp succeed.' );
end;

procedure TForm1.SAVE_JPG_BUTTONClick(Sender: TObject);
begin
  m_nSaveImageType := MV_Image_Jpeg;
  m_nRet := SaveImage();
  if m_nRet<>MV_OK then
  begin
    ShowMessage( 'Save jpg fail.' + IntToHex(m_nRet,8) );
    exit
  end;
  ShowMessage( 'Save jpg succeed.' );
end;

procedure TForm1.OnClose(Sender: TObject; var Action: TCloseAction);
begin
  CLOSE_BUTTONClick(Sender);
end;

procedure TForm1.OnCreat(Sender: TObject);
begin
  m_nTriggerMode := TypInfo.GetEnumValue(TypeInfo(MV_CAM_TRIGGER_MODE),'MV_TRIGGER_MODE_OFF');
  m_nSaveImageType := MV_Image_Undefined;
  UpdateDisplayHandle;
  EnableControls(FALSE);
end;

end.

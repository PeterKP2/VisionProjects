unit CameraParamsUnit;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, SysUtils, Variants, Classes, PixelTypeUnit;

const
  // Definition of correct code
  MV_OK: Integer = $00000000;

  // ch:НЁУГґнОуВл¶ЁТе:·¶О§0x80000000-0x800000FF | en: Definition of common error code : 0x80000000-0x800000FF
  MV_E_HANDLE: Integer = $80000000;  ///< ґнОу»тОЮР§µДѕд±ъ | en:Error or invalid handle
  MV_E_SUPPORT: Integer = $80000001;  ///< І»Ц§іЦµД№¦ДЬ | en:Not supported function
  MV_E_BUFOVER: Integer = $80000002;  ///< »єґжТСВъ | en:Cache is full
  MV_E_CALLORDER: Integer = $80000003;  ///< єЇКэµчУГЛіРтґнОу | en:Function calling order error
  MV_E_PARAMETER: Integer = $80000004;  ///< ґнОуµДІОКэ | en:Incorrect parameter
  MV_E_RESOURCE: Integer = $80000006;  ///< ЧКФґЙкЗлК§°Ь | en:Applying resource failed
  MV_E_NODATA: Integer = $80000007;  ///< ОЮКэѕЭ | en:No data
  MV_E_PRECONDITION: Integer = $80000008;  ///< З°ЦГМхјюУРОуЈ¬»тФЛРР»·ѕіТС·ўЙъ±д»Ї | en:Precondition error, or running environment changed
  MV_E_VERSION: Integer = $80000009;  ///< °ж±ѕІ»ЖҐЕд | en:Version mismatches
  MV_E_NOENOUGH_BUF: Integer = $8000000A;  ///< ґ«ИлµДДЪґжїХјдІ»Чг | en:Insufficient memory
  MV_E_ABNORMAL_IMAGE: Integer = $8000000B;  ///< ТміЈНјПсЈ¬їЙДЬКЗ¶Є°ьµјЦВНјПсІ»НкХы | en:Abnormal image, maybe incomplete image because of lost packet
  MV_E_LOAD_LIBRARY: Integer = $8000000C;  ///< ¶ЇМ¬µјИлDLLК§°Ь | en:Load library failed
  MV_E_UNKNOW: Integer = $800000FF;  ///< ОґЦЄµДґнОу | en:Unknown error

  // ch:GenICamПµБРґнОу:·¶О§0x80000100-0x800001FF | en:GenICam Series Error Codes: Range from 0x80000100 to 0x800001FF
  MV_E_GC_GENERIC: Integer = $80000100;  ///< НЁУГґнОу | en:General error
  MV_E_GC_ARGUMENT: Integer = $80000101;  ///< ІОКэ·З·Ё | en:Illegal parameters
  MV_E_GC_RANGE: Integer   = $80000102;  ///< Цµі¬іц·¶О§ | en:The value is out of range
  MV_E_GC_PROPERTY: Integer = $80000103;  ///< КфРФ | en:Property
  MV_E_GC_RUNTIME: Integer = $80000104;  ///< ФЛРР»·ѕіУРОКМв | en:Running environment error
  MV_E_GC_LOGICAL: Integer = $80000105;  ///< ВЯј­ґнОу | en:Logical error
  MV_E_GC_ACCESS: Integer  = $80000106;  ///< ЅЪµг·ГОКМхјюУРОу | en:Node accessing condition error
  MV_E_GC_TIMEOUT: Integer = $80000107;  ///< і¬К± | en:Timeout
  MV_E_GC_DYNAMICCAST: Integer = $80000108;  ///< ЧЄ»»ТміЈ | en:Transformation exception
  MV_E_GC_UNKNOW: Integer = $800001FF;  ///< GenICamОґЦЄґнОу | en:GenICam unknown error

  //ch:GigE_STATUS¶ФУ¦µДґнОуВл:·¶О§0x80000200-0x800002FF | en:GigE_STATUS Error Codes: Range from 0x80000200 to 0x800002FF
  MV_E_NOT_IMPLEMENTED: Integer = $80000200;  ///< ГьБоІ»±»Йи±ёЦ§іЦ | en:The command is not supported by device
  MV_E_INVALID_ADDRESS: Integer = $80000201;  ///< ·ГОКµДДї±кµШЦ·І»ґжФЪ | en:The target address being accessed does not exist
  MV_E_WRITE_PROTECT: Integer = $80000202;  ///< Дї±кµШЦ·І»їЙРґ | en:The target address is not writable
  MV_E_ACCESS_DENIED: Integer = $80000203;  ///< Йи±ёОЮ·ГОКИЁПЮ | en:No permission
  MV_E_BUSY: Integer = $80000204;  ///< Йи±ёГ¦Ј¬»тНшВз¶ПїЄ | en:Device is busy, or network disconnected
  MV_E_PACKET: Integer = $80000205;  ///< НшВз°ьКэѕЭґнОу | en:Network data packet error
  MV_E_NETER: Integer = $80000206;  ///< НшВзПа№ШґнОу | en:Network error
  // GigEПа»ъМШУРµДґнОуВл
  MV_E_IP_CONFLICT = $80000221;  ///< Йи±ёIPіеН» | en:Device IP conflict

  //ch:USB_STATUS¶ФУ¦µДґнОуВл:·¶О§0x80000300-0x800003FF | en:USB_STATUS Error Codes: Range from 0x80000300 to 0x800003FF
  MV_E_USB_READ: Integer = $80000300;      ///< ¶Бusbіцґн | en:Reading USB error
  MV_E_USB_WRITE: Integer = $80000301;      ///< Рґusbіцґн | en:Writing USB error
  MV_E_USB_DEVICE: Integer = $80000302;      ///< Йи±ёТміЈ | en:Device exception
  MV_E_USB_GENICAM: Integer = $80000303;      ///< GenICamПа№ШґнОу | en:GenICam error
  MV_E_USB_BANDWIDTH: Integer = $80000304;      ///< ґшїнІ»Чг  ёГґнОуВлРВФц | en:Insufficient bandwidth, this error code is newly added
  MV_E_USB_DRIVER: Integer = $80000305;      ///< Зэ¶ЇІ»ЖҐЕд»тХЯОґЧ°Зэ¶Ї | en:Driver mismatch or unmounted drive
  MV_E_USB_UNKNOW: Integer = $800003FF;      ///< USBОґЦЄµДґнОу | en:USB unknown error

  //ch:Йэј¶К±¶ФУ¦µДґнОуВл:·¶О§0x80000400-0x800004FF | en:Upgrade Error Codes: Range from 0x80000400 to 0x800004FF
  MV_E_UPG_FILE_MISMATCH: Integer = $80000400; ///< Йэј¶№МјюІ»ЖҐЕд | en:Firmware mismatches
  MV_E_UPG_LANGUSGE_MISMATCH: Integer = $80000401; ///< Йэј¶№МјюУпСФІ»ЖҐЕд | en:Firmware language mismatches
  MV_E_UPG_CONFLICT: Integer = $80000402; ///< Йэј¶іеН»ЈЁЙи±ёТСѕ­ФЪЙэј¶БЛФЩґОЗлЗуЙэј¶јґ·µ»ШґЛґнОуЈ© | en:Upgrading conflicted (repeated upgrading requests during device upgrade)
  MV_E_UPG_INNER_ERR: Integer = $80000403; ///< Йэј¶К±Па»ъДЪІїіцПЦґнОу | en:Camera internal error during upgrade
  MV_E_UPG_UNKNOW: Integer = $800004FF; ///< Йэј¶К±ОґЦЄґнОу | en:Unknown error during upgrade


  // ch: Йи±ёАаРН | en: device type
  MV_UNKNOW_DEVICE: Integer = $00000000;       // ch:ОґЦЄЙи±ёАаРНЈ¬±ЈБфТвТе | en:Unknown Device Type, Reserved
  MV_GIGE_DEVICE: Integer = $00000001;         // ch:GigEЙи±ё | en:GigE Device
  MV_1394_DEVICE: Integer = $00000002;         // ch:1394-a/b Йи±ё | en:1394-a/b Device
  MV_USB_DEVICE: Integer = $00000004;          // ch:USB3.0 Йи±ё | en:USB3.0 Device
  MV_CAMERALINK_DEVICE: Integer = $00000008;   // ch:CameraLinkЙи±ё | en:CameraLink Device


// device information
type
  MV_GIGE_DEVICE_INFO = record
    nIpCfgOption: Cardinal;
    nIpCfgCurrent: Cardinal;
    nCurrentIp: Cardinal;
    nCurrentSubNetMask: Cardinal;
    nDefultGateWay: Cardinal;
    chManufacturerName: array[0..31] of Byte;
    chModelName: array[0..31] of Byte;
    chDeviceVersion: array[0..31] of Byte;
    chManufacturerSpecificInfo: array[0..47] of Byte;
    chSerialNumber: array[0..15] of Byte;
    chUserDefinedName: array[0..15] of Byte;
    nNetExport: Cardinal;
    nReserved: array[0..3] of Cardinal;
end;

type
  MV_USB3_DEVICE_INFO = record
    CrtlInEndPoint: Byte;
    CrtlOutEndPoint: Byte;
    StreamEndPoint: Byte;
    EventEndPoint: Byte;
    idVendor: Byte;
    idProduct: Byte;
    nDeviceNumber: Cardinal;
    chDeviceGUID: array[0..63] of Byte;
    chVendorName: array[0..63] of Byte;
    chModelName: array[0..63] of Byte;
    chFamilyName: array[0..63] of Byte;
    chDeviceVersion: array[0..63] of Byte;
    chManufacturerName: array[0..63] of Byte;
    chSerialNumber: array[0..63] of Byte;
    chUserDefinedName: array[0..63] of Byte;
    nbcdUSB: Cardinal;
    nReserved: array[0..2] of Cardinal;
end;

type
  MV_CC_SpecialInfo = record
    case integer of
    0: (stGigEInfo: MV_GIGE_DEVICE_INFO);
    1: (stUsb3VInfo: MV_USB3_DEVICE_INFO);
 end;

 type
  MV_CC_DEVICE_INFO = record
     nMajorVer: Word;
     nMinorVer: Word;
     nMacAddrHigh: Cardinal;
     nMacAddrLow: Cardinal;
     nTLayerType: Cardinal;
     nReserved: array[0..3] of Cardinal;
     SpecialInfo: MV_CC_SpecialInfo;
end;

type
  PMV_CC_DEVICE_INFO_LIST = ^MV_CC_DEVICE_INFO_LIST;
  MV_CC_DEVICE_INFO_LIST = record
    nDeviceNum: Cardinal;
    pDeviceInfo: array[0..255] of ^MV_CC_DEVICE_INFO;
end;


// data type of feature node
type
  PMVCC_INTVALUE = ^MVCC_INTVALUE;
  MVCC_INTVALUE = record
     nCurValue: Cardinal;
     nMax: Cardinal;
     nMin: Cardinal;
     nInc: Cardinal;
     nReserved: array[0..3] of Cardinal;
end;

type
  PMVCC_FLOATVALUE = ^MVCC_FLOATVALUE;
  MVCC_FLOATVALUE = record
     fCurValue: Single;
     fMax: Single;
     fMin: Single;
     nReserved: array[0..3] of Cardinal;
end;


type
  PMVCC_ENUMVALUE = ^MVCC_ENUMVALUE;
  MVCC_ENUMVALUE = record
     nCurValue: Cardinal;
     nSupportedNum: Cardinal;
     nSupportValue: array[0..63] of Cardinal;
     nReserved: array[0..3] of Cardinal;
end;

type
  PMVCC_STRINGVALUE = ^MVCC_STRINGVALUE;
  MVCC_STRINGVALUE = record
     chCurValue: array[0..255] of AnsiChar;
     nReserved: array[0..3] of Cardinal;
end;

// ch:КдіцЦЎµДРЕПў | en:Output Frame Information
type
  PMV_FRAME_OUT_INFO_EX = ^MV_FRAME_OUT_INFO_EX;
  MV_FRAME_OUT_INFO_EX = record
     nWidth: Word;  // ch:НјПсїн | en:Image Width
     nHeight: Word; // ch:НјПсёЯ | en:Image Height
     enPixelType: MvGvspPixelType;
     nFrameNum: Cardinal;  // ch:ЦЎєЕ | en:Frame Number
     nDevTimeStampHigh: Cardinal;   // ch:К±јдґБёЯ32О» | en:Timestamp high 32 bits
     nDevTimeStampLow: Cardinal;    // ch:К±јдґБµН32О» | en:Timestamp low 32 bits
     nReserved0: Cardinal;     // ch:±ЈБфЈ¬8ЧЦЅЪ¶ФЖл | en:Reserved, 8-byte aligned
     nHostTimeStamp: Int64;    // ch:Цч»ъЙъіЙµДК±јдґБ | en:Host-generated timestamp

     nFrameLen: Cardinal;

    // ch:ТФПВОЄchunkРВФцЛ®УЎРЕПў | en:The followings are chunk add frame-specific information
    // ch:Йи±ёЛ®УЎК±±к | en:Device frame-specific time scale
     nSecondCount: Cardinal;
     nCycleCount: Cardinal;
     nCycleOffset: Cardinal;

     fGain: Single;
     fExposureTime: Single;
     nAverageBrightness: Cardinal;   // ch:ЖЅѕщББ¶И | en:Average brightness

    // ch:°ЧЖЅєвПа№Ш | en:White balance
     nRed: Cardinal;
     nGreen: Cardinal;
     nBlue: Cardinal;

     nFrameCounter: Cardinal;
     nTriggerIndex: Cardinal;   // ch:ґҐ·ўјЖКэ | en:Trigger Counting

     // ch:Line КдИл/Кдіц | en:Line Input/Output
     nInput: Cardinal;
     nOutput: Cardinal;

     // ch:ROIЗшУт | en:ROI Region
     nOffsetX: Word;
     nOffsetY: Word;
     nChunkWidth: Word;
     nChunkHeight: Word;

     nLostPacket: Cardinal;  // ch:±ѕЦЎ¶Є°ьКэ | en:Lost Pacekt Number In This Frame

     nReserved: array[0..38] of Cardinal;
end;

// ch:±ЈґжНјЖ¬ёсКЅ | en:Save image type
type  MV_SAVE_IAMGE_TYPE = (
       MV_Image_Undefined = 0,
       MV_Image_Bmp = 1,
       MV_Image_Jpeg = 2,
       MV_Image_Png = 3,            // ch:І»Ц§іЦ | en:Not support
       MV_Image_Tif = 4);            // ch:І»Ц§іЦ | en:Not support

// ch:НјЖ¬±ЈґжІОКэ | en:Save Image Parameters
type
  PMV_SAVE_IMAGE_PARAM_EX = ^MV_SAVE_IMAGE_PARAM_EX;
  MV_SAVE_IMAGE_PARAM_EX = record
     pData: PAnsiChar;  // [IN] ch:КдИлКэѕЭ»єґж | en:Input Data Buffer
     nDataLen: Cardinal; // [IN] ch:КдИлКэѕЭґуРЎ | en:Input Data Size
     enPixelType: MvGvspPixelType; // [IN] ch:КдИлКэѕЭµДПсЛШёсКЅ | en:Input Data Pixel Format
     nWidth: Word;  // [IN] ch:НјПсїн | en:Image Width
     nHeight: Word; // [IN] ch:НјПсёЯ | en:Image Height

     pImageBuffer: PAnsiChar;  // [OUT] ch:КдіцНјЖ¬»єґж | en:Output Image Buffer
     nImageLen: Cardinal; // [OUT] ch:КдіцНјЖ¬ґуРЎ | en:Output Image Size
     nBufferSize: Cardinal; // [IN] ch:Мб№©µДКдіц»єіеЗшґуРЎ | en:Output buffer size provided
     enImageType: MV_SAVE_IAMGE_TYPE;  // [IN] ch:КдіцНјЖ¬ёсКЅ | en:Output Image Format
     nJpgQuality: Cardinal; // [IN] ch:±аВлЦКБї, (50-99] | en:Encoding quality, (50-99]

     // [IN]ch:BayerёсКЅЧЄОЄRGB24µДІеЦµ·Ѕ·Ё  0-ЧоЅьБЪ 1-Л«ПЯРФ 2-Hamilton ЈЁИз№ыґ«ИлЖдЛьЦµФтД¬ИПОЄЧоЅьБЪЈ©
	   // [IN]en:Interpolation method of convert Bayer to RGB24  0-nearest neighbour 1-bilinearity 2-Hamilton
     nMethodValue: Cardinal;

     nReserved: array[0..2] of Cardinal;
end;

// ch:Йи±ёЧґМ¬ | en:device state

// ch:ІЙјЇДЈКЅ | en:Acquisition mode
type  MV_CAM_ACQUISITION_MODE = (
       MV_ACQ_MODE_SINGLE = 0,            // ch:µҐЦЎДЈКЅ | en:Single Mode
       MV_ACQ_MODE_MUTLI = 1,            // ch:¶аЦЎДЈКЅ | en:Multi Mode
       MV_ACQ_MODE_CONTINUOUS = 1);            // ch:іЦРшІЙјЇДЈКЅ | en:Continuous Mode

// ch:ФцТжДЈКЅ | en:Gain Mode
type  MV_CAM_GAIN_MODE = (
       MV_GAIN_MODE_OFF = 0,            // ch:№Ш±Х | en:Single Mode
       MV_GAIN_MODE_ONCE = 1,            // ch:Т»ґО | en:Multi Mode
       MV_GAIN_MODE_CONTINUOUS = 1);            // ch:Б¬Рш | en:Continuous Mode

// ch:ЖШ№вДЈКЅ | en:Exposure Mode
type  MV_CAM_EXPOSURE_MODE = (
       MV_EXPOSURE_MODE_TIMED = 0,
       MV_EXPOSURE_MODE_TRIGGER_WIDTH = 1);

// ch:ЧФ¶ЇЖШ№вДЈКЅ | en:Auto Exposure Mode
type  MV_CAM_EXPOSURE_AUTO_MODE = (
       MV_EXPOSURE_AUTO_MODE_OFF = 0,            // ch:№Ш±Х | en:Off
       MV_EXPOSURE_AUTO_MODE_ONCE = 1,            // ch:Т»ґО | en:Once
       MV_EXPOSURE_AUTO_MODE_CONTINUOUS = 2);            // ch:Б¬Рш | en:Continuous

type  MV_CAM_TRIGGER_MODE = (
       MV_TRIGGER_MODE_OFF = 0,            // ch:№Ш±Х | en:Off
       MV_TRIGGER_MODE_ON = 1);            // ch:ґтїЄ | en:ON

type  MV_CAM_GAMMA_SELECTOR = (
       MV_GAMMA_SELECTOR_USER = 0,
       MV_GAMMA_SELECTOR_SRGB = 1);

type  MV_CAM_BALANCEWHITE_AUTO = (
       MV_BALANCEWHITE_AUTO_OFF = 0,
       MV_BALANCEWHITE_AUTO_CONTINUOUS = 1,
       MV_BALANCEWHITE_AUTO_ONCE = 2);

type  MV_CAM_TRIGGER_SOURCE = (
       MV_TRIGGER_SOURCE_LINE0 = 0,
       MV_TRIGGER_SOURCE_LINE1 = 1,
       MV_TRIGGER_SOURCE_LINE2 = 2,
       MV_TRIGGER_SOURCE_LINE3 = 3,
       MV_TRIGGER_SOURCE_COUNTER0 = 4,
       MV_TRIGGER_SOURCE_RESERVED = 5,
       MV_TRIGGER_SOURCE_RESERVED2 = 6,
       MV_TRIGGER_SOURCE_SOFTWARE = 7,
       MV_TRIGGER_SOURCE_FrequencyConverter = 8);

type  MV_GIGE_TRANSMISSION_TYPE = (
       MV_GIGE_TRANSTYPE_UNICAST = $0,      // ch:±нКѕµҐІҐ(Д¬ИП) | en:Unicast mode
       MV_GIGE_TRANSTYPE_MULTICAST = $1,    // ch:±нКѕЧйІҐ | en:Multicast mode
       MV_GIGE_TRANSTYPE_LIMITEDBROADCAST = $2,  // ch:±нКѕѕЦУтНшДЪ№гІҐЈ¬ФЭІ»Ц§іЦ | en:Limited broadcast mode,not support
       MV_GIGE_TRANSTYPE_SUBNETBROADCAST = $3,   // ch:±нКѕЧУНшДЪ№гІҐЈ¬ФЭІ»Ц§іЦ | en:Subnet broadcast mode,not support
       MV_GIGE_TRANSTYPE_CAMERADEFINED = $4,     // ch:±нКѕґУПа»ъ»сИЎЈ¬ФЭІ»Ц§іЦ | en:Transtype from camera,not support
       MV_GIGE_TRANSTYPE_UNICAST_DEFINED_PORT = $5,  // ch:±нКѕУГ»§ЧФ¶ЁТеУ¦УГ¶ЛЅУКХНјПсКэѕЭPortєЕ | en:User Defined Receive Data Port
       MV_GIGE_TRANSTYPE_UNICAST_WITHOUT_RECV = $00010000,  // ch:±нКѕЙиЦГБЛµҐІҐЈ¬µ«±ѕКµАэІ»ЅУКХНјПсКэѕЭ | en:Unicast without receive data
       MV_GIGE_TRANSTYPE_MULTICAST_WITHOUT_RECV = $00010001);  // ch:±нКѕЧйІҐДЈКЅЈ¬µ«±ѕКµАэІ»ЅУКХНјПсКэѕЭ | en:Multicast without receive data

implementation

end.

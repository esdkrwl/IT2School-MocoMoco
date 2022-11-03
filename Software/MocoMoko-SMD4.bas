$prog &HFF , &HCF , &HD9 , &H00                             ' generated. Take care that the chip supports all fuse bytes.
$regfile = "m32def.dat"
$crystal = 12000000
Config Error = Ignore , 380 = Ignore                        'For 2.0.7.6 version!!!

$hwstack = 30
$swstack = 30
$framesize = 40                                             '24 bytes reserved

'Include the software USB library
$lib "swusb.lbx"
$external _swusb
$external Crcusb
$include "funktionen.inc"
Declare Sub Keyup
Declare Sub Typekey2

'Pinzuweisungen
Dim D0 As Word
Dim D1 As Word
Dim D2 As Word
Dim D3 As Word
Dim D4 As Word
Dim D5 As Word
Dim D6 As Word
Dim D7 As Word
Dim D8 As Word
Dim D9 As Word
Dim D10 As Word
Dim Gw0 As Word
Dim Gw1 As Word
Dim Gw2 As Word
Dim Gw3 As Word
Dim Gw4 As Word
Dim Gw5 As Word
Dim Gw6 As Word
Dim Gw7 As Word
Dim Gw8 As Word
Dim Gw9 As Word
Dim Gw10 As Word
Dim Taste(6) As Word

Schalter Alias Pind.1
Config Schalter = Input

Led Alias Portd.3
Config Led = Output

A0_port Alias Portb.3
A0_ddr Alias Ddrb.3
B0_port Alias Portb.4
B0_ddr Alias Ddrb.4
B0_pin Alias Pinb.4                                         'V an Cs messen

A1_port Alias Portb.1
A1_ddr Alias Ddrb.1
B1_port Alias Portb.2
B1_ddr Alias Ddrb.2
B1_pin Alias Pinb.2

A2_port Alias Porta.0
A2_ddr Alias Ddra.0
B2_port Alias Portb.0
B2_ddr Alias Ddrb.0
B2_pin Alias Pinb.0

A3_port Alias Porta.3
A3_ddr Alias Ddra.3
B3_port Alias Porta.2
B3_ddr Alias Ddra.2
B3_pin Alias Pina.2

A4_port Alias Porta.5
A4_ddr Alias Ddra.5
B4_port Alias Porta.4
B4_ddr Alias Ddra.4
B4_pin Alias Pina.4

A5_port Alias Porta.7
A5_ddr Alias Ddra.7
B5_port Alias Porta.6
B5_ddr Alias Ddra.6
B5_pin Alias Pina.6

A6_port Alias Portc.6
A6_ddr Alias Ddrc.6
B6_port Alias Portc.7
B6_ddr Alias Ddrc.7
B6_pin Alias Pinc.7

A7_port Alias Portc.4
A7_ddr Alias Ddrc.4
B7_port Alias Portc.5
B7_ddr Alias Ddrc.5
B7_pin Alias Pinc.5

A8_port Alias Portc.2
A8_ddr Alias Ddrc.2
B8_port Alias Portc.3
B8_ddr Alias Ddrc.3
B8_pin Alias Pinc.3

A9_port Alias Portc.0
A9_ddr Alias Ddrc.0
B9_port Alias Portc.1
B9_ddr Alias Ddrc.1
B9_pin Alias Pinc.1

A10_port Alias Portd.6
A10_ddr Alias Ddrd.6
B10_port Alias Portd.7
B10_ddr Alias Ddrd.7
B10_pin Alias Pind.7

A0_port = 0
B0_port = 0
A0_ddr = 1
B0_ddr = 1

A1_port = 0
B1_port = 0
A1_ddr = 1
B1_ddr = 1

A2_port = 0
B2_port = 0
A2_ddr = 1
B2_ddr = 1

A3_port = 0
B3_port = 0
A3_ddr = 1
B3_ddr = 1

A4_port = 0
B4_port = 0
A4_ddr = 1
B4_ddr = 1

A5_port = 0
B5_port = 0
A5_ddr = 1
B5_ddr = 1

A6_port = 0
B6_port = 0
A6_ddr = 1
B6_ddr = 1

A7_port = 0
B7_port = 0
A7_ddr = 1
B7_ddr = 1

A8_port = 0
B8_port = 0
A8_ddr = 1
B8_ddr = 1

A9_port = 0
B9_port = 0
A9_ddr = 1
B9_ddr = 1

A10_port = 0
B10_port = 0
A10_ddr = 1
B10_ddr = 1

Config Adc = Single , Prescaler = Auto , Reference = Avcc

Dim T0 As Byte , T1 As Byte , T2 As Byte , T3 As Byte , T4 As Byte , T5 As Byte
Dim T6 As Byte , T7 As Byte , T8 As Byte , T9 As Byte , T10 As Byte



Dim Resetcounter As Word
Dim Idlemode As Byte

Dim Keybd_leds As Byte                                      'keyboard status LEDs (numlock, capslock, etc.)
Dim message as string * 10

Dim Akey As Byte

Dim Pause As Word

Dim Schwelle As Word
Dim X As Integer
Dim I As Byte

Dim Limit As Word

Dim Wdh As Word

Limit = 3100
Schwelle = 50
Pause = 1

Message = "Hello"

'Initialisierung
For X = 1 To 5
    Toggle Led
    Waitms 150
Next X
Led = 0

Gosub Sense
Gosub Kalibrieren

Do
   Resetcounter = 0
   'Check for reset here
   While _usb_pin._usb_dminus = 0
      Incr Resetcounter
      If Resetcounter = 1000 Then
         Call Usb_reset()
      End If
   Wend

   'Check for received data
   If _usb_status._usb_rxc = 1 Then
      If _usb_status._usb_setup = 1 Then
         'Process a setup packet/Control message
         Call Usb_processsetup(_usb_tx_status)
      'else
      End If
      'Reset the RXC bit and set the RTR bit (ready to receive a new packet)
      _usb_status._usb_rxc = 0
      _usb_status._usb_rtr = 1
   End If


  'Aktiv
  If Schalter = 0 Then
    Led = 1
    Schwelle = Getadc(1)
    'Schwelle = Schwelle / 3
    'Schwelle = Schwelle * 2
    Schwelle = Schwelle + 8
    Gosub Sense2

    Gosub Taste_senden
    'Gosub Messwerte_anzeigen
  End If

  'Nicht aktiv
  If Schalter = 1 Then
     Led = 0
     Gosub Sense
     Gosub Kalibrieren
  End If
Loop


'*******************************************************************************
'********************** Subroutines from here on *******************************


Sub TypeMessage(message as string)
   Local Count As Byte
   Local key as byte
   Local char as string * 1
   for count = 1 to len(message)
      char = mid(message, count, 1)
      Key = Asc(char)
      Key = Ascii2usage(key)
      Call Typekey(key)
   next
End Sub

Sub Typekey(key As Byte)
   Local Usage As Word
   'Usage = Ascii2usage(key)
   Usage = Key
   do:loop until _usb_tx_status2._usb_txc = 1
   ' Key down
   _usb_tx_buffer2(2) = High(key)                           'Modifier keys (shift, ctl, alt, etc)
   _usb_tx_buffer2(3) = 0                                   'Reserved.  Always 0
   _usb_tx_buffer2(4) = Low(key)                            'key1
   _usb_tx_buffer2(5) = 0                                   'key2
   _usb_tx_buffer2(6) = 0                             'key3
   _usb_tx_buffer2(7) = 0                             'key4
   _usb_tx_buffer2(8) = 0                             'key5
   _usb_tx_buffer2(9) = 0                             'key6
   Call Usb_send(_usb_tx_status2 , 8)

   ' Key up
   do:loop until _usb_tx_status2._usb_txc = 1
   _usb_tx_buffer2(2) = 0                             'Modifier keys (shift, ctl, alt, etc)
   _usb_tx_buffer2(3) = 0                             'Reserved.  Always 0
   _usb_tx_buffer2(4) = 0                             'key1
   _usb_tx_buffer2(5) = 0                             'key2
   _usb_tx_buffer2(6) = 0                             'key3
   _usb_tx_buffer2(7) = 0                             'key4
   _usb_tx_buffer2(8) = 0                             'key5
   _usb_tx_buffer2(9) = 0                             'key6
   Call Usb_send(_usb_tx_status2 , 8)

End Sub

Sub Typekey2
   Local Usage1 As Word
   Local Usage2 As Word
   Local Usage3 As Word
   Local Usage4 As Word
   Local Usage5 As Word
   Local Usage6 As Word
   Usage1 = Taste(1)
   Usage2 = Taste(2)
   Usage3 = Taste(3)
   Usage4 = Taste(4)
   Usage5 = Taste(5)
   Usage6 = Taste(6)
   Do : Loop Until _usb_tx_status2._usb_txc = 1
   ' Key down
   _usb_tx_buffer2(2) = High(usage1)                        'Modifier keys (shift, ctl, alt, etc)
   _usb_tx_buffer2(3) = 0                                   'Reserved.  Always 0
   _usb_tx_buffer2(4) = Low(usage1)                         'key1
   _usb_tx_buffer2(5) = Low(usage2)                         'key2
   _usb_tx_buffer2(6) = Low(usage3)                         'key3
   _usb_tx_buffer2(7) = Low(usage4)                         'key4
   _usb_tx_buffer2(8) = Low(usage5)                         'key5
   _usb_tx_buffer2(9) = Low(usage6)                         'key6
   Call Usb_send(_usb_tx_status2 , 8)
End Sub

Sub Keyup
    ' Key up
   do:loop until _usb_tx_status2._usb_txc = 1
   _usb_tx_buffer2(2) = 0                             'Modifier keys (shift, ctl, alt, etc)
   _usb_tx_buffer2(3) = 0                             'Reserved.  Always 0
   _usb_tx_buffer2(4) = 0                             'key1
   _usb_tx_buffer2(5) = 0                             'key2
   _usb_tx_buffer2(6) = 0                             'key3
   _usb_tx_buffer2(7) = 0                             'key4
   _usb_tx_buffer2(8) = 0                             'key5
   _usb_tx_buffer2(9) = 0                             'key6
   Call Usb_send(_usb_tx_status2 , 8)
End Sub

End

'*******************************************************************************
'******************** Descriptors stored in FLASH ******************************
'                  Do not change the order of the descriptors!
'

$data


'Device Descriptor
_usb_devicedescriptor:
Data 18 , 18 , _usb_desc_device , _usb_specl , _usb_spech , _usb_devclass
Data _usb_devsubclass , _usb_devprot , 8 , _usb_vidl , _usb_vidh , _usb_pidl
Data _usb_pidh , _usb_devrell , _usb_devrelh , _usb_imanufacturer
Data _usb_iproduct , _usb_iserial , _usb_numconfigs


'Retrieving the configuration descriptor also gets all the interface and
'endpoint descriptors for that configuration.  It is not possible to retrieve
'only an interface or only an endpoint descriptor.  Consequently, this is a
'large transaction of variable size.
_usb_configdescriptor:
Data _usb_descr_total , 9 , _usb_desc_config , _usb_descr_totall
Data _usb_descr_totalh , _usb_numifaces , _usb_confignum , _usb_iconfig
Data _usb_powered , _usb_maxpower

'_usb_IFaceDescriptor
Data 9 , _usb_desc_iface , _usb_ifaceaddr , _usb_alternate
Data _usb_ifaceendpoints , _usb_ifclass , _usb_ifsubclass , _usb_ifprotocol
Data _usb_iiface

#if _usb_hids > 0
'_usb_HIDDescriptor
Data _usb_hid_descr_len , _usb_desc_hid , _usb_hid_releasel , _usb_hid_releaseh
Data _usb_hid_country , _usb_hid_numdescriptors

'Next follows a list of bType and wLength bytes/words for each report and
'physical descriptor.  There must be at least 1 report descriptor.  In practice,
'There are usually 0 physical descriptors and only 1 report descriptor.
Data _usb_desc_report
Data 63 , 0
'End of report/physical descriptor list
#endif

#if _usb_endpoints > 1
'_usb_EndpointDescriptor
Data 7 , _usb_desc_endpoint , _usb_endp2attr , _usb_endp2type , 8 , 0
Data _usb_endp2interval
#endif

#if _usb_endpoints > 2
'_usb_EndpointDescriptor
Data 7 , _usb_desc_endpoint , _usb_endp3attr , _usb_endp3type , 8 , 0
Data _usb_endp3interval
#endif

#if _usb_hids > 0
_usb_hid_reportdescriptor:
Data 63
Data &H05 , &H01                                            ' USAGE_PAGE (Generic Desktop)
Data &H09 , &H06                                            ' USAGE (Keyboard)
Data &HA1 , &H01                                            ' COLLECTION (Application)
Data &H05 , &H07                                            '   USAGE_PAGE (Keyboard)
Data &H19 , &HE0                                            '   USAGE_MINIMUM (Keyboard LeftControl)
Data &H29 , &HE7                                            '   USAGE_MAXIMUM (Keyboard Right GUI)
Data &H15 , &H00                                            '   LOGICAL_MINIMUM (0)
Data &H25 , &H01                                            '   LOGICAL_MAXIMUM (1)
Data &H75 , &H01                                            '   REPORT_SIZE (1)
Data &H95 , &H08                                            '   REPORT_COUNT (8)
Data &H81 , &H02                                            '   INPUT (Data,Var,Abs)
Data &H95 , &H01                                            '   REPORT_COUNT (1)
Data &H75 , &H08                                            '   REPORT_SIZE (8)
Data &H81 , &H03                                            '   INPUT (Cnst,Var,Abs)
Data &H95 , &H05                                            '   REPORT_COUNT (5)
Data &H75 , &H01                                            '   REPORT_SIZE (1)
Data &H05 , &H08                                            '   USAGE_PAGE (LEDs)
Data &H19 , &H01                                            '   USAGE_MINIMUM (Num Lock)
Data &H29 , &H05                                            '   USAGE_MAXIMUM (Kana)
Data &H91 , &H02                                            '   OUTPUT (Data,Var,Abs)
Data &H95 , &H01                                            '   REPORT_COUNT (1)
Data &H75 , &H03                                            '   REPORT_SIZE (3)
Data &H91 , &H03                                            '   OUTPUT (Cnst,Var,Abs)
Data &H95 , &H06                                            '   REPORT_COUNT (6)
Data &H75 , &H08                                            '   REPORT_SIZE (8)
Data &H15 , &H00                                            '   LOGICAL_MINIMUM (0)
Data &H25 , &H65                                            '   LOGICAL_MAXIMUM (101)
Data &H05 , &H07                                            '   USAGE_PAGE (Keyboard)
Data &H19 , &H00                                            '   USAGE_MINIMUM (Reserved (no event indicated))
Data &H29 , &H65                                            '   USAGE_MAXIMUM (Keyboard Application)
Data &H81 , &H00                                            '   INPUT (Data,Ary,Abs)
Data &HC0                                                   ' END_COLLECTION
#endif

'*****************************String descriptors********************************
'Yes, they MUST be written like "t","e","s","t".  Doing so pads them with
'0's.  If you write it like "test," I promise you it won't work.

'Default language descriptor (index 0)
_usb_langdescriptor:
Data 4 , 4 , _usb_desc_string , 09 , 04                     '&h0409 = English

'Manufacturer Descriptor (unicode)
_usb_mandescriptor:
Data 14 , 14 , _usb_desc_string
Data "o" , "l" , "l" , "o" , "p" , "a"

'Product Descriptor (unicode)
_usb_proddescriptor:
Data 46 , 46 , _usb_desc_string
Data "M" , "o" , "c" , "o" , "M" , "o" , "c" , "o"
' , " " , " " , " " , " " , " " , " " , " " , " " , " " , " "
Data "v" , "1" , "." , "0"
'Data "o" , "l" , "l" , "o" , "p" , "a" , "'" , "s" , " " , "k" , "e" , "y" , "b" , "o" , "a" , "r" , "d" , " "
'Data "v" , "1" , "." , "0"



'*******************************************************************************



'*******************************************************************************
'******************************** Subroutines **********************************
'*******************************************************************************

Sub Usb_processsetup(txstate As Byte)
Senddescriptor = 0
   'Control transfers reset the sync bits like so
   Txstate = _usb_setup_sync

   'These are the standard device, interface, and endpoint requests that the
   'USB spec requires that we support.
   Select Case _usb_rx_buffer(2)
      'Standard Device Requests
      Case &B10000000:
         Select Case _usb_rx_buffer(3)
'            CASE _usb_REQ_GET_STATUS:
            Case _usb_req_get_descriptor:
               Select Case _usb_rx_buffer(5)
                  Case _usb_desc_device:
                     'Send the device descriptor
                     #if _usb_use_eeprom = 1
                        Readeeprom _usb_eepromaddrl , _usb_devicedescriptor
                     #else
                        Restore _usb_devicedescriptor
                     #endif
                     Senddescriptor = 1
                  Case _usb_desc_config:
                     'Send the configuration descriptor
                     #if _usb_use_eeprom = 1
                        Readeeprom _usb_eepromaddrl , _usb_configdescriptor
                     #else
                        Restore _usb_configdescriptor
                     #endif
                     Senddescriptor = 1
                  Case _usb_desc_string:
                     Select Case _usb_rx_buffer(4)
                        Case 0:
                           'Send the language descriptor
                           #if _usb_use_eeprom = 1
                              Readeeprom _usb_eepromaddrl , _usb_langdescriptor
                           #else
                              Restore _usb_langdescriptor
                           #endif
                           Senddescriptor = 1
                        Case 1:
                           'Send the manufacturer descriptor
                           #if _usb_use_eeprom = 1
                              Readeeprom _usb_eepromaddrl , _usb_mandescriptor
                           #else
                              Restore _usb_mandescriptor
                           #endif
                           Senddescriptor = 1
                        Case 2:
                           'Send the product descriptor
                           #if _usb_use_eeprom = 1
                              Readeeprom _usb_eepromaddrl , _usb_proddescriptor
                           #else
                              Restore _usb_proddescriptor
                           #endif
                           Senddescriptor = 1
                     End Select
               End Select
'            CASE _usb_REQ_GET_CONFIG:
         End Select
      Case &B00000000:
         Select Case _usb_rx_buffer(3)
'            CASE _usb_REQ_CLEAR_FEATURE:
'            CASE _usb_REQ_SET_FEATURE:
            Case _usb_req_set_address:
               'USB status reporting for control writes
               Call Usb_send(txstate , 0)
               While Txstate._usb_txc = 0 : Wend
               'We are now addressed.
               _usb_deviceid = _usb_rx_buffer(4)
'            CASE _usb_REQ_SET_DESCRIPTOR:
            Case _usb_req_set_config:
               'Have to do status reporting
               Call Usb_send(txstate , 0)
         End Select
      'Standard Interface Requests
      Case &B10000001:
         Select Case _usb_rx_buffer(3)
'            CASE _usb_REQ_GET_STATUS:
'            CASE _usb_REQ_GET_IFACE:
            Case _usb_req_get_descriptor
            '_usb_rx_buffer(4) is the descriptor index and (5) is the type
               Select Case _usb_rx_buffer(5)
                  Case _usb_desc_report:
                     #if _usb_use_eeprom = 1
                        Readeeprom _usb_eepromaddrl , _usb_hid_reportdescriptor
                     #else
                        Restore _usb_hid_reportdescriptor
                     #endif
                     Senddescriptor = 1
'                  CASE _usb_DESC_PHYSICAL

'                  CASE _USB_DESC_HID

               End Select
         End Select
      'CASE &B00000001:
         'SELECT CASE _usb_rx_buffer(3)
         '   CASE _usb_REQ_CLEAR_FEATURE:

         '   CASE _usb_REQ_SET_FEATURE:

         '   CASE _usb_REQ_SET_IFACE:

         'END SELECT
      'Standard Endpoint Requests
      'CASE &B10000010:
         'SELECT CASE _usb_rx_buffer(3)
         '   CASE _usb_REQ_GET_STATUS:

         'END SELECT
      'CASE &B00000010:
         'SELECT CASE _usb_rx_buffer(3)
         '   CASE _usb_REQ_CLEAR_FEATURE:

         '   CASE _usb_REQ_SET_FEATURE:

         'END SELECT

      'Class specific requests (useful for HID)
      Case &B10100001:
         'Class specific GET requests
         Select Case _usb_rx_buffer(3)
            Case _usb_req_get_report:
            'CASE _usb_REQ_GET_IDLE:
            'CASE _usb_REQ_GET_PROTOCOL:
         End Select
      Case &B00100001:
         'Class specific SET requests
         Select Case _usb_rx_buffer(3)
            Case _usb_req_set_report:
               _usb_status._usb_rxc = 0
               _usb_status._usb_rtr = 1
               _usb_status2._usb_ignore = 0
               'Do status reporting
               Call Usb_send(txstate , 0)

               'We need to get the second data packet
               'Reset the RXC bit and set the RTR bit (ready to receive a new packet)
               Do
               Loop Until _usb_status._usb_rxc = 1

               Keybd_leds = _usb_rx_buffer(2)


               'The output report for a keyboard containts a bitmap representing
               'the status of the LEDs:
               'BIT    Description
               '0      NUM LOCK
               '1      CAPS LOCK
               '2      SCROLL LOCK
               '3      COMPOSE
               '4      KANA
               '5-7    CONSTANT/RESERVED
'               Toggle Keybd_leds
'               Portb = Keybd_leds

            Case _usb_req_set_idle:
               Idlemode = 1
               'Do status reporting
               Call Usb_send(txstate , 0)
            'CASE _usb_REQ_SET_PROTOCOL:
         End Select
   End Select

   If Senddescriptor = 1 Then
      Call Usb_senddescriptor(txstate , _usb_rx_buffer(8))
   End If

End Sub


Dim SD_Size As Byte
Dim SD_I As Byte
Dim SD_J As Byte
Dim SD_Timeout As Word

Sub Usb_senddescriptor(txstate As Byte , Maxlen As Byte)
      Read Sd_size

   If Maxlen < Sd_size Then Sd_size = Maxlen

   SD_I = 2
   For SD_J = 1 To SD_Size
      Incr SD_I
         Read Txstate(sd_i)

      If SD_I = 10 Or SD_J = SD_Size Then
         SD_I = SD_I - 2
         Call Usb_send(txstate , SD_I)
         While Txstate._usb_txc = 0
            SD_Timeout = 0
            'To prevent an infinite loop, check for reset here
            While _usb_pin._usb_dminus = 0
               Incr SD_Timeout
               If SD_Timeout = 1000 Then
                  Call Usb_reset()
                  Exit Sub
               End If
            Wend
         Wend
         SD_I = 2
      End If
   Next
End Sub

Sub Usb_send(txstate As Byte , Byval Count As Byte)

   'Calculates and adds the CRC16,adds the DATAx PID,
   'and signals to the ISR that the data is ready to be sent.
   '
   '"Count" is the DATA payload size.  Range is 0 to 8. Do not exceed 8!

   'Reset all the flags except TxSync and RxSync
   Txstate = Txstate And _usb_syncmask

   'Calculate the 16-bit CRC
    _usb_crc = crcusb(txstate(3), Count)

   'Bytes to transmit will be PID + DATA payload + CRC16
   Count = Count + 3
   Txstate = Txstate + Count

   Txstate(count) = Low(_usb_crc)
   Incr Count
   Txstate(count) = High(_usb_crc)


   'Add the appropriate DATAx PID
   Txstate(2) = _usb_pid_data1
   If Txstate._usb_txsync = 0 Then
      Txstate(2) = _usb_pid_data0
   End If

   'The last step is to signal that the packet is Ready To Transmit
   Txstate._usb_rtt = 1
   Txstate._usb_txc = 0
End Sub

Sub Usb_reset()
   'Reset the receive flags
   _usb_status._usb_rtr = 1
   _usb_status._usb_rxc = 0

   'Reset the transmit flags
   _usb_tx_status = _usb_endp_init
   #if Varexist( "_usb_Endp2Addr")
   _usb_tx_status2 = _usb_endp_init
   #endif
   #if Varexist( "_usb_Endp3Addr")
   _usb_tx_status3 = _usb_endp_init
   #endif

   'Reset the device ID to 0
   _usb_deviceid = 0

   Idlemode = 0
End Sub

Function Ascii2usage(ascii As Byte) As Word
Local Result As Word

'Maps common (mostly printable) ASCII characters to USB Keyboard usage codes
'Returns two bytes: keyboard modifier flags and key code

'Modifier bits:
'0 LEFT CTRL
'1 LEFT SHIFT
'2 LEFT ALT
'3 LEFT GUI
'4 RIGHT CTRL
'5 RIGHT SHIFT
'6 RIGHT ALT
'7 RIGHT GUI

'USB Keyboard usage codes
'0   No event (no keys pressed)
'1   Keyboard ErrorRollOver
'2   Keyboard POSTFail
'3   Undefined Keyboard Error

'Standard Keyboard keys
'04-29 (a and A) to (z and Z)     Letters
'30-39 (1 and !) to (0 and ))     Numbers
'40    Enter/Return (^m)
'41    Escape
'42    Backspace  (^h)
'43    Tab
'44    Space
'45    - and _
'46    = and +
'47    [ and {
'48    ] and }
'49    \ and |
'50    Non-US # and ~  or \ and |
'51    ; and :
'52    ' and "
'53    ` and ~
'54    , and <
'55    . and >
'56    / and ?
'57    CAPS LOCK
'58-69 F1 - F12
'70    PRINT SCREEN
'71    SCROLL LOCK
'72    Pause
'73    Insert
'74    Home
'75    PageUp
'76    Delete
'77    End
'78    PageDown
'79    Right Arrow
'80    Left Arrow
'81    Down Arrow
'82    Up Arrow

'Standard Keypad keys (ten-key)
'83    Keypad Numlock
'84    Keypad /
'85    Keypad *
'86    Keypad -
'87    Keypad +
'88    Keypad ENTER
'89-98 Keypad 1-0
'99    Keypad . and DEL
Select Case Ascii
Case "a" To "z":
   Result = Ascii - 93
Case "A" To "Z":
   Result = Ascii - 61
   Result = Result OR &B00000010_00000000                  'left shift modifier
Case "1" To "9":
   Result = Ascii - 19
Case "0":
   Result = 39
Case " ":
   Result = 44
Case Else:
   Result = 0
End Select
Ascii2usage = Result
End Function

Messwerte_anzeigen:
    Message = Str(schwelle)
    Message = "schwelle " + Message
    Call Typemessage(message)
    Akey = &H28                                             'Enter
    Call Typekey(akey)
    Message = Str(d0)
    Message = "d0 " + Message
    Call Typemessage(message)
    Akey = &H28                                             'Enter
    Call Typekey(akey)
    Message = Str(d1)
    Message = "d1  " + Message
    Call Typemessage(message)
    Akey = &H28                                             'Enter
    Call Typekey(akey)
    Message = Str(d2)
    Message = "d2  " + Message
    Call Typemessage(message)
    Akey = &H28                                             'Enter
    Call Typekey(akey)
    Message = Str(d3)
    Message = "d3  " + Message
    Call Typemessage(message)
    Akey = &H28                                             'Enter
    Call Typekey(akey)
    Message = Str(d4)
    Message = "d4  " + Message
    Call Typemessage(message)
    Akey = &H28                                             'Enter
    Call Typekey(akey)
    Message = Str(d5)
    Message = "d5  " + Message
    Call Typemessage(message)
    Akey = &H28                                             'Enter
    Call Typekey(akey)
    Message = Str(d6)
    Message = "d6  " + Message
    Call Typemessage(message)
    Akey = &H28                                             'Enter
    Call Typekey(akey)
    Message = Str(d7)
    Message = "d7  " + Message
    Call Typemessage(message)
    Akey = &H28                                             'Enter
    Call Typekey(akey)
    Message = Str(d8)
    Message = "d8  " + Message
    Call Typemessage(message)
    Akey = &H28                                             'Enter
    Call Typekey(akey)
    Message = Str(d9)
    Message = "d9  " + Message
    Call Typemessage(message)
    Akey = &H28                                             'Enter
    Call Typekey(akey)
    Message = Str(d10)
    Message = "d10 " + Message
    Call Typemessage(message)
    Akey = &H28                                             'Enter
    Call Typekey(akey)
    Akey = &H28                                             'Enter
    Call Typekey(akey)
Return

Taste_senden:
    X = Gw0 - D0                                            'Hoch  Akey = &H52
    If X > Schwelle Then T0 = 1 Else T0 = 0
    X = Gw1 - D1                                            'Runter  Akey = &H51
    If X > Schwelle Then T1 = 1 Else T1 = 0
    X = Gw2 - D2                                            'Links Akey = &H50
    If X > Schwelle Then T2 = 1 Else T2 = 0
    X = Gw3 - D3                                            'Rechts Akey = &H4F
    If X > Schwelle Then T3 = 1 Else T3 = 0
    X = Gw4 - D4                                            'W Akey = &H1A
    If X > Schwelle Then T4 = 1 Else T4 = 0
    X = Gw5 - D5                                            'S Akey = &H16
    If X > Schwelle Then T5 = 1 Else T5 = 0
    X = Gw6 - D6                                            'A Akey = &H04
    If X > Schwelle Then T6 = 1 Else T6 = 0
    X = Gw7 - D7                                            'D Akey = &H07
    If X > Schwelle Then T7 = 1 Else T7 = 0
    X = Gw8 - D8                                            'Space Akey = &H2C
    If X > Schwelle Then T8 = 1 Else T8 = 0
    X = Gw9 - D9                                            'Enter Akey = &H28
    If X > Schwelle Then T9 = 1 Else T9 = 0
    X = Gw10 - D10                                          'Strg links Akey = &HE0
    If X > Schwelle Then T10 = 1 Else T10 = 0

    For I = 1 To 6
        Taste(i) = 0
    Next I
    I = 1
    If T0 = 1 Then
       Taste(i) = &H52
       If I < 6 Then Incr I
    End If
    If T1 = 1 Then
       Taste(i) = &H51
       If I < 6 Then Incr I
    End If
    If T2 = 1 Then
       Taste(i) = &H50
       If I < 6 Then Incr I
    End If
    If T3 = 1 Then
       Taste(i) = &H4F
       If I < 6 Then Incr I
    End If
    If T4 = 1 Then
       Taste(i) = &H1A
       If I < 6 Then Incr I
    End If
    If T5 = 1 Then
       Taste(i) = &H16
       If I < 6 Then Incr I
    End If
    If T6 = 1 Then
       Taste(i) = &H04
       If I < 6 Then Incr I
    End If
    If T7 = 1 Then
       Taste(i) = &H07
       If I < 6 Then Incr I
    End If
    If T8 = 1 Then
       Taste(i) = &H2C
       If I < 6 Then Incr I
    End If
    If T9 = 1 Then
       Taste(i) = &H28
       If I < 6 Then Incr I
    End If
    If T10 = 1 Then
       Taste(i) = &HE0
       If I < 6 Then Incr I
    End If
    'Taste(1) = &H04
    Do : Loop Until _usb_tx_status2._usb_txc = 1
   ' Key down
   _usb_tx_buffer2(2) = High(taste(1))                      'Modifier keys (shift, ctl, alt, etc)
   _usb_tx_buffer2(3) = 0                                   'Reserved.  Always 0
   _usb_tx_buffer2(4) = Low(taste(1))                       'key1
   _usb_tx_buffer2(5) = Low(taste(2))                       'key2
   _usb_tx_buffer2(6) = Low(taste(3))                       'key3
   _usb_tx_buffer2(7) = Low(taste(4))                       'key4
   _usb_tx_buffer2(8) = Low(taste(5))                       'key5
   _usb_tx_buffer2(9) = Low(taste(6))                       'key6
   Call Usb_send(_usb_tx_status2 , 8)
Return

Sense2:
'Sensor0
If Gw0 <> 0 Then
 For D0 = 1 To Limit
  A0_ddr = 0
  B0_ddr = 0
  B0_port = 1
  B0_ddr = 1
  B0_ddr = 0
  B0_port = 0
  A0_ddr = 1
  Waitus 1
  If B0_pin = 1 Then Exit For
 Next D0
 A0_port = 0
 B0_port = 0
 A0_ddr = 1
 B0_ddr = 1
End If
 'Sensor1
If Gw1 <> 0 Then
 For D1 = 1 To Limit
  A1_ddr = 0
  B1_ddr = 0
  B1_port = 1
  B1_ddr = 1
  B1_ddr = 0
  B1_port = 0
  A1_ddr = 1
  Waitus 1
  If B1_pin = 1 Then Exit For
 Next D1
 A1_port = 0
 B1_port = 0
 A1_ddr = 1
 B1_ddr = 1
End If
 'Sensor2
If Gw2 <> 0 Then
 For D2 = 1 To Limit
  A2_ddr = 0
  B2_ddr = 0
  B2_port = 1
  B2_ddr = 1
  B2_ddr = 0
  B2_port = 0
  A2_ddr = 1
  Waitus 1
  If B2_pin = 1 Then Exit For
 Next D2
 A2_port = 0
 B2_port = 0
 A2_ddr = 1
 B2_ddr = 1
End If
 'Sensor3
If Gw3 <> 0 Then
 For D3 = 1 To Limit
  A3_ddr = 0
  B3_ddr = 0
  B3_port = 1
  B3_ddr = 1
  B3_ddr = 0
  B3_port = 0
  A3_ddr = 1
  Waitus 1
  If B3_pin = 1 Then Exit For
 Next D3
 A3_port = 0
 B3_port = 0
 A3_ddr = 1
 B3_ddr = 1
End If
 'Sensor4
If Gw4 <> 0 Then
 For D4 = 1 To Limit
  A4_ddr = 0
  B4_ddr = 0
  B4_port = 1
  B4_ddr = 1
  B4_ddr = 0
  B4_port = 0
  A4_ddr = 1
  Waitus 1
  If B4_pin = 1 Then Exit For
 Next D4
 A4_port = 0
 B4_port = 0
 A4_ddr = 1
 B4_ddr = 1
End If
 'Sensor5
If Gw5 <> 0 Then
 For D5 = 1 To Limit
  A5_ddr = 0
  B5_ddr = 0
  B5_port = 1
  B5_ddr = 1
  B5_ddr = 0
  B5_port = 0
  A5_ddr = 1
  Waitus 1
  If B5_pin = 1 Then Exit For
 Next D5
 A5_port = 0
 B5_port = 0
 A5_ddr = 1
 B5_ddr = 1
End If
 'Sensor6
If Gw6 <> 0 Then
 For D6 = 1 To Limit
  A6_ddr = 0
  B6_ddr = 0
  B6_port = 1
  B6_ddr = 1
  B6_ddr = 0
  B6_port = 0
  A6_ddr = 1
  Waitus 1
  If B6_pin = 1 Then Exit For
 Next D6
 A6_port = 0
 B6_port = 0
 A6_ddr = 1
 B6_ddr = 1
End If
 'Sensor7
If Gw7 <> 0 Then
 For D7 = 1 To Limit
  A7_ddr = 0
  B7_ddr = 0
  B7_port = 1
  B7_ddr = 1
  B7_ddr = 0
  B7_port = 0
  A7_ddr = 1
  Waitus 1
  If B7_pin = 1 Then Exit For
 Next D7
 A7_port = 0
 B7_port = 0
 A7_ddr = 1
 B7_ddr = 1
End If
 'Sensor8
If Gw8 <> 0 Then
 For D8 = 1 To Limit
  A8_ddr = 0
  B8_ddr = 0
  B8_port = 1
  B8_ddr = 1
  B8_ddr = 0
  B8_port = 0
  A8_ddr = 1
  Waitus 1
  If B8_pin = 1 Then Exit For
 Next D8
 A8_port = 0
 B8_port = 0
 A8_ddr = 1
 B8_ddr = 1
End If
 'Sensor9
If Gw9 <> 0 Then
 For D9 = 1 To Limit
  A9_ddr = 0
  B9_ddr = 0
  B9_port = 1
  B9_ddr = 1
  B9_ddr = 0
  B9_port = 0
  A9_ddr = 1
  Waitus 1
  If B9_pin = 1 Then Exit For
 Next D9
 A9_port = 0
 B9_port = 0
 A9_ddr = 1
 B9_ddr = 1
End If
 'Sensor10
If Gw10 <> 0 Then
 For D10 = 1 To Limit
  A10_ddr = 0
  B10_ddr = 0
  B10_port = 1
  B10_ddr = 1
  B10_ddr = 0
  B10_port = 0
  A10_ddr = 1
  Waitus 1
  If B10_pin = 1 Then Exit For
 Next D10
 A10_port = 0
 B10_port = 0
 A10_ddr = 1
 B10_ddr = 1
End If
Return

Sense:
'Sensor0
 For D0 = 1 To Limit
  A0_ddr = 0
  B0_ddr = 0
  B0_port = 1
  B0_ddr = 1
  B0_ddr = 0
  B0_port = 0
  A0_ddr = 1
  Waitus 1
  If B0_pin = 1 Then Exit For
 Next D0
 A0_port = 0
 B0_port = 0
 A0_ddr = 1
 B0_ddr = 1

 'Sensor1
 For D1 = 1 To Limit
  A1_ddr = 0
  B1_ddr = 0
  B1_port = 1
  B1_ddr = 1
  B1_ddr = 0
  B1_port = 0
  A1_ddr = 1
  Waitus 1
  If B1_pin = 1 Then Exit For
 Next D1
 A1_port = 0
 B1_port = 0
 A1_ddr = 1
 B1_ddr = 1

 'Sensor2
 For D2 = 1 To Limit
  A2_ddr = 0
  B2_ddr = 0
  B2_port = 1
  B2_ddr = 1
  B2_ddr = 0
  B2_port = 0
  A2_ddr = 1
  Waitus 1
  If B2_pin = 1 Then Exit For
 Next D2
 A2_port = 0
 B2_port = 0
 A2_ddr = 1
 B2_ddr = 1

 'Sensor3
 For D3 = 1 To Limit
  A3_ddr = 0
  B3_ddr = 0
  B3_port = 1
  B3_ddr = 1
  B3_ddr = 0
  B3_port = 0
  A3_ddr = 1
  Waitus 1
  If B3_pin = 1 Then Exit For
 Next D3
 A3_port = 0
 B3_port = 0
 A3_ddr = 1
 B3_ddr = 1

 'Sensor4
 For D4 = 1 To Limit
  A4_ddr = 0
  B4_ddr = 0
  B4_port = 1
  B4_ddr = 1
  B4_ddr = 0
  B4_port = 0
  A4_ddr = 1
  Waitus 1
  If B4_pin = 1 Then Exit For
 Next D4
 A4_port = 0
 B4_port = 0
 A4_ddr = 1
 B4_ddr = 1

 'Sensor5
 For D5 = 1 To Limit
  A5_ddr = 0
  B5_ddr = 0
  B5_port = 1
  B5_ddr = 1
  B5_ddr = 0
  B5_port = 0
  A5_ddr = 1
  Waitus 1
  If B5_pin = 1 Then Exit For
 Next D5
 A5_port = 0
 B5_port = 0
 A5_ddr = 1
 B5_ddr = 1

 'Sensor6
 For D6 = 1 To Limit
  A6_ddr = 0
  B6_ddr = 0
  B6_port = 1
  B6_ddr = 1
  B6_ddr = 0
  B6_port = 0
  A6_ddr = 1
  Waitus 1
  If B6_pin = 1 Then Exit For
 Next D6
 A6_port = 0
 B6_port = 0
 A6_ddr = 1
 B6_ddr = 1

 'Sensor7
 For D7 = 1 To Limit
  A7_ddr = 0
  B7_ddr = 0
  B7_port = 1
  B7_ddr = 1
  B7_ddr = 0
  B7_port = 0
  A7_ddr = 1
  Waitus 1
  If B7_pin = 1 Then Exit For
 Next D7
 A7_port = 0
 B7_port = 0
 A7_ddr = 1
 B7_ddr = 1

 'Sensor8
 For D8 = 1 To Limit
  A8_ddr = 0
  B8_ddr = 0
  B8_port = 1
  B8_ddr = 1
  B8_ddr = 0
  B8_port = 0
  A8_ddr = 1
  Waitus 1
  If B8_pin = 1 Then Exit For
 Next D8
 A8_port = 0
 B8_port = 0
 A8_ddr = 1
 B8_ddr = 1

 'Sensor9
 For D9 = 1 To Limit
  A9_ddr = 0
  B9_ddr = 0
  B9_port = 1
  B9_ddr = 1
  B9_ddr = 0
  B9_port = 0
  A9_ddr = 1
  Waitus 1
  If B9_pin = 1 Then Exit For
 Next D9
 A9_port = 0
 B9_port = 0
 A9_ddr = 1
 B9_ddr = 1

 'Sensor10
 For D10 = 1 To Limit
  A10_ddr = 0
  B10_ddr = 0
  B10_port = 1
  B10_ddr = 1
  B10_ddr = 0
  B10_port = 0
  A10_ddr = 1
  Waitus 1
  If B10_pin = 1 Then Exit For
 Next D10
 A10_port = 0
 B10_port = 0
 A10_ddr = 1
 B10_ddr = 1

Return

Kalibrieren:
    'Ports deaktivieren falls nichts angeschlossen ist
    If D0 < 2593 Then Gw0 = D0 Else Gw0 = 0
    If D1 < 2495 Then Gw1 = D1 Else Gw1 = 0
    If D2 < 2580 Then Gw2 = D2 Else Gw2 = 0
    If D3 < 2927 Then Gw3 = D3 Else Gw3 = 0
    If D4 < 3006 Then Gw4 = D4 Else Gw4 = 0
    If D5 < 3046 Then Gw5 = D5 Else Gw5 = 0
    If D6 < 2765 Then Gw6 = D6 Else Gw6 = 0
    If D7 < 2882 Then Gw7 = D7 Else Gw7 = 0
    If D8 < 2745 Then Gw8 = D8 Else Gw8 = 0
    If D9 < 2267 Then Gw9 = D9 Else Gw9 = 0
    If D10 < 2810 Then Gw10 = D10 Else Gw10 = 0
    'Bei weniger Tasten die Pausen bis zum Dauerfeuer erhöhen
    Wdh = 3
    If Gw0 = 0 Then Wdh = Wdh + 3
    If Gw1 = 0 Then Wdh = Wdh + 3
    If Gw2 = 0 Then Wdh = Wdh + 3
    If Gw3 = 0 Then Wdh = Wdh + 3
    If Gw4 = 0 Then Wdh = Wdh + 3
    If Gw5 = 0 Then Wdh = Wdh + 3
    If Gw6 = 0 Then Wdh = Wdh + 3
    If Gw7 = 0 Then Wdh = Wdh + 3
    If Gw8 = 0 Then Wdh = Wdh + 3
    If Gw9 = 0 Then Wdh = Wdh + 3
    If Gw10 = 0 Then Wdh = Wdh + 3
Return
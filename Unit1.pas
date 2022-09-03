unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    ComboBox1: TComboBox;
    Button1: TButton;
    Label11_11: TLabel;
    Label12_12: TLabel;
    Label13_13: TLabel;
    Label14_14: TLabel;
    Label15_15: TLabel;
    Label16_16: TLabel;
    Label17_17: TLabel;
    Label18_18: TLabel;
    Label19_19: TLabel;
    Label1: TLabel;
    Timer1: TTimer;
    Panel3: TPanel;
    Label6: TLabel;
    Panel5: TPanel;
    Button2: TButton;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    Button3: TButton;
    Label4_4: TLabel;
    Label5_5: TLabel;
    Label3: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label30: TLabel;
    Label1_1: TLabel;
    Label3_3: TLabel;
    Label7_7: TLabel;
    Label8_8: TLabel;
    Label9_9: TLabel;
    Label10_10: TLabel;
    Button4: TButton;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Panel4: TPanel;
    Label20: TLabel;
    Label20_20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label21_21: TLabel;
    Label22_22: TLabel;
    Panel6: TPanel;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Label23: TLabel;
    Label23_23: TLabel;
    Label24: TLabel;
    Label24_24: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);

  private
  public
    { Public declarations }
  end;

ReadTh=class(Tthread)
private{ private declarations }
protected
procedure execute; override; // Главная процедура потока;
procedure OutToLabel; //Процедура вывода в Label содержимого переменной буфера;
end;

WriteTh=class(Tthread)
private{ private declarations }
protected
procedure execute; override;
end;

var
  Form1: TForm1;
  Adr:PWideChar; //Переменная номера COM порта;
  W:WideString; //Промежуточная переменная;
  ComFile:THandle;
  Phandle:Thandle;
  DCB:TDCB;
  OverRead:TOverlapped;
  OverWrite:TOverlapped;
  ComStat:TComStat; //Переменная состояния порта;
  Timeouts:TCommTimeouts; //Переменная таймаутов;

  ReadThread:ReadTh; //Переменная потока чтения;
  WriteThread:WriteTh; //Переменная потока записи;

  Btr, Temp, Mask, Signal:DWORD;

  Buffer_COM_PORT:array [0..18] of Byte; //Массив данных Byte;

  buffer_read:array [0..18] of Byte;

  count_byte_read, j, k, n: Byte;

  timer_Enable: bool;
  delay_Enable: bool;
  timer_count: Byte;

  Enabled_button: bool;

  count_pack_input: Longint;
  count_pack_output: Longint;
  count_error_crc8: Longint;
  count_invalid_pack: Longint;

  CRC: Byte;

  TimeStart : TDateTime;

  count_ADC_calibration_point: Byte;

  CRC8 : Byte;
  l: integer;

  result_callibration_U: bool;
  result_callibration_I: bool;

  result_MessageBox: Word;

  ON_Pin_ON_OFF_1_3: bool;
  ON_Pin_ON_OFF_2_3: bool;
  OFF_Pin_ON_OFF_1: bool;
  OFF_Pin_ON_OFF_2: bool;

  Table : Array[0..255] of Byte = (
0, 94, 188, 226, 97, 63, 221, 131, 194, 156, 126, 32, 163, 253, 31, 65,
157, 195, 33, 127, 252, 162, 64, 30, 95, 1, 227, 189, 62, 96, 130, 220,
35, 125, 159, 193, 66, 28, 254, 160, 225, 191, 93, 3, 128, 222, 60, 98,
190, 224, 2, 92, 223, 129, 99, 61, 124, 34, 192, 158, 29, 67, 161, 255,
70, 24, 250, 164, 39, 121, 155, 197, 132, 218, 56, 102, 229, 187, 89, 7,
219, 133, 103, 57, 186, 228, 6, 88, 25, 71, 165, 251, 120, 38, 196, 154,
101, 59, 217, 135, 4, 90, 184, 230, 167, 249, 27, 69, 198, 152, 122, 36,
248, 166, 68, 26, 153, 199, 37, 123, 58, 100, 134, 216, 91, 5, 231, 185,
140, 210, 48, 110, 237, 179, 81, 15, 78, 16, 242, 172, 47, 113, 147, 205,
17, 79, 173, 243, 112, 46, 204, 146, 211, 141, 111, 49, 178, 236, 14, 80,
175, 241, 19, 77, 206, 144, 114, 44, 109, 51, 209, 143, 12, 82, 176, 238,
50, 108, 142, 208, 83, 13, 239, 177, 240, 174, 76, 18, 145, 207, 45, 115,
202, 148, 118, 40, 171, 245, 23, 73, 8, 86, 180, 234, 105, 55, 213, 139,
87, 9, 235, 181, 54, 104, 138, 212, 149, 203, 41, 119, 244, 170, 72, 22,
233, 183, 85, 11, 136, 214, 52, 106, 43, 117, 151, 201, 74, 20, 246, 168,
116, 42, 200, 150, 21, 75, 169, 247, 182, 232, 10, 84, 215, 137, 107, 53);


implementation

{$R *.dfm}

procedure CRC8_MAXIM(X: array of Byte; num_array:Byte);
Begin
  CRC8:=0;
  for l:=0 to num_array do CRC8 := Table[CRC8 xor X[l]];
End;


procedure TForm1.FormCreate(Sender: TObject);
Var i:Byte;
begin

  count_pack_input:=0;
  count_pack_output:=0;
  count_error_crc8:=0;
  count_invalid_pack:=0;

  TimeStart := Now;
  Form1.Label20_20.Caption := '00:00:00';
  Timer1.Enabled:=True;
  Button1.Enabled:=True;
  Button2.Enabled:=False;
  Button3.Enabled:=False;
  Button4.Enabled:=False;
  Button5.Enabled:=False;
  Button6.Enabled:=False;
  Button7.Enabled:=False;
  Button8.Enabled:=False;
  RadioButton1.Enabled:=False;
  RadioButton2.Enabled:=False;

  delay_Enable:=False;
  Enabled_button:=False;
  result_callibration_U := False;
  result_callibration_I := False;

  ON_Pin_ON_OFF_1_3 := False;
  ON_Pin_ON_OFF_2_3 := False;
  OFF_Pin_ON_OFF_1 := False;
  OFF_Pin_ON_OFF_2 := False;

  Form1.Label1_1.Caption := 'Не подключен';
  Form1.Label3_3.Caption := 'Не установлено';
  Form1.Label4_4.Caption := '0';
  Form1.Label5_5.Caption := '0';
  Form1.Label7_7.Caption := 'Не произведена';
  Form1.Label8_8.Caption := 'Не произведена';
  Form1.Label9_9.Caption := 'Не произведена';
  Form1.Label10_10.Caption := 'Не произведена';
  Form1.Label11_11.Caption := ' ';
  Form1.Label12_12.Caption := ' ';
  Form1.Label13_13.Caption := ' ';
  Form1.Label14_14.Caption := ' ';
  Form1.Label15_15.Caption := ' ';
  Form1.Label16_16.Caption := ' ';
  Form1.Label17_17.Caption := ' ';
  Form1.Label18_18.Caption := ' ';
  Form1.Label19_19.Caption := ' ';
  Form1.Label21_21.Caption := 'Не произведена';
  Form1.Label22_22.Caption := 'Не произведена';
  Form1.Label23_23.Caption := '0';
  Form1.Label24_24.Caption := '0';

  for i:=1 to 255 do
    begin
      Phandle:=CreateFile(Pchar('\\.\COM'+intToStr(i)), generic_read + generic_write, 0, nil, open_existing, file_flag_overlapped,0);
      if Phandle<>INVALID_HANDLE_VALUE then
        begin
          Combobox1.Items.Add('COM'+ IntToStr(i));
          CloseHandle(Phandle);
        end;
    end;

  comboBox1.ItemIndex := 0;

end;


procedure TForm1.RadioButton1Click(Sender: TObject);
begin
  Form1.RadioButton2.Enabled:=False;
  Button3.Enabled:=True;
  Button4.Enabled:=False;
  timer_Enable := False;
  count_ADC_calibration_point := 1;
  if(result_callibration_U) then
  begin
    result_MessageBox := MessageBox(0,'Калибровка АЦП была произведена.'+#13#10+'Вы действительно хотите перекалибровать АЦП?','Внимание!',MB_YESNO+MB_ICONWARNING);
    case result_MessageBox of
    IDYES:
      begin
        MessageBox(0,'Режим калибровки АЦП активирован.'+#13#10+'Не выключайте питание ККВН в процессе калибровки.','Внимание!',MB_OK+MB_ICONWARNING);
        Form1.Label7_7.Caption := 'Не произведена';
        Form1.Label8_8.Caption := 'Не произведена';
      end;
    IDNO:
      begin
        Form1.RadioButton1.Checked:=False;
        Form1.RadioButton2.Enabled:=True;
        Button3.Enabled:=False;
        timer_Enable := True;
      end;
    end;
  end
  else MessageBox(0,'Режим калибровки АЦП активирован.'+#13#10+'Не выключайте питание ККВН в процессе калибровки.','Внимание!',MB_OK+MB_ICONWARNING);
  end;

procedure TForm1.RadioButton2Click(Sender: TObject);
begin
  Form1.RadioButton1.Enabled:=False;
  Button3.Enabled:=False;
  Button4.Enabled:=True;
  timer_Enable := False;
  count_ADC_calibration_point := 3;
  if(result_callibration_I) then
  begin
    result_MessageBox := MessageBox(0,'Калибровка датчиков тока была произведена.'+#13#10+'Вы действительно хотите перекалибровать датчики тока?','Внимание!',MB_YESNO+MB_ICONWARNING);
    case result_MessageBox of
    IDYES:
      begin
        MessageBox(0,'Режим калибровки датчика тока активирован.'+#13#10+'Не выключайте питание ККВН в процессе калибровки.','Внимание!',MB_OK+MB_ICONWARNING);
        Form1.Label9_9.Caption := 'Не произведена';
        Form1.Label10_10.Caption := 'Не произведена';
        Form1.Label21_21.Caption := 'Не произведена';
        Form1.Label22_22.Caption := 'Не произведена';
      end;
    IDNO:
      begin
        Form1.RadioButton1.Enabled:=True;
        Form1.RadioButton2.Checked:=False;
        Button4.Enabled:=False;
        timer_Enable := True;
      end;
    end;
  end
  else MessageBox(0,'Режим калибровки датчика тока активирован.'+#13#10+'Не выключайте питание ККВН в процессе калибровки.','Внимание!',MB_OK+MB_ICONWARNING);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if timer_Enable then
  begin
    Buffer_COM_PORT[0]:= $7B;
    Buffer_COM_PORT[1]:= $7B;
    CRC8_MAXIM(Buffer_COM_PORT, 1);
    Buffer_COM_PORT[2]:= CRC8;

    WriteThread:=WriteTh.Create(false); //Создаем поток записи;
    WriteThread.FreeOnTerminate:=true; //Запускаем поток записи;
    WriteThread.Priority:=tpNormal; //Устанавливаем приоритет;
  end;
  if delay_Enable then
  begin
    inc(timer_count, 1);
    if timer_count = 3 then
    begin
      delay_Enable := False;
      timer_Enable := True;
      timer_count := 0;
      count_byte_read:= 0;
      k:=0;
      n:=0;
    end;
  end;

  Label20_20.Caption := FormatDateTime('hh:nn:ss', Now - TimeStart);

end;

procedure TForm1.Button1Click(Sender: TObject);
begin

  W:=Form1.ComboBox1.Items.Strings[form1.ComboBox1.ItemIndex]; {Загружаем выбранную запись в переменную}
  Adr:=PWideChar(W); {Преобразуем ее в тип годный для использования в функции открытия порта (WideChar);}

  ComFile:=CreateFile(Pchar('\\.\'+Adr), generic_read+generic_write,0,nil,OPEN_EXISTING,file_flag_overlapped,0);
  if ComFile=INVALID_HANDLE_VALUE  then
  begin
    Label1_1.Caption:='Не удалось открыть порт' ;
    exit;
  end
  else
  begin
    Label1_1.Caption:='COM-порт открыт' ;
  end;

  PurgeComm(ComFile, Purge_TXabort or Purge_RXabort or Purge_TXclear or Purge_RXclear); //Очищаем буферы приема и передачи и очередей чтения/записи;

  GetCommState(ComFile, DCB);
  with DCB do begin
    BaudRate:=9600;
    ByteSize:=8;
    Parity:=NoParity;
    StopBits:=OneStopBit;
  end;

  if not SetCommState(ComFile, DCB) then
  begin
    Label1_1.Caption:='Порт не настроен';
    CloseHandle(ComFile);
    exit;
    end;

  if ComFile <> INVALID_HANDLE_VALUE then
  begin
    GetCommTimeouts(ComFile, Timeouts); { Чтение текущих таймаутов и настройка параметров структуры CommTimeouts }
    Timeouts.ReadIntervalTimeout:=MAXDWORD; //Таймаут между двумя символами;
    Timeouts.ReadTotalTimeoutMultiplier:=0; //Общий таймаут операции чтения;
    Timeouts.ReadTotalTimeoutConstant:=0; //Константа для общего таймаута операции чтения;
    Timeouts.WriteTotalTimeoutMultiplier:=0; //Общий таймаут операции записи;
    Timeouts.WriteTotalTimeoutConstant:=0; //Константа для общего таймаута операции записи;
    SetCommTimeouts(ComFile, Timeouts); //Установка таймаутов;
  end;

  SetupComm(ComFile, 4096, 4096); //Настройка буферов;
  if not SetupComm(ComFile, 4096, 4096) then //Ошибка настройки буферов;
  begin
    Label1_1.Caption:='Ошибка настройки буферов';
    CloseHandle(ComFile);
    exit;
  end;

  SetCommMask(ComFile, EV_RXchar); {Устанавливаем маску для срабатывания по событию - "Прием байта в порт"}

  Button1.Enabled:=False;
  Button2.Enabled:=True;
  ComboBox1.Enabled:=False;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ReadThread:=ReadTh.Create(false); //Создаем поток чтения;
  ReadThread.FreeOnTerminate:=true; //Запускаем поток чтения;
  ReadThread.Priority:=tpNormal; //Устанавливаем приоритет;

  timer_Enable := True;
  Button2.Enabled:=False;
  timer_count := 0;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  case count_ADC_calibration_point of
  1:
  begin
    Form1.Button3.Enabled:=False;
    Buffer_COM_PORT[0]:= $7A;
    Buffer_COM_PORT[1]:= $01;
    CRC8_MAXIM(Buffer_COM_PORT, 1);
    Buffer_COM_PORT[2]:= CRC8;
  end;
  2:
  begin
    Form1.Button3.Enabled:=False;
    Buffer_COM_PORT[0]:= $7A;
    Buffer_COM_PORT[1]:= $02;
    CRC8_MAXIM(Buffer_COM_PORT, 1);
    Buffer_COM_PORT[2]:= CRC8;
  end;
  end;
  WriteThread:=WriteTh.Create(false); //Создаем поток записи;
  WriteThread.FreeOnTerminate:=true; //Запускаем поток записи;
  WriteThread.Priority:=tpNormal; //Устанавливаем приоритет;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  case count_ADC_calibration_point of
  3:
  begin
    Form1.Button4.Enabled:=False;
    Buffer_COM_PORT[0]:= $7A;
    Buffer_COM_PORT[1]:= $03;
    CRC8_MAXIM(Buffer_COM_PORT, 1);
    Buffer_COM_PORT[2]:= CRC8;
  end;
  4:
  begin
    Form1.Button4.Enabled:=False;
    Buffer_COM_PORT[0]:= $7A;
    Buffer_COM_PORT[1]:= $04;
    CRC8_MAXIM(Buffer_COM_PORT, 1);
    Buffer_COM_PORT[2]:= CRC8;
  end;
  5:
  begin
    Form1.Button4.Enabled:=False;
    Buffer_COM_PORT[0]:= $7A;
    Buffer_COM_PORT[1]:= $05;
    CRC8_MAXIM(Buffer_COM_PORT, 1);
    Buffer_COM_PORT[2]:= CRC8;
  end;
  6:
  begin
    Form1.Button4.Enabled:=False;
    Buffer_COM_PORT[0]:= $7A;
    Buffer_COM_PORT[1]:= $06;
    CRC8_MAXIM(Buffer_COM_PORT, 1);
    Buffer_COM_PORT[2]:= CRC8;
  end;
  end;
  WriteThread:=WriteTh.Create(false); //Создаем поток записи;
  WriteThread.FreeOnTerminate:=true; //Запускаем поток записи;
  WriteThread.Priority:=tpNormal; //Устанавливаем приоритет;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  timer_Enable := False;

  ON_Pin_ON_OFF_1_3:=True;

  Button5.Enabled:=False;
  Button7.Enabled:=False;

  Buffer_COM_PORT[0]:= $6C;
  Buffer_COM_PORT[1]:= $6C;
  CRC8_MAXIM(Buffer_COM_PORT, 1);
  Buffer_COM_PORT[2]:= CRC8;

  WriteThread:=WriteTh.Create(false); //Создаем поток записи;
  WriteThread.FreeOnTerminate:=true; //Запускаем поток записи;
  WriteThread.Priority:=tpNormal; //Устанавливаем приоритет;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  timer_Enable := False;

  OFF_Pin_ON_OFF_1:=True;

  Button6.Enabled:=False;

  Buffer_COM_PORT[0]:= $7C;
  Buffer_COM_PORT[1]:= $7C;
  CRC8_MAXIM(Buffer_COM_PORT, 1);
  Buffer_COM_PORT[2]:= CRC8;

  WriteThread:=WriteTh.Create(false); //Создаем поток записи;
  WriteThread.FreeOnTerminate:=true; //Запускаем поток записи;
  WriteThread.Priority:=tpNormal; //Устанавливаем приоритет;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  timer_Enable := False;

  ON_Pin_ON_OFF_2_3:=True;

  Button5.Enabled:=False;
  Button7.Enabled:=False;

  Buffer_COM_PORT[0]:= $8C;
  Buffer_COM_PORT[1]:= $8C;
  CRC8_MAXIM(Buffer_COM_PORT, 1);
  Buffer_COM_PORT[2]:= CRC8;

  WriteThread:=WriteTh.Create(false); //Создаем поток записи;
  WriteThread.FreeOnTerminate:=true; //Запускаем поток записи;
  WriteThread.Priority:=tpNormal; //Устанавливаем приоритет;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  timer_Enable := False;

  OFF_Pin_ON_OFF_2:=True;

  Button8.Enabled:=False;

  Buffer_COM_PORT[0]:= $9C;
  Buffer_COM_PORT[1]:= $9C;
  CRC8_MAXIM(Buffer_COM_PORT, 1);
  Buffer_COM_PORT[2]:= CRC8;

  WriteThread:=WriteTh.Create(false); //Создаем поток записи;
  WriteThread.FreeOnTerminate:=true; //Запускаем поток записи;
  WriteThread.Priority:=tpNormal; //Устанавливаем приоритет;
end;

procedure WriteTh.execute;
begin
  PurgeComm(ComFile, Purge_TXabort or Purge_TXclear); //Очищаем передающий буфер и очереди записи;
  OverWrite.Hevent:=CreateEvent(Nil, True, True, Nil); {Сигнальный объект событие для ассинхронных операций;}
  WriteFile(ComFile, Buffer_COM_PORT, 3, Temp, @OverWrite); {Пишем в порт массив;}
  Signal:=WaitForSingleObject(OverWrite.hEvent, Infinite); {Приостанавливаем поток до тех пор пока не завершится передача;}
  if (Signal=Wait_Object_0) and GetOverlappedResult(ComFile, OverWrite, Temp, true) then
  begin
    Form1.Label3_3.Caption:='Пакет передан';
    inc(count_pack_output, 1);
    Form1.Label4_4.Caption:=intToStr(count_pack_output);
  end
  else Form1.Label3_3.Caption:='Пакет не передан';

  CloseHandle(OverWrite.Hevent); //Закрываем объект событие;
end;

procedure ReadTh.execute;
begin
 OverRead.Hevent:=CreateEvent(Nil, True, True, Nil); //Сигнальный объект событие для ассинхронных операций;
 while not ReadThread.Terminated do //Пока поток не остановлен;
 begin

  WaitCommEvent(ComFile, Mask, @OverRead); //Ожидаем события (поступление байта);
  Signal:=WaitForSingleObject(OverRead.hEvent, Infinite); {Приостанавливаем поток до тех пор пока байт не поступит;}
  if (Signal=Wait_Object_0) then //Если байт поступил;
  begin
   if GetOverlappedResult(ComFile, OverRead, Temp, true) then {Проверяем успешность завершения операции;}
   begin
    if ((Mask and EV_RXchar)<>0) then //Если маска соответствует,
    begin
     ClearCommError(ComFile, Temp, @ComStat); //Заполняем структуру ComStat;
     Btr:=ComStat.CbInQue; //Получаем из структуры количество байт;
     if Btr.Size<>0 then //Если байты присутствуют,
      begin
        ReadFile(ComFile, Buffer_COM_PORT, SizeOf(Buffer_COM_PORT), Temp, @OverRead); //Читаем порт;

        k := k+Temp;

        for j:=count_byte_read to k do
        begin
          buffer_read[j] := Buffer_COM_PORT[n];
          inc(n, 1);
        end;

        if ((buffer_read[0] <> $7A) and (buffer_read[0] <> $7B)) then
        begin
          count_byte_read:= 0;
          k:=0;
          n:=0;
          //delay_Enable := True;
          //timer_Enable := False;
          inc(count_invalid_pack, 1);
          Form1.Label24_24.Caption:= IntToStr(count_invalid_pack);
        end;

        count_byte_read:=k;
        n:=0;

        if (k = 19) then
        begin
          CRC8_MAXIM(buffer_read, 18);
          if(CRC8 = 0) then begin Synchronize(OutToLabel); end
          else
          begin
            delay_Enable := True;
            timer_Enable := False;
            inc(count_error_crc8, 1);
            Form1.Label23_23.Caption:= IntToStr(count_error_crc8);
          end;
        count_byte_read:= 0;
        k:=0;
        n:=0;
        end;
      end;
     end;
    end
   end;
  end;
 CloseHandle(OverRead.Hevent);
end;

procedure ReadTh.OutToLabel;
begin

  Form1.Label3_3.Caption:='Соединение установлено';

  inc(count_pack_input, 1);
  Form1.Label5_5.Caption:=intToStr(count_pack_input);

  Form1.Label11_11.Caption:= IntToStr(buffer_read[1]);
  Form1.Label12_12.Caption:= IntToStr(buffer_read[2])+','+IntToStr(buffer_read[3])+' В';
  Form1.Label13_13.Caption:= IntToStr(buffer_read[4])+','+IntToStr(buffer_read[5])+' В';
  Form1.Label14_14.Caption:= IntToStr(buffer_read[6])+','+IntToStr(buffer_read[7])+' В';
  Form1.Label15_15.Caption:= IntToStr(buffer_read[8])+','+IntToStr(buffer_read[9])+' В';
  Form1.Label16_16.Caption:= IntToStr(buffer_read[10]shl 4+buffer_read[11]shr 4)+','+ IntToStr(buffer_read[11] and $0F)+' А';
  Form1.Label17_17.Caption:= IntToStr(buffer_read[12]shl 4+buffer_read[13]shr 4)+','+ IntToStr(buffer_read[13] and $0F)+' А';
  Form1.Label18_18.Caption:= IntToStr(buffer_read[14])+','+IntToStr(buffer_read[15])+' %';
  Form1.Label19_19.Caption:= IntToStr(buffer_read[16])+','+IntToStr(buffer_read[17])+' %';

  case buffer_read[0] of
  $7A:
  begin
    case count_ADC_calibration_point of
      1:
      begin
        Form1.Label7_7.Caption:= 'Выполнена';
        Form1.Button3.Enabled:=True;
        inc(count_ADC_calibration_point,1);
      end;
      2:
      begin
        result_callibration_U := True;
        Form1.Button3.Enabled:=False;
        Form1.RadioButton1.Checked:=False;
        Form1.RadioButton2.Enabled:=True;
        Form1.Label8_8.Caption:= 'Выполнена';
        count_ADC_calibration_point := 1;
        timer_Enable := True;
      end;
      3:
      begin
        Form1.Button4.Enabled:=True;
        Form1.Label9_9.Caption:= 'Выполнена';
        inc(count_ADC_calibration_point,1);
      end;
      4:
      begin
        Form1.Button4.Enabled:=True;
        Form1.Label10_10.Caption:= 'Выполнена';
        inc(count_ADC_calibration_point,1);
      end;
      5:
      begin
        Form1.Button4.Enabled:=True;
        Form1.Label21_21.Caption:= 'Выполнена';
        inc(count_ADC_calibration_point,1);
      end;
      6:
      begin
        result_callibration_I := True;
        Form1.RadioButton2.Checked:=False;
        Form1.Label22_22.Caption:= 'Выполнена';
        Form1.RadioButton1.Enabled:=True;
        count_ADC_calibration_point := 1;
        timer_Enable := True;
      end;
    end;
  end;
  $7B:
  begin
  if ON_Pin_ON_OFF_1_3 = true then
    begin
      ON_Pin_ON_OFF_1_3:=False;
      Form1.Button6.Enabled:=True;
    end;
    if OFF_Pin_ON_OFF_1 = true then
    begin
      OFF_Pin_ON_OFF_1:=False;
      Form1.Button5.Enabled:=True;
      Form1.Button7.Enabled:=True;
    end;
    if ON_Pin_ON_OFF_2_3 = true then
    begin
      ON_Pin_ON_OFF_2_3:=False;
      Form1.Button8.Enabled:=True;
    end;
    if OFF_Pin_ON_OFF_2 = true then
    begin
      OFF_Pin_ON_OFF_2:=False;
      Form1.Button5.Enabled:=True;
      Form1.Button7.Enabled:=True;
    end;
    timer_Enable := True;
  end;
  end;

  if Enabled_button = false then
  begin
    Form1.RadioButton1.Enabled:=True;
    Form1.RadioButton2.Enabled:=True;
    Form1.Button5.Enabled:=True;
    Form1.Button7.Enabled:=True;
    Enabled_button:=True;
  end;

end;
end.

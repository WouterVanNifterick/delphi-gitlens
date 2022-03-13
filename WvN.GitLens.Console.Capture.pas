unit WvN.GitLens.Console.Capture;

interface

uses
  System.Threading,
  System.SysUtils;

procedure CaptureConsoleOutputSync(const ACommand: String; CallBack: TProc<string>);
function CaptureConsoleOutputAsync(const ACommand: String; CallBack: TProc<string>):ITask;

implementation

uses
  Winapi.Windows, System.Classes;

procedure CaptureConsoleOutputSync(const ACommand: String; CallBack: TProc<String>);
const
  CReadBuffer = 40000;
var
  saSecurity: TSecurityAttributes;
  hRead: THandle;
  hWrite: THandle;
  suiStartup: TStartupInfo;
  piProcess: TProcessInformation;
  pBuffer: array [0 .. CReadBuffer] of AnsiChar;
  dBuffer: array [0 .. CReadBuffer] of AnsiChar;
  dRead: DWORD;
  dRunning: DWORD;
  dAvailable: DWORD;
begin
  saSecurity.nLength := SizeOf(TSecurityAttributes);
  saSecurity.bInheritHandle := true;
  saSecurity.lpSecurityDescriptor := nil;
  if not CreatePipe(hRead, hWrite, @saSecurity, 0) then
    Exit;

  try
    suiStartup := default(TStartupInfo);
    suiStartup.cb := SizeOf(TStartupInfo);
    suiStartup.hStdInput := hRead;
    suiStartup.hStdOutput := hWrite;
    suiStartup.hStdError := hWrite;
    suiStartup.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    suiStartup.wShowWindow := SW_HIDE;
    if not Createprocess(nil, PChar(ACommand+''), @saSecurity, @saSecurity, true, NORMAL_PRIORITY_CLASS, nil, nil, suiStartup, piProcess) then
      Exit;

    try
      var txt := '';
      repeat
        dRunning := WaitForSingleObject(piProcess.hProcess, 10);
        PeekNamedPipe(hRead, nil, 0, nil, @dAvailable, nil);
        if (dAvailable > 0) then
          repeat
            dRead := 0;
            ReadFile(hRead, pBuffer[0], CReadBuffer, dRead, nil);
            pBuffer[dRead] := #0;
            OemToCharA(pBuffer, dBuffer);

            txt:=txt + dBuffer;
          until (dRead < CReadBuffer);
      until (dRunning <> WAIT_TIMEOUT);
      TThread.Synchronize(
        nil,
        procedure
        begin
          CallBack(txt)
        end
      )
    finally
      CloseHandle(piProcess.hProcess);
      CloseHandle(piProcess.hThread)
    end;
  finally
    CloseHandle(hRead);
    CloseHandle(hWrite)
  end;
end;

function CaptureConsoleOutputAsync(const ACommand: String; CallBack: TProc<string>):ITask;
begin
  Result := TTask.Create(procedure
                         begin
                           CaptureConsoleOutputSync(ACommand, CallBack);
                         end).Start
end;



end.

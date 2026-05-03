PROGRAM Project_01_Conveyor
  VAR
    PB_Start AT %IX0.0 : BOOL;
    PB_Stop AT %IX0.1 : BOOL;
    PB_EStop AT %IX0.2 : BOOL;
    PB_FaultReset AT %IX0.3 : BOOL;
    SW_ModeAuto AT %IX0.4 : BOOL;
    SEN_Entry AT %IX0.5 : BOOL;
    SEN_Exit AT %IX0.6 : BOOL;
    SEN_Jam AT %IX0.7 : BOOL;
    KM1_ConveyorMotor AT %QX0.0 : BOOL;
    HL1_RunLamp AT %QX0.1 : BOOL;
    HL2_AlarmLamp AT %QX0.2 : BOOL;
    HL3_AutoLamp AT %QX0.3 : BOOL;
    MR_MasterEnable
 AT %M0.0 : BOOL;
    MR_RunLatch AT %M0.1 : BOOL;
    MR_FaultActive AT %M0.2 : BOOL;
    MR_AutoMode AT %M0.3 : BOOL;
    MR_ManualMode AT %M0.4 : BOOL;
    MR_AutoRunCmd AT %M0.5 : BOOL;
  END_VAR
  VAR
    TON_JamDelay : TON;
    JamDelayTime : TIME := T#3s;
    AutoTimeoutTime : TIME := T#15s;
    TON_AutoTimeout : TON;
  END_VAR

  MR_MasterEnable
 := NOT(MR_FaultActive) AND PB_EStop;
  TON_JamDelay(IN := NOT(SEN_Jam) AND KM1_ConveyorMotor, PT := JamDelayTime);
  IF TON_JamDelay.Q THEN
    MR_FaultActive := TRUE; (*set*)
  END_IF;
  IF SEN_Jam AND PB_FaultReset THEN
    MR_FaultActive := FALSE; (*reset*)
  END_IF;
  MR_AutoMode := MR_MasterEnable
 AND SW_ModeAuto;
  MR_ManualMode := MR_MasterEnable
 AND NOT(SW_ModeAuto);
  HL3_AutoLamp := MR_AutoMode;
  IF PB_Start AND MR_ManualMode THEN
    MR_RunLatch := TRUE; (*set*)
  END_IF;
  IF NOT(PB_Stop) AND MR_ManualMode THEN
    MR_RunLatch := FALSE; (*reset*)
  END_IF;
  IF SEN_Entry AND MR_AutoMode THEN
    MR_AutoRunCmd := TRUE; (*set*)
  END_IF;
  IF SEN_Exit THEN
    MR_AutoRunCmd := FALSE; (*reset*)
  END_IF;
  IF TON_AutoTimeout.Q THEN
    MR_AutoRunCmd := FALSE; (*reset*)
  END_IF;
  KM1_ConveyorMotor := (MR_AutoRunCmd OR MR_RunLatch) AND MR_MasterEnable
;
  HL1_RunLamp := KM1_ConveyorMotor;
  HL2_AlarmLamp := MR_FaultActive;
  TON_AutoTimeout(IN := MR_AutoRunCmd, PT := AutoTimeoutTime);
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : Project_01_Conveyor;
  END_RESOURCE
END_CONFIGURATION

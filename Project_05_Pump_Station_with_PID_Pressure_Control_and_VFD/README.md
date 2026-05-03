# Project 05 — Pump Station with PID Pressure Control and VFD

**PLC:** Siemens S7-1200 CPU 1214C DC/DC/DC  
**Software:** TIA Portal V17+ (with PID_Compact V2 function block)  
**Language:** Ladder Logic (LAD) + Structured Control Language (SCL) for PID tuning  
**Difficulty:** ⭐⭐⭐⭐⭐ Advanced

---

## 1. System Description

A municipal-style booster pump station maintains constant network **pressure** in a water distribution system. The station contains **two identical centrifugal pumps**:

- **Pump 1 (P1):** Lead pump — controlled via a **Variable Frequency Drive (VFD)**. The PLC sends a 4–20mA speed reference signal to the VFD, and the PID controller adjusts pump speed to maintain pressure setpoint.
- **Pump 2 (P2):** Lag/standby pump — direct-on-line (DOL) contactor. Starts automatically when P1 VFD is at 100% and pressure is still below setpoint (high demand). Also serves as duty standby in case P1 fails.

A **4–20mA pressure transmitter** (PT-01) provides the process variable feedback to the PID. A **4–20mA flow transmitter** (FT-01) provides flow rate monitoring.

**Operating Modes:**
- **Auto:** PID controls VFD speed for P1. P2 starts/stops on demand. Duty/Standby swap on runtime equalization.
- **Manual:** Operator sets VFD speed directly as a percentage via HMI. P2 manual on/off.
- **Test Mode:** Both pumps stopped, all interlocks bypassed for maintenance testing.

**Key Advanced Features:**
- Analog I/O with engineering unit scaling (bar, m³/h)
- PID_Compact function block (Siemens S7 standard block)
- Duty/Standby automatic swap (runtime equalizer)
- VFD fault input and communication
- Flow totalization (daily, weekly cumulative)
- Pressure low/high alarm with hysteresis
- Soft-stop on P2 (run-on timer before stopping)
- Data logging concept (DB-based production record)

**The project includes:**

- Master enable safety logic
- Auto / Manual / Test mode selection
- Analog scaling for pressure, flow, and VFD speed feedback
- PID pressure control
- Manual speed reference
- PID output low and high clamp
- Analog output scaling for VFD speed reference
- Pump 2 lag start and stop logic
- Pressure low and high alarm with hysteresis
- Pump contactor feedback fault detection
- Alarm lamp and buzzer logic
- Runtime hour calculation
- Flow totalizer
- Duty swap recommendation

---

## 2. Tags List

Digital Inputs:

Tag Name              OpenPLC Address   Type    Description
------------------------------------------------------------
PB_EStop              %IX0.0            BOOL    Emergency stop, NC
PB_FaultReset         %IX0.1            BOOL    Fault reset pushbutton, NO
SW_ModeAuto           %IX0.2            BOOL    Auto/manual selector
SW_ModeTest           %IX0.3            BOOL    Test mode selector
F2_P1_Overload        %IX0.4            BOOL    Pump 1 overload, NC
F3_P2_Overload        %IX0.5            BOOL    Pump 2 overload, NC
KM1_P1_Feedback       %IX0.6            BOOL    Pump 1 contactor feedback
KM2_P2_Feedback       %IX0.7            BOOL    Pump 2 contactor feedback

VFD1_Running          %IX1.0            BOOL    VFD running feedback
VFD1_Fault            %IX1.1            BOOL    VFD fault relay, NC
LS_SumpLow            %IX1.2            BOOL    Sump low level switch, NC
PB_P1_ManStart        %IX1.3            BOOL    Pump 1 manual start, NO
PB_P1_ManStop         %IX1.4            BOOL    Pump 1 manual stop, NC
PB_P2_ManStart        %IX1.5            BOOL    Pump 2 manual start, NO
PB_P2_ManStop         %IX1.6            BOOL    Pump 2 manual stop, NC
LS_TankHighHigh       %IX1.7            BOOL    High-high pressure switch, NC

Digital Outputs:

Tag Name              OpenPLC Address   Type    Description
------------------------------------------------------------
KM1_P1_Contactor      %QX0.0            BOOL    Pump 1 contactor output
KM2_P2_Contactor      %QX0.1            BOOL    Pump 2 contactor output
VFD1_Enable           %QX0.2            BOOL    VFD run enable
SOL_DischargeValve    %QX0.3            BOOL    Discharge valve solenoid
HL1_P1RunLamp         %QX0.4            BOOL    Pump 1 run lamp
HL2_P2RunLamp         %QX0.5            BOOL    Pump 2 run lamp
HL3_AlarmLamp         %QX0.6            BOOL    Alarm lamp
HL4_AutoLamp          %QX0.7            BOOL    Auto mode lamp
BZ1_Alarm             %QX1.0            BOOL    Alarm buzzer

Analog Inputs:

Tag Name              OpenPLC Address   Type    Description
------------------------------------------------------------
AI_Pressure_Raw       %IW0              INT     Raw pressure input
AI_Flow_Raw           %IW1              INT     Raw flow input
AI_VFD1_Speed_Raw     %IW2              INT     Raw VFD speed feedback

Analog Output:

Tag Name              OpenPLC Address   Type    Description
------------------------------------------------------------
AO_VFD1_SpeedRef      %QW0              INT     VFD analog speed reference

Important:
In this OpenPLC project, analog values are handled as 0 to 27648 counts.
This is used to simulate typical Siemens-style analog scaling.

Internal OpenPLC Tags:

BOOL Tags:

MasterEnable
FaultActive
FaultP1_Overload
FaultP2_Overload
FaultVFD1
FaultSumpLow
FaultPressLow
FaultPressHigh
AutoMode
ManualMode
TestMode
P1_RunCmd
P2_RunCmd
P2_LagActive
DutySwapReq
BuzzerSilenced
Clock_1Hz
Clock_1Hz_Rise
PID_LowLimit
PID_HighLimit
P2_SpeedHigh
P2_SpeedLow
P2_PressureLow
FaultP1_Feedback
FaultP2_Feedback
DutySwapCompare

REAL Tags:

Pressure_EU
Flow_EU
VFD1_Speed_EU
Setpoint_EU
PID_Output
ManSpeedRef
P2_LagThreshold
P2_StopThreshold
PressAlarmLo
PressAlarmHi
PressAlarmLo_Reset
PressAlarmHi_Reset
Pressure_Raw_Real
Pressure_Mul
Flow_Raw_Real
Flow_Mul
VFD_Raw_Real
VFD_Mul
AO_TempReal
AO_TempReal2
P2_StartPressure
P1_RunHours
P2_RunHours
RuntimeDiff
FlowPerSecond
FlowTotal_Daily

TIME Tags:

TON_PressAlarmDelayTime
TON_ValvePreOpenTime
TON_P1_FbkDelayTime
TON_P2_FbkDelayTime
TON_P2_StartDelayTime
TON_P2_StopDelayTime
PID_TR
PID_TD
PID_CYCLE

TON Function Blocks:

TON_PressAlarmDelay
TON_ValvePreOpen
TON_P1_FbkDelay
TON_P2_FbkDelay
TON_P2_StartDelay
TON_P2_StopDelay

Constants Used in OpenPLC:

Tag Name     Type    Value       Description
------------------------------------------------------------
I6           REAL    16.0        Pressure range, 0 to 16 bar
n200         REAL    200.0       Flow range, 0 to 200 m3/h
n100         REAL    100.0       Percent full scale
n20          REAL    20.0        Minimum VFD speed while running
n10          REAL    10.0        Runtime difference for duty swap request
n05          REAL    0.5         Pressure hysteresis for P2 start
n0           INT     0           Zero analog output
n27648       REAL    27648.0     Analog full scale
n3600        REAL    3600.0      Seconds per hour
nClock       REAL    0.000278    One second converted to hours

Recommended Initial Values:

Setpoint_EU              = 6.0
ManSpeedRef              = 50.0
P2_LagThreshold          = 95.0
P2_StopThreshold         = 60.0
PressAlarmLo             = 4.0
PressAlarmLo_Reset       = 4.3
PressAlarmHi             = 12.0
PressAlarmHi_Reset       = 11.5
TON_PressAlarmDelayTime  = T#10s
TON_ValvePreOpenTime     = T#3s
TON_P1_FbkDelayTime      = T#1s
TON_P2_FbkDelayTime      = T#1s
TON_P2_StartDelayTime    = T#5s
TON_P2_StopDelayTime     = T#30s

PID_KP                   = 2.0
PID_TR                   = T#30s
PID_TD                   = T#0s
PID_CYCLE                = T#100ms


******OpenPLC to Siemens Conversion Explanation******
------------------------------------------------------------

This project is written for OpenPLC, so the addresses use OpenPLC style:

Digital inputs use %IX.
Digital outputs use %QX.
Analog input words use %IW.
Analog output words use %QW.

For Siemens S7-1200 in TIA Portal, the same logic can be converted, but the address format changes.

Example conversions:

OpenPLC %IX0.0 becomes Siemens %I0.0.
OpenPLC %QX0.0 becomes Siemens %Q0.0.
OpenPLC %IW0 can become Siemens %IW64.
OpenPLC %QW0 can become Siemens %QW64.

The exact Siemens analog addresses depend on the hardware configuration in TIA Portal.

The internal logic tags can be placed inside a Siemens data block instead of using only memory bits. For example, tags like Pressure_EU, PID_Output, P1_RunHours, and FaultActive can be stored in a DB such as DB_PumpStation.

In OpenPLC, the PID block uses pins such as AUTO, PV, SP, X0, KP, TR, TD, CYCLE, and XOUT.

In Siemens, this should be replaced by PID_Compact. The process value would be Pressure_EU, the setpoint would be Setpoint_EU, and the output would be PID_Output. The output limits should be set to 20.0 and 100.0 percent.

For analog scaling in Siemens, the current OpenPLC method using INT_TO_REAL, MUL, and DIV can still be used. However, Siemens also provides NORM_X and SCALE_X blocks, which are commonly used for analog scaling.

For timers, OpenPLC TON function blocks should be converted to Siemens IEC TON timers with proper instance memory.

Before running the Siemens version on real hardware, the analog module addresses, VFD wiring, safety circuit, overload inputs, and signal ranges must be checked in TIA Portal Device Configuration.
---------------

## 3. Analog Signal Scaling — Engineering Units

### Theory

The S7-1200 represents a 4–20mA signal as an integer raw value: **0 = 4mA, 27648 = 20mA**.

The engineering unit value is calculated by linear interpolation:

```
EU = EU_Low + (Raw - 0) × (EU_High - EU_Low) / 27648

For pressure (0–16 bar):
EU = 0.0 + Raw × (16.0 / 27648)
EU = Raw × 0.000579 bar per count

For flow (0–200 m³/h):
EU = Raw × (200.0 / 27648)
EU = Raw × 0.007234 m³/h per count
```

### Implementation in TIA Portal

In TIA Portal, use the **NORM_X** and **SCALE_X** instruction blocks (available in the "Conversion" library):

```
NETWORK: PRESSURE SCALING
──────────────────────────────────────────────────────────────────
  Step 1 — Normalize raw value to 0.0–1.0 float:
  NORM_X: MIN = 0, MAX = 27648, VALUE = IW64 → OUT = MW100 (temp float)

  Step 2 — Scale to engineering units:
  SCALE_X: MIN = 0.0, MAX = 16.0, VALUE = MW100 → OUT = MD20 (MR_Pressure_EU)

  In ladder, wire as:
  [Always TRUE] ──[NORM_X: VALUE=IW64]──[SCALE_X: OUT=MD20]

  Note: Always-TRUE means these conversion boxes execute every scan.
        Use the ENO→EN chained connection.

NETWORK: FLOW SCALING
──────────────────────────────────────────────────────────────────
  Same pattern: IW66 → NORM_X → SCALE_X (0–200) → MD24

NETWORK: VFD SPEED FEEDBACK SCALING
──────────────────────────────────────────────────────────────────
  IW68 → NORM_X → SCALE_X (0–100.0%) → MD28
```

### AO Scaling (PID Output → VFD Speed Reference)

```
NETWORK: VFD SPEED REFERENCE OUTPUT
──────────────────────────────────────────────────────────────────
  The PID output (0.0–100.0%) must be converted to a 0–27648 integer
  for the analog output module.

  NORM_X: MIN=0.0, MAX=100.0, VALUE=MD36 → temp float
  SCALE_X: MIN=0, MAX=27648, VALUE=temp → OUT=QW64

  Note: If PID output is 0.0%, AO = 0 counts = 4mA → VFD minimum speed
        If PID output is 100.0%, AO = 27648 = 20mA → VFD maximum speed
```

---

## 4. Ladder Logic — Network by Network

---
This section explains the purpose of each ladder network in the OpenPLC pump station project. The program is written for OpenPLC using OpenPLC tag addressing. The same control concept can later be converted to Siemens S7-1200 / TIA Portal by changing the address format, analog scaling blocks, timer style, and PID block.

------------------------------------------------------------
Network 1 — Master Enable
------------------------------------------------------------

This network creates the main safety permissive for the whole pump station.

The tag MasterEnable becomes TRUE only when all safety-related inputs are healthy. These inputs include the emergency stop, both pump overload contacts, the VFD fault contact, the sump low-level switch, and the tank high-high switch.

Most of these devices are wired as normally closed field contacts. In a healthy condition, the PLC input is TRUE. If a fault happens or the wire opens, the PLC input becomes FALSE and MasterEnable turns OFF.

When MasterEnable is OFF, the pump run commands are reset and the pump outputs are disabled. This protects the pumps from running during an unsafe condition.

------------------------------------------------------------
Network 2 — Mode Selection
------------------------------------------------------------

This network selects the operating mode of the pump station.

AutoMode becomes TRUE when the Auto selector is ON, Test mode is OFF, and MasterEnable is TRUE.

ManualMode becomes TRUE when the Auto selector is OFF, Test mode is OFF, and MasterEnable is TRUE.

TestMode becomes TRUE when the Test mode selector is ON.

TestMode is used for maintenance or testing. In this project, TestMode prevents the pumps from running by resetting the pump run commands.

------------------------------------------------------------
Network 3 — Pressure Scaling
------------------------------------------------------------

This network converts the raw analog pressure input into engineering units.

The raw pressure input AI_Pressure_Raw is an INT value. It is first converted to a REAL value using INT_TO_REAL. Then it is multiplied by the pressure range, which is 16.0 bar. Finally, it is divided by 27648.0, which represents the analog full-scale count.

The final result is stored in Pressure_EU.

The scaling formula is:

Pressure_EU = AI_Pressure_Raw x 16.0 / 27648.0

The constant I6 is used as 16.0. This is correct because the pressure transmitter range is 0 to 16 bar.

------------------------------------------------------------
Network 4 — Flow Scaling
------------------------------------------------------------

This network converts the raw flow transmitter signal into engineering units.

The raw flow input AI_Flow_Raw is converted from INT to REAL. Then it is multiplied by 200.0 because the flow transmitter range is 0 to 200 m3/h. The result is divided by 27648.0.

The final result is stored in Flow_EU.

The scaling formula is:

Flow_EU = AI_Flow_Raw x 200.0 / 27648.0

This value is later used for flow monitoring and daily flow totalization.

------------------------------------------------------------
Network 5 — VFD Speed Feedback Scaling
------------------------------------------------------------

This network converts the raw VFD speed feedback signal into percent.

The raw VFD speed feedback input AI_VFD1_Speed_Raw is converted from INT to REAL. Then it is multiplied by 100.0 and divided by 27648.0.

The final result is stored in VFD1_Speed_EU.

The scaling formula is:

VFD1_Speed_EU = AI_VFD1_Speed_Raw x 100.0 / 27648.0

This value is used by the Pump 2 lag start and stop logic. If the VFD speed is very high and the pressure is still low, Pump 2 is requested.

------------------------------------------------------------
Network 6 — Pump 1 Overload Fault
------------------------------------------------------------

This network detects and latches the Pump 1 overload fault.

The overload input F2_P1_Overload is wired as a normally closed contact. When the overload is healthy, the input is TRUE. If the overload trips, the input becomes FALSE.

When F2_P1_Overload becomes FALSE, FaultP1_Overload is SET and remains latched.

The fault can be reset only when PB_FaultReset is pressed and F2_P1_Overload has returned to the healthy TRUE state.

------------------------------------------------------------
Network 7 — Pump 2 Overload Fault
------------------------------------------------------------

This network detects and latches the Pump 2 overload fault.

The overload input F3_P2_Overload is also treated as a normally closed device. If the overload trips, the input becomes FALSE and FaultP2_Overload is SET.

The fault can be reset only when PB_FaultReset is pressed and the overload input has returned to healthy.

------------------------------------------------------------
Network 8 — VFD Fault
------------------------------------------------------------

This network detects and latches a VFD fault.

The VFD fault relay input VFD1_Fault is assumed to be normally closed. In the healthy condition, the input is TRUE. If the VFD faults or the relay opens, the input becomes FALSE.

When VFD1_Fault becomes FALSE, FaultVFD1 is SET.

The fault can be reset only when the VFD fault input is healthy again and PB_FaultReset is pressed.

------------------------------------------------------------
Network 9 — Sump Low Fault
------------------------------------------------------------

This network detects a low sump level condition.

The sump low-level input LS_SumpLow is treated as a normally closed dry-run protection contact. When the sump level is healthy, the input is TRUE. When the sump level is low, the input becomes FALSE.

When LS_SumpLow becomes FALSE, FaultSumpLow is SET.

Unlike the overload and VFD faults, the sump low fault resets automatically when LS_SumpLow becomes TRUE again. This allows the station to recover automatically when the water level returns.

------------------------------------------------------------
Network 10 — Pressure Low Alarm
------------------------------------------------------------

This network monitors low discharge pressure.

The pressure value Pressure_EU is compared with PressAlarmLo. If Pressure_EU is lower than PressAlarmLo, the timer TON_PressAlarmDelay starts.

If the pressure remains low for the full delay time, FaultPressLow is SET.

The low-pressure alarm resets when Pressure_EU becomes higher than PressAlarmLo_Reset.

This creates hysteresis. For example, if the alarm setpoint is 4.0 bar and the reset value is 4.3 bar, the alarm will not chatter around the 4.0 bar point.

Recommended values:

PressAlarmLo = 4.0
PressAlarmLo_Reset = 4.3
TON_PressAlarmDelayTime = T#10s

------------------------------------------------------------
Network 11 — Pressure High Alarm
------------------------------------------------------------

This network monitors high discharge pressure.

FaultPressHigh is SET when Pressure_EU is greater than PressAlarmHi.

FaultPressHigh is RESET when Pressure_EU falls below PressAlarmHi_Reset.

This also creates hysteresis. For example, if the high-pressure alarm is 12.0 bar and the reset value is 11.5 bar, the alarm stays active until the pressure has dropped safely below the reset value.

Recommended values:

PressAlarmHi = 12.0
PressAlarmHi_Reset = 11.5

Important note:
The high-pressure set comparison must be greater-than:

Pressure_EU > PressAlarmHi

The reset comparison must be less-than:

Pressure_EU < PressAlarmHi_Reset

------------------------------------------------------------
Network 12 — Combined Fault Active
------------------------------------------------------------

This network combines all individual fault bits into one general fault signal.

FaultActive becomes TRUE if any of the following faults are active:

FaultP1_Overload
FaultP2_Overload
FaultVFD1
FaultSumpLow
FaultPressLow
FaultPressHigh
FaultP1_Feedback
FaultP2_Feedback

FaultActive is used for the alarm lamp, buzzer, and general alarm indication.

------------------------------------------------------------
Network 13 — Pump 1 Auto Run Command
------------------------------------------------------------

This network starts Pump 1 automatically.

In AutoMode, P1_RunCmd is SET when MasterEnable is TRUE, Pump 1 has no overload fault, the VFD has no fault, and TestMode is OFF.

This means that in Auto mode, Pump 1 is the main pressure-control pump. It starts whenever the system is healthy and AutoMode is selected.

------------------------------------------------------------
Network 14 — Pump 1 Manual Run Command
------------------------------------------------------------

This network starts Pump 1 manually.

In ManualMode, pressing PB_P1_ManStart SETs P1_RunCmd, but only if MasterEnable is TRUE, Pump 1 has no overload fault, the VFD has no fault, and TestMode is OFF.

This allows an operator to manually start Pump 1 from the local panel or HMI.

------------------------------------------------------------
Network 15 — Pump 1 Stop Conditions
------------------------------------------------------------

This network resets P1_RunCmd when any stop condition occurs.

P1_RunCmd is reset if MasterEnable turns OFF, TestMode turns ON, Pump 1 overload fault becomes active, VFD fault becomes active, or the manual stop button is pressed during ManualMode.

The manual stop input PB_P1_ManStop is normally closed. This means the PLC input is normally TRUE. When the stop button is pressed, the input opens and becomes FALSE.

------------------------------------------------------------
Network 16 — Discharge Valve Pre-Open Timer
------------------------------------------------------------

This network starts the discharge valve pre-open timer.

The timer TON_ValvePreOpen starts when either P1_RunCmd or P2_RunCmd is active.

The purpose is to give the discharge valve time to open before the pump contactor turns ON. This helps prevent the pump from starting against a closed valve.

Recommended value:

TON_ValvePreOpenTime = T#3s

------------------------------------------------------------
Network 17 — Discharge Valve Output
------------------------------------------------------------

This network controls the discharge valve solenoid.

SOL_DischargeValve turns ON when either P1_RunCmd or P2_RunCmd is active.

This means the discharge valve opens as soon as a pump run command is requested. The pump output itself waits for the pre-open timer from the previous network.

------------------------------------------------------------
Network 18 — Pump 1 Contactor Output
------------------------------------------------------------

This network energizes the Pump 1 contactor output.

KM1_P1_Contactor turns ON when P1_RunCmd is TRUE, TON_ValvePreOpen.Q is TRUE, MasterEnable is TRUE, and TestMode is OFF.

This ensures that Pump 1 only starts after the valve pre-open delay and only when the system is healthy.

------------------------------------------------------------
Network 19 — VFD Enable Output
------------------------------------------------------------

This network enables the VFD.

VFD1_Enable follows KM1_P1_Contactor.

When the Pump 1 contactor is ON, the VFD enable output turns ON. When the Pump 1 contactor is OFF, the VFD enable output turns OFF.

This allows the PLC to give the VFD a run-enable signal only when Pump 1 is commanded to run.

------------------------------------------------------------
Network 20 — Pump 1 Feedback Fault
------------------------------------------------------------

This network checks whether the Pump 1 contactor feedback matches the output command.

If KM1_P1_Contactor is ON but KM1_P1_Feedback is not ON, the timer TON_P1_FbkDelay starts.

If the feedback does not arrive before the timer finishes, FaultP1_Feedback is SET.

This detects a failed contactor, wiring issue, auxiliary contact problem, or output problem.

The fault resets when PB_FaultReset is pressed and KM1_P1_Feedback is healthy.

Recommended value:

TON_P1_FbkDelayTime = T#1s

------------------------------------------------------------
Network 21 — PID / Manual Speed Command
------------------------------------------------------------

This network generates the speed command for the VFD.

In ManualMode, ManSpeedRef is moved directly into PID_Output. This allows the operator to control the VFD speed manually as a percentage.

In AutoMode, the OpenPLC PID block controls PID_Output. The PID compares the actual pressure Pressure_EU with the desired pressure Setpoint_EU.

PID block connections:

AUTO = AutoMode
PV = Pressure_EU
SP = Setpoint_EU
X0 = ManSpeedRef
KP = PID_KP
TR = PID_TR
TD = PID_TD
CYCLE = PID_CYCLE
XOUT = PID_Output

PID_Output represents the speed reference percentage before analog output scaling.

Recommended starting values:

Setpoint_EU = 6.0
ManSpeedRef = 50.0
PID_KP = 2.0
PID_TR = T#30s
PID_TD = T#0s
PID_CYCLE = T#100ms

If the PID response is reversed, the sign of PID_KP may need to be changed.

------------------------------------------------------------
Network 22 — Clamp PID Output Low
------------------------------------------------------------

This network prevents the PID output from going too low while Pump 1 is running.

If PID_Output is less than 20.0 and P1_RunCmd is TRUE, the program forces PID_Output to 20.0.

This is used because many pumps should not run at extremely low VFD speed. A minimum speed helps prevent unstable flow, poor cooling, or pump operation below the useful range.

The minimum value is stored in n20.

Recommended value:

n20 = 20.0

------------------------------------------------------------
Network 23 — Clamp PID Output High
------------------------------------------------------------

This network prevents the PID output from going above 100 percent.

If PID_Output is greater than 100.0, the program forces PID_Output to 100.0.

This prevents the analog speed reference from exceeding the valid VFD command range.

The maximum value is stored in n100.

Recommended value:

n100 = 100.0

------------------------------------------------------------
Network 24 — Analog Output Scaling to VFD
------------------------------------------------------------

This network converts PID_Output from percent into raw analog output counts.

PID_Output is multiplied by 27648.0 and divided by 100.0. The result is converted from REAL to INT and written to AO_VFD1_SpeedRef.

The formula is:

AO_VFD1_SpeedRef = PID_Output x 27648.0 / 100.0

Example:

50 percent gives about 13824 counts.
75 percent gives about 20736 counts.
100 percent gives 27648 counts.

When P1_RunCmd is FALSE, AO_VFD1_SpeedRef is forced to 0. This ensures the VFD speed reference is removed when the pump is not running.

------------------------------------------------------------
Network 25 — Pump 2 Start Pressure Calculation
------------------------------------------------------------

This network calculates the pressure level used to start Pump 2.

P2_StartPressure is calculated as:

P2_StartPressure = Setpoint_EU - 0.5

The 0.5 bar difference creates a deadband so Pump 2 does not start immediately when pressure is only slightly below the setpoint.

The constant n05 is used as 0.5.

------------------------------------------------------------
Network 26 — Pump 2 High Demand Detection
------------------------------------------------------------

This network decides when Pump 2 is needed as a lag pump.

The logic checks two conditions:

1. VFD1_Speed_EU is greater than or equal to P2_LagThreshold.
2. Pressure_EU is lower than P2_StartPressure.

If Pump 1 is already running near maximum speed and the pressure is still low, this means the demand is too high for Pump 1 alone.

When AutoMode, P1_RunCmd, P2_SpeedHigh, P2_PressureLow, and MasterEnable are all TRUE, the timer TON_P2_StartDelay starts.

When the timer is done, P2_LagActive is SET.

Recommended values:

P2_LagThreshold = 95.0
TON_P2_StartDelayTime = T#5s

------------------------------------------------------------
Network 27 — Pump 2 Stop Demand
------------------------------------------------------------

This network decides when Pump 2 is no longer needed.

P2_SpeedLow becomes TRUE when VFD1_Speed_EU is less than or equal to P2_StopThreshold.

If P2_LagActive is TRUE and P2_SpeedLow remains TRUE for the stop delay time, TON_P2_StopDelay finishes and P2_LagActive is RESET.

This prevents Pump 2 from stopping too quickly and avoids rapid cycling.

P2_LagActive is also reset when AutoMode is OFF or MasterEnable is OFF.

Recommended values:

P2_StopThreshold = 60.0
TON_P2_StopDelayTime = T#30s

------------------------------------------------------------
Network 28 — Pump 2 Auto Run Command
------------------------------------------------------------

This network starts Pump 2 automatically.

In AutoMode, P2_RunCmd is SET when P2_LagActive is TRUE, MasterEnable is TRUE, Pump 2 overload fault is not active, and TestMode is OFF.

This allows Pump 2 to act as the lag pump during high demand.

------------------------------------------------------------
Network 29 — Pump 2 Manual Run Command
------------------------------------------------------------

This network starts Pump 2 manually.

In ManualMode, pressing PB_P2_ManStart SETs P2_RunCmd if MasterEnable is TRUE, Pump 2 has no overload fault, and TestMode is OFF.

This allows the operator to manually run Pump 2 for testing or local operation.

------------------------------------------------------------
Network 30 — Pump 2 Stop Conditions
------------------------------------------------------------

This network resets P2_RunCmd when any stop condition occurs.

P2_RunCmd is reset if MasterEnable turns OFF, TestMode turns ON, Pump 2 overload fault becomes active, or the manual stop button is pressed during ManualMode.

In AutoMode, P2_RunCmd is also reset when P2_LagActive becomes FALSE.

The manual stop input PB_P2_ManStop is normally closed. When the stop button is pressed, the input becomes FALSE and the run command is reset.

------------------------------------------------------------
Network 31 — Pump 2 Contactor Output
------------------------------------------------------------

This network energizes the Pump 2 contactor.

KM2_P2_Contactor turns ON when P2_RunCmd is TRUE, TON_ValvePreOpen.Q is TRUE, MasterEnable is TRUE, and TestMode is OFF.

This ensures Pump 2 also waits for the discharge valve pre-open delay before starting.

------------------------------------------------------------
Network 32 — Pump 2 Feedback Fault
------------------------------------------------------------

This network checks the Pump 2 contactor feedback.

If KM2_P2_Contactor is ON but KM2_P2_Feedback is not ON, the timer TON_P2_FbkDelay starts.

If the feedback does not arrive before the timer finishes, FaultP2_Feedback is SET.

The fault resets when PB_FaultReset is pressed and KM2_P2_Feedback is healthy.

Recommended value:

TON_P2_FbkDelayTime = T#1s

------------------------------------------------------------
Network 33 — Run Lamps
------------------------------------------------------------

This network controls the basic status lamps.

HL1_P1RunLamp turns ON when KM1_P1_Contactor is ON.

HL2_P2RunLamp turns ON when KM2_P2_Contactor is ON.

HL4_AutoLamp turns ON when AutoMode is active.

These lamps provide simple operator indication for pump and mode status.

------------------------------------------------------------
Network 34 — Alarm Lamp and Buzzer
------------------------------------------------------------

This network controls the alarm lamp and buzzer.

HL3_AlarmLamp flashes when FaultActive is TRUE and Clock_1Hz is TRUE. This creates a flashing alarm indication.

BZ1_Alarm turns ON when FaultActive is TRUE and BuzzerSilenced is FALSE.

PB_FaultReset sets BuzzerSilenced, which silences the buzzer. When all faults are cleared and FaultActive becomes FALSE, BuzzerSilenced is reset automatically so the next fault can sound the buzzer again.

------------------------------------------------------------
Network 35 — Runtime Hours
------------------------------------------------------------

This network accumulates runtime hours for both pumps.

On every rising edge of Clock_1Hz, if KM1_P1_Contactor is ON, P1_RunHours is increased by nClock.

On every rising edge of Clock_1Hz, if KM2_P2_Contactor is ON, P2_RunHours is increased by nClock.

The value nClock is 0.000278, which is approximately one second converted to hours.

This gives a simple runtime counter for maintenance and duty comparison.

------------------------------------------------------------
Network 36 — Flow Total Daily
------------------------------------------------------------

This network calculates the daily flow total.

First, FlowPerSecond is calculated by dividing Flow_EU by 3600.0.

Flow_EU is in cubic meters per hour. Dividing by 3600 converts it into cubic meters per second.

On every rising edge of Clock_1Hz, if either pump is running, FlowPerSecond is added to FlowTotal_Daily.

This creates a simple daily flow totalizer.

------------------------------------------------------------
Network 37 — Runtime Difference / Duty Swap Request
------------------------------------------------------------

This network compares the runtime of Pump 1 and Pump 2.

RuntimeDiff is calculated as:

RuntimeDiff = P1_RunHours - P2_RunHours

If RuntimeDiff is greater than 10.0 hours, DutySwapReq is SET.

This means Pump 1 has run significantly more than Pump 2, so the system recommends a duty swap.

In this project, DutySwapReq is only an indication or maintenance recommendation. It does not physically change the VFD from Pump 1 to Pump 2.

PB_FaultReset resets DutySwapReq.

---

## 6. PID_Compact Configuration (TIA Portal Wizard)

| Parameter | Value | Explanation |
|---|---|---|
| Controller type | General | Standard PID |
| Process value source | Input (MD20) | Read from scaled pressure real value |
| Process value limits | Min: 0.0, Max: 16.0 | Engineering units — bar |
| Setpoint | MD32 | Adjustable from HMI |
| Output type | Output | % output to AO scaling |
| Output limits | Low: 20.0%, High: 100.0% | Min speed = 20% to prevent stall |
| Kp (starting value) | 2.0 | Tune with commissioning tool |
| Ti (starting value) | 30.0s | Integral time |
| Td (starting value) | 0.0s | No derivative (noisy pressure signal) |
| Sampling time | 100ms | Use OB35 cyclic interrupt |
| Anti-windup | Enabled | Prevent integral runaway at output limits |

**PID Tuning Procedure:**
1. Switch to Manual mode, set speed to 50%
2. Observe pressure stabilization on trend chart
3. Switch to Auto mode with Kp=1.0, Ti=60s (conservative start)
4. Enable TIA Portal PID Tune → Step response tuning
5. Allow auto-tuning to complete, accept suggested Kp/Ti values
6. Monitor for oscillation — increase Ti if overshooting

---

## 7. HMI Tags

| HMI Tag | PLC Tag | Type | Screen |
|---|---|---|---|
| `HMI_PressureEU` | `MR_Pressure_EU` | Real | Main mimic |
| `HMI_FlowEU` | `MR_Flow_EU` | Real | Main mimic |
| `HMI_VFDSpeed` | `MR_VFD1_Speed_EU` | Real | Main mimic |
| `HMI_Setpoint` | `MR_Setpoint_EU` | Real (Write) | Setpoint screen |
| `HMI_PIDOutput` | `MR_PID_Output` | Real | Status bar |
| `HMI_P1Running` | `KM1_P1_Contactor` | Bool | Mimic |
| `HMI_P2Running` | `KM2_P2_Contactor` | Bool | Mimic |
| `HMI_ManSpeedRef` | `MR_ManSpeedRef` | Real (Write) | Manual screen |
| `HMI_FlowDaily` | `MR_FlowTotal_Daily` | Real | Totals screen |
| `HMI_P1Hours` | `MR_P1_RunHours` | Real | Maintenance |
| `HMI_P2Hours` | `MR_P2_RunHours` | Real | Maintenance |
| `HMI_P1Starts` | `MW_P1_DutyCycles` | Word | Maintenance |
| `HMI_P2Starts` | `MW_P2_DutyCycles` | Word | Maintenance |
| `HMI_FaultOverloadP1` | `MR_FaultP1_Overload` | Bool | Alarms |
| `HMI_FaultVFD` | `MR_FaultVFD1` | Bool | Alarms |
| `HMI_FaultSump` | `MR_FaultSumpLow` | Bool | Alarms |
| `HMI_DutySwapReq` | `MR_DutySwapReq` | Bool | Maintenance |
| `HMI_Btn_Reset` | `MX_HMI_Reset` | Bool (Write) | All screens |
| `HMI_Btn_P1Start` | `MX_HMI_P1Start` | Bool (Write) | Manual screen |
| `HMI_Btn_P2Start` | `MX_HMI_P2Start` | Bool (Write) | Manual screen |
| `HMI_PID_Kp` | `SysDB.Kp` | Real (Write) | PID tuning screen |
| `HMI_PID_Ti` | `SysDB.Ti` | Real (Write) | PID tuning screen |

---

## 8. Alarms

| # | Tag | Message | Priority | Annunciation |
|---|---|---|---|---|
| A001 | `MR_FaultP1_Overload` | PUMP 1 OVERLOAD TRIP — Check motor and overload relay | Critical | Lamp + Buzzer |
| A002 | `MR_FaultP2_Overload` | PUMP 2 OVERLOAD TRIP — Check motor and overload relay | Critical | Lamp + Buzzer |
| A003 | `MR_FaultVFD1` | VFD1 FAULT — Check VFD display for fault code | Critical | Lamp + Buzzer |
| A004 | `MR_FaultSumpLow` | SUCTION SUMP LOW — Dry run protection active | Critical | Lamp + Buzzer |
| A005 | `PB_EStop` | EMERGENCY STOP ACTIVE | Critical | Buzzer only |
| A006 | `MR_FaultPressLow` | NETWORK PRESSURE LOW — Check demand and pump status | High | Lamp flash |
| A007 | `MR_FaultPressHigh` | NETWORK PRESSURE HIGH — Check PRV and discharge valve | High | Lamp flash |
| A008 | `MR_P2_LagActive` | Lag pump P2 started — High demand | Medium | Info |
| A009 | `MR_DutySwapReq` | DUTY SWAP RECOMMENDED — P1 runtime exceeds P2 by 10h | Low | HMI only |
| A010 | `LS_SumpLow` | Sump level low — monitor | Medium | HMI only |

---

## 9. Test Scenarios

### Test 1 — PID Auto Pressure Control
1. Connect PLCSIM, simulate pressure transmitter by forcing IW64
2. Set setpoint MD32 = 6.0 bar
3. Set Auto mode ON → P1 starts, VFD ramps up
4. Force IW64 to low value (low pressure) → PID should increase QW64 (speed up)
5. Force IW64 to high value (above setpoint) → PID reduces QW64 (slow down)
6. ✅ Expected: VFD speed tracks PID output, pressure converges to setpoint

### Test 2 — Lag Pump Start
1. Auto mode running
2. Force MD28 (VFD speed feedback) = 96.0% (above lag threshold)
3. Force MD20 (pressure) < MD32 - 0.5 (below setpoint with hysteresis)
4. Wait 5 seconds (TON_P2_StartDelay)
5. ✅ Expected: MR_P2_LagActive = TRUE, KM2_P2_Contactor = TRUE
6. Force MD28 = 55.0% (demand dropped), wait 30 seconds
7. ✅ Expected: MR_P2_LagActive = RESET, P2 stops

### Test 3 — VFD Fault
1. Auto mode, P1 running
2. Force I1.1 = FALSE (VFD fault relay opens)
3. ✅ Expected: Master enable drops, KM1 de-energizes, MR_FaultVFD1 latches, buzzer sounds
4. Force I1.1 = TRUE (VFD fault cleared), press FaultReset
5. ✅ Expected: Fault clears, system can restart

### Test 4 — Sump Dry-Run Protection
1. Auto mode, pumps running
2. Force I1.2 = FALSE (sump level low)
3. ✅ Expected: Master enable drops immediately, both pumps stop
4. This is NOT a latching fault — auto-resets when level returns

### Test 5 — Pressure Low Alarm with Hysteresis
1. Force MD20 = 3.5 bar, setpoint MD32 = 6.0 bar, alarm low DB20.DBD32 = 4.0 bar
2. Wait 10 seconds (confirmation timer)
3. ✅ Expected: MR_FaultPressLow latches, A006 alarm
4. Force MD20 = 4.5 bar (above 4.0 + 0.3 = 4.3 bar hysteresis)
5. ✅ Expected: Alarm auto-resets

### Test 6 — Manual Mode PID Bypass
1. Switch to Manual mode
2. PID_Compact mode changes to Manual
3. Set MD40 = 75.0% (manual speed reference via HMI)
4. ✅ Expected: QW64 = 20736 counts (75% of 27648), VFD runs at 75%
5. P2 manual start/stop via HMI buttons work independently

---

## 10. Safety Notes and Limitations

- **Analog input module required:** The CPU 1214C has 2x 0–10V inputs by default. For 4–20mA, the SM 1231 signal module is mandatory.
- **PID minimum output (20%):** The VFD should never receive 0% reference while the pump is running — this can cause surge and reverse flow. The 20% output lower limit prevents this.
- **Anti-deadhead protection:** The discharge valve pre-open timer (Network 5) is essential. Never start a centrifugal pump against a closed valve.
- **Seal water:** Real pump seals often require seal water or lubrication. If the pump runs dry (sump low), the seal may fail within seconds. The sump low protection (I1.2) is a critical safety feature.
- **VFD harmonics:** High-power VFDs inject harmonic currents into the electrical supply. In a real installation, a line reactor and EMC filter are required.
- **No ATEX/EX rating:** This project does not address hazardous area classification. Pumping flammable fluids requires EX-rated equipment and a different safety strategy.
- **PID tuning:** The starting Kp=2.0 and Ti=30s are typical for a small water system. Actual tuning depends heavily on the pipe volume, pump curve, and consumer demand profile.

---

## 1۱. Extension Ideas for Portfolio

| Extension | New Skills |
|---|---|
| Add pH or chlorine dosing pump | Second PID loop, ratio control |
| PROFIBUS/PROFINET VFD integration | Network communication, VFD drive profile |
| SMS/email alarm via IoT gateway | Node-RED or Ewon Cosy connectivity |
| Scheduled night/day setpoint change | RTC (RD_SYS_T), setpoint scheduling |
| Energy consumption calculation | Power = V × I, kWh counter |

---


# Project 02 — Tank Level Control with Pump and Valves

**PLC:** Siemens S7-1200 CPU 1214C DC/DC/DC  
**Software:** TIA Portal V17+  
**Language:** Ladder Logic (LAD)  
**Difficulty:** ⭐⭐⭐ Intermediate

---

## Project Overview

This project was first developed and tested in **OpenPLC Editor** using Ladder Logic.  
The purpose of this approach was to build and verify the control logic in an open-source PLC environment before converting the same logic to **Siemens TIA Portal** for an S7-1200 PLC.

The program controls a process tank using:

- One fill pump
- One fill solenoid valve
- One drain solenoid valve
- Four discrete level sensors
- Emergency stop and fault reset functions
- Auto and manual operating modes
- Dry-run, overflow, fill timeout, and drain timeout protection

The logic was written network by network, using memory bits, timers, Set/Reset coils, and interlocks. After testing in OpenPLC, the same structure can be recreated in TIA Portal with Siemens tags, TON timers, and LAD networks.

---

## 1. System Description

A stainless-steel process tank stores water (or chemical) for a downstream process. The system automatically maintains the tank level between a LOW and HIGH setpoint using a fill pump and a solenoid fill valve. A drain valve allows controlled emptying. Four discrete level sensors (float switches or point level probes) detect: Low-Low (empty), Low, High, and High-High (overflow) levels.

**Operating Modes:**
- **Auto:** Fill pump and valve activate when level drops to LOW. Stop when HIGH is reached.
- **Manual:** Operator controls pump and valves individually via HMI buttons.
- **Drain:** Opens drain valve to empty tank (manual command only).

**Safety:** On High-High level (overflow), all fill outputs immediately cut off and an alarm activates.

---

## 2. Input / Output List

### Digital Inputs

| OpenPLC Address | Siemens Address | Tag Name | Description |
|---|---|---|---|
| %IX0.0 | I0.0 | `PB_EStop` | Emergency Stop NC |
| %IX0.1 | I0.1 | `PB_FaultReset` | Fault reset push button NO |
| %IX0.2 | I0.2 | `SW_ModeAuto` | Auto/Manual selector |
| %IX0.3 | I0.3 | `LS_LowLow` | Low-Low level switch |
| %IX0.4 | I0.4 | `LS_Low` | Low level switch |
| %IX0.5 | I0.5 | `LS_High` | High level switch |
| %IX0.6 | I0.6 | `LS_HighHigh` | High-High overflow switch |
| %IX0.7 | I0.7 | `PB_ManDrain` | Manual drain push button |

### Digital Outputs

| OpenPLC Address | Siemens Address | Tag Name | Description |
|---|---|---|---|
| %QX0.0 | Q0.0 | `MP1_FillPump` | Fill pump contactor |
| %QX0.1 | Q0.1 | `SV1_FillValve` | Fill solenoid valve |
| %QX0.2 | Q0.2 | `SV2_DrainValve` | Drain solenoid valve |
| %QX0.3 | Q0.3 | `HL1_RunLamp` | Fill running indicator |
| %QX0.4 | Q0.4 | `HL2_AlarmLamp` | Alarm lamp |
| %QX0.5 | Q0.5 | `HL3_DrainLamp` | Drain indicator |

### Memory Bits

| OpenPLC Address | Siemens Address | Tag Name | Description |
|---|---|---|---|
| %MX0.0 | M0.0 | `MR_MasterEnable` | Master enable |
| %MX0.1 | M0.1 | `MR_FaultOverflow` | Overflow fault |
| %MX0.2 | M0.2 | `MR_FaultDryRun` | Dry-run fault |
| %MX0.3 | M0.3 | `MR_FaultAny` | Combined fault |
| %MX0.4 | M0.4 | `MR_AutoMode` | Auto mode active |
| %MX0.5 | M0.5 | `MR_ManualMode` | Manual mode active |
| %MX0.6 | M0.6 | `MR_FillActive` | Fill cycle active |
| %MX0.7 | M0.7 | `MR_DrainActive` | Drain cycle active |
| %MX1.0 | M1.0 | `MR_TankEmpty` | Tank empty flag |
| %MX1.1 | M1.1 | `MR_TankFull` | Tank full flag |
| %MX1.2 | M1.2 | `MR_FaultFillTimeout` | Fill timeout fault |
| %MX1.3 | M1.3 | `MR_FaultDrainTimeout` | Drain timeout fault |

### Timers and Time Variables

| Tag Name | Data Type | Value | Description |
|---|---|---|---|
| `TON_DryRunDelay` | TON | — | Dry-run timer |
| `TON_FillTimeout` | TON | — | Fill watchdog timer |
| `TON_DrainTimeout` | TON | — | Drain watchdog timer |
| `DryRunTime` | TIME | T#5s | Dry-run delay time |
| `FillTimeoutTime` | TIME | T#120s | Fill timeout time |
| `DrainTimeoutTime` | TIME | T#180s | Drain timeout time |

## OpenPLC Variable Definition

In OpenPLC Editor, the variables can be defined like this:

  PB_EStop AT %IX0.0 : BOOL;
  PB_FaultReset AT %IX0.1 : BOOL;
  SW_ModeAuto AT %IX0.2 : BOOL;
  LS_LowLow AT %IX0.3 : BOOL;
  LS_Low AT %IX0.4 : BOOL;
  LS_High AT %IX0.5 : BOOL;
  LS_HighHigh AT %IX0.6 : BOOL;
  PB_ManDrain AT %IX0.7 : BOOL;

  MP1_FillPump AT %QX0.0 : BOOL;
  SV1_FillValve AT %QX0.1 : BOOL;
  SV2_DrainValve AT %QX0.2 : BOOL;
  HL1_RunLamp AT %QX0.3 : BOOL;
  HL2_AlarmLamp AT %QX0.4 : BOOL;
  HL3_DrainLamp AT %QX0.5 : BOOL;

  MR_MasterEnable AT %MX0.0 : BOOL;
  MR_FaultOverflow AT %MX0.1 : BOOL;
  MR_FaultDryRun AT %MX0.2 : BOOL;
  MR_FaultAny AT %MX0.3 : BOOL;
  MR_AutoMode AT %MX0.4 : BOOL;
  MR_ManualMode AT %MX0.5 : BOOL;
  MR_FillActive AT %MX0.6 : BOOL;
  MR_DrainActive AT %MX0.7 : BOOL;

  MR_TankEmpty AT %MX1.0 : BOOL;
  MR_TankFull AT %MX1.1 : BOOL;
  MR_FaultFillTimeout AT %MX1.2 : BOOL;
  MR_FaultDrainTimeout AT %MX1.3 : BOOL;

  TON_DryRunDelay : TON;
  TON_FillTimeout : TON;
  TON_DrainTimeout : TON;

  DryRunTime : TIME := T#5s;
  FillTimeoutTime : TIME := T#120s;
  DrainTimeoutTime : TIME := T#180s;

---

## 4. Ladder Logic — Network by Network

---------
Network 1 — Emergency Stop / Master Enable

This network creates the main permission bit for the system.

MR_MasterEnable becomes active only when the Emergency Stop is healthy and there is no active fault. Since PB_EStop is physically wired as NC, the PLC input is TRUE during normal operation and FALSE when the E-Stop is pressed.
---------

Network 2 — Level Status Flags

This network converts raw level sensor signals into easier internal status flags.

MR_TankEmpty becomes TRUE when the Low-Low sensor is not active, meaning the tank is below the Low-Low level.

MR_TankFull becomes TRUE when the High level sensor is active, meaning the tank has reached the full level.
---------

Network 3 — Fault Detection

This network detects and stores all fault conditions.

The overflow fault is latched when the High-High sensor becomes active. It can only be reset when the High-High sensor is clear and the reset button is pressed.

The dry-run fault is detected using a 5-second timer. If the fill pump is running while the Low-Low sensor remains inactive, the timer finishes and the dry-run fault is latched.

The fill timeout fault is detected if the tank does not reach the High level within the preset fill time.

The drain timeout fault is detected if the tank does not become empty within the preset drain time.

All fault bits are combined into MR_FaultAny, which is used to stop the system and activate the alarm.
---------

Network 4 — Mode Selection

This network selects the operating mode.

If the selector switch is in Auto position and the system is enabled, MR_AutoMode becomes active.

If the selector switch is not in Auto position and the system is enabled, MR_ManualMode becomes active.
---------

Network 5 — Auto Fill Control

This network controls the automatic filling cycle.

In Auto mode, the fill cycle starts when the tank level drops below the Low level, the tank is not full, and drain is not active.

The fill cycle stops when the tank reaches the High level, when any fault occurs, when the master enable is lost, or when the fill timeout timer finishes.
---------

Network 6 — Manual Drain Control

This network controls the manual drain operation.

Drain can start only in Manual mode, when the drain push button is pressed, the tank is not empty, and fill is not active.

Drain stops when the tank becomes empty, when the drain push button is released, when any fault occurs, when master enable is lost, or when the drain timeout timer finishes.
---------

Network 7 — Physical Output Control

This network controls the real outputs.

The fill pump and fill valve turn ON only when master enable is active, fill is active, and drain is not active.

The drain valve turns ON only when master enable is active, drain is active, and fill is not active.

This prevents filling and draining at the same time.
---------

Network 8 — Indicators

This network controls the indicator lamps.

The green run lamp turns ON when the fill pump is running.

The yellow drain lamp turns ON when the drain valve is open.
---------

The red alarm lamp turns ON when any fault is active. In this OpenPLC version, the alarm lamp is steady ON, not flashing.
  Note: M200.4 = built-in 1Hz clock. Enable System Memory Byte
        in PLC properties → Hardware Configuration → PLC → System
        and Clock Memory → enable, set byte to MB200.
```

---

## 5. I/O Mapping Table

| Terminal | Field Device | Notes |
|---|---|---|
| I0.0 | E-Stop (NC) | Wired NC — fail-safe |
| I0.1 | Fault Reset (NO) | Flush panel button |
| I0.2 | Auto/Manual Switch | Key switch recommended |
| I0.3 | LS_LowLow float switch | Bottom of tank |
| I0.4 | LS_Low float switch | 20% level |
| I0.5 | LS_High float switch | 80% level |
| I0.6 | LS_HighHigh float switch | 95% level (overflow) |
| I0.7 | Manual drain button | Panel pushbutton |
| Q0.0 | Fill pump contactor | 24VDC coil |
| Q0.1 | Fill solenoid valve | 24VDC coil, spring return |
| Q0.2 | Drain solenoid valve | 24VDC coil, spring return |

---

## 6. HMI Tags

| HMI Tag | PLC Tag | Type | Access | Screen |
|---|---|---|---|---|
| `HMI_LevelLowLow` | `LS_LowLow` | Bool | Read | Tank overview |
| `HMI_LevelLow` | `LS_Low` | Bool | Read | Tank overview |
| `HMI_LevelHigh` | `LS_High` | Bool | Read | Tank overview |
| `HMI_LevelHighHigh` | `LS_HighHigh` | Bool | Read | Tank overview |
| `HMI_FillPumpRunning` | `MP1_FillPump` | Bool | Read | Status panel |
| `HMI_FillValveOpen` | `SV1_FillValve` | Bool | Read | Status panel |
| `HMI_DrainValveOpen` | `SV2_DrainValve` | Bool | Read | Status panel |
| `HMI_FaultOverflow` | `MR_FaultOverflow` | Bool | Read | Alarm screen |
| `HMI_FaultDryRun` | `MR_FaultDryRun` | Bool | Read | Alarm screen |
| `HMI_AutoMode` | `MR_AutoMode` | Bool | Read | Mode display |
| `HMI_Btn_Reset` | `MX_HMI_Reset` | Bool | Write | Alarm screen |
| `HMI_Btn_ManDrain` | `MX_HMI_Drain` | Bool | Write | Manual panel |
| `HMI_Btn_ManFill` | `MX_HMI_Fill` | Bool | Write | Manual panel |

---

## 7. Alarms

| # | Tag | Message | Priority |
|---|---|---|---|
| A001 | `MR_FaultOverflow` | OVERFLOW — High-High level reached. Fill stopped. | Critical |
| A002 | `MR_FaultDryRun` | DRY RUN — Pump running but no level rise. Check supply. | High |
| A003 | `TON_FillTimeout.Q` | FILL TIMEOUT — Tank did not reach HIGH in 120s | High |
| A004 | `TON_DrainTimeout.Q` | DRAIN TIMEOUT — Tank did not empty in 180s | Medium |
| A005 | `MR_TankEmpty` | TANK EMPTY — Low-Low level reached | Medium |
| A006 | `PB_EStop` | EMERGENCY STOP ACTIVE | Critical |

---

## 8. Test Scenarios

### Test 1 — Auto Fill Cycle
1. Set SW_ModeAuto = TRUE
2. Force LS_Low = FALSE, LS_High = FALSE (tank low)
3. ✅ Expected: Fill pump and valve activate (MR_FillActive = TRUE)
4. Force LS_High = TRUE (tank full)
5. ✅ Expected: Pump and valve de-activate

### Test 2 — Overflow Protection
1. During Auto fill, force LS_HighHigh = TRUE
2. ✅ Expected: MR_FaultOverflow latches, fill stops immediately, alarm lamp flashes
3. Force LS_HighHigh = FALSE, press FaultReset
4. ✅ Expected: Fault clears, system returns to normal

### Test 3 — Manual Drain
1. Set SW_ModeAuto = FALSE (Manual mode)
2. Tank has level (LS_Low = TRUE)
3. Press PB_ManDrain
4. ✅ Expected: Drain valve opens, run lamp for drain ON
5. When LS_LowLow fires (empty), drain stops automatically

### Test 4 — Dry-Run Fault
1. Pump running in auto mode, LS_LowLow remains FALSE for 5 seconds
2. ✅ Expected: MR_FaultDryRun = TRUE, pump stops, alarm

### Test 5 — Fill/Drain Interlock
1. Manually activate MR_FillActive
2. Try to activate MR_DrainActive simultaneously
3. ✅ Expected: The NC interlock contact blocks simultaneous operation

---

## 9. Safety Notes and Limitations

- **This is a discrete level system.** A real process plant typically uses a 4–20mA level transmitter with analog PID control. This project uses discrete float switches for simplicity.
- **Solenoid valves are fail-closed (spring return).** Power loss = valve closes. This is the safe state for a fill valve.
- **The drain valve must also be fail-safe.** Depending on the application, fail-open or fail-closed must be specified at design time.
- **Chemical compatibility:** Level switches and valve materials must be rated for the process fluid.
- **No SIL/Safety PLC** is implemented here. For chemical or high-pressure systems, a dedicated Safety Instrumented System is required.

---


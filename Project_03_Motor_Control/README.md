# Project 03 — Three-Phase Motor Control with Fault Detection and HMI

**PLC:** Siemens S7-1200 CPU 1214C DC/DC/DC  
**Software:** TIA Portal V17+  
**Language:** Ladder Logic (LAD)  
**Difficulty:** ⭐⭐⭐ Intermediate

---
##  Project Overview

This project implements a **three-phase motor control system with Star-Delta starting method**.

The program was first designed and tested using **OpenPLC Editor** to build and verify the control logic in a simple and flexible environment.

After validation, the same logic can be transferred to **Siemens TIA Portal** for real industrial PLC hardware.

---

## 1. System Description

A Direct-On-Line (DOL) 3-phase induction motor starter panel for an industrial fan or pump application. The motor is controlled by a main contactor (KM1) and protected by a thermal overload relay (F2). The system includes a star-delta (Y/Δ) soft-start timer to reduce inrush current: the motor starts in star (Y) configuration for 5 seconds, then switches to delta (Δ) for full-speed operation.

The control panel has a physical Start/Stop push station and an HMI (KTP700) for remote control and status monitoring. An Auto mode allows the motor to be started remotely from the HMI or from a process signal.

**Safety:** E-Stop, overload relay feedback, phase loss detection flag, and thermal fault — all result in a latched fault that requires manual reset.

---

## 2. Input / Output List

### Digital Inputs

| Address | Tag Name | Description |
|---------|----------|-------------|
| I0.0 | `PB_EStop` | Emergency Stop (NC) |
| I0.1 | `PB_Stop` | Stop push button (NC) |
| I0.2 | `PB_Start` | Start push button (NO) |
| I0.3 | `PB_FaultReset` | Fault Reset push button (NO) |
| I0.4 | `SW_ModeAuto` | Auto/Manual selector (ON = Auto) |
| I0.5 | `F2_Overload` | Thermal overload relay contact (NC) |
| I0.6 | `KM1_Feedback` | KM1 contactor auxiliary contact (NO) |
| I0.7 | `KM_Star_Feedback` | Star contactor auxiliary contact (NO) |
| I1.0 | `KM_Delta_Feedback` | Delta contactor auxiliary contact (NO) |
| I1.1 | `SEN_HighTemp` | Motor winding temperature sensor (NO) |

### Digital Outputs

| Address | Tag Name | Description |
|---------|----------|-------------|
| Q0.0 | `KM1_MainContactor` | Main motor contactor coil |
| Q0.1 | `KM_Star` | Star (Y) contactor coil |
| Q0.2 | `KM_Delta` | Delta (Δ) contactor coil |
| Q0.3 | `HL1_RunLamp` | Green — motor running indicator |
| Q0.4 | `HL2_StopLamp` | Red — motor stopped indicator |
| Q0.5 | `HL3_AlarmLamp` | Amber — fault/alarm indicator (flashing) |
| Q0.6 | `HL4_StarLamp` | White — star mode indicator |
| Q0.7 | `HL5_DeltaLamp` | Blue — delta mode indicator |

### Memory Bits

| Address | Tag Name | Description |
|---------|----------|-------------|
| M0.0 | `MR_MasterEnable` | Master enable (safety gate) |
| M0.1 | `MR_FaultOverload` | Overload fault flag |
| M0.2 | `MR_FaultHighTemp` | High temperature fault flag |
| M0.3 | `MR_FaultContactor` | Contactor feedback mismatch fault |
| M0.4 | `MR_FaultAny` | Combined fault flag |
| M0.5 | `MR_RunLatch` | Run self-hold latch |
| M0.6 | `MR_AutoMode` | Auto mode active |
| M0.7 | `MR_ManualMode` | Manual mode active |
| M1.0 | `MR_StarActive` | Star (Y) mode active |
| M1.1 | `MR_DeltaActive` | Delta (Δ) mode active |
| M1.2 | `MR_AutoStartCmd` | Auto mode start command (from HMI/process) |
| MW10 | `MW_RunHours_Lo` | Run hour counter low word |
| MW12 | `MW_StartCounter` | Start event counter |

### Timers

| Address | Tag Name | Description |
|---------|----------|-------------|
| DB1 | `TON_StarDelta` | Star-to-delta transition timer (T#5S) |
| DB2 | `TON_FbkDelay` | Contactor feedback verification delay (T#500ms) |
| DB3 | `TON_TransDelay` | Star/Delta transition overlap delay (T#200ms) |

---

## 3. Tag List (TIA Portal Format)

```
Input Tags

PB_EStop             BOOL    %IX0.0    Emergency Stop NC
PB_Stop              BOOL    %IX0.1    Stop push button NC
PB_Start             BOOL    %IX0.2    Start push button NO
PB_FaultReset        BOOL    %IX0.3    Fault reset NO
SW_ModeAuto          BOOL    %IX0.4    Auto/Manual selector
F2_Overload          BOOL    %IX0.5    Overload relay NC
KM1_Feedback         BOOL    %IX0.6    Main contactor feedback NO
KM_Star_Feedback     BOOL    %IX0.7    Star contactor feedback NO
KM_Delta_Feedback    BOOL    %IX1.0    Delta contactor feedback NO
SEN_HighTemp         BOOL    %IX1.1    Motor high temperature sensor NO

Output Tags

KM1_MainContactor    BOOL    %QX0.0    Main contactor coil
KM_Star              BOOL    %QX0.1    Star contactor coil
KM_Delta             BOOL    %QX0.2    Delta contactor coil
HL1_RunLamp          BOOL    %QX0.3    Run lamp
HL2_StopLamp         BOOL    %QX0.4    Stop lamp
HL3_AlarmLamp        BOOL    %QX0.5    Alarm lamp
HL4_StarLamp         BOOL    %QX0.6    Star mode lamp
HL5_DeltaLamp        BOOL    %QX0.7    Delta mode lamp

Memory Tags

MR_MasterEnable      BOOL    %MX0.0    Master enable
MR_FaultOverload     BOOL    %MX0.1    Overload fault
MR_FaultHighTemp     BOOL    %MX0.2    High temperature fault
MR_FaultContactor    BOOL    %MX0.3    Contactor feedback fault
MR_FaultAny          BOOL    %MX0.4    Combined fault
MR_RunLatch          BOOL    %MX0.5    Motor run latch
MR_AutoMode          BOOL    %MX0.6    Auto mode active
MR_ManualMode        BOOL    %MX0.7    Manual mode active
MR_StarActive        BOOL    %MX1.0    Star mode active
MR_DeltaActive       BOOL    %MX1.1    Delta mode active
MR_AutoStartCmd      BOOL    %MX1.2    Auto start command from HMI/process

Timer Tags

TON_StarDelta        TON               Star-to-delta timer
TON_FbkDelay         TON               Feedback check timer
TON_TransDelay       TON               Star-to-delta transition delay

Time Variables

StarDeltaTime        TIME    T#5s      Star running time
FbkDelayTime         TIME    T#500ms   Contactor feedback delay
TransDelayTime       TIME    T#200ms   Delay before Delta starts```

OpenPLC address conversion:

%IX0.0  becomes  I0.0
%IX1.0  becomes  I1.0
%QX0.0  becomes  Q0.0
%MX0.0  becomes  M0.0
%MX1.0  becomes  M1.0

For example:

PB_EStop in OpenPLC is %IX0.0
PB_EStop in Siemens is I0.0

KM1_MainContactor in OpenPLC is %QX0.0
KM1_MainContactor in Siemens is Q0.0

MR_RunLatch in OpenPLC is %MX0.5
MR_RunLatch in Siemens is M0.5

Timer Conversion to Siemens

In OpenPLC, timers are defined as TON variables.

In Siemens TIA Portal, use IEC TON timer blocks. Each timer should have its own instance DB.

Example:

TON_StarDelta    DB1    PT = T#5s
TON_FbkDelay     DB2    PT = T#500ms
TON_TransDelay   DB3    PT = T#200ms

---

## 4. Ladder Logic — Network by Network

---
Network 1 — Master Enable

This network creates the main permission for the motor control system.

MR_MasterEnable turns ON only when:
PB_EStop is healthy, F2_Overload is healthy, and no fault is active.

Because PB_EStop and F2_Overload are NC devices, their PLC inputs are TRUE in normal condition.

Network 2 — Fault Detection

This network detects and stores all motor faults.

If F2_Overload opens, MR_FaultOverload turns ON.
If SEN_HighTemp turns ON, MR_FaultHighTemp turns ON.
If KM1_MainContactor is ON but KM1_Feedback does not turn ON within 500 ms, MR_FaultContactor turns ON.

All faults are combined into MR_FaultAny.

Network 3 — Mode Selection

This network selects Auto or Manual mode.

If SW_ModeAuto is ON and MR_MasterEnable is ON, MR_AutoMode turns ON.
If SW_ModeAuto is OFF and MR_MasterEnable is ON, MR_ManualMode turns ON.

Network 4 — Run Latch

This network starts and stops the motor command.

In Manual mode, pressing PB_Start sets MR_RunLatch.
In Auto mode, MR_AutoStartCmd sets MR_RunLatch.

MR_RunLatch resets when:
PB_Stop is pressed, any fault occurs, or MR_MasterEnable turns OFF.

Network 5 — Star-Delta Logic

This network controls the Star-Delta sequence.

When KM1_MainContactor turns ON, TON_StarDelta starts.
Before the 5-second timer finishes, MR_StarActive is ON.
After 5 seconds, Star turns OFF.
Then TON_TransDelay waits 200 ms.
After 200 ms, MR_DeltaActive turns ON.

The sequence is:

Start → Star for 5 seconds → 200 ms delay → Delta

Network 6 — Output Control

This network controls the real PLC outputs.

KM1_MainContactor turns ON when MR_MasterEnable and MR_RunLatch are ON.
KM_Star turns ON when MR_StarActive is ON and KM_Delta is OFF.
KM_Delta turns ON when MR_DeltaActive is ON and KM_Star is OFF.

This prevents Star and Delta from turning ON at the same time.

Network 7 — Indicator Lamps

This network controls the lamps.

HL1_RunLamp turns ON when KM1_MainContactor is ON.
HL2_StopLamp turns ON when KM1_MainContactor is OFF.
HL3_AlarmLamp turns ON when MR_FaultAny is ON.
HL4_StarLamp turns ON when KM_Star is ON.
HL5_DeltaLamp turns ON when KM_Delta is ON.


  Note: Using rising edge (P_TRIG) prevents the command bit from
        holding the motor on permanently if the HMI operator forgets
        to release the button or the HMI communication is interrupted.
```

---

## 5. I/O Mapping Table

| Terminal | Field Device | Note |
|---|---|---|
| I0.0 | E-Stop button (NC) | Panel or remote E-Stop |
| I0.1 | Stop button (NC) | Fail-safe wiring |
| I0.2 | Start button (NO) | |
| I0.3 | Fault Reset (NO) | |
| I0.4 | Auto/Manual selector | Key switch recommended |
| I0.5 | F2 Overload relay (NC) | Bimetal/electronic overload |
| I0.6 | KM1 Auxiliary contact (NO) | Main contactor verification |
| I0.7 | KM_Star Auxiliary (NO) | Star contactor verification |
| I1.0 | KM_Delta Auxiliary (NO) | Delta contactor verification |
| I1.1 | Winding temp sensor (NO) | PTC thermistor + relay |
| Q0.0 | KM1 Main contactor coil | 24VDC coil |
| Q0.1 | KM_Star contactor coil | 24VDC coil |
| Q0.2 | KM_Delta contactor coil | 24VDC coil |

---

## 6. HMI Tags

| HMI Tag | PLC Tag | Type | Screen |
|---|---|---|---|
| `HMI_MotorRunning` | `KM1_MainContactor` | Bool | Overview |
| `HMI_StarMode` | `KM_Star` | Bool | Status |
| `HMI_DeltaMode` | `KM_Delta` | Bool | Status |
| `HMI_FaultOverload` | `MR_FaultOverload` | Bool | Alarms |
| `HMI_FaultTemp` | `MR_FaultHighTemp` | Bool | Alarms |
| `HMI_FaultContactor` | `MR_FaultContactor` | Bool | Alarms |
| `HMI_AutoMode` | `MR_AutoMode` | Bool | Overview |
| `HMI_RunHours` | `MW_RunHours_Lo` | Word | Maintenance |
| `HMI_StartCount` | `MW_StartCounter` | Word | Maintenance |
| `HMI_Btn_Start` | `MR_AutoStartCmd` | Bool (Write) | Control |
| `HMI_Btn_Stop` | `MX_HMI_Stop` | Bool (Write) | Control |
| `HMI_Btn_Reset` | `MX_HMI_Reset` | Bool (Write) | Alarms |

---

## 7. Alarms

| # | Tag | Message | Priority |
|---|---|---|---|
| A001 | `MR_FaultOverload` | MOTOR OVERLOAD TRIP — Check motor and overload relay | Critical |
| A002 | `MR_FaultHighTemp` | MOTOR WINDING HIGH TEMPERATURE — Allow to cool | Critical |
| A003 | `MR_FaultContactor` | CONTACTOR FEEDBACK FAULT — Check KM1 wiring | High |
| A004 | `PB_EStop` | EMERGENCY STOP ACTIVE | Critical |
| A005 | `TON_StarDelta.Q` | Star-to-Delta transition completed | Info |
| A006 | `MR_DeltaActive` rising | Motor now in Delta (full speed) | Info |

---

## 8. Test Scenarios

### Test 1 — Manual DOL Start (without Star-Delta)
> To test basic start/stop first, bypass Star-Delta by setting MR_StarActive = FALSE manually
1. Set SW_ModeAuto = FALSE
2. Press PB_Start → KM1 energizes, run lamp ON ✅
3. Press PB_Stop → KM1 de-energizes ✅

### Test 2 — Star-Delta Sequence
1. Start motor in Manual mode
2. ✅ T=0s: KM1 ON, KM_Star ON, KM_Delta OFF (Star mode lamp ON)
3. ✅ T=5s: TON_StarDelta fires, KM_Star drops out
4. ✅ T=5.2s: TON_TransDelay fires, KM_Delta picks up (Delta lamp ON)
5. Motor now running at full speed in Delta

### Test 3 — Overload Fault
1. Motor running in Delta
2. Force F2_Overload = FALSE (simulate trip)
3. ✅ Expected: KM1 de-energizes, MR_FaultOverload latches, alarm flashes
4. Reset overload relay (I0.5 = TRUE), press FaultReset ✅

### Test 4 — Contactor Feedback Mismatch
1. Motor commanded to start (KM1 output = TRUE)
2. Keep KM1_Feedback = FALSE (simulate stuck contactor)
3. Wait 500ms
4. ✅ Expected: TON_FbkDelay fires, MR_FaultContactor latches

### Test 5 — HMI Auto Start
1. Set SW_ModeAuto = TRUE
2. From HMI, set MR_AutoStartCmd = TRUE
3. ✅ Expected: MR_RunLatch sets, motor starts, auto command clears
4. Press HMI Stop → MR_RunLatch resets, motor stops

---

## 9. Safety Notes and Limitations

- **Star-Delta timing:** The 200ms transition delay is a minimum. Industrial standards recommend 300ms–500ms. Adjust TON_TransDelay.PT based on contactor dropout time specifications.
- **Simultaneous Star-Delta contact:** If both star and delta contactors close simultaneously, a phase-to-phase fault occurs. The NC hardware auxiliary interlock in the panel is NON-NEGOTIABLE. The software interlock is secondary.
- **Overload relay manual reset:** This project assumes the overload relay requires manual reset (standard). If using automatic reset overloads, remove the F2_Overload NO contact from the RESET rung — the PLC cannot confirm motor thermal state.
- **Contactor feedback:** This is a professional feature often omitted in beginner projects. Including it demonstrates real industry knowledge.

---

## 10. Industrial Notes

This project is suitable for learning, simulation, and portfolio work.For real industrial use:E-Stop must be hardwired in a safety circuit.Overload should directly interrupt the contactor control circuit.Star and Delta contactors must have mechanical and electrical interlocks.The PLC software interlock is not enough by itself.Motor protection devices, fuses, phase protection, grounding, and proper wiring are required.

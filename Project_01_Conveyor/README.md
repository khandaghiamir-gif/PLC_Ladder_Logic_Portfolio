# Project 01 — Conveyor Start/Stop with Sensors

**PLC:** Siemens S7-1200 CPU 1214C DC/DC/DC  
**Software:** TIA Portal V17+  
**Language:** Ladder Logic (LAD)  
**Difficulty:** ⭐⭐ Beginner–Intermediate

---

## Project Note

This project was implemented using **OpenPLC Editor**, which is a free and open-source PLC programming environment.  
The original control logic is compatible with standard PLC ladder logic concepts, but the addressing and timer handling are written for OpenPLC.

This version is suitable for learning, simulation, and portfolio demonstration without requiring licensed PLC software such as Siemens TIA Portal.

---
---

## 1. System Description

A single-zone industrial belt conveyor transports packages from a loading station to an unloading station. The conveyor belt is driven by a 3-phase motor via a contactor. A photo-electric sensor at the entry detects incoming packages. A second sensor at the exit confirms delivery. A jam detection sensor monitors belt tension. The system supports Auto and Manual operating modes, a fault reset button, an Emergency Stop, and an alarm lamp.

**Operating Modes:**
- **Manual:** Operator holds RUN button to run conveyor. Releases = stop.
- **Auto:** Conveyor runs automatically when the entry sensor detects a package. Stops when exit sensor confirms delivery or after a timeout.

---

## 2. Input / Output List

### Digital Inputs

| Address | Tag Name | Description |
|---------|----------|-------------|
| I0.0 | `PB_Start` | Green START push button (NO) |
| I0.1 | `PB_Stop` | Red STOP push button (NC) |
| I0.2 | `PB_EStop` | Emergency Stop mushroom button (NC) |
| I0.3 | `PB_FaultReset` | Fault Reset push button (NO) |
| I0.4 | `SW_ModeAuto` | Auto/Manual selector switch (ON = Auto) |
| I0.5 | `SEN_Entry` | Entry photo-electric sensor — package present (NO) |
| I0.6 | `SEN_Exit` | Exit photo-electric sensor — package arrived (NO) |
| I0.7 | `SEN_Jam` | Belt jam detection sensor (NC — opens on jam) |

### Digital Outputs

| Address | Tag Name | Description |
|---------|----------|-------------|
| Q0.0 | `KM1_ConveyorMotor` | Motor contactor coil — conveyor belt |
| Q0.1 | `HL1_RunLamp` | Green run indicator lamp |
| Q0.2 | `HL2_AlarmLamp` | Red alarm/fault lamp |
| Q0.3 | `HL3_AutoLamp` | White Auto mode indicator lamp |

### Memory Bits (Internal Flags)

| Address | Tag Name | Description |
|---------|----------|-------------|
| M0.0 | `MR_MasterEnable` | Master Control Relay (safety enable) |
| M0.1 | `MR_RunLatch` | Run latch (self-holding bit) |
| M0.2 | `MR_FaultActive` | Fault active flag |
| M0.3 | `MR_AutoMode` | Auto mode active flag |
| M0.4 | `MR_ManualMode` | Manual mode active flag |
| M0.5 | `MR_AutoRunCmd` | Auto mode run command |
| M1.0 | `MR_EStopAck` | E-Stop acknowledged flag |

### Timers

| Address | Tag Name | Description |
|---------|----------|-------------|
| DB1 | `TON_JamDelay` | Jam detection delay timer (T#3S) |
| DB2 | `TON_AutoTimeout` | Auto mode delivery timeout (T#15S) |

---


## 3.OpenPLC Addressing

In OpenPLC, physical inputs and outputs use IEC-style addressing:

| Device Type | Siemens Style | OpenPLC Style |
|---|---|---|
| Digital Input | I0.0 | %IX0.0 |
| Digital Output | Q0.0 | %QX0.0 |
| Internal Memory | M0.0 | Local BOOL variable |
| Timer DB | DB Timer | TON Function Block |
| Time Preset | T#3S | TIME variable or T#3s |

---

## OpenPLC Variable Table

### Digital Inputs

| Name | Type | Location |
|---|---|---|
| PB_Start | BOOL | %IX0.0 |
| PB_Stop | BOOL | %IX0.1 |
| PB_EStop | BOOL | %IX0.2 |
| PB_FaultReset | BOOL | %IX0.3 |
| SW_ModeAuto | BOOL | %IX0.4 |
| SEN_Entry | BOOL | %IX0.5 |
| SEN_Exit | BOOL | %IX0.6 |
| SEN_Jam | BOOL | %IX0.7 |

### Digital Outputs

| Name | Type | Location |
|---|---|---|
| KM1_ConveyorMotor | BOOL | %QX0.0 |
| HL1_RunLamp | BOOL | %QX0.1 |
| HL2_AlarmLamp | BOOL | %QX0.2 |
| HL3_AutoLamp | BOOL | %QX0.3 |

### Internal Variables

| Name | Type | Location |
|---|---|---|
| MR_MasterEnable | BOOL | Empty |
| MR_RunLatch | BOOL | Empty |
| MR_FaultActive | BOOL | Empty |
| MR_AutoMode | BOOL | Empty |
| MR_ManualMode | BOOL | Empty |
| MR_AutoRunCmd | BOOL | Empty |

### Timers and Time Presets

| Name | Type | Location | Initial Value |
|---|---|---|---|
| TON_JamDelay | TON | Empty | Empty |
| JamDelayTime | TIME | Empty | T#3s |
| TON_AutoTimeout | TON | Empty | Empty |
| AutoTimeoutTime | TIME | Empty | T#15s |

## 4.Notes for Siemens TIA Portal Conversion

To write this same project in Siemens TIA Portal, these changes are required:

1. Replace OpenPLC addresses with Siemens addresses:
   - %IX0.0 → %I0.0
   - %QX0.0 → %Q0.0

2. Internal OpenPLC variables should be mapped to Siemens memory bits:
   - MR_MasterEnable → %M0.0
   - MR_RunLatch → %M0.1
   - MR_FaultActive → %M0.2
   - MR_AutoMode → %M0.3
   - MR_ManualMode → %M0.4
   - MR_AutoRunCmd → %M0.5

3. OpenPLC TON function blocks should be replaced with Siemens TON timers.
   In TIA Portal, each TON timer normally creates an instance DB automatically.

4. OpenPLC TIME variables such as:
   - JamDelayTime = T#3s
   - AutoTimeoutTime = T#15s

   can be entered directly into the TON preset input `PT` in TIA Portal.

---

---

## 5. I/O Mapping Table

| PLC Terminal | Field Device | Wire Color | Voltage | Description |
|---|---|---|---|---|
| I0.0 | Start PB (NO) | Green | 24VDC | Green mushroom pushbutton |
| I0.1 | Stop PB (NC) | Red | 24VDC | Red flush pushbutton |
| I0.2 | E-Stop (NC) | Yellow/Red | 24VDC | Latching mushroom E-Stop |
| I0.3 | Fault Reset (NO) | Blue | 24VDC | Flush pushbutton |
| I0.4 | Mode Selector | Black | 24VDC | Key or standard selector |
| I0.5 | Entry Sensor | Orange | 24VDC | PNP photoelectric, 10–30VDC |
| I0.6 | Exit Sensor | Orange | 24VDC | PNP photoelectric, 10–30VDC |
| I0.7 | Jam Sensor (NC) | White | 24VDC | Limit switch on tensioner |
| Q0.0 | KM1 Contactor | Brown | 24VDC | To coil of motor contactor |
| Q0.1 | Run Lamp | Green | 24VDC | Panel indicator lamp |
| Q0.2 | Alarm Lamp | Red | 24VDC | Panel indicator lamp |
| Q0.3 | Auto Mode Lamp | White | 24VDC | Panel indicator lamp |

---

## 6. HMI Tags (KTP700 Basic)

| HMI Tag | PLC Tag | Data Type | Access | Description |
|---|---|---|---|---|
| `HMI_ConveyorRunning` | `KM1_ConveyorMotor` | Bool | Read | Motor status display |
| `HMI_FaultActive` | `MR_FaultActive` | Bool | Read | Fault indicator on HMI |
| `HMI_AutoMode` | `MR_AutoMode` | Bool | Read | Mode display |
| `HMI_ManualMode` | `MR_ManualMode` | Bool | Read | Mode display |
| `HMI_EStopStatus` | `PB_EStop` | Bool | Read | E-Stop status |
| `HMI_PackagesDelivered` | `MW10` | Word | Read | Package counter (add CTU) |
| `HMI_Btn_Start` | `MX_HMI_Start` | Bool | Write | HMI start button |
| `HMI_Btn_Stop` | `MX_HMI_Stop` | Bool | Write | HMI stop button |
| `HMI_Btn_FaultReset` | `MX_HMI_Reset` | Bool | Write | HMI fault reset |

---

## 6.1 HOW IT WORKS?

## Network 1 — Master Enable

Creates the main safety permission for the system. The conveyor can run only when the Emergency Stop is healthy and no fault is active.

## Network 2 — Jam Fault Detection

Detects a belt jam while the motor is running. If the jam signal stays active for 3 seconds, the fault is latched. The fault can be reset only after the jam is cleared.

## Network 3 — Mode Selection

Selects the operating mode. When the selector is ON, Auto mode is active. When it is OFF, Manual mode is active.

## Network 4 — Manual Run Control

Controls the conveyor in Manual mode. The Start button latches the run command, and the Stop button resets it.

## Network 5 — Auto Run Control

Controls the conveyor in Auto mode. The entry sensor starts the conveyor, and the exit sensor stops it. If the package does not reach the exit within 15 seconds, the auto command is reset.

## Network 6 — Motor Output

Turns on the conveyor motor only when Master Enable is active and either Manual Run or Auto Run command is active.

## Network 7 — Indicator Lamps

Turns on the Run lamp when the motor is running. Turns on the Alarm lamp when a fault is active.


---
## 7. Alarms

| Alarm # | Tag | Message | Priority | Action |
|---|---|---|---|---|
| A001 | `MR_FaultActive` | Belt Jam Detected — Conveyor Stopped | High | Inspect belt, press reset |
| A002 | `PB_EStop` (NC FALSE) | Emergency Stop Active | Critical | Clear E-Stop, reset |
| A003 | `TON_AutoTimeout.Q` | Auto Delivery Timeout — Package Not Detected at Exit | Medium | Check belt/sensors |
| A004 | `SW_ModeAuto` edge | Mode Changed to Auto | Info | Operator notification |
| A005 | `SW_ModeAuto` edge | Mode Changed to Manual | Info | Operator notification |

---

## 8. Test Scenarios

### Test 1 — Normal Manual Start/Stop
1. Set `SW_ModeAuto` = FALSE (Manual mode)
2. Press `PB_Start` → `KM1_ConveyorMotor` should energize, `HL1_RunLamp` ON
3. Press `PB_Stop` → Motor de-energizes, lamp OFF
4. ✅ **Expected:** Clean start and stop, no faults

### Test 2 — Emergency Stop
1. Start conveyor in Manual mode
2. Press `PB_EStop`
3. ✅ **Expected:** Motor immediately de-energizes. `MR_MasterEnable` = FALSE. Conveyor cannot restart until E-Stop is released AND fault (if any) is reset.

### Test 3 — Jam Detection
1. Start conveyor in Manual mode
2. Force `SEN_Jam` = FALSE (simulate jam: sensor opens)
3. Wait 3 seconds
4. ✅ **Expected:** `MR_FaultActive` = TRUE, motor stops, alarm lamp flashes
5. Force `SEN_Jam` = TRUE, press `PB_FaultReset`
6. ✅ **Expected:** Fault clears, conveyor can restart

### Test 4 — Auto Mode Cycle
1. Set `SW_ModeAuto` = TRUE (Auto mode)
2. Force `SEN_Entry` = TRUE (package arrives)
3. ✅ **Expected:** Conveyor starts automatically
4. Force `SEN_Exit` = TRUE (package delivered)
5. ✅ **Expected:** Conveyor stops automatically

### Test 5 — Auto Timeout
1. Auto mode ON, trigger entry sensor
2. Do NOT trigger exit sensor
3. Wait 15 seconds
4. ✅ **Expected:** `TON_AutoTimeout` fires, conveyor stops, alarm A003

---

## 9. Safety Notes and Limitations

- **E-Stop wiring:** The E-Stop must be wired as NC to the PLC input. Never wire E-Stop as NO — a broken wire would fail to stop the machine.
- **Stop button wiring:** The STOP button is also wired NC (fail-safe). A wire break stops the conveyor.
- **This project does NOT implement a Safety PLC (SIL) circuit.** For real installations, the E-Stop loop must be hardwired through a safety relay (e.g., Pilz PNOZ) independently of the PLC.
- **Motor protection:** A real system requires a thermal overload relay (bimetal) in the motor circuit, independently of the PLC.
- **Sensor power:** PNP sensors require separate 24VDC supply. Do not power sensors from PLC terminals.

---

## 10. Simulation Suggestions

**Using S7-PLCSIM (TIA Portal built-in):**
1. Configure simulation in TIA Portal → Download to PLCSIM
2. Open Force Table → manually force I0.5, I0.6 to simulate sensors
3. Use Watch Table to monitor M-bits and Q outputs in real time

**Using Factory I/O:**
1. Install Factory I/O (free 30-day trial)
2. Choose "Conveyor with Sensors" scene
3. Configure Siemens S7-PLCSIM driver in Factory I/O
4. Map Factory I/O signals to I0.5, I0.6, Q0.0 addresses
5. Watch the 3D conveyor respond to your ladder logic

---


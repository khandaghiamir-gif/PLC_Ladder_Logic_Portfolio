# Project 04 — Pneumatic Pick and Place Station with Step Sequencer

**PLC:** Siemens S7-1200 CPU 1214C DC/DC/DC  
**Software:** TIA Portal V17+  
**Language:** Ladder Logic (LAD)  
**Difficulty:** ⭐⭐⭐⭐⭐ Advanced

---

## 1. System Description

A 3-axis pneumatic pick and place station transfers parts from an **input conveyor** to one of two destination positions: a **good parts tray** or a **reject bin**. The station uses four double-acting pneumatic cylinders controlled by 5/2-way solenoid valves (one solenoid to extend, one to retract). An inductive sensor detects metallic (good) parts; non-metallic parts are rejected.

**Axes:**
- **X-Axis:** Horizontal traverse (Home = retracted = over input conveyor, Extended = over trays)
- **Z-Axis:** Vertical (Home = up, Extended = down — pick/place height)
- **Gripper:** Opens / Closes (pneumatic parallel gripper)
- **Reject Pusher:** Single-acting (extend = push part to reject bin)

**Operating principle:**
The system runs a **step-sequenced cycle** using an integer step counter in a Data Block. Each step performs one action and waits for confirmation (sensor or timer) before advancing to the next. This is the industry-standard approach for multi-step pneumatic machines.

**Cycle (Auto Mode):**
1. Wait for part at input (SEN_PartPresent)
2. Read part type (SEN_PartType — inductive = good, no signal = reject)
3. Z-Axis down
4. Gripper close (pick)
5. Z-Axis up
6. X-Axis extend (move to destination)
7. Z-Axis down
8. Gripper open (place)
9. Z-Axis up
10. X-Axis retract (home)
11. If reject: Reject pusher extend, then retract
12. Cycle complete → increment counter → return to Step 1
------

## 1.1. OpenPLC Implementation Notes

In OpenPLC Editor, the following methods were used:

Step variable:
CurrentStep (INT)
Numeric constants must be defined manually:
Zero = 0
One = 1
Two = 2
Three = 3
...
Fifteen = 15
Step transitions are done using MOVE:
MOVE (NextStep → CurrentStep)
Comparison blocks used:
EQ (==)
GE (>=)
LE (<=)
NE (!=)
Timers use variables for preset:
StepTimeoutTime = T#8s
GripDelayTime = T#300ms
RejectHoldTime = T#1s
---

## 1.2. Conversion to Siemens TIA Portal

When converting this project to Siemens TIA Portal:

Numeric variables (Zero, One, etc.) are not needed
Use direct values like 0, 1, 2
MOVE instruction remains the same
Comparison blocks remain the same
Timers are simplified:
PT = T#8s (no need for separate variable)
It is recommended to store step in a Data Block:
Example:
DB10.CurrentStep
------

## 2. Input / Output List


Digital Inputs:

%IX0.0  PB_EStop
%IX0.1  PB_Stop
%IX0.2  PB_Start
%IX0.3  PB_FaultReset
%IX0.4  SW_ModeAuto
%IX0.5  SEN_PartPresent
%IX0.6  SEN_PartType
%IX0.7  SEN_X_Home
%IX1.0  SEN_X_Extended
%IX1.1  SEN_Z_Up
%IX1.2  SEN_Z_Down
%IX1.3  SEN_Grip_Open
%IX1.4  SEN_Grip_Closed
%IX1.5  SEN_Reject_Home
%IX1.6  SEN_Reject_Extended
%IX1.7  SEN_TrayFull

--------------------------------------------------

Digital Outputs:

%QX0.0  SOL_X_Extend
%QX0.1  SOL_X_Retract
%QX0.2  SOL_Z_Down
%QX0.3  SOL_Z_Up
%QX0.4  SOL_Grip_Close
%QX0.5  SOL_Grip_Open
%QX0.6  SOL_Reject_Extend
%QX0.7  HL_RunLamp
%QX1.0  HL_StopLamp
%QX1.1  HL_AlarmLamp
%QX1.2  HL_AutoLamp
%QX1.3  BZ_Beep

--------------------------------------------------

Memory Bits:

%MX0.0  MR_MasterEnable
%MX0.1  MR_CycleActive
%MX0.2  MR_CycleStopReq
%MX0.3  MR_FaultActive
%MX0.4  MR_FaultTimeout
%MX0.5  MR_FaultSensor
%MX0.6  MR_FaultTrayFull
%MX0.7  MR_AutoMode

%MX1.0  MR_ManualMode
%MX1.1  MR_PartIsGood
%MX1.2  MR_PartIsReject
%MX1.3  MR_HomePosition
%MX1.4  MR_StepAdvance
%MX1.5  MR_CycleBeepTrig

--------------------------------------------------

Integer Variables:

CurrentStep      (INT)
PreviousStep     (INT)

--------------------------------------------------

Constants (Required in OpenPLC):

Zero = 0
One = 1
Two = 2
Three = 3
...
Fifteen = 15

--------------------------------------------------

Timers:

TON_StepTimeout   PT = StepTimeoutTime (T#8s)
TON_GripDelay     PT = GripDelayTime (T#300ms)
TON_RejectHold    PT = RejectHoldTime (T#1s)


## 2.1. How to Convert to Siemens TIA Portal

Step 1 — Remove Constants

Delete:
Zero, One, Two, ...

Replace with:
0,1,2,...

--------------------------------------------------

Step 2 — Replace Addressing

OpenPLC → Siemens

%IX0.0 → I0.0
%QX0.0 → Q0.0
%MX0.0 → M0.0

--------------------------------------------------

Step 3 — Move Step to Data Block

Create DB:

DB10.CurrentStep (INT)
DB10.PreviousStep (INT)

Replace everywhere:
CurrentStep → DB10.CurrentStep

--------------------------------------------------

Step 4 — Timers

OpenPLC:
PT = StepTimeoutTime

TIA:
PT = T#8s

Use TON blocks with instance DB

--------------------------------------------------

Step 5 — Comparisons

Same logic:

EQ → ==
GE → >=
LE → <=
NE → !=

Use CMP blocks in TIA

--------------------------------------------------

Step 6 — MOVE

Same instruction:

MOVE 1 → DB10.CurrentStep

--------------------------------------------------

Step 7 — Clock Memory

For blinking alarm:

Enable Clock Memory in PLC:
MB200

Use:
M200.4 for 1Hz

---

## 4. Step Sequencer Design

### The Step Table

The entire pick and place cycle is described as a numbered table. The PLC executes exactly ONE step at a time. Each step has:
- A **condition to enter** (what must be TRUE to stay in this step)
- An **action** (what output to energize)
- An **advance condition** (what must happen to move to the next step)

| Step | Name | Action | Advance Condition |
|------|------|--------|-------------------|
| 0 | IDLE | All off, await start | `MR_CycleActive` = TRUE |
| 1 | WAIT_FOR_PART | None | `SEN_PartPresent` + debounce |
| 2 | READ_PART_TYPE | Latch MR_PartIsGood / MR_PartIsReject | Immediate (1 scan) |
| 3 | CHECK_TRAY | Block if tray full + good part | Immediate or fault |
| 4 | Z_DOWN_PICK | `SOL_Z_Down` ON | `SEN_Z_Down` = TRUE |
| 5 | GRIP_CLOSE | `SOL_Grip_Close` ON | `SEN_Grip_Closed` + TON_GripDelay |
| 6 | Z_UP_WITH_PART | `SOL_Z_Up` ON | `SEN_Z_Up` = TRUE |
| 7 | X_EXTEND | `SOL_X_Extend` ON | `SEN_X_Extended` = TRUE |
| 8 | Z_DOWN_PLACE | `SOL_Z_Down` ON | `SEN_Z_Down` = TRUE |
| 9 | GRIP_OPEN | `SOL_Grip_Open` ON | `SEN_Grip_Open` + TON_GripDelay |
| 10 | Z_UP_EMPTY | `SOL_Z_Up` ON | `SEN_Z_Up` = TRUE |
| 11 | X_RETRACT | `SOL_X_Retract` ON | `SEN_X_Home` = TRUE |
| 12 | REJECT_EXTEND | `SOL_Reject_Extend` ON (if reject) | `SEN_Reject_Extended` = TRUE |
| 13 | REJECT_RETRACT | `SOL_Reject_Extend` OFF | `SEN_Reject_Home` + TON_RejectHold |
| 14 | UPDATE_COUNTERS | Increment cycle counter, good/reject count | Immediate (1 scan) |
| 15 | CYCLE_END | Beep, reset part flags | Return to Step 1 or 0 |

---

## 5. Ladder Logic — Network by Network

---

### Network 1 — Emergency Stop / Master Enable

```
NETWORK 1: MASTER ENABLE
Enable system if no E-Stop and no Fault

  Note: E-Stop NC wired. Fault active blocks master enable.
        Loss of master enable immediately de-energizes ALL outputs
        because every output rung has [MR_MasterEnable] in series.
```

---

### Network 2 — Fault Detection

Detect:
- Step timeout
- Tray full

Set:
MR_FaultActive

```
NETWORK 2A: STEP TIMEOUT WATCHDOG TIMER

NETWORK 2B: TIMEOUT FAULT LATCH

  Note: Also save the current step to DB for diagnostics:
        Use MOVE instruction: EN = TON_StepTimeout.Q
        IN = StepDB.CurrentStep → OUT = StepDB.FaultStep
        (Use a MOVE box in TIA Portal on a separate rung)


NETWORK 2C: TRAY FULL FAULT

NETWORK 2D: COMBINED FAULT FLAG

---

### Network 3 — Mode Selection

```
NETWORK 3: MODE SELECT
---

### Network 4 — Cycle Start/Stop Control
Start:
Auto mode + Home position

Set:
MR_CycleActive

Stop:
Stop button or Fault


```
NETWORK 4A: HOME POSITION CHECK

  Note: All four axes must confirm home before a cycle can start.
        This is a critical safety check — prevents starting mid-cycle.

NETWORK 4B: CYCLE START LATCH

  Note: Cycle can only start in Auto mode AND all axes confirmed home.

NETWORK 4C: CYCLE STOP REQUEST

  Note: PB_Stop is NC. When pressed → I0.1 = FALSE → contact FALSE.
        Use NO contact of I0.1 here (wired NC so pressing = FALSE).
        The stop request does NOT immediately kill the cycle —
        it flags to stop AFTER the current cycle completes at Step 15.

NETWORK 4D: CYCLE STOP ON FAULT OR STEP 15 WITH STOP REQUEST

---

### Network 5 — Step Sequencer (Core of the Program)

**Architecture Note:** The step sequencer uses a COMPARE (CMP ==) instruction to check `StepDB.CurrentStep` against a constant. Each step has its own rung. When the advance condition is met, a MOVE instruction writes the next step number into `StepDB.CurrentStep`.

In TIA Portal Ladder, this is done with a **CMP box** followed by a **MOVE box**.

Core logic:

IF CurrentStep == N AND condition
THEN MOVE (N+1 → CurrentStep)

```
STEP 0 — IDLE

  Note: When cycle starts, jump immediately from Step 0 to Step 1.

STEP 1 — WAIT FOR PART

STEP 2 — READ PART TYPE AND LATCH

STEP 3 — CHECK TRAY AVAILABLE (Good parts only)

STEP 4 — Z-AXIS DOWN (PICK POSITION)
─  Activate Z-Down solenoid (controlled via output rungs, see Network 6):
  This step activates when CurrentStep = 4.

STEP 5 — GRIPPER CLOSE (PICK)

STEP 6 — Z-AXIS UP (LIFT PART)

STEP 7 — X-AXIS EXTEND (MOVE TO DESTINATION)

STEP 8 — Z-AXIS DOWN (PLACE POSITION)

STEP 9 — GRIPPER OPEN (RELEASE PART)

  Note: When reusing TON_GripDelay for Step 9, the timer from
        Step 5 has already elapsed and reset (step changed).
        In TIA Portal, IEC timers in function blocks (DBs) reset
        when the IN input goes FALSE, so this works correctly.

STEP 10 — Z-AXIS UP (CLEAR TRAY)

STEP 11 — X-AXIS RETRACT (HOME POSITION)

STEP 12 — REJECT PUSHER EXTEND (Reject parts only)

STEP 13 — REJECT PUSHER RETRACT

STEP 14 — UPDATE COUNTERS

  Note: In TIA Portal, use ADD instruction boxes:
  
  Increment Cycle Counter:
  [CMP==] → ADD (DB10.DBW6 + 1 → DB10.DBW6)

  Increment Good Parts Counter:
  [CMP==]  [MR_PartIsGood] → ADD (DB10.DBW2 + 1 → DB10.DBW2)

  Increment Reject Counter:
  [CMP==]  [MR_PartIsReject] → ADD (DB10.DBW4 + 1 → DB10.DBW4)

  Clear part flags:
  [CMP==] → (RESET MR_PartIsGood M1.1)
  [CMP==] → (RESET MR_PartIsReject M1.2)

  Advance immediately:
  [CMP==]  → MOVE [15 → DB10.DBW0]

STEP 15 — CYCLE END

---

### Network 6 — Solenoid Output Control

**Architecture:** Outputs are driven by step comparisons. Each solenoid output is TRUE when the step number is within the range of steps that require it. This separates action definition (Network 5) from output wiring (Network 6) — a professional practice.

xamples:

Grip Close:
CurrentStep >= 5 AND CurrentStep <= 8

Z Down:
Step 4 OR Step 8

X Extend:
Step 7 to 10

```
NETWORK 6A: SOL_Z_DOWN

NETWORK 6B: SOL_Z_UP

NETWORK 6C: SOL_GRIP_CLOSE

NETWORK 6D: SOL_GRIP_OPEN

NETWORK 6E: SOL_X_EXTEND

NETWORK 6F: SOL_X_RETRACT

NETWORK 6G: SOL_REJECT_EXTEND

  Reject pusher extends only in Step 12 (and stays until Step 13 dwell ends).

 ---

### Network 7 — Step Advance Flag (for Timeout Reset)

```
NETWORK 7: STEP ADVANCE DETECTION

  Detect when the step number changes (rising edge of any MOVE completing).
  Used to reset the step timeout timer.

  Store previous step to detect change:
  Use a comparison: if current step ≠ previous step → pulse MR_StepAdvance

  Implementation: Use a MOVE to copy CurrentStep to DB10.DBW20
  (PreviousStep) at end of each scan.

 IF CurrentStep != PreviousStep
→ MR_StepAdvance = TRUE

Then:
MOVE CurrentStep → PreviousStep

  Note: This produces a one-scan pulse (MR_StepAdvance = TRUE for exactly
        one scan) whenever the step changes. Used to reset TON_StepTimeout.


---

### Network 8 — Indicator Lamps and Buzzer
Run Lamp → MR_CycleActive
Stop Lamp → NOT MR_CycleActive
Alarm → Flash on Fault
Beep → End of cycleNETWORK 8A: RUN LAMP

NETWORK 8B: STOP LAMP

NETWORK 8C: FAULT LAMP (FLASHING)

NETWORK 8D: AUTO LAMP

NETWORK 8E: CYCLE COMPLETE BEEP

---

## 6. I/O Mapping Table

| Terminal | Field Device | Note |
|---|---|---|
| I0.0 | E-Stop (NC) | Safety mushroom on panel |
| I0.1 | Stop button (NC) | Clean stop |
| I0.2 | Start button (NO) | |
| I0.3 | Fault Reset (NO) | |
| I0.4 | Auto/Manual switch | Key switch |
| I0.5 | Part present sensor | Inductive, M18, 10-30VDC PNP |
| I0.6 | Part type sensor | Inductive (metal = ON) |
| I0.7 | X-home reed switch | Magnetic reed, M8 |
| I1.0 | X-extended reed switch | Magnetic reed, M8 |
| I1.1 | Z-up reed switch | |
| I1.2 | Z-down reed switch | |
| I1.3 | Gripper open reed switch | Parallel jaw gripper |
| I1.4 | Gripper closed reed switch | |
| I1.5 | Reject pusher home | |
| I1.6 | Reject pusher extended | |
| I1.7 | Tray full sensor | Inductive, top of tray |
| Q0.0 | SOL_X_Extend | Festo MSSD-C or equivalent |
| Q0.1 | SOL_X_Retract | 5/2 bistable solenoid |
| Q0.2 | SOL_Z_Down | |
| Q0.3 | SOL_Z_Up | |
| Q0.4 | SOL_Grip_Close | |
| Q0.5 | SOL_Grip_Open | |
| Q0.6 | SOL_Reject_Extend | Single-acting, spring return |

---

## 7. HMI Tags

| HMI Tag | PLC Tag | Type | Screen |
|---|---|---|---|
| `HMI_CurrentStep` | `StepDB.CurrentStep` | Int | Process overview |
| `HMI_GoodParts` | `StepDB.GoodPartsCount` | Int | Production stats |
| `HMI_RejectCount` | `StepDB.RejectCount` | Int | Production stats |
| `HMI_CycleCount` | `StepDB.CycleCount` | Int | Production stats |
| `HMI_FaultStep` | `StepDB.FaultStep` | Int | Diagnostics |
| `HMI_CycleActive` | `MR_CycleActive` | Bool | Overview |
| `HMI_FaultActive` | `MR_FaultActive` | Bool | Alarms |
| `HMI_FaultTimeout` | `MR_FaultTimeout` | Bool | Alarms |
| `HMI_FaultTrayFull` | `MR_FaultTrayFull` | Bool | Alarms |
| `HMI_HomePosition` | `MR_HomePosition` | Bool | Status |
| `HMI_X_Pos` | (Derived from SEN_X_Home/Extended) | Bool | Cylinder status |
| `HMI_Z_Pos` | (Derived from SEN_Z_Up/Down) | Bool | Cylinder status |
| `HMI_Btn_Start` | `MX_HMI_Start` | Bool (Write) | Control |
| `HMI_Btn_Stop` | `MX_HMI_Stop` | Bool (Write) | Control |
| `HMI_Btn_Reset` | `MX_HMI_Reset` | Bool (Write) | Alarms |
| `HMI_Btn_ResetCounters` | `MX_HMI_ResetCnt` | Bool (Write) | Maintenance |

---

## 8. Alarms

| # | Tag | Message | Priority | Action |
|---|---|---|---|---|
| A001 | `MR_FaultTimeout` | STEP TIMEOUT — Cylinder stuck or sensor failed. Step: {FaultStep} | Critical | Check cylinder + sensor, reset |
| A002 | `MR_FaultTrayFull` | GOOD PARTS TRAY FULL — Remove parts and reset | High | Empty tray, reset |
| A003 | `PB_EStop` | EMERGENCY STOP ACTIVE | Critical | Clear E-Stop |
| A004 | `SEN_TrayFull` | Tray full — production paused | Medium | Info |
| A005 | `MR_CycleStopReq` | Stop requested — completing current cycle | Info | — |

---

## 9. Test Scenarios

### Test 1 — Full Good Part Cycle
1. Auto mode ON, all axes confirmed home
2. Press Start → `MR_CycleActive` = TRUE, Step → 1
3. Force `SEN_PartPresent` = TRUE, force `SEN_PartType` = TRUE (good part)
4. Watch step counter advance: 1→2→3→4→5→6→7→8→9→10→11→12 (skip to 14)→15→1
5. ✅ Expected: `StepDB.GoodPartsCount` increments, `StepDB.CycleCount` increments

### Test 2 — Reject Part Cycle
1. Same as Test 1 but force `SEN_PartType` = FALSE (non-metallic)
2. ✅ Expected: `MR_PartIsReject` = TRUE, Step 12 activates reject pusher, Steps 12→13→14→15
3. `StepDB.RejectCount` increments

### Test 3 — Step Timeout Fault
1. Cycle running, Z-Down step active (Step 4)
2. Do NOT assert `SEN_Z_Down`
3. Wait 8 seconds
4. ✅ Expected: `MR_FaultTimeout` latches, `StepDB.FaultStep` = 4, cycle stops
5. Fix sensor, press Reset ✅

### Test 4 — Tray Full
1. Auto mode, good part approaching
2. Force `SEN_TrayFull` = TRUE
3. ✅ Expected: Fault latches at Step 3, cycle pauses. Reject parts bypass this fault.
4. Force `SEN_TrayFull` = FALSE, press Reset ✅

### Test 5 — E-Stop Mid-Cycle
1. Cycle running, e.g. at Step 7 (X-extending)
2. Press E-Stop
3. ✅ Expected: All solenoid outputs immediately de-energize
4. On release + Reset: Step counter must be manually set to 0, all axes homed manually first
5. Note this in the operator procedure

---

## 10. Safety Notes and Limitations

- **Cylinder position on E-Stop:** When E-Stop cuts all solenoid outputs, double-acting cylinders remain in their CURRENT position (5/2 bistable valves). For safety, consider 5/3 center-exhaust valves which retract all cylinders on power loss.
- **Gripper on E-Stop:** With bistable valve, gripper stays CLOSED on E-Stop, which keeps the part held. This is usually the correct behavior (prevents part from falling). Document this explicitly.
- **Step counter on restart:** After E-Stop or fault, the step counter must be VERIFIED before restarting. The Home check (Network 4A) enforces this — the system cannot restart unless all axes are confirmed home.
- **Compressed air:** No air pressure detection is implemented here. Add a pressure switch input (I2.0) and check it in the Master Enable rung for a production system.
- **Gripper confirm:** If `SEN_Grip_Closed` does NOT fire after gripper close command, the part was not gripped. The timeout will catch this. For production, add a specific "no-grip" fault before Step 6.

---

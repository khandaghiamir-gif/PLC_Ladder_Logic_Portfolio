# GitHub Portfolio Guide — PLC Projects
---

## 📁 Recommended Repository Structure

```
YourName-PLC-Portfolio/
│
├── README.md                          ← Master portfolio index (done)
│
├── Project_01_Conveyor/
│   ├── README.md                      ← Full documentation (done)
│   ├── plc.xml                        ← Open PLC Editor File
│   ├── beremiz.xml                    ← Open PLC Editor File
│   └── Project_01_Conveyor.pdf        ← Ladder Schematic File
│
├── Project_02_Tank_Level/                                             ← Same structure
├── Project_03_Auto_Door/                                              ← Same structure
├── Project_04_Motor_Control/                                          ← Same structure
└── Project_05_Pump_Station_with_PID_Pressure_Control_and_VFD/         ← Same structure
```

---

## 🛠️ How to Open This Project in OpenPLC Editor / Beremiz

1. Download or clone this repository.
2. Open **OpenPLC Editor**.
3. Go to **File → Open**.
4. Select the project folder.
5. Open the file:

   ```text
   beremiz.xml

And add this Siemens conversion section after it:

```md
---

## 🔄 How to Convert This OpenPLC Project to Siemens TIA Portal

This project was created in **OpenPLC Editor / Beremiz**, not directly in Siemens TIA Portal.  
To convert it to Siemens, the logic must be recreated in TIA Portal using the same tag names and control sequence.

### 1. Create a New Siemens Project

1. Open **TIA Portal**.
2. Create a new project.
3. Add the target PLC, for example:

   ```text
   Siemens S7-1200 CPU 1214C DC/DC/DC
4. Change address:
    
OpenPLC      Siemens
%IX0.0   →   %I0.0
%IX0.1   →   %I0.1
%QX0.0   →   %Q0.0
%QX0.1   →   %Q0.1
%IW0     →   %IW64
%IW1     →   %IW66
%IW2     →   %IW68
%QW0     →   %QW64

OpenPLC Tag:   PB_EStop
OpenPLC Addr:  %IX0.0

Siemens Tag:   PB_EStop
Siemens Addr:  %I0.0
Type:          Bool


## ✏️ How to Write a Good Project README on GitHub

Each project README should have these sections (already done in these files):

1. **Badge line** — difficulty, PLC type, software version
2. **System description** — what it does in plain English
3. **I/O table** — formatted markdown table (already done)
4. **Ladder logic** — text-form pseudo-code for each network
5. **Test scenarios** — shows you understand verification
6. **Safety notes** — shows professional awareness
7. **Simulation instructions** — shows you can work without real hardware

---

## 🎨 How to Draw Diagrams for Free

### draw.io (diagrams.net) — Recommended
- Free, browser-based
- Has PLC ladder symbols library
- Export as PNG for GitHub
- Use for: P&IDs, wiring diagrams, state machines, timing diagrams

### Lucidchart (free tier)
- Good for flowcharts and state diagrams

### Excel / LibreOffice Calc
- Use for timing diagrams (rows = time, columns = outputs)
- Fill cells with color to show ON/OFF states

---

## 🧪 How to Simulate Without Hardware

### Method 1: S7-PLCSIM (Free with TIA Portal)
1. In TIA Portal → Download to device → Select "PLCSIM"
2. Open PLCSIM window
3. PLC starts in STOP → Put to RUN
4. Use Watch Tables to force inputs and observe outputs

### Method 2: Factory I/O (30-day free trial)
- Website: factoryio.com
- Download and open a scene (conveyor, tank, etc.)
- Connect driver: Drivers → Siemens → S7-PLCSIM
- Map your I/O addresses to the scene sensors and actuators
- Best scenes for these projects:
  - Project 01: "Sorting by Height" or "Roll Conveyor"
  - Project 02: "Filling Station"
  - Project 03: (create custom or use "Assembling" scene)
  - Project 04: "From Uni to Factory" motor scene
  - Project 05: (custom scene or demo mode)

### Method 3: PLCSIM Advanced (for HMI)
- Required if you want to connect KTP700 HMI simulation to PLCSIM
- Set up OPC-UA connection between TIA Portal HMI runtime and PLCSIM Advanced

---

---

## 📚 Recommended Additions After These 5 Projects

| Project | Skills Added |
|---------|-------------|
| PID Temperature Control | Analog I/O, PID block, DB structures |
| Pick and Place with SCL | Structured Control Language, motion sequences |
| Bottle Filling with Counting | CTU/CTD counters, recipe management |
| Alarm Management System | S7-1200 alarm DB, HMI alarm server |
| PROFINET I/O Expansion | Distributed I/O, ET 200SP modules |

---

*This guide is part of the Siemens S7-1200 PLC Portfolio by Amir Khandaghi*

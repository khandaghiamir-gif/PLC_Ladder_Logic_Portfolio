[README.md](https://github.com/user-attachments/files/27322958/README.md)
# 🏭 PLC Ladder Logic Portfolio — Siemens S7-1200

**Platform:** Siemens S7-1200 CPU 1214C DC/DC/DC  
**Software:** TIA Portal V17/V18 , Open PLC Editor  
**Language:** Ladder Logic (LAD)  
**Author:** Amir Khandaghi 

---

## 📁 Project Index

| # | Project | Description | Difficulty |
|---|---------|-------------|------------|
| 01 | [Conveyor Start/Stop with Sensors](./Project_01_Conveyor/README.md) | Belt conveyor with jam detection, E-stop, and Auto/Manual mode | ⭐⭐ |
| 02 | [Tank Level Control](./Project_02_Tank_Level/README.md) | Pump and valve control with level sensors and overflow protection | ⭐⭐⭐ |
| 03 | [Motor Control with Fault & HMI](./Project_04_Motor_Control/README.md) | Three-phase motor DOL starter with overload, fault reset, and HMI | ⭐⭐⭐
| 04 | [Pneumatic Pick](./Project_04_Pneumatic_Pick_and_Place/README.md) | Pneumatic Pick and Place Station with Step Sequencer | ⭐⭐⭐⭐⭐ 
| 05 | [Pump Station with PID Pressure Control and VFD](./Project_05_Pump_Station_with_PID_Pressure_Control_and_VFD/README.md) | Pump Station with PID Pressure Control and VFD | ⭐⭐⭐⭐⭐ |

---

## 🔧 Hardware Reference (All Projects)

- **PLC:** Open PLC Editor, Siemens S7-1200 CPU 1214C DC/DC/DC  
- **Power Supply:** SITOP PSU100S 24VDC  
- **I/O Voltage:** 24VDC (source type inputs)  
- **Output Type:** Transistor (DC), relay module used for contactor switching  
- **HMI:** Siemens KTP700 Basic (optional, simulated in all projects)

---

## 🛡️ Common Safety Standards Applied

- Emergency Stop per **IEC 60204-1**
- Master Control Relay (MCR) concept in all projects
- Fault latch with manual reset
- Auto/Manual mode separation
- Output de-energize on E-Stop

---

## 💻 Simulation Without Hardware

All projects can be simulated using:
- **S7-PLCSIM** (included in TIA Portal) — full logic simulation
- **Factory I/O** (free trial) — 3D visualization of conveyor, tanks, doors, motors
- **PLCSIM Advanced** — for HMI connection via OPC-UA

---

## 📚 How to Use These Projects

1. Open TIA Portal → Create new project → Select CPU 1214C DC/DC/DC (6ES7 214-1AG40-0XB0)
2. Set IP address to `192.168.0.1` (default for all projects)
3. Create a new PLC program block (OB1 — Main)
4. Add tags from the tag list in each project's README
5. Implement networks as documented, network by network with the help of the pdf and Open PLC editor file
6. Download to PLCSIM for simulation
7. Connect HMI tags as listed

---

## 📂 Repository Structure

```
## Repository Structure

PLC_Portfolio/

|-- README.md
|   # Main portfolio documentation #
|
|-- Project_01_Conveyor/
|   |-- README.md
|   |   # Project documentation #
|   |
|   |
|   |-- Project_01_Conveyor.pdf
|   |  # Project documentation export #
|   |
|   |-- plc.xml
|   |  # OpenPLC project core file #
|   |
|   |-- beremiz.xml
|       # OpenPLC / Beremiz configuration #
|
|-- Project_02_Tank_Level/
|   |-- README.md
|   |-- Project_02_Tank_Level.pdf
|   |-- plc.xml
|   |-- beremiz.xml
|
|-- Project_03_Motor_Control/
|   |-- README.md
|   |-- Project_03_Motor_Control.pdf
|   |-- plc.xml
|   |-- beremiz.xml
|
|-- Project_04_Pneumatic_Pick_and_Place/
|   |-- README.md
|   |-- Project_04_Pneumatic_Pick_and_Place.pdf
|   |-- plc.xml
|   |-- beremiz.xml
|
|
|-- Project_06_Pneumatic_Pick_and_Place/
    |-- README.md
    |-- Project_06_Pneumatic_Pick_and_Place.pdf
    |-- plc.xml
    |-- beremiz.xml


Note:
Each project folder contains:
- Project configuration files (plc.xml, beremiz.xml)
- PDF documentation
- README explanation file
```

---

## 🤝 Contributing

Feel free to fork, improve, or adapt these projects. If you spot errors in the logic, please open an issue.

---

*These projects are designed for educational and portfolio purposes. Always follow local electrical safety codes and machine safety standards before deploying PLC programs in real industrial environments.*

# Software Requirements Specification (SRS) - OpenRocket (Ada Implementation)

## 1. Introduction
### 1.1 Purpose
This document specifies the software requirements for the Ada implementation of OpenRocket, a model rocket simulator. The purpose of this project is to reimplement the core functionalities of the original Java-based OpenRocket in the Ada programming language, ensuring high reliability, safety, and performance.

### 1.2 Scope
The software will provide capabilities to design model rockets using standard components, calculate physical and aerodynamic properties (such as Center of Gravity and Center of Pressure), and simulate flight trajectories using a 6-degree-of-freedom (6-DOF) physics engine.

## 2. Overall Description
### 2.1 Product Perspective
This system is a standalone application. The initial focus of the Ada implementation will be on the simulation and calculation engine, followed by a command-line interface (CLI).

### 2.2 User Characteristics
The intended users are hobbyist rocketeers, students, and engineers who need to design model rockets and simulate their flights to predict altitude, velocity, and stability.

## 3. Specific Requirements
### 3.1 Functional Requirements
- **FR1 (Component Design):** The system shall allow users to define a rocket as a tree of components (Nose Cone, Body Tube, Fins, Engine Block, Mass Object, Parachute).
- **FR2 (Physical Calculations):** The system shall calculate the mass and Center of Gravity (CG) of the assembled rocket.
- **FR3 (Aerodynamic Calculations):** The system shall calculate the aerodynamic properties, specifically the Center of Pressure (CP) using the Barrowman equations.
- **FR4 (Stability Metric):** The system shall calculate and display the stability margin in calibers (distance between CG and CP divided by maximum body diameter).
- **FR5 (Motor Configuration):** The system shall allow users to load motor thrust curves and assign them to engine mounts.
- **FR6 (Flight Simulation):** The system shall perform a 6-DOF numerical simulation of the rocket flight given environmental conditions.
- **FR7 (Event Triggers):** The system shall support recovery system deployment triggers.
- **FR8 (Data Output):** The system shall output simulation results in a structured format (e.g., CSV).

### 3.2 Non-Functional Requirements
- **NFR1 (Reliability):** The use of Ada shall eliminate common memory safety and concurrency bugs.
- **NFR2 (Performance):** Flight simulations should compute faster than real-time.
- **NFR3 (Portability):** The software shall compile using the GNAT Ada compiler and be manageable via the Alire package manager.
- **NFR4 (Testability):** The architecture must support Test-Driven Development (TDD).

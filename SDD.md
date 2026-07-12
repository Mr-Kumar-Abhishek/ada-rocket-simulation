# Software Design Document (SDD) - OpenRocket (Ada Implementation)

## 1. Introduction
This document describes the architecture and system design for the Ada implementation of OpenRocket. The software is organized into modules to ensure separation of concerns, maintainability, and testability.

## 2. System Architecture
The application follows a layered architecture:
1. **Core Domain (Rocket Components):** Defines the hierarchical structure of a rocket.
2. **Physics & Math Engine:** Handles linear algebra, numerical integration, and aerodynamic formulas.
3. **Simulation Engine:** Orchestrates a flight simulation over time using the physics engine.
4. **Data Management:** Handles loading and saving of rocket designs (`.ork` XML format equivalents) and motor files (`.eng`, `.rse`).
5. **Interface Layer:** CLI or GUI for user interaction.

## 3. High-Level Components

### 3.1 Rocket Component Hierarchy
The rocket design is based on a Composite pattern. 
- `Component` (Abstract Base Class/Tagged Type)
  - `Nose_Cone`
  - `Body_Tube`
  - `Fin_Set`
  - `Mass_Object`
  - `Engine_Mount`

Each component can calculate its own mass, CG, and aerodynamic coefficients, which are aggregated by the parent components.

### 3.2 Aerodynamic Calculator (Barrowman)
The `Aerodynamics` module provides functions to calculate the Normal Force Coefficient (C_N) and Center of Pressure (CP) for various components based on Barrowman's equations.

### 3.3 Physics Engine (6-DOF)
The `Simulation` module uses a Simple Euler numerical integrator to step through time.
- State vector includes: Position (3D), Velocity (3D), Orientation (Quaternion), Angular Velocity (3D).
- Forces considered: Thrust, Gravity, Aerodynamic Drag, Aerodynamic Lift/Normal Force.
- Moments considered: Weathercocking Restoring Moment, Aerodynamic Damping.

### 3.4 Motor Subsystem
The `Motors` module parses `.eng` RASP motor data files and provides thrust vs. time interpolation and mass tracking.

### 3.5 Parsers & Interface
The `Parser` module loads XML configuration files directly into the in-memory Component tree. The main executable acts as a robust CLI, allowing users to parse, load, and dynamically simulate any configuration.

## 4. Ada-Specific Design Considerations
- **Strong Typing:** Use distinct types for physical units to prevent unit mismatch errors.
- **Tagged Types & Polymorphism:** Used for the component tree to allow dynamic dispatching of `Get_Mass` and `Get_CP` functions.
- **Package Hierarchy:**
  - `Components`
  - `Math`
  - `Aerodynamics`
  - `Simulation`
  - `Parser`
  - `Motors`
  - `Data_Logger`

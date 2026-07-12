# Ada Rocket Simulations

This project is an Ada port of the core physics and component hierarchies of OpenRocket, an open-source model rocket simulation software. It provides a highly reliable, strongly typed 6-DOF simulation engine driven by the Ada programming language.

## Project Structure

The codebase is built using **Test-Driven Development (TDD)** and is structured iteratively into sprints:
- **Core Math**: 3D Vectors, Operations, Cross Products, and Scalar Multiplication.
- **Components**: Composite tree hierarchy of rocket components with recursive Mass and CG accumulation.
- **Aerodynamics**: Barrowman Equations implementation for calculating Normal Force Coefficient (CN) and Center of Pressure (CP), plus Stability Margin.
- **Motors**: Motor subsystem with thrust curves and dynamic mass reduction.
- **Simulation**: Full flight loop using Euler numerical integration for time, velocity, and position given thrust, drag, and gravity, with CSV data output.

## Prerequisites

To compile and run this project, you need the Alire package manager.

1. Install [Alire](https://alire.ada.dev/).
2. A compatible GNAT native compiler (Alire will download this automatically upon the first build).

## How to Run

1. Clone the repository and navigate into the root directory:
   ```bash
   cd ada-rocket-simulations
   ```

2. Run the executable. It supports three modes:

   - **TDD Test Runner** (default):
     ```bash
     alr run -- --test
     ```
   
   - **Load Rocket & Simulate** (from XML):
     ```bash
     alr run -- --rocket test_rocket.xml
     ```

   - **Load Rocket & Output Custom CSV**:
     ```bash
     alr run -- --rocket test_rocket.xml --output flight_data.csv
     ```
   
   *Note: On the very first run, Alire will fetch and set up the GNAT toolchain, which may take some time depending on your connection.*

## Documentation

- [Software Requirements Specification (SRS)](SRS.md)
- [Software Design Document (SDD)](SDD.md)
- [Project Cost Estimation (COCOMO)](COCOMO_Estimation.md)

# COCOMO Cost Estimation

This document provides a cost and schedule estimation for developing the full Ada-based OpenRocket simulator, calculated using the Constructive Cost Model (COCOMO) for software development.

## 1. Project Sizing Estimates

Based on the scope defined in the Software Requirements Specification (SRS), translating the core functionalities of OpenRocket (6-DOF engine, UI wrapper, component parsing, aerodynamics engine) into Ada will result in an estimated **15,000 Lines of Code (15 KLOC)**. 

Because the project relies on well-understood physics equations and relatively standard GUI concepts, we classify the project mode as **Organic** (small team, familiar environment, standard requirements).

## 2. COCOMO Formulas (Organic Mode)

The basic COCOMO formulas for the Organic mode are:
- **Effort (E):** `E = 2.4 * (KLOC)^1.05` [Person-Months]
- **Time/Duration (Tdev):** `Tdev = 2.5 * (E)^0.38` [Months]
- **Staffing (P):** `P = E / Tdev` [Persons]

## 3. Calculation

Plugging in our estimated `KLOC = 15`:

1. **Effort (E)**:
   `E = 2.4 * (15)^1.05`
   `E ≈ 2.4 * 16.96`
   **E ≈ 40.7 Person-Months**

2. **Time (Tdev)**:
   `Tdev = 2.5 * (40.7)^0.38`
   `Tdev ≈ 2.5 * 4.09`
   **Tdev ≈ 10.2 Months**

3. **Average Staffing (P)**:
   `P = 40.7 / 10.2`
   **P ≈ 4 Full-Time Developers**

## 4. Cost Estimation

Assuming an average loaded salary for an Ada Software Engineer of **$10,000 USD** per month (including benefits and overhead):

- **Total Development Cost**: `40.7 Person-Months * $10,000 USD/Month`
- **Total Estimated Cost**: **$407,000 USD**

## Summary Table

| Metric | Value |
|--------|-------|
| Mode | Organic |
| Estimated Size | 15 KLOC |
| Effort | 40.7 Person-Months |
| Schedule (Duration) | 10.2 Months |
| Team Size | 4 Developers |
| **Total Cost** | **$407,000 USD** |

*Note: These estimates cover the development phase up to initial delivery and do not account for long-term maintenance or post-release expansions.*

## 5. Current Phase Actuals (Sprints 1 to 4)

As of the current sprints (covering Core Math, Components, Aerodynamics including Barrowman Fin logic, Motor Subsystem, Flight Loop, Recovery Systems, and XML Parser), the codebase size is roughly **1.01 KLOC** (1008 lines). Applying the COCOMO formula retrospectively:

1. **Effort (E)**:
   `E = 2.4 * (1.01)^1.05`
   `E ≈ 2.4 * 1.010`
   **E ≈ 2.42 Person-Months**

2. **Time (Tdev)**:
   `Tdev = 2.5 * (2.42)^0.38`
   `Tdev ≈ 2.5 * 1.397`
   **Tdev ≈ 3.49 Months**

3. **Cost Estimation**:
   - `2.42 Person-Months * $10,000 USD/Month`
   - **Cost for current codebase**: **$24,200 USD**

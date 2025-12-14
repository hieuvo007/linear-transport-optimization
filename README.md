# Linear Transport Optimization: Numerical Solver Portfolio
[![MATLAB](https://img.shields.io/badge/Language-MATLAB-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Completed-success.svg)]()

> **A comprehensive MATLAB implementation of fundamental and advanced Linear Programming algorithms for the Transportation Problem. This collection covers Initial Basic Feasible Solutions (IBFS) and Iterative Optimization, developed for the "Linear Algebra" course at HCMUT.**

---

## Table of Contents
- [Project Overview](#-project-overview)
- [Repository Structure](#-repository-structure)
- [Module 1: Initialization Strategy](#-module-1-initialization-strategy)
- [Module 2: Optimization Algorithms](#-module-2-optimization-algorithms)
- [Module 3: Technical Implementation Details](#-module-3-technical-implementation-details)
- [Authors & Acknowledgments](#-authors--acknowledgments)

---

## Project Overview


This repository serves as a practical implementation guide for solving the **Transportation Problem**, a classic Operations Research challenge. The project utilizes **MATLAB** to model Supply (Sources) and Demand (Destinations) networks to minimize total shipping costs.

**Key Domains Covered:**
* **Initialization:** North-West Corner Method (NWCM).
* **Optimization:** Modified Distribution Method (MODI).
* **Constraint Handling:** Unbalanced Supply/Demand, Degeneracy Resolution.
* **Data Analysis:** Cost matrix evaluation and iterative improvement tracking.

---

## Repository Structure

| Phase | Algorithm | Type | Language | Key Feature |
| :--- | :--- | :--- | :--- | :--- |
| **01** | **NWCM** | Initialization | MATLAB | Allocates based on position (Top-Left) logic. |
| **02** | **MODI** | Optimization | MATLAB | Dual variable ($u_i, v_j$) calculation. |
| **03** | **Stepping Stone** | Adjustment | MATLAB | Loop detection for reallocation. |
| **04** | **Balancing** | Pre-processing | MATLAB | Dummy Row/Column insertion for unbalance. |

---

## Module 1: Initialization Strategy

### Method: North-West Corner (NWCM)
Implementation of the geometric allocation strategy to find the Initial Basic Feasible Solution (IBFS).
* **Task:** Allocate resources starting from the top-left cell $(1,1)$ down to $(m,n)$ without considering costs.
* [cite_start]**Formula:** $x_{ij} = \min(a_i, b_j)$[cite: 482].
* [cite_start]**Initial Result:** The algorithm generated a baseline cost of **1015 units**[cite: 591, 1151].
* [cite_start]**Allocations:** 6 basic cells identified for a $3 \times 4$ matrix[cite: 595].

---

## Module 2: Optimization Algorithms

### Method: Modified Distribution (MODI)


Utilizing the UV-Method to test for optimality and iteratively reduce transportation costs.
* **Mechanism:** Calculates potentials $u_i$ and $v_j$ such that $c_{ij} = u_i + v_j$ for basic cells.
* **Improvement Process:**
    * [cite_start]**Iteration 1:** Identified Opportunity Cost $\Delta_{3,2} = -52$. Reallocated using a closed loop[cite: 608, 1153].
    * [cite_start]**Iteration 2:** Identified Opportunity Cost $\Delta_{1,4} = -32$. Reallocated resources[cite: 621, 1154].
* [cite_start]**Final Performance:** Achieved a global minimum cost of **743 units**[cite: 646, 1169].
* [cite_start]**Efficiency:** Reduced total cost by **272 units** (~26.8% improvement) compared to NWCM[cite: 648].

---

## Module 3: Technical Implementation Details

### Unbalanced Problem Handling
Robust logic to handle real-world scenarios where Total Supply $\neq$ Total Demand.
* [cite_start]**Supply > Demand:** Automatically adds a **Dummy Column** with cost 0[cite: 26].
* [cite_start]**Demand > Supply:** Automatically adds a **Dummy Row** with cost 0[cite: 26].

### Degeneracy Handling
A fail-safe mechanism for mathematical edge cases.
* **Condition:** Triggered when the number of basic cells $< m + n - 1$.
* [cite_start]**Solution:** Injects an artificial **Epsilon ($\epsilon$)** allocation to maintain the basis for the MODI algorithm to proceed[cite: 789].

---

## Authors & Acknowledgments

[cite_start]**Group 13 - Linear Algebra (L13)** [cite: 6, 26]
* [cite_start]**Instructor:** ThS. Nguyễn Xuân Mỹ [cite: 7]
* [cite_start]**Institution:** Ho Chi Minh City University of Technology (HCMUT) [cite: 1]

**Team Members:**

| No. | Full Name | Student ID | Responsibility |
| :---: | :--- | :---: | :--- |
| **1** | **Trương Quốc Học** | `2510606` | Introduction |
| **2** | **Trương Tuấn Khôi** | `2510708` | Theory (2.1) |
| **3** | **Võ Duy Vũ Hoàng** | `2510604` | Theory (2.1) |
| **4** | **Võ Thị Thảo** | `2413214` | Theory (2.2) |
| **5** | **Võ Thu Hằng** | `2510561` | Simplex (2.3-2.5) |
| **6** | **Võ Thừa Hiếu** | `2510587` | Transport Model (3.1, 3.4) |
| **7** | **Võ Trương Gia Huấn** | `2510608` | Theory & Synthesis |
| **8** | **Võ Việt Hoàng** | `2510605` | Conclusion (4.1) |
| **9** | **Võ Việt Khuê** | `2510710` | MATLAB Functions (3.5) |
| **10** | **Trương Thiện Hùng** | `2510615` | MODI Method (3.2.3) |
| **11** | **Vương Quốc Hùng** | `2510616` | References |

---
*Created December 2025*

# Tokenized Smart City Energy Management

A set of Clarity smart contracts for managing energy in a smart city context, with tokenized incentives for energy efficiency and grid participation.

## Overview

This project implements a comprehensive system for managing energy in a smart city using blockchain technology. The system consists of five main contracts:

1. **Building Verification Contract**: Validates urban structures and their energy profiles
2. **Energy Consumption Contract**: Tracks usage patterns for buildings
3. **Efficiency Optimization Contract**: Manages energy-saving measures and incentives
4. **Grid Integration Contract**: Coordinates with utility systems
5. **Performance Analytics Contract**: Monitors energy improvements and provides insights

## Contracts

### Building Verification Contract

This contract handles the registration and verification of buildings in the smart city:

- Register new buildings with energy class and size information
- Verify or reject buildings by authorized administrators
- Transfer building ownership
- Query building details

### Energy Consumption Contract

This contract tracks energy consumption for registered buildings:

- Record energy consumption data (kWh and peak load)
- Track total and average consumption per building
- Query historical consumption data

### Efficiency Optimization Contract

This contract manages energy efficiency measures and rewards:

- Add and manage efficiency measures (e.g., LED lighting, smart thermostats)
- Implement efficiency measures for buildings
- Verify implementations and reward tokens
- Query measure and implementation details

### Grid Integration Contract

This contract coordinates building participation in the energy grid:

- Update grid status (normal, peak demand, surplus, emergency)
- Register buildings for grid participation
- Create and manage grid events (demand response, feed-in requests)
- Respond to grid events and calculate compensation
- Query grid status and participation details

### Performance Analytics Contract

This contract monitors energy performance and provides analytics:

- Record building performance metrics
- Track city-wide aggregated metrics
- Set and monitor building performance goals
- Calculate reward eligibility
- Compare building performance to city averages

## Usage

### Prerequisites

- Clarity language support
- Stacks blockchain environment

### Testing

The project includes comprehensive tests for all contracts using Vitest. To run the tests:

\`\`\`bash
npm test
\`\`\`

## Contract Functions

### Building Verification Contract

```clarity
(define-public (register-building (building-id (string-utf8 36)) (energy-class (string-utf8 2)) (square-meters uint)))
(define-public (verify-building (building-id (string-utf8 36))))
(define-public (reject-building (building-id (string-utf8 36))))
(define-public (transfer-building (building-id (string-utf8 36)) (new-owner principal)))
(define-read-only (get-building-details (buildin
